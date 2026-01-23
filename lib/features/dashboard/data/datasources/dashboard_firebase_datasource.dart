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
    // Get stats from aggregated document
    final statsDoc =
        await _firestore.collection('stats').doc('dashboard').get();

    if (statsDoc.exists) {
      return DashboardStatsModel.fromJson(statsDoc.data()!);
    }

    // Calculate stats from Deliverzler collections
    final ordersSnapshot = await _ordersCollection.get();
    // Note: vendors/customers not used in Deliverzler, using users collection for drivers
    final driversSnapshot = await _usersCollection.get();

    final orders = ordersSnapshot.docs;
    final pendingOrders = orders.where((d) {
      final status =
          _normalizeStatus(d.data()[OrderFields.deliveryStatus] as String?);
      return status == OrderStatus.pending;
    }).length;
    final completedOrders = orders.where((d) {
      final status =
          _normalizeStatus(d.data()[OrderFields.deliveryStatus] as String?);
      return status == OrderStatus.delivered;
    }).length;
    final cancelledOrders = orders.where((d) {
      final status =
          _normalizeStatus(d.data()[OrderFields.deliveryStatus] as String?);
      return status == OrderStatus.cancelled;
    }).length;

    final drivers = driversSnapshot.docs;
    // Deliverzler doesn't have isActive field for users
    final activeDrivers = drivers.length;

    // Deliverzler stores total in 'total' field (not 'amount')
    final totalRevenue = orders.fold<double>(
      0,
      (total, doc) => total + (doc.data()['total'] as num? ?? 0).toDouble(),
    );

    // Deliverzler uses 'date' as Unix timestamp (milliseconds)
    final todayStart = DateTime.now().copyWith(
      hour: 0,
      minute: 0,
      second: 0,
      millisecond: 0,
    );
    final todayTimestamp = todayStart.millisecondsSinceEpoch;
    final todayOrders = orders.where((d) {
      final date = d.data()[OrderFields.date] as int?;
      return date != null && date >= todayTimestamp;
    });
    final todayRevenue = todayOrders.fold<double>(
      0,
      (total, doc) => total + (doc.data()['total'] as num? ?? 0).toDouble(),
    );

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
      revenueGrowth: 0.0, // Would need historical data
      ordersGrowth: 0.0,
    );
  }

  @override
  Future<List<RecentOrderModel>> getRecentOrders({int limit = 10}) async {
    // Deliverzler uses 'date' field for ordering
    final snapshot = await _ordersCollection
        .orderBy(OrderFields.date, descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      // Map Deliverzler fields to expected format
      return RecentOrderModel(
        id: doc.id,
        orderNumber: doc.id.substring(0, 8).toUpperCase(),
        customerName: data[OrderFields.userName] as String? ?? 'Unknown',
        vendorName: 'Deliverzler', // Deliverzler doesn't have vendor concept
        amount: (data['total'] as num?)?.toDouble() ?? 0.0,
        status: _normalizeStatus(data[OrderFields.deliveryStatus] as String?),
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          (data[OrderFields.date] as int?) ??
              DateTime.now().millisecondsSinceEpoch,
        ),
      );
    }).toList();
  }

  @override
  Future<List<RevenueDataPointModel>> getRevenueData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Deliverzler uses Unix timestamp for date
    final snapshot = await _ordersCollection
        .where(OrderFields.date,
            isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch)
        .where(OrderFields.date,
            isLessThanOrEqualTo: endDate.millisecondsSinceEpoch)
        .where(OrderFields.deliveryStatus, isEqualTo: 'delivered')
        .get();

    // Group by date
    final revenueByDate = <DateTime, double>{};

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final dateTimestamp = data[OrderFields.date] as int;
      final createdAt = DateTime.fromMillisecondsSinceEpoch(dateTimestamp);
      final dateKey = DateTime(createdAt.year, createdAt.month, createdAt.day);
      final amount = (data['total'] as num?)?.toDouble() ?? 0.0;

      revenueByDate[dateKey] = (revenueByDate[dateKey] ?? 0) + amount;
    }

    // Fill in missing dates with zero
    final points = <RevenueDataPointModel>[];
    var currentDate = startDate;

    while (!currentDate.isAfter(endDate)) {
      final dateKey =
          DateTime(currentDate.year, currentDate.month, currentDate.day);
      points.add(RevenueDataPointModel(
        date: dateKey,
        amount: revenueByDate[dateKey] ?? 0,
      ));
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return points;
  }

  @override
  Future<OrdersDistributionModel> getOrdersDistribution() async {
    final snapshot = await _ordersCollection.get();

    int pending = 0,
        confirmed = 0,
        preparing = 0,
        ready = 0,
        pickedUp = 0,
        delivered = 0,
        cancelled = 0;

    for (final doc in snapshot.docs) {
      // Deliverzler uses 'deliveryStatus' field
      final rawStatus = doc.data()[OrderFields.deliveryStatus] as String?;
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
  }
}
