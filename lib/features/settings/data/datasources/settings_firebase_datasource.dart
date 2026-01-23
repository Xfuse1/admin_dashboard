import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firebase/firebase_service.dart';
import '../../domain/entities/settings_entities.dart';
import '../models/settings_models.dart';
import 'settings_datasource.dart';

/// Firebase implementation of SettingsDataSource.
///
/// Stores and retrieves app settings from Firestore.
/// Collection: 'settings', Document: 'app_config'
class SettingsFirebaseDataSource implements SettingsDataSource {
  final FirebaseFirestore _firestore;

  /// Settings document reference for quick access.
  late final DocumentReference<Map<String, dynamic>> _settingsDoc;

  SettingsFirebaseDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance {
    _settingsDoc =
        _firestore.collection(FirestoreCollections.settings).doc('app_config');
  }

  @override
  Future<AppSettingsModel> getSettings() async {
    final doc = await _settingsDoc.get();

    if (!doc.exists) {
      // Create default settings if not exists
      final defaultSettings = _createDefaultSettings();
      await _settingsDoc.set(defaultSettings.toJson());
      return defaultSettings;
    }

    final data = doc.data()!;
    data['id'] = doc.id;
    return AppSettingsModel.fromJson(data);
  }

  @override
  Future<void> updateGeneralSettings(GeneralSettings settings) async {
    final generalModel = GeneralSettingsModel(
      appName: settings.appName,
      appNameAr: settings.appNameAr,
      currency: settings.currency,
      currencySymbol: settings.currencySymbol,
      timezone: settings.timezone,
      supportEmail: settings.supportEmail,
      supportPhone: settings.supportPhone,
      maintenanceMode: settings.maintenanceMode,
    );

    await _settingsDoc.update({
      'general': generalModel.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateDeliverySettings(DeliverySettings settings) async {
    final deliveryModel = DeliverySettingsModel(
      baseDeliveryFee: settings.baseDeliveryFee,
      feePerKilometer: settings.feePerKilometer,
      minimumOrderAmount: settings.minimumOrderAmount,
      freeDeliveryThreshold: settings.freeDeliveryThreshold,
      maxDeliveryRadius: settings.maxDeliveryRadius,
      estimatedDeliveryTime: settings.estimatedDeliveryTime,
      zones: settings.zones
          .map((z) => DeliveryZoneModel(
                id: z.id,
                name: z.name,
                nameAr: z.nameAr,
                fee: z.fee,
                isActive: z.isActive,
              ))
          .toList(),
    );

    await _settingsDoc.update({
      'delivery': deliveryModel.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateCommissionSettings(CommissionSettings settings) async {
    final commissionModel = CommissionSettingsModel(
      defaultStoreCommission: settings.defaultStoreCommission,
      defaultDriverCommission: settings.defaultDriverCommission,
      minimumPayout: settings.minimumPayout,
      payoutFrequency: settings.payoutFrequency,
    );

    await _settingsDoc.update({
      'commission': commissionModel.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateNotificationSettings(NotificationSettings settings) async {
    final notificationModel = NotificationSettingsModel(
      enablePushNotifications: settings.enablePushNotifications,
      enableEmailNotifications: settings.enableEmailNotifications,
      enableSmsNotifications: settings.enableSmsNotifications,
      notifyOnNewOrder: settings.notifyOnNewOrder,
      notifyOnOrderStatusChange: settings.notifyOnOrderStatusChange,
      notifyOnNewDriver: settings.notifyOnNewDriver,
      notifyOnNewStore: settings.notifyOnNewStore,
    );

    await _settingsDoc.update({
      'notifications': notificationModel.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<DeliveryZone> addDeliveryZone(DeliveryZone zone) async {
    final newZone = DeliveryZoneModel(
      id: 'zone_${DateTime.now().millisecondsSinceEpoch}',
      name: zone.name,
      nameAr: zone.nameAr,
      fee: zone.fee,
      isActive: zone.isActive,
    );

    // Get current settings
    final currentSettings = await getSettings();
    final currentZones = currentSettings.delivery.zones;
    final updatedZones = [...currentZones, newZone];

    // Update with new zone
    await _settingsDoc.update({
      'delivery.zones': updatedZones.map((z) {
        if (z is DeliveryZoneModel) {
          return z.toJson();
        }
        return DeliveryZoneModel(
          id: z.id,
          name: z.name,
          nameAr: z.nameAr,
          fee: z.fee,
          isActive: z.isActive,
        ).toJson();
      }).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return newZone;
  }

  @override
  Future<void> updateDeliveryZone(DeliveryZone zone) async {
    final currentSettings = await getSettings();
    final updatedZones = currentSettings.delivery.zones.map((z) {
      if (z.id == zone.id) {
        return DeliveryZoneModel(
          id: zone.id,
          name: zone.name,
          nameAr: zone.nameAr,
          fee: zone.fee,
          isActive: zone.isActive,
        );
      }
      return z;
    }).toList();

    await _settingsDoc.update({
      'delivery.zones': updatedZones.map((z) {
        if (z is DeliveryZoneModel) {
          return z.toJson();
        }
        return DeliveryZoneModel(
          id: z.id,
          name: z.name,
          nameAr: z.nameAr,
          fee: z.fee,
          isActive: z.isActive,
        ).toJson();
      }).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteDeliveryZone(String zoneId) async {
    final currentSettings = await getSettings();
    final updatedZones =
        currentSettings.delivery.zones.where((z) => z.id != zoneId).toList();

    await _settingsDoc.update({
      'delivery.zones': updatedZones.map((z) {
        if (z is DeliveryZoneModel) {
          return z.toJson();
        }
        return DeliveryZoneModel(
          id: z.id,
          name: z.name,
          nameAr: z.nameAr,
          fee: z.fee,
          isActive: z.isActive,
        ).toJson();
      }).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Creates default settings for first-time setup.
  AppSettingsModel _createDefaultSettings() {
    return AppSettingsModel(
      id: 'app_config',
      general: const GeneralSettingsModel(
        appName: 'Delivery Admin',
        appNameAr: 'لوحة تحكم التوصيل',
        currency: 'EGP',
        currencySymbol: 'ج.م',
        timezone: 'Africa/Cairo',
        supportEmail: 'support@delivery.com',
        supportPhone: '+201000000000',
        maintenanceMode: false,
      ),
      delivery: const DeliverySettingsModel(
        baseDeliveryFee: 15.0,
        feePerKilometer: 3.0,
        minimumOrderAmount: 30.0,
        freeDeliveryThreshold: 150.0,
        maxDeliveryRadius: 25,
        estimatedDeliveryTime: 45,
        zones: [],
      ),
      commission: const CommissionSettingsModel(
        defaultStoreCommission: 0.15,
        defaultDriverCommission: 0.80,
        minimumPayout: 100.0,
        payoutFrequency: 'weekly',
      ),
      notifications: const NotificationSettingsModel(
        enablePushNotifications: true,
        enableEmailNotifications: true,
        enableSmsNotifications: false,
        notifyOnNewOrder: true,
        notifyOnOrderStatusChange: true,
        notifyOnNewDriver: true,
        notifyOnNewStore: true,
      ),
      updatedAt: DateTime.now(),
    );
  }
}
