import 'package:cloud_firestore/cloud_firestore.dart';

/// Service for cross-feature read-only Firestore lookups used in presentation.
///
/// This centralises lightweight queries that don't fit neatly into a single
/// feature's domain layer (e.g. fetching a store name while viewing an order).
/// Registered as a singleton via DI so presentation widgets never touch
/// FirebaseFirestore.instance directly.
class FirestoreLookupService {
  final FirebaseFirestore _firestore;

  FirestoreLookupService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ──────────────────────────────────────────────
  // Store / User lookups
  // ──────────────────────────────────────────────

  /// Fetch a user/store document by ID.
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data();
  }

  // ──────────────────────────────────────────────
  // Settings lookups
  // ──────────────────────────────────────────────

  /// Get the driver commission rate from settings.
  Future<double> getDriverCommissionRate() async {
    final doc =
        await _firestore.collection('settings').doc('driverCommission').get();
    final data = doc.data();
    if (data != null && data.containsKey('rate')) {
      return (data['rate'] as num?)?.toDouble() ?? 0.0;
    }
    return 0.0;
  }

  // ──────────────────────────────────────────────
  // Driver stats lookups
  // ──────────────────────────────────────────────

  /// Count delivered orders for a driver.
  Future<int> getDeliveredOrdersCount(String driverId) async {
    final snapshot = await _firestore
        .collection('orders')
        .where('deliveryId', isEqualTo: driverId)
        .where('status', isEqualTo: 'delivered')
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  /// Count delivered orders for a driver using deliveryStatus field.
  Future<int> getDeliveredOrdersCountByDeliveryStatus(String driverId) async {
    final snapshot = await _firestore
        .collection('orders')
        .where('deliveryId', isEqualTo: driverId)
        .where('deliveryStatus', isEqualTo: 'delivered')
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  /// Count orders rejected by a driver.
  Future<int> getRejectedOrdersCount(String driverId) async {
    final snapshot = await _firestore
        .collection('orders')
        .where('rejected_by_drivers', arrayContains: driverId)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  /// Fetch rejection request documents for a driver.
  Future<List<Map<String, dynamic>>> getRejectionRequests(
      String driverId) async {
    final snapshot = await _firestore
        .collection('rejection_requests')
        .where('driverId', isEqualTo: driverId)
        .get();
    return snapshot.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }
}
