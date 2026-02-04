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
}
