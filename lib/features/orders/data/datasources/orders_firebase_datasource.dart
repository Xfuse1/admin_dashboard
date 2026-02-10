import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firebase/firebase_service.dart';
import '../../domain/entities/order_entities.dart';
import '../../domain/repositories/orders_repository.dart';
import '../models/order_model.dart';
import 'orders_datasource.dart';

/// Firebase implementation of OrdersDataSource.
///
/// Performance-optimized version:
/// - Batch order item fetching (1-2 queries instead of N)
/// - Batch store name resolving (1-2 queries instead of N)
/// - Product detail caching across requests
/// - Stats caching with 5-minute TTL
/// - Proper Firestore limit usage
class OrdersFirebaseDataSource implements OrdersDataSource {
  final FirebaseFirestore _firestore;

  OrdersFirebaseDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ─── Caches ───────────────────────────────────────────────
  final Map<String, String> _storeNameCache = {};
  final Map<String, Map<String, dynamic>> _productCache = {};
  OrderStats? _cachedStats;
  DateTime? _cachedStatsTime;
  static const _statsCacheDuration = Duration(minutes: 5);

  // ─── Collection refs ──────────────────────────────────────
  CollectionReference<Map<String, dynamic>> get _ordersCollection =>
      _firestore.collection(FirestoreCollections.orders);

  CollectionReference<Map<String, dynamic>> get _orderItemsCollection =>
      _firestore.collection(FirestoreCollections.orderItems);

  CollectionReference<Map<String, dynamic>> get _productsCollection =>
      _firestore.collection(FirestoreCollections.products);

  // ─── Store name helpers ───────────────────────────────────

  /// Resolves store name from users collection with caching.
  Future<String?> _getStoreName(String storeId) async {
    if (storeId.isEmpty) return null;
    if (_storeNameCache.containsKey(storeId)) {
      return _storeNameCache[storeId];
    }
    try {
      final doc = await _firestore
          .collection(FirestoreCollections.users)
          .doc(storeId)
          .get();
      if (doc.exists) {
        final storeData =
            (doc.data()?['store'] as Map<String, dynamic>?) ?? {};
        final name = storeData['name'] as String?;
        if (name != null && name.isNotEmpty) {
          _storeNameCache[storeId] = name;
          return name;
        }
      }
    } catch (_) {}
    return null;
  }

  /// Batch resolves store names for multiple store IDs.
  /// Uses whereIn (max 10 per query) to minimize reads.
  Future<void> _batchResolveStoreNames(List<String> storeIds) async {
    final uncached = storeIds
        .where((id) => id.isNotEmpty && !_storeNameCache.containsKey(id))
        .toSet()
        .toList();
    if (uncached.isEmpty) return;

    for (var i = 0; i < uncached.length; i += 10) {
      final chunk = uncached.sublist(i, min(i + 10, uncached.length));
      try {
        final snapshot = await _firestore
            .collection(FirestoreCollections.users)
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        for (final doc in snapshot.docs) {
          final storeData =
              (doc.data()['store'] as Map<String, dynamic>?) ?? {};
          final name = storeData['name'] as String?;
          if (name != null && name.isNotEmpty) {
            _storeNameCache[doc.id] = name;
          }
        }
      } catch (_) {}
    }
  }

  // ─── Item fetching helpers ────────────────────────────────

  /// Batch fetches items for multiple orders at once.
  /// Before: 20 individual queries (one per order).
  /// After: 2 queries (ceil(20/10)).
  Future<Map<String, List<OrderItemModel>>> _batchGetOrderItems(
      List<String> orderIds) async {
    if (orderIds.isEmpty) return {};

    final result = <String, List<OrderItemModel>>{};
    for (final id in orderIds) {
      result[id] = [];
    }

    for (var i = 0; i < orderIds.length; i += 10) {
      final chunk = orderIds.sublist(i, min(i + 10, orderIds.length));
      try {
        final snapshot = await _orderItemsCollection
            .where('order_id', whereIn: chunk)
            .get();

        for (final doc in snapshot.docs) {
          try {
            var data = doc.data();
            data['id'] = doc.id;
            final orderId = data['order_id'] as String?;
            if (orderId == null || !result.containsKey(orderId)) continue;

            final item = OrderItemModel.fromJson(data);
            final enriched = await _maybeEnrichItem(item, data);
            result[orderId]!.add(enriched);
          } catch (e) {
            final orderId = doc.data()['order_id'] as String?;
            if (orderId != null && result.containsKey(orderId)) {
              result[orderId]!.add(OrderItemModel(
                  id: doc.id,
                  name: 'Error loading item',
                  quantity: 1,
                  price: 0,
                  total: 0));
            }
          }
        }
      } catch (e) {
        print('Error batch fetching order items: $e');
      }
    }
    return result;
  }

