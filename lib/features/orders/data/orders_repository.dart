import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/order_model.dart';

class OrdersRepository {
  final FirebaseFirestore _firestore;

  OrdersRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get all orders stream
  Stream<List<AppOrder>> getOrdersStream() {
    return _firestore
        .collection('orders')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => AppOrder.fromFirestore(doc)).toList();
    });
  }

  /// Get orders by status
  Stream<List<AppOrder>> getOrdersByStatus(DeliveryStatus status) {
    return _firestore
        .collection('orders')
        .where('deliveryStatus', isEqualTo: status.value)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => AppOrder.fromFirestore(doc)).toList();
    });
  }

  /// Update order status
  Future<void> updateOrderStatus(
    String orderId,
    DeliveryStatus newStatus, {
    String? employeeCancelNote,
  }) async {
    final updateData = <String, dynamic>{
      'deliveryStatus': newStatus.value,
    };

    if (employeeCancelNote != null) {
      updateData['employeeCancelNote'] = employeeCancelNote;
    }

    await _firestore.collection('orders').doc(orderId).update(updateData);
  }

  /// Assign delivery to order
  Future<void> assignDelivery(
    String orderId,
    String deliveryId,
    String deliveryName,
  ) async {
    await _firestore.collection('orders').doc(orderId).update({
      'deliveryId': deliveryId,
      'deliveryName': deliveryName,
      'deliveryStatus': DeliveryStatus.confirmed.value,
    });
  }

  /// Get single order
  Future<AppOrder?> getOrder(String orderId) async {
    final doc = await _firestore.collection('orders').doc(orderId).get();
    if (!doc.exists) return null;
    return AppOrder.fromFirestore(doc);
  }
}
