import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/firebase/firebase_service.dart';
import '../../domain/entities/dashboard_entities.dart';
import '../models/dashboard_models.dart';
import 'dashboard_datasource.dart';

/// Firebase implementation of dashboard data source.
///
/// Integrates with Deliverzler's Firestore structure:
/// - Status field: 'deliveryStatus' (not 'status')
/// - Date field: 'date' as Unix timestamp (not 'createdAt' as Timestamp)
/// - Drivers collection: 'users' (not 'drivers')
/// - Legacy status mapping: 'upcoming'→'confirmed', 'onTheWay'→'on_the_way'
class DashboardFirebaseDataSource implements DashboardDataSource {
  final FirebaseFirestore _firestore;

  DashboardFirebaseDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _ordersCollection =>
      _firestore.collection(FirestoreCollections.orders);

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection(FirestoreCollections.users);

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

  @override
  Future<DashboardStatsModel> getStats() async {
    try {
      // Get stats from aggregated document if available
      final statsDoc =
          await _firestore.collection('stats').doc('dashboard').get();

      if (statsDoc.exists && statsDoc.data() != null) {
        return DashboardStatsModel.fromJson(statsDoc.data()!);
      }

      // Calculate stats from Deliverzler collections
      final ordersSnapshot = await _ordersCollection.get();
      final driversSnapshot = await _usersCollection.get();

      final orders = ordersSnapshot.docs;
      final drivers = driversSnapshot.docs;

      // Calculate today's boundaries
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayTimestamp = todayStart.millisecondsSinceEpoch;
      
      // Calculate yesterday's boundaries for growth
      final yesterdayStart = todayStart.subtract(const Duration(days: 1));
      final yesterdayEnd = todayStart;
      final yesterdayStartTimestamp = yesterdayStart.millisecondsSinceEpoch;
      final yesterdayEndTimestamp = yesterdayEnd.millisecondsSinceEpoch;

      // Count orders by status
      int pendingOrders = 0;
      int activeOrders = 0; // Not delivered or cancelled
      int completedOrders = 0;
      int cancelledOrders = 0;
      double totalRevenue = 0.0;
      double todayRevenue = 0.0;
      int todayOrdersCount = 0;
      double yesterdayRevenue = 0.0;
      int yesterdayOrdersCount = 0;

      for (final doc in orders) {
        final data = doc.data();
        final status = _normalizeStatus(
            data[OrderFields.deliveryStatus] as String?);
        final orderTotal = (data['total'] as num?)?.toDouble() ?? 0.0;
        final orderDate = data[OrderFields.date] as int?;

        // Count by status
        switch (status) {
          case OrderStatus.pending:
            pendingOrders++;
            activeOrders++;
            break;
          case OrderStatus.confirmed:
          case OrderStatus.preparing:
          case OrderStatus.ready:
          case OrderStatus.pickedUp:
            activeOrders++;
            break;
          case OrderStatus.delivered:
            completedOrders++;
            break;
          case OrderStatus.cancelled:
            cancelledOrders++;
            break;
        }

        // Calculate revenue
        if (status == OrderStatus.delivered) {
          totalRevenue += orderTotal;
        }

        // Today's revenue and count
        if (orderDate != null && orderDate >= todayTimestamp) {
          if (status == OrderStatus.delivered) {
            todayRevenue += orderTotal;
          }
          todayOrdersCount++;
        }

        // Yesterday's revenue and count for growth calculation
        if (orderDate != null &&
            orderDate >= yesterdayStartTimestamp &&
            orderDate < yesterdayEndTimestamp) {
          if (status == OrderStatus.delivered) {
            yesterdayRevenue += orderTotal;
          }
          yesterdayOrdersCount++;
        }
      }

      // Calculate growth percentages
      double revenueGrowth = 0.0;
      double ordersGrowth = 0.0;

      if (yesterdayRevenue > 0) {
        revenueGrowth =
            ((todayRevenue - yesterdayRevenue) / yesterdayRevenue) * 100;
      } else if (todayRevenue > 0) {
        revenueGrowth = 100.0; // 100% growth from zero
      }

      if (yesterdayOrdersCount > 0) {
        ordersGrowth = ((todayOrdersCount - yesterdayOrdersCount) /
                yesterdayOrdersCount) *
            100;
      } else if (todayOrdersCount > 0) {
        ordersGrowth = 100.0;
      }

      // Deliverzler doesn't have active status for drivers, so all are considered active
      final activeDrivers = drivers.length;

      return DashboardStatsModel(
        totalOrders: orders.length,
        pendingOrders: pendingOrders,
        completedOrders: completedOrders,
        cancelledOrders: cancelledOrders,
        totalVendors: 0, // Not used in Deliverzler
        activeVendors: 0,
        totalDrivers: drivers.length,
        activeDrivers: activeDrivers,
        totalCustomers: 0, // Not tracked separately in Deliverzler
        totalRevenue: totalRevenue,
        todayRevenue: todayRevenue,
        revenueGrowth: revenueGrowth.isFinite ? revenueGrowth : 0.0,
        ordersGrowth: ordersGrowth.isFinite ? ordersGrowth : 0.0,
      );
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
      // Deliverzler uses 'date' field for ordering
      final snapshot = await _ordersCollection
          .orderBy(OrderFields.date, descending: true)
          .limit(limit)
          .get();

      final orders = <RecentOrderModel>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (data == null) continue;

        try {
          // Map Deliverzler fields to expected format
          final order = RecentOrderModel(
            id: doc.id,
            orderNumber: doc.id.substring(0, 8).toUpperCase(),
            customerName: data[OrderFields.userName] as String? ?? 'Unknown',
            vendorName: 'Deliverzler', // Deliverzler doesn't have vendor concept
            amount: (data['total'] as num?)?.toDouble() ?? 0.0,
            status:
                _normalizeStatus(data[OrderFields.deliveryStatus] as String?),
            createdAt: DateTime.fromMillisecondsSinceEpoch(
              (data[OrderFields.date] as int?) ??
                  DateTime.now().millisecondsSinceEpoch,
            ),
          );
          orders.add(order);
        } catch (e) {
          // Skip invalid orders
          continue;
        }
      }

      return orders;
    } catch (e) {
      // Return empty list on error
      return [];
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

      // Deliverzler uses Unix timestamp for date
      final snapshot = await _ordersCollection
          .where(OrderFields.date,
              isGreaterThanOrEqualTo: normalizedStartDate.millisecondsSinceEpoch)
          .where(OrderFields.date,
              isLessThanOrEqualTo: normalizedEndDate.millisecondsSinceEpoch)
          .get();

      // Group by date and only count delivered orders
      final revenueByDate = <DateTime, double>{};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final status =
            _normalizeStatus(data[OrderFields.deliveryStatus] as String?);
        
        // Only count delivered orders for revenue
        if (status != OrderStatus.delivered) continue;

        final dateTimestamp = data[OrderFields.date] as int?;
        if (dateTimestamp == null) continue;

        final createdAt = DateTime.fromMillisecondsSinceEpoch(dateTimestamp);
        final dateKey = DateTime(createdAt.year, createdAt.month, createdAt.day);
        final amount = (data['total'] as num?)?.toDouble() ?? 0.0;

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
    try {
      final snapshot = await _ordersCollection.get();

      int pending = 0,
          confirmed = 0,
          preparing = 0,
          ready = 0,
          pickedUp = 0,
          delivered = 0,
          cancelled = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (data == null) continue;

        // Deliverzler uses 'deliveryStatus' field
        final rawStatus = data[OrderFields.deliveryStatus] as String?;
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

      return OrdersDistributionModel(
        pending: pending,
        confirmed: confirmed,
        preparing: preparing,
        ready: ready,
        pickedUp: pickedUp,
        delivered: delivered,
        cancelled: cancelled,
      );
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
