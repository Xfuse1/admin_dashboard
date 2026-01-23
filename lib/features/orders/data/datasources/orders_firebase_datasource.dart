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

  CollectionReference<Map<String, dynamic>> get _ordersCollection =>
      _firestore.collection(FirestoreCollections.orders);

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
    Query<Map<String, dynamic>> query = _ordersCollection;

    // Deliverzler uses 'deliveryStatus' field
    if (status != null) {
      query = query.where(OrderFields.deliveryStatus, isEqualTo: status.value);
    }
    // Note: storeId not used in Deliverzler structure, kept for compatibility
    if (storeId != null) {
      query = query.where('storeId', isEqualTo: storeId);
    }
    // Deliverzler uses 'deliveryId' for driver
    if (driverId != null) {
      query = query.where(OrderFields.deliveryId, isEqualTo: driverId);
    }
    // Deliverzler uses 'date' as Unix timestamp (milliseconds)
    if (fromDate != null) {
      query = query.where(OrderFields.date,
          isGreaterThanOrEqualTo: fromDate.millisecondsSinceEpoch);
    }
    if (toDate != null) {
      query = query.where(OrderFields.date,
          isLessThanOrEqualTo: toDate.millisecondsSinceEpoch);
    }

    query = query.orderBy(OrderFields.date, descending: true).limit(limit);

    if (lastOrderId != null) {
      final lastDoc = await _ordersCollection.doc(lastOrderId).get();
      if (lastDoc.exists) {
        query = query.startAfterDocument(lastDoc);
      }
    }

    final snapshot = await query.get();

    return snapshot.docs.map((doc) {
      return OrderModel.fromDeliverzler(doc.data(), documentId: doc.id);
    }).toList();
  }

  @override
  Future<OrderModel> getOrderById(String orderId) async {
    final doc = await _ordersCollection.doc(orderId).get();

    if (!doc.exists) {
      throw Exception('Order not found');
    }

    return OrderModel.fromDeliverzler(doc.data()!, documentId: doc.id);
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
    Query<Map<String, dynamic>> query =
        _ordersCollection.orderBy(OrderFields.date, descending: true).limit(50);

    // Deliverzler uses 'deliveryStatus' field
    if (status != null) {
      query = query.where(OrderFields.deliveryStatus, isEqualTo: status.value);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return OrderModel.fromDeliverzler(doc.data(), documentId: doc.id);
      }).toList();
    });
  }

  @override
  Future<OrderStats> getOrderStats({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    Query<Map<String, dynamic>> query = _ordersCollection;

    // Deliverzler uses 'date' as Unix timestamp
    if (fromDate != null) {
      query = query.where(OrderFields.date,
          isGreaterThanOrEqualTo: fromDate.millisecondsSinceEpoch);
    }
    if (toDate != null) {
      query = query.where(OrderFields.date,
          isLessThanOrEqualTo: toDate.millisecondsSinceEpoch);
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
