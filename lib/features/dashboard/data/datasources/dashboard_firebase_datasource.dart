// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/firebase/firebase_service.dart';
import '../../domain/entities/dashboard_entities.dart';
import '../models/dashboard_models.dart';
import 'dashboard_datasource.dart';

/// Firebase implementation of dashboard data source.
///
/// Performance-optimized:
/// - Uses a shared orders snapshot (fetched once, used by all methods)
/// - Uses Firestore count() aggregation for user counts
/// - Caches results for 3 minutes
/// - Recent orders use proper limit() instead of fetching all
/// - Batch store name resolution instead of N+1 queries
class DashboardFirebaseDataSource implements DashboardDataSource {
  final FirebaseFirestore _firestore;

  DashboardFirebaseDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ─── Cache ────────────────────────────────────────────────
  static const _cacheDuration = Duration(minutes: 3);

  /// Cached orders docs — shared across stats, revenue, distribution
  List<QueryDocumentSnapshot<Map<String, dynamic>>>? _cachedOrderDocs;
  DateTime? _ordersCacheTime;

  /// Cached stats result
  DashboardStatsModel? _cachedStats;
  DateTime? _statsCacheTime;

  /// Cached distribution
  OrdersDistributionModel? _cachedDistribution;
  DateTime? _distributionCacheTime;

  /// Store name cache to avoid N+1 lookups
  final Map<String, String> _storeNameCache = {};

  bool _isCacheValid(DateTime? cacheTime) =>
      cacheTime != null &&
      DateTime.now().difference(cacheTime) < _cacheDuration;

  // ─── Collection refs ──────────────────────────────────────
  CollectionReference<Map<String, dynamic>> get _ordersCollection =>
      _firestore.collection(FirestoreCollections.orders);

  CollectionReference<Map<String, dynamic>> get _driversCollection =>
      _firestore.collection(FirestoreCollections.drivers);

  CollectionReference<Map<String, dynamic>> get _customersCollection =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _storesCollection =>
      _firestore.collection('users');

  /// Query for sellers (users with stores)
  Query<Map<String, dynamic>> get _sellersQuery =>
      _storesCollection.where('role', isEqualTo: 'seller');

  // ─── Shared orders snapshot ───────────────────────────────

  /// Fetches orders once and caches. All dashboard methods share this.
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      _getOrderDocs() async {
    if (_cachedOrderDocs != null && _isCacheValid(_ordersCacheTime)) {
      return _cachedOrderDocs!;
    }
    final snapshot = await _ordersCollection.get();
    _cachedOrderDocs = snapshot.docs;
    _ordersCacheTime = DateTime.now();
    return _cachedOrderDocs!;
  }

  // ─── Status normalization ─────────────────────────────────

