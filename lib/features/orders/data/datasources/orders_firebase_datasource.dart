import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firebase/firebase_service.dart';
import '../../domain/entities/order_entities.dart';
import '../../domain/repositories/orders_repository.dart';
import '../models/order_model.dart';
import 'orders_datasource.dart';

/// Firebase implementation of OrdersDataSource.
///
/// Integrates with Deliverzler's Firestore structure:
/// - Collection: 'orders'
/// - Status field: 'deliveryStatus' (not 'status')
/// - Date field: 'date' as Unix timestamp (not 'createdAt' as ISO string)
/// - Customer: 'userId', 'userName', 'userImage'
/// - Driver: 'deliveryId', 'deliveryName'
class OrdersFirebaseDataSource implements OrdersDataSource {
  final FirebaseFirestore _firestore;

  OrdersFirebaseDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Cache for store names to avoid redundant Firestore calls.
  final Map<String, String> _storeNameCache = {};

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
        final storeData = (doc.data()?['store'] as Map<String, dynamic>?) ?? {};
        final name = storeData['name'] as String?;
        if (name != null && name.isNotEmpty) {
          _storeNameCache[storeId] = name;
          return name;
        }
      }
    } catch (_) {}
    return null;
  }

  CollectionReference<Map<String, dynamic>> get _ordersCollection =>
      _firestore.collection(FirestoreCollections.orders);

  CollectionReference<Map<String, dynamic>> get _orderItemsCollection =>
      _firestore.collection(FirestoreCollections.orderItems);

  CollectionReference<Map<String, dynamic>> get _productsCollection =>
      _firestore.collection(FirestoreCollections.products);

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
    // 1. Fetch orders ordered by date
    Query<Map<String, dynamic>> query = _ordersCollection
        .orderBy(OrderFields.createdAt, descending: true)
        .limit(100);

    if (lastOrderId != null) {
      final lastDoc = await _ordersCollection.doc(lastOrderId).get();
      if (lastDoc.exists) {
        query = query.startAfterDocument(lastDoc);
      }
    }

    final snapshot = await query.get();

    // 2. Map Key-Value to OrderModel
    var orders = snapshot.docs.map((doc) {
      return OrderModel.fromDeliverzler(doc.data(), documentId: doc.id);
    }).toList();

    // 3. Apply filters in Memory (Client-side filtering)
    // This avoids needing complex composite indexes for every combination
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
      // Add one day to include the end date fully
      final end = toDate
          .add(const Duration(days: 1))
          .subtract(const Duration(seconds: 1));
      orders = orders.where((o) => o.createdAt.isBefore(end)).toList();
    }

    // 4. Return limited results
    final limitedOrders = orders.take(limit).toList();

    // 5. Fetch items for each order and resolve store names
    final ordersWithItems = await Future.wait(
      limitedOrders.map((order) async {
        if (order.isMultiStore) return order;
        final items = await _getOrderItems(order.id);
        // Resolve store name and apply to items
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
      }),
    );

    return ordersWithItems;
  }

  @override
  Future<OrderModel> getOrderById(String orderId) async {
    final doc = await _ordersCollection.doc(orderId).get();

    if (!doc.exists) {
      throw Exception('Order not found');
    }

    final order = OrderModel.fromDeliverzler(doc.data()!, documentId: doc.id);

    // Skip item fetch for multi_store orders (items are embedded in pickup_stops)
    if (order.isMultiStore) return order;

    final items = await _getOrderItems(order.id);

    // Resolve store name and apply to items
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
    final orderRef = _ordersCollection.doc(orderId);

    // Deliverzler uses 'deliveryStatus' field and doesn't have timeline
    // Just update the status directly
    await orderRef.update({
      OrderFields.deliveryStatus: newStatus.value,
    });
  }

  @override
  Future<void> assignDriver(String orderId, String driverId) async {
    // Get driver name from 'users' collection (Deliverzler structure)
    final driverDoc = await _firestore
        .collection(FirestoreCollections.users)
        .doc(driverId)
        .get();
    final driverName = driverDoc.data()?[UserFields.name] ?? 'Unknown Driver';

    // Deliverzler uses 'deliveryId' and 'deliveryName'
    await _ordersCollection.doc(orderId).update({
      OrderFields.deliveryId: driverId,
      OrderFields.deliveryName: driverName,
    });
  }

  @override
  Future<void> cancelOrder(String orderId, String reason) async {
    // Deliverzler uses 'deliveryStatus' and 'employeeCancelNote'
    await _ordersCollection.doc(orderId).update({
      OrderFields.deliveryStatus: OrderStatus.cancelled.value,
      OrderFields.employeeCancelNote: reason,
    });
  }

  @override
  Stream<List<OrderModel>> watchOrders({OrderStatus? status}) {
    // Query without where clause to avoid index requirement
    Query<Map<String, dynamic>> query = _ordersCollection
        .orderBy(OrderFields.createdAt, descending: true)
        .limit(100);

    return query.snapshots().asyncMap((snapshot) async {
      var orders = snapshot.docs.map((doc) {
        return OrderModel.fromDeliverzler(doc.data(), documentId: doc.id);
      }).toList();

      // Client-side filtering by status to avoid composite index
      if (status != null) {
        orders = orders.where((o) => o.status == status).toList();
      }

      // Return first 50 after filtering
      final limitedOrders = orders.take(50).toList();

      // Fetch items for each order and resolve store names
      final ordersWithItems = await Future.wait(
        limitedOrders.map((order) async {
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
        }),
      );

      return ordersWithItems;
    });
  }

  /// Fetches items for a specific order from 'order_items' collection.
  Future<List<OrderItemModel>> _getOrderItems(String orderId) async {
    try {
      final snapshot = await _orderItemsCollection
          .where('order_id', isEqualTo: orderId)
          .get();

      final items = await Future.wait(snapshot.docs.map((doc) async {
        try {
          var data = doc.data();
          data['id'] = doc.id; // Ensure ID is present

          // Create base item from order_item data
          final item = OrderItemModel.fromJson(data);

          // Check if we need to enrich with product details
          // Condition: Name is missing/unknown AND we have a product_id
          final productId = data['product_id'] as String?;
          final needsEnrichment =
              (item.name == 'Unknown Product' || item.name.isEmpty) &&
                  (productId != null && productId.isNotEmpty);

          if (needsEnrichment) {
            try {
              final productDoc = await _productsCollection.doc(productId).get();
              if (productDoc.exists) {
                final productData = productDoc.data()!;
                final productPrice =
                    (productData['price'] as num?)?.toDouble() ?? 0.0;

                // Calculate total if missing
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
              // On product fetch error, return original item
              print('Error fetching product details: $e');
            }
          }

          return item;
        } catch (e) {
          print('Error parsing item: $e');
          // Return a simplified error item or null (filtered out later) if strictly needed
          // For now, return a placeholder to avoid empty list if possible, or rethrow
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
      print('Error fetching order items: $e');
      // Return empty list on failure to avoid breaking the whole order fetch
      return [];
    }
  }

  @override
  Future<OrderStats> getOrderStats({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    Query<Map<String, dynamic>> query = _ordersCollection;

    // Deliverzler uses 'created_at' as ISO string
    if (fromDate != null) {
      query = query.where(OrderFields.createdAt,
          isGreaterThanOrEqualTo: fromDate.toIso8601String());
    }
    if (toDate != null) {
      query = query.where(OrderFields.createdAt,
          isLessThanOrEqualTo: toDate.toIso8601String());
    }

    final snapshot = await query.get();
    final orders = snapshot.docs.map((doc) {
      return OrderModel.fromDeliverzler(doc.data(), documentId: doc.id);
    }).toList();

    final totalOrders = orders.length;
    final pendingOrders =
        orders.where((o) => o.status == OrderStatus.pending).length;
    final activeOrders = orders.where((o) => o.status.isActive).length;
    final completedOrders =
        orders.where((o) => o.status == OrderStatus.delivered).length;
    final cancelledOrders =
        orders.where((o) => o.status == OrderStatus.cancelled).length;
    final totalRevenue = orders
        .where((o) => o.status == OrderStatus.delivered)
        .fold(0.0, (total, o) => total + (o.total ?? 0.0));

    return OrderStats(
      totalOrders: totalOrders,
      pendingOrders: pendingOrders,
      activeOrders: activeOrders,
      completedOrders: completedOrders,
      cancelledOrders: cancelledOrders,
      totalRevenue: totalRevenue,
      averageOrderValue:
          completedOrders > 0 ? totalRevenue / completedOrders : 0,
    );
  }
}
