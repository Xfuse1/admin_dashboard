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

  CollectionReference<Map<String, dynamic>> get _driversCollection =>
      _firestore.collection(FirestoreCollections.drivers);

  CollectionReference<Map<String, dynamic>> get _customersCollection =>
      _firestore.collection('profiles');

  CollectionReference<Map<String, dynamic>> get _storesCollection =>
      _firestore.collection(FirestoreCollections.stores);

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

      // Calculate stats from collections in parallel for performance
      final results = await Future.wait([
        _ordersCollection.get(),
        _driversCollection.get(),
        _customersCollection.get(),
        _storesCollection.get(),
      ]);

      final ordersSnapshot = results[0];
      final driversSnapshot = results[1];
      final customersSnapshot = results[2];
      final storesSnapshot = results[3];

      final orders = ordersSnapshot.docs;
      final drivers = driversSnapshot.docs;
      final customers = customersSnapshot.docs;
      final stores = storesSnapshot.docs;

      // Calculate 24h boundaries (Rolling window)
      final now = DateTime.now();
      final last24HoursStart = now.subtract(const Duration(hours: 24));
      final last24HoursTimestamp = last24HoursStart.millisecondsSinceEpoch;
      
      // Calculate previous 24h boundaries for growth comparison
      final previous24HorusStart = last24HoursStart.subtract(const Duration(hours: 24));
      final previous24HoursEndTimestamp = last24HoursTimestamp; // Same as last24HoursStart
      final previous24HoursStartTimestamp = previous24HorusStart.millisecondsSinceEpoch;

      // Count orders by status
      int pendingOrders = 0;
      int completedOrders = 0;
      int cancelledOrders = 0;
      double totalRevenue = 0.0;
      double todayRevenue = 0.0; // Represents Last 24h revenue
      int todayOrdersCount = 0;
      double yesterdayRevenue = 0.0; // Represents Previous 24h revenue
      int yesterdayOrdersCount = 0;

      for (final doc in orders) {
        final data = doc.data();
        final rawStatus = (data[OrderFields.deliveryStatus] ?? data['status']) as String?;
        final status = _normalizeStatus(rawStatus);
        
        final orderTotal = (data['total'] as num?)?.toDouble() ?? 
                           (data['totalAmount'] as num?)?.toDouble() ?? 
                           (data['total_price'] as num?)?.toDouble() ?? 0.0;
        
        // Handle date field - can be 'created_at' (ISO string) or 'date' (int milliseconds)
        int? orderDate;
        final createdAtField = data['created_at'] ?? data[OrderFields.date];
        
        if (createdAtField != null) {
          if (createdAtField is int) {
            orderDate = createdAtField;
          } else if (createdAtField is String) {
            try {
              final dateTime = DateTime.parse(createdAtField);
              orderDate = dateTime.millisecondsSinceEpoch;
            } catch (e) {
              // Invalid date format, skip
            }
          }
        }

        // Count by status
        switch (status) {
          case OrderStatus.pending:
            pendingOrders++;
          case OrderStatus.confirmed:
          case OrderStatus.preparing:
          case OrderStatus.ready:
          case OrderStatus.pickedUp:
            break; // These are counted as active but we don't track active separately
          case OrderStatus.delivered:
            completedOrders++;
          case OrderStatus.cancelled:
            cancelledOrders++;
        }

        // Calculate revenue
        if (status == OrderStatus.delivered) {
          totalRevenue += orderTotal;
        }

        // Last 24h revenue and count
        if (orderDate != null && orderDate >= last24HoursTimestamp) {
          if (status == OrderStatus.delivered) {
            todayRevenue += orderTotal;
          }
          todayOrdersCount++;
        }

        // Previous 24h revenue and count for growth calculation
        if (orderDate != null &&
            orderDate >= previous24HoursStartTimestamp &&
            orderDate < previous24HoursEndTimestamp) {
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

      // Count active vendors (stores with active status)
      int activeVendors = 0;
      for (final store in stores) {
        final data = store.data();
        final status = data['status'] as String?;
        if (status == 'active') {
          activeVendors++;
        }
      }

      // Count active drivers
      int activeDrivers = 0;
      for (final driver in drivers) {
        final data = driver.data();
        final isActive = data['isActive'] as bool? ?? false;
        if (isActive) {
          activeDrivers++;
        }
      }

      return DashboardStatsModel(
        totalOrders: orders.length,
        pendingOrders: pendingOrders,
        completedOrders: completedOrders,
        cancelledOrders: cancelledOrders,
        totalVendors: stores.length,
        activeVendors: activeVendors,
        totalDrivers: drivers.length,
        activeDrivers: activeDrivers,
        totalCustomers: customers.length,
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
      // Deliverzler uses mixed date formats, so we fetch and sort in memory
      final snapshot = await _ordersCollection.get();
      final allDocs = snapshot.docs;
      
      // Sort by date descending
      allDocs.sort((a, b) {
        final dataA = a.data();
        final dataB = b.data();
        
        int? dateA;
        final createdA = dataA['created_at'] ?? dataA[OrderFields.date];
        if (createdA is int) dateA = createdA;
        else if (createdA is String) dateA = DateTime.tryParse(createdA)?.millisecondsSinceEpoch;
        
        int? dateB;
        final createdB = dataB['created_at'] ?? dataB[OrderFields.date];
        if (createdB is int) dateB = createdB;
        else if (createdB is String) dateB = DateTime.tryParse(createdB)?.millisecondsSinceEpoch;
        
        // Handle nulls (put nulls last)
        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;
        
        return dateB.compareTo(dateA); // Descending
      });
      
      final recentDocs = allDocs.take(limit).toList();

      final orders = <RecentOrderModel>[];

      for (final doc in recentDocs) {
        final data = doc.data();

        try {
          // Get vendor name from storeId if available
          String vendorName = 'غير محدد';
          final storeId = data['storeId'] as String?;
          if (storeId != null) {
            try {
              final storeDoc = await _storesCollection.doc(storeId).get();
              if (storeDoc.exists && storeDoc.data() != null) {
                vendorName = storeDoc.data()!['name'] as String? ?? 'غير محدد';
              }
            } catch (_) {
              // Use default if store fetch fails
            }
          }

          int dateTimestamp = DateTime.now().millisecondsSinceEpoch;
          final createdField = data['created_at'] ?? data[OrderFields.date];
          if (createdField is int) dateTimestamp = createdField;
          else if (createdField is String) {
             dateTimestamp = DateTime.tryParse(createdField)?.millisecondsSinceEpoch ?? dateTimestamp;
          }

          final order = RecentOrderModel(
            id: doc.id,
            orderNumber: doc.id.substring(0, 8).toUpperCase(),
            customerName: data[OrderFields.userName] as String? ?? 'Unknown',
            vendorName: vendorName,
            amount: (data['total'] as num?)?.toDouble() ?? 
                    (data['totalAmount'] as num?)?.toDouble() ?? 
                    (data['total_price'] as num?)?.toDouble() ?? 0.0,
            status: _normalizeStatus((data[OrderFields.deliveryStatus] ?? data['status']) as String?),
            createdAt: DateTime.fromMillisecondsSinceEpoch(dateTimestamp),
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

      // Deliverzler uses mixed date formats, so we fetch all and filter in memory
      // Ideally we should fix the database schema, but for now this works
      final snapshot = await _ordersCollection.get();

      // Group by date and only count delivered orders
      final revenueByDate = <DateTime, double>{};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final rawStatus = (data[OrderFields.deliveryStatus] ?? data['status']) as String?;
        final status = _normalizeStatus(rawStatus);
        
        // Only count delivered orders for revenue
        if (status != OrderStatus.delivered) continue;

        // Handle date field
        int? dateTimestamp;
        final createdAtField = data['created_at'] ?? data[OrderFields.date];
        
        if (createdAtField != null) {
          if (createdAtField is int) {
            dateTimestamp = createdAtField;
          } else if (createdAtField is String) {
            try {
              final dateTime = DateTime.parse(createdAtField);
              dateTimestamp = dateTime.millisecondsSinceEpoch;
            } catch (e) {
              // Invalid date format
            }
          }
        }

        if (dateTimestamp == null) continue;
        
        // Filter by date range
        if (dateTimestamp < normalizedStartDate.millisecondsSinceEpoch || 
            dateTimestamp > normalizedEndDate.millisecondsSinceEpoch) {
          continue;
        }

        final createdAt = DateTime.fromMillisecondsSinceEpoch(dateTimestamp);
        final dateKey = DateTime(createdAt.year, createdAt.month, createdAt.day);
        final amount = (data['total'] as num?)?.toDouble() ?? 
                       (data['totalAmount'] as num?)?.toDouble() ?? 
                       (data['total_price'] as num?)?.toDouble() ?? 0.0;

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

        // Deliverzler uses 'deliveryStatus' field
        // Deliverzler uses 'deliveryStatus' field
        final rawStatus = (data[OrderFields.deliveryStatus] ?? data['status']) as String?;
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