  /// Normalize legacy status values from Deliverzler to OrderStatus enum
  OrderStatus _normalizeStatus(String? status) {
    if (status == null) return OrderStatus.pending;
    switch (status) {
      case 'pending':
        return OrderStatus.pending;
      case 'upcoming':
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'preparing':
        return OrderStatus.preparing;
      case 'ready':
        return OrderStatus.ready;
      case 'picked_up':
      case 'pickedUp':
        return OrderStatus.pickedUp;
      case 'onTheWay':
      case 'on_the_way':
        return OrderStatus.pickedUp; // Map to pickedUp as closest match
      case 'delivered':
        return OrderStatus.delivered;
      case 'canceled':
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  /// Parses a date field (int millis or ISO string) to milliseconds
  int? _parseDateToMillis(dynamic field) {
    if (field == null) return null;
    if (field is int) return field;
    if (field is String) {
      return DateTime.tryParse(field)?.millisecondsSinceEpoch;
    }
    return null;
  }

  @override
  Future<DashboardStatsModel> getStats() async {
    // Return cached stats if valid
    if (_cachedStats != null && _isCacheValid(_statsCacheTime)) {
      return _cachedStats!;
    }

    try {
      // Check for aggregated stats document first (fast path)
      final statsDoc =
          await _firestore.collection('stats').doc('dashboard').get();

      if (statsDoc.exists && statsDoc.data() != null) {
        _cachedStats = DashboardStatsModel.fromJson(statsDoc.data()!);
        _statsCacheTime = DateTime.now();
        return _cachedStats!;
      }

      // Use aggregation count() for user collections (1 read each, not N)
      // and shared orders snapshot for order stats
      final results = await Future.wait([
        _getOrderDocs(), // shared snapshot
        _driversCollection.count().get(), // 1 aggregation read
        _customersCollection.count().get(), // 1 aggregation read
        _sellersQuery.get(), // need full docs for isApproved check
      ]);

      final orderDocs =
          results[0] as List<QueryDocumentSnapshot<Map<String, dynamic>>>;
      final driversCount = (results[1] as AggregateQuerySnapshot).count ?? 0;
      final customersCount = (results[2] as AggregateQuerySnapshot).count ?? 0;
      final sellersSnapshot = results[3] as QuerySnapshot<Map<String, dynamic>>;

      // Calculate 24h boundaries
      final now = DateTime.now();
      final last24HoursTimestamp =
          now.subtract(const Duration(hours: 24)).millisecondsSinceEpoch;
      final previous24HoursStartTimestamp =
          now.subtract(const Duration(hours: 48)).millisecondsSinceEpoch;

      // Count orders by status (single pass)
      int pendingOrders = 0;
      int completedOrders = 0;
      int cancelledOrders = 0;
      int multiStoreOrders = 0;
      double totalRevenue = 0.0;
      double todayRevenue = 0.0;
      int todayOrdersCount = 0;
      double yesterdayRevenue = 0.0;
      int yesterdayOrdersCount = 0;

      for (final doc in orderDocs) {
        final data = doc.data();
        final rawStatus =
            (data[OrderFields.deliveryStatus] ?? data['status']) as String?;
        final status = _normalizeStatus(rawStatus);

        final orderTotal = (data['total'] as num?)?.toDouble() ??
            (data['totalAmount'] as num?)?.toDouble() ??
            (data['total_price'] as num?)?.toDouble() ??
            0.0;

        if (data['order_type'] == 'multi_store') multiStoreOrders++;

        final orderDate =
            _parseDateToMillis(data['created_at'] ?? data[OrderFields.date]);

        switch (status) {
          case OrderStatus.pending:
            pendingOrders++;
          case OrderStatus.delivered:
            completedOrders++;
            totalRevenue += orderTotal;
          case OrderStatus.cancelled:
            cancelledOrders++;
          default:
            break;
        }

        // Last 24h
        if (orderDate != null && orderDate >= last24HoursTimestamp) {
          todayOrdersCount++;
          if (status == OrderStatus.delivered) todayRevenue += orderTotal;
        }

        // Previous 24h (for growth)
        if (orderDate != null &&
            orderDate >= previous24HoursStartTimestamp &&
            orderDate < last24HoursTimestamp) {
          yesterdayOrdersCount++;
          if (status == OrderStatus.delivered) yesterdayRevenue += orderTotal;
        }
      }

      // Growth calculations
      double revenueGrowth = 0.0;
      if (yesterdayRevenue > 0) {
        revenueGrowth =
            ((todayRevenue - yesterdayRevenue) / yesterdayRevenue) * 100;
      } else if (todayRevenue > 0) {
        revenueGrowth = 100.0;
      }

      double ordersGrowth = 0.0;
      if (yesterdayOrdersCount > 0) {
        ordersGrowth =
            ((todayOrdersCount - yesterdayOrdersCount) / yesterdayOrdersCount) *
                100;
      } else if (todayOrdersCount > 0) {
        ordersGrowth = 100.0;
      }

      // Count active vendors from sellers snapshot
      int activeVendors = 0;
      for (final store in sellersSnapshot.docs) {
        final storeData = store.data()['store'] as Map<String, dynamic>?;
        if (storeData != null && (storeData['is_approved'] as bool? ?? false)) {
          activeVendors++;
        }
      }

      // For active drivers, use a filtered count query
      int activeDrivers = 0;
      try {
        final activeDriversResult = await _driversCollection
            .where('isActive', isEqualTo: true)
            .count()
            .get();
        activeDrivers = activeDriversResult.count ?? 0;
      } catch (_) {}

      _cachedStats = DashboardStatsModel(
        totalOrders: orderDocs.length,
        pendingOrders: pendingOrders,
        completedOrders: completedOrders,
        cancelledOrders: cancelledOrders,
        multiStoreOrders: multiStoreOrders,
        totalVendors: sellersSnapshot.docs.length,
        activeVendors: activeVendors,
        totalDrivers: driversCount,
        activeDrivers: activeDrivers,
        totalCustomers: customersCount,
        totalRevenue: totalRevenue,
        todayRevenue: todayRevenue,
        revenueGrowth: revenueGrowth.isFinite ? revenueGrowth : 0.0,
        ordersGrowth: ordersGrowth.isFinite ? ordersGrowth : 0.0,
      );
      _statsCacheTime = DateTime.now();

      return _cachedStats!;
    } catch (e) {
      // Return empty stats on error to prevent crash
      return const DashboardStatsModel(
        totalOrders: 0,
        pendingOrders: 0,
        completedOrders: 0,
        cancelledOrders: 0,
        totalVendors: 0,
        activeVendors: 0,
        totalDrivers: 0,
        activeDrivers: 0,
        totalCustomers: 0,
        totalRevenue: 0.0,
        todayRevenue: 0.0,
        revenueGrowth: 0.0,
        ordersGrowth: 0.0,
      );
    }
  }

  @override
  Future<List<RecentOrderModel>> getRecentOrders({int limit = 10}) async {
    try {
      // Use proper Firestore ordering + limit instead of fetching ALL orders
      QuerySnapshot<Map<String, dynamic>> snapshot;
      try {
        snapshot = await _ordersCollection
            .orderBy('created_at', descending: true)
            .limit(limit + 5) // fetch a few extra in case some are invalid
            .get();
      } catch (_) {
        // If index doesn't exist, use shared snapshot sorted in memory
        final allDocs = await _getOrderDocs();
        final sorted =
            List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(allDocs);
        sorted.sort((a, b) {
          final dateA = _parseDateToMillis(
              a.data()['created_at'] ?? a.data()[OrderFields.date]);
          final dateB = _parseDateToMillis(
              b.data()['created_at'] ?? b.data()[OrderFields.date]);
          if (dateA == null && dateB == null) return 0;
          if (dateA == null) return 1;
          if (dateB == null) return -1;
          return dateB.compareTo(dateA);
        });
        return _buildRecentOrders(sorted.take(limit).toList());
      }

      return _buildRecentOrders(snapshot.docs.take(limit).toList());
    } catch (e) {
      return [];
    }
  }

  /// Builds RecentOrderModel list from docs with batch store name resolution.
  Future<List<RecentOrderModel>> _buildRecentOrders(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    if (docs.isEmpty) return [];

    // Collect all unique store IDs that need resolution
    final storeIdsToResolve = <String>{};
    for (final doc in docs) {
      final data = doc.data();
      final orderType = data['order_type'] as String?;
      if (orderType != 'multi_store') {
        final storeId = data['storeId'] as String?;
        if (storeId != null && !_storeNameCache.containsKey(storeId)) {
          storeIdsToResolve.add(storeId);
        }
      }
    }

    // Batch resolve store names (max 10 per whereIn query)
    await _batchResolveStoreNames(storeIdsToResolve.toList());

    // Build order models
    final orders = <RecentOrderModel>[];
    for (final doc in docs) {
      final data = doc.data();
      try {
        final orderType = data['order_type'] as String?;
        final isMultiStore = orderType == 'multi_store';
        final pickupStops = data['pickup_stops'] as List<dynamic>?;
        final storeCount = isMultiStore ? (pickupStops?.length ?? 0) : 1;

        // Get vendor name from cache (already resolved in batch)
        String vendorName = 'غير محدد';
        if (isMultiStore && pickupStops != null && pickupStops.isNotEmpty) {
          final storeNames = pickupStops
              .map((s) =>
                  (s as Map<String, dynamic>)['store_name'] as String? ?? '')
              .where((name) => name.isNotEmpty)
              .toList();
          vendorName =
              storeNames.isNotEmpty ? storeNames.join(' • ') : 'متعدد المتاجر';
        } else {
          final storeId = data['storeId'] as String?;
          if (storeId != null) {
            vendorName = _storeNameCache[storeId] ?? 'غير محدد';
          }
        }

        final dateTimestamp =
            _parseDateToMillis(data['created_at'] ?? data[OrderFields.date]) ??
                DateTime.now().millisecondsSinceEpoch;

        orders.add(RecentOrderModel(
          id: doc.id,
          orderNumber: doc.id.substring(0, 8).toUpperCase(),
          customerName: data[OrderFields.userName] as String? ?? 'Unknown',
          vendorName: vendorName,
          amount: (data['total'] as num?)?.toDouble() ??
              (data['totalAmount'] as num?)?.toDouble() ??
              (data['total_price'] as num?)?.toDouble() ??
              0.0,
          status: _normalizeStatus(
              (data[OrderFields.deliveryStatus] ?? data['status']) as String?),
          createdAt: DateTime.fromMillisecondsSinceEpoch(dateTimestamp),
          isMultiStore: isMultiStore,
          storeCount: storeCount,
        ));
      } catch (e) {
        continue;
      }
    }

    return orders;
  }

  /// Batch resolves store names using whereIn (max 10 per query).
  Future<void> _batchResolveStoreNames(List<String> storeIds) async {
    if (storeIds.isEmpty) return;

    for (var i = 0; i < storeIds.length; i += 10) {
      final chunk = storeIds.sublist(
          i, i + 10 > storeIds.length ? storeIds.length : i + 10);
      try {
        final snapshot = await _storesCollection
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        for (final doc in snapshot.docs) {
          final userData = doc.data();
          final storeData = userData['store'] as Map<String, dynamic>?;
          final name =
              storeData?['name'] as String? ?? userData['full_name'] as String?;
          if (name != null && name.isNotEmpty) {
            _storeNameCache[doc.id] = name;
          }
        }
      } catch (_) {}
    }
  }

  @override
  Future<List<RevenueDataPointModel>> getRevenueData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Normalize dates to start of day
      final normalizedStartDate =
          DateTime(startDate.year, startDate.month, startDate.day);
      final normalizedEndDate =
          DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

      // Use shared orders snapshot instead of fetching again
      final orderDocs = await _getOrderDocs();

      // Group by date and only count delivered orders
      final revenueByDate = <DateTime, double>{};

      for (final doc in orderDocs) {
        final data = doc.data();
        final rawStatus =
            (data[OrderFields.deliveryStatus] ?? data['status']) as String?;
        final status = _normalizeStatus(rawStatus);

        // Only count delivered orders for revenue
        if (status != OrderStatus.delivered) continue;

        // Handle date field
        final dateTimestamp =
            _parseDateToMillis(data['created_at'] ?? data[OrderFields.date]);

        if (dateTimestamp == null) continue;

        // Filter by date range
        if (dateTimestamp < normalizedStartDate.millisecondsSinceEpoch ||
            dateTimestamp > normalizedEndDate.millisecondsSinceEpoch) {
          continue;
        }

        final createdAt = DateTime.fromMillisecondsSinceEpoch(dateTimestamp);
        final dateKey =
            DateTime(createdAt.year, createdAt.month, createdAt.day);
        final amount = (data['total'] as num?)?.toDouble() ??
            (data['totalAmount'] as num?)?.toDouble() ??
            (data['total_price'] as num?)?.toDouble() ??
            0.0;

        revenueByDate[dateKey] = (revenueByDate[dateKey] ?? 0) + amount;
      }

      // Fill in missing dates with zero
      final points = <RevenueDataPointModel>[];
      var currentDate = normalizedStartDate;

      while (!currentDate.isAfter(normalizedEndDate)) {
        final dateKey =
            DateTime(currentDate.year, currentDate.month, currentDate.day);
        points.add(RevenueDataPointModel(
          date: dateKey,
          amount: revenueByDate[dateKey] ?? 0,
        ));
        currentDate = currentDate.add(const Duration(days: 1));
      }

      return points;
    } catch (e) {
      // Return empty list on error
      return [];
    }
  }

