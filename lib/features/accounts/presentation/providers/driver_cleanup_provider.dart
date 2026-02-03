import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Provider that automatically sets offline status for drivers
/// who haven't been active for more than 12 hours.
class DriverCleanupProvider {
  final FirebaseFirestore _firestore;

  DriverCleanupProvider({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Starts periodic cleanup job (runs every hour)
  void startCleanupJob(BuildContext context) {
    // Run initial cleanup
    _runCleanup();

    // Schedule periodic cleanup every hour
    Future.doWhile(() async {
      await Future.delayed(const Duration(hours: 1));
      if (context.mounted) {
        _runCleanup();
        return true; // Continue loop
      }
      return false; // Stop loop if context is disposed
    });
  }

  /// Runs the cleanup job to set offline status for stale drivers
  Future<void> _runCleanup() async {
    try {
      final now = DateTime.now();
      final twelveHoursAgo = now.subtract(const Duration(hours: 12));

      // Query drivers who are online but haven't been active for 12+ hours
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

      // Batch update stale drivers
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

  /// Manual cleanup trigger (for admin button if needed)
  Future<int> runManualCleanup() async {
    try {
      final now = DateTime.now();
      final twelveHoursAgo = now.subtract(const Duration(hours: 12));

      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'delivery')
          .where('isOnline', isEqualTo: true)
          .where('lastActiveAt', isLessThan: Timestamp.fromDate(twelveHoursAgo))
          .get();

      if (snapshot.docs.isEmpty) {
        return 0;
      }

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