  /// Enriches an item with product details if needed, using cache.
  Future<OrderItemModel> _maybeEnrichItem(
      OrderItemModel item, Map<String, dynamic> data) async {
    final productId = data['product_id'] as String?;
    final needsEnrichment =
        (item.name == 'Unknown Product' || item.name.isEmpty) &&
            (productId != null && productId.isNotEmpty);

    if (!needsEnrichment) return item;

    try {
      // Check product cache first
      var productData = _productCache[productId];
      if (productData == null) {
        final productDoc = await _productsCollection.doc(productId!).get();
        if (productDoc.exists) {
          productData = productDoc.data()!;
          _productCache[productId] = productData;
        }
      }

      if (productData != null) {
        final productPrice =
            (productData['price'] as num?)?.toDouble() ?? 0.0;
        final calculatedTotal =
            item.total > 0 ? item.total : productPrice * item.quantity;
        return OrderItemModel(
          id: item.id,
          name: productData['name'] as String? ??
              productData['title'] as String? ??
              item.name,
          imageUrl: productData['image'] as String? ??
              productData['imageUrl'] as String? ??
              item.imageUrl,
          quantity: item.quantity,
          price: productPrice > 0 ? productPrice : item.price,
          total: calculatedTotal,
          notes: item.notes,
          category: productData['category'] as String? ?? item.category,
          storeName: item.storeName,
        );
      }
    } catch (e) {
      print('Error enriching item with product: $e');
    }
    return item;
  }

  /// Fetches items for a single order (used by getOrderById).
  Future<List<OrderItemModel>> _getOrderItems(String orderId) async {
    try {
      final snapshot = await _orderItemsCollection
          .where('order_id', isEqualTo: orderId)
          .get();

      final items = await Future.wait(snapshot.docs.map((doc) async {
        try {
          var data = doc.data();
          data['id'] = doc.id;
          final item = OrderItemModel.fromJson(data);
          return await _maybeEnrichItem(item, data);
        } catch (e) {
          return OrderItemModel(
              id: doc.id,
              name: 'Error loading item',
              quantity: 1,
              price: 0,
              total: 0);
        }
      }));
      return items;
    } catch (e) {
      return [];
    }
  }

  /// Applies items and store names to a list of orders.
  List<OrderModel> _applyItemsAndStoreNames(
    List<OrderModel> orders,
    Map<String, List<OrderItemModel>> allItems,
  ) {
    return orders.map((order) {
      if (order.isMultiStore) return order;
      final items = allItems[order.id] ?? [];
      final storeName =
          order.storeId != null ? _storeNameCache[order.storeId!] : null;
      if (storeName != null) {
        final itemsWithStore =
            items.map((item) => item.withStoreName(storeName)).toList();
        return order.copyWith(items: itemsWithStore, storeName: storeName);
      }
      return order.copyWith(items: items);
    }).toList();
  }

  // ─── Main API ─────────────────────────────────────────────

  @override
  Future<List<OrderModel>> getOrders({
    OrderStatus? status,
    String? storeId,
    String? driverId,
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 20,
    String? lastOrderId,
  }) async {
    final needsClientFilter =
        status != null || storeId != null || driverId != null ||
        fromDate != null || toDate != null;
    final fetchLimit = needsClientFilter ? 100 : limit;

    Query<Map<String, dynamic>> query = _ordersCollection
        .orderBy(OrderFields.createdAt, descending: true)
        .limit(fetchLimit);

    if (lastOrderId != null) {
      final lastDoc = await _ordersCollection.doc(lastOrderId).get();
      if (lastDoc.exists) {
        query = query.startAfterDocument(lastDoc);
      }
    }

    final snapshot = await query.get();
    var orders = snapshot.docs.map((doc) {
      return OrderModel.fromDeliverzler(doc.data(), documentId: doc.id);
    }).toList();

    // Client-side filtering
    if (status != null) {
      orders = orders.where((o) => o.status == status).toList();
    }
    if (storeId != null) {
      orders = orders.where((o) => o.involvesStore(storeId)).toList();
    }
    if (driverId != null) {
      orders = orders.where((o) => o.driverId == driverId).toList();
    }
    if (fromDate != null) {
      orders = orders.where((o) => o.createdAt.isAfter(fromDate)).toList();
    }
    if (toDate != null) {
      final end = toDate
          .add(const Duration(days: 1))
          .subtract(const Duration(seconds: 1));
      orders = orders.where((o) => o.createdAt.isBefore(end)).toList();
    }

    final limitedOrders = orders.take(limit).toList();

    // Batch-fetch items and store names
    final singleStoreOrders =
        limitedOrders.where((o) => !o.isMultiStore).toList();
    if (singleStoreOrders.isEmpty) return limitedOrders;

    final orderIds = singleStoreOrders.map((o) => o.id).toList();
    final storeIds = singleStoreOrders
        .where((o) => o.storeId != null)
        .map((o) => o.storeId!)
        .toList();

    // Run batch fetches in parallel
    final results = await Future.wait([
      _batchGetOrderItems(orderIds),
      _batchResolveStoreNames(storeIds).then((_) => null),
    ]);

    final allItems = results[0] as Map<String, List<OrderItemModel>>;
    return _applyItemsAndStoreNames(limitedOrders, allItems);
  }