  @override
  Future<OrdersDistributionModel> getOrdersDistribution() async {
    // Return cached if valid
    if (_cachedDistribution != null && _isCacheValid(_distributionCacheTime)) {
      return _cachedDistribution!;
    }

    try {
      // Use shared orders snapshot instead of fetching again
      final orderDocs = await _getOrderDocs();

      int pending = 0,
          confirmed = 0,
          preparing = 0,
          ready = 0,
          pickedUp = 0,
          delivered = 0,
          cancelled = 0;

      for (final doc in orderDocs) {
        final data = doc.data();

        final rawStatus =
            (data[OrderFields.deliveryStatus] ?? data['status']) as String?;
        final status = _normalizeStatus(rawStatus);

        switch (status) {
          case OrderStatus.pending:
            pending++;
          case OrderStatus.confirmed:
            confirmed++;
          case OrderStatus.preparing:
            preparing++;
          case OrderStatus.ready:
            ready++;
          case OrderStatus.pickedUp:
            pickedUp++;
          case OrderStatus.delivered:
            delivered++;
          case OrderStatus.cancelled:
            cancelled++;
        }
      }

      _cachedDistribution = OrdersDistributionModel(
        pending: pending,
        confirmed: confirmed,
        preparing: preparing,
        ready: ready,
        pickedUp: pickedUp,
        delivered: delivered,
        cancelled: cancelled,
      );
      _distributionCacheTime = DateTime.now();

      return _cachedDistribution!;
    } catch (e) {
      // Return empty distribution on error
      return const OrdersDistributionModel(
        pending: 0,
        confirmed: 0,
        preparing: 0,
        ready: 0,
        pickedUp: 0,
        delivered: 0,
        cancelled: 0,
      );
    }
  }
}
