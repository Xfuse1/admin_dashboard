import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Background service that periodically sets offline status for drivers
/// who haven't been active for more than 12 hours.
///
/// Lifecycle managed via [start] / [dispose] — no BuildContext dependency.
class DriverCleanupService {
  final FirebaseFirestore _firestore;
  Timer? _timer;

  DriverCleanupService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Start the periodic cleanup (runs immediately, then every hour).
  void start() {
    if (_timer != null) return; // already running
    _runCleanup(); // initial run
    _timer = Timer.periodic(const Duration(hours: 1), (_) => _runCleanup());
  }

  /// Stop the periodic cleanup.
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }

  /// Runs the cleanup — sets drivers offline if inactive for 12+ hours.
  Future<void> _runCleanup() async {
    try {
      final twelveHoursAgo = DateTime.now().subtract(const Duration(hours: 12));

      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'delivery')
          .where('isOnline', isEqualTo: true)
          .where('lastActiveAt', isLessThan: Timestamp.fromDate(twelveHoursAgo))
          .get();

      if (snapshot.docs.isEmpty) {
        debugPrint('✅ Driver cleanup: No stale drivers found');
        return;
      }

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {
          'isOnline': false,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      debugPrint(
        '✅ Driver cleanup: Set ${snapshot.docs.length} drivers offline',
      );
    } catch (e) {
      debugPrint('❌ Driver cleanup error: $e');
    }
  }

  /// Manual cleanup trigger (for admin button if needed).
  Future<int> runManualCleanup() async {
    try {
      final twelveHoursAgo = DateTime.now().subtract(const Duration(hours: 12));

      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'delivery')
          .where('isOnline', isEqualTo: true)
          .where('lastActiveAt', isLessThan: Timestamp.fromDate(twelveHoursAgo))
          .get();

      if (snapshot.docs.isEmpty) return 0;

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {
          'isOnline': false,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      return snapshot.docs.length;
    } catch (e) {
      debugPrint('❌ Manual cleanup error: $e');
      return 0;
    }
  }
}