  @override
  Future<OrderModel> getOrderById(String orderId) async {
    final doc = await _ordersCollection.doc(orderId).get();
    if (!doc.exists) throw Exception('Order not found');

    final order = OrderModel.fromDeliverzler(doc.data()!, documentId: doc.id);
    if (order.isMultiStore) return order;

    final items = await _getOrderItems(order.id);
    String? storeName;
    if (order.storeId != null) {
      storeName = await _getStoreName(order.storeId!);
    }
    if (storeName != null) {
      final itemsWithStore =
          items.map((item) => item.withStoreName(storeName)).toList();
      return order.copyWith(items: itemsWithStore, storeName: storeName);
    }
    return order.copyWith(items: items);
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    await _ordersCollection.doc(orderId).update({
      OrderFields.deliveryStatus: newStatus.value,
    });
    // Invalidate stats cache
    _cachedStats = null;
    _cachedStatsTime = null;
  }

  @override
  Future<void> assignDriver(String orderId, String driverId) async {
    final driverDoc = await _firestore
        .collection(FirestoreCollections.users)
        .doc(driverId)
        .get();
    final driverName = driverDoc.data()?[UserFields.name] ?? 'Unknown Driver';

    await _ordersCollection.doc(orderId).update({
      OrderFields.deliveryId: driverId,
      OrderFields.deliveryName: driverName,
    });
  }

  @override
  Future<void> cancelOrder(String orderId, String reason) async {
    await _ordersCollection.doc(orderId).update({
      OrderFields.deliveryStatus: OrderStatus.cancelled.value,
      OrderFields.employeeCancelNote: reason,
    });
    _cachedStats = null;
    _cachedStatsTime = null;
  }

  @override
  Stream<List<OrderModel>> watchOrders({OrderStatus? status}) {
    Query<Map<String, dynamic>> query = _ordersCollection
        .orderBy(OrderFields.createdAt, descending: true)
        .limit(100);

    return query.snapshots().asyncMap((snapshot) async {
      var orders = snapshot.docs.map((doc) {
        return OrderModel.fromDeliverzler(doc.data(), documentId: doc.id);
      }).toList();

      if (status != null) {
        orders = orders.where((o) => o.status == status).toList();
      }

      final limitedOrders = orders.take(50).toList();
      final singleStoreOrders =
          limitedOrders.where((o) => !o.isMultiStore).toList();

      if (singleStoreOrders.isEmpty) return limitedOrders;

      final orderIds = singleStoreOrders.map((o) => o.id).toList();
      final storeIds = singleStoreOrders
          .where((o) => o.storeId != null)
          .map((o) => o.storeId!)
          .toList();

      final results = await Future.wait([
        _batchGetOrderItems(orderIds),
        _batchResolveStoreNames(storeIds).then((_) => null),
      ]);

      final allItems = results[0] as Map<String, List<OrderItemModel>>;
      return _applyItemsAndStoreNames(limitedOrders, allItems);
    });
  }

  @override
  Future<OrderStats> getOrderStats({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    // Return cached stats if available (no date filter)
    if (fromDate == null && toDate == null) {
      if (_cachedStats != null &&
          _cachedStatsTime != null &&
          DateTime.now().difference(_cachedStatsTime!) <
              _statsCacheDuration) {
        return _cachedStats!;
      }
    }

    Query<Map<String, dynamic>> query = _ordersCollection;

    if (fromDate != null) {
      query = query.where(OrderFields.createdAt,
          isGreaterThanOrEqualTo: fromDate.toIso8601String());
    }
    if (toDate != null) {
      query = query.where(OrderFields.createdAt,
          isLessThanOrEqualTo: toDate.toIso8601String());
    }

    // Limit to 500 instead of unbounded fetch
    query = query.limit(500);

    final snapshot = await query.get();
    final orders = snapshot.docs.map((doc) {
      return OrderModel.fromDeliverzler(doc.data(), documentId: doc.id);
    }).toList();

    final stats = OrderStats(
      totalOrders: orders.length,
      pendingOrders:
          orders.where((o) => o.status == OrderStatus.pending).length,
      activeOrders: orders.where((o) => o.status.isActive).length,
      completedOrders:
          orders.where((o) => o.status == OrderStatus.delivered).length,
      cancelledOrders:
          orders.where((o) => o.status == OrderStatus.cancelled).length,
      totalRevenue: orders
          .where((o) => o.status == OrderStatus.delivered)
          .fold(0.0, (total, o) => total + (o.total ?? 0.0)),
      averageOrderValue: orders
                  .where((o) => o.status == OrderStatus.delivered)
                  .isNotEmpty
          ? orders
                  .where((o) => o.status == OrderStatus.delivered)
                  .fold(0.0, (total, o) => total + (o.total ?? 0.0)) /
              orders
                  .where((o) => o.status == OrderStatus.delivered)
                  .length
          : 0,
    );

    // Cache unfiltered stats
    if (fromDate == null && toDate == null) {
      _cachedStats = stats;
      _cachedStatsTime = DateTime.now();
    }

    return stats;
  }
}
