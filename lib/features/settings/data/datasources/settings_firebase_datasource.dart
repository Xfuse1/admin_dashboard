import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/delivery_settings_model.dart';
import 'settings_datasource.dart';

class SettingsFirebaseDataSource implements SettingsDataSource {
  final FirebaseFirestore _firestore;

  SettingsFirebaseDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<DeliverySettingsModel> getDeliverySettings() async {
    final doc = await _firestore.collection('settings').doc('delivery').get();

    if (doc.exists && doc.data() != null) {
      return DeliverySettingsModel.fromMap(doc.data()!);
    } else {
      // Return default if not exists
      return const DeliverySettingsModel(deliveryPrice: 0.0);
    }
  }

  @override
  Future<void> updateDeliveryPrice(double price) async {
    await _firestore.collection('settings').doc('delivery').set(
      {'price': price},
      SetOptions(merge: true),
    );
  }

  @override
  Future<double> getDriverCommission() async {
    final doc =
        await _firestore.collection('settings').doc('driverCommission').get();

    if (doc.exists && doc.data() != null) {
      return (doc.data()!['rate'] as num?)?.toDouble() ?? 10.0;
    } else {
      // Return default commission rate
      return 10.0;
    }
  }

  @override
  Future<void> updateDriverCommission(double rate) async {
    await _firestore.collection('settings').doc('driverCommission').set(
      {'rate': rate},
      SetOptions(merge: true),
    );
  }

  @override
  Future<Map<String, double>> getAllDriverCommissions() async {
    final doc =
        await _firestore.collection('settings').doc('driverCommission').get();

    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      return {
        'rate': (data['rate'] as num?)?.toDouble() ?? 10.0,
        'rate2Orders': (data['rate2Orders'] as num?)?.toDouble() ?? 10.0,
        'rate3Orders': (data['rate3Orders'] as num?)?.toDouble() ?? 10.0,
        'rate4Orders': (data['rate4Orders'] as num?)?.toDouble() ?? 10.0,
      };
    } else {
      return {
        'rate': 10.0,
        'rate2Orders': 10.0,
        'rate3Orders': 10.0,
        'rate4Orders': 10.0,
      };
    }
  }

  @override
  Future<void> updateAllDriverCommissions({
    required double rate1Order,
    required double rate2Orders,
    required double rate3Orders,
    required double rate4Orders,
  }) async {
    await _firestore.collection('settings').doc('driverCommission').set(
      {
        'rate': rate1Order,
        'rate2Orders': rate2Orders,
        'rate3Orders': rate3Orders,
        'rate4Orders': rate4Orders,
      },
      SetOptions(merge: true),
    );
  }
}
