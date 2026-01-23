import '../../domain/entities/settings_entities.dart';
import '../models/settings_models.dart';
import 'settings_datasource.dart';

/// Mock implementation of SettingsDataSource for development.
class SettingsMockDataSource implements SettingsDataSource {
  late AppSettingsModel _settings;

  SettingsMockDataSource() {
    _settings = _generateMockSettings();
  }

  @override
  Future<AppSettingsModel> getSettings() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _settings;
  }

  @override
  Future<void> updateGeneralSettings(GeneralSettings settings) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _settings = AppSettingsModel(
      id: _settings.id,
      general: GeneralSettingsModel(
        appName: settings.appName,
        appNameAr: settings.appNameAr,
        currency: settings.currency,
        currencySymbol: settings.currencySymbol,
        timezone: settings.timezone,
        supportEmail: settings.supportEmail,
        supportPhone: settings.supportPhone,
        maintenanceMode: settings.maintenanceMode,
      ),
      delivery: _settings.delivery,
      commission: _settings.commission,
      notifications: _settings.notifications,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> updateDeliverySettings(DeliverySettings settings) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _settings = AppSettingsModel(
      id: _settings.id,
      general: _settings.general,
      delivery: DeliverySettingsModel(
        baseDeliveryFee: settings.baseDeliveryFee,
        feePerKilometer: settings.feePerKilometer,
        minimumOrderAmount: settings.minimumOrderAmount,
        freeDeliveryThreshold: settings.freeDeliveryThreshold,
        maxDeliveryRadius: settings.maxDeliveryRadius,
        estimatedDeliveryTime: settings.estimatedDeliveryTime,
        zones: settings.zones,
      ),
      commission: _settings.commission,
      notifications: _settings.notifications,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> updateCommissionSettings(CommissionSettings settings) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _settings = AppSettingsModel(
      id: _settings.id,
      general: _settings.general,
      delivery: _settings.delivery,
      commission: CommissionSettingsModel(
        defaultStoreCommission: settings.defaultStoreCommission,
        defaultDriverCommission: settings.defaultDriverCommission,
        minimumPayout: settings.minimumPayout,
        payoutFrequency: settings.payoutFrequency,
      ),
      notifications: _settings.notifications,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> updateNotificationSettings(NotificationSettings settings) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _settings = AppSettingsModel(
      id: _settings.id,
      general: _settings.general,
      delivery: _settings.delivery,
      commission: _settings.commission,
      notifications: NotificationSettingsModel(
        enablePushNotifications: settings.enablePushNotifications,
        enableEmailNotifications: settings.enableEmailNotifications,
        enableSmsNotifications: settings.enableSmsNotifications,
        notifyOnNewOrder: settings.notifyOnNewOrder,
        notifyOnOrderStatusChange: settings.notifyOnOrderStatusChange,
        notifyOnNewDriver: settings.notifyOnNewDriver,
        notifyOnNewStore: settings.notifyOnNewStore,
      ),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<DeliveryZone> addDeliveryZone(DeliveryZone zone) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final newZone = DeliveryZoneModel(
      id: 'zone_${DateTime.now().millisecondsSinceEpoch}',
      name: zone.name,
      nameAr: zone.nameAr,
      fee: zone.fee,
      isActive: zone.isActive,
    );

    final currentDelivery = _settings.delivery as DeliverySettingsModel;
    final updatedZones = [...currentDelivery.zones, newZone];

    _settings = AppSettingsModel(
      id: _settings.id,
      general: _settings.general,
      delivery: DeliverySettingsModel(
        baseDeliveryFee: currentDelivery.baseDeliveryFee,
        feePerKilometer: currentDelivery.feePerKilometer,
        minimumOrderAmount: currentDelivery.minimumOrderAmount,
        freeDeliveryThreshold: currentDelivery.freeDeliveryThreshold,
        maxDeliveryRadius: currentDelivery.maxDeliveryRadius,
        estimatedDeliveryTime: currentDelivery.estimatedDeliveryTime,
        zones: updatedZones,
      ),
      commission: _settings.commission,
      notifications: _settings.notifications,
      updatedAt: DateTime.now(),
    );

    return newZone;
  }

  @override
  Future<void> updateDeliveryZone(DeliveryZone zone) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final currentDelivery = _settings.delivery as DeliverySettingsModel;
    final updatedZones = currentDelivery.zones.map((z) {
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

    _settings = AppSettingsModel(
      id: _settings.id,
      general: _settings.general,
      delivery: DeliverySettingsModel(
        baseDeliveryFee: currentDelivery.baseDeliveryFee,
        feePerKilometer: currentDelivery.feePerKilometer,
        minimumOrderAmount: currentDelivery.minimumOrderAmount,
        freeDeliveryThreshold: currentDelivery.freeDeliveryThreshold,
        maxDeliveryRadius: currentDelivery.maxDeliveryRadius,
        estimatedDeliveryTime: currentDelivery.estimatedDeliveryTime,
        zones: updatedZones,
      ),
      commission: _settings.commission,
      notifications: _settings.notifications,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> deleteDeliveryZone(String zoneId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final currentDelivery = _settings.delivery as DeliverySettingsModel;
    final updatedZones =
        currentDelivery.zones.where((z) => z.id != zoneId).toList();

    _settings = AppSettingsModel(
      id: _settings.id,
      general: _settings.general,
      delivery: DeliverySettingsModel(
        baseDeliveryFee: currentDelivery.baseDeliveryFee,
        feePerKilometer: currentDelivery.feePerKilometer,
        minimumOrderAmount: currentDelivery.minimumOrderAmount,
        freeDeliveryThreshold: currentDelivery.freeDeliveryThreshold,
        maxDeliveryRadius: currentDelivery.maxDeliveryRadius,
        estimatedDeliveryTime: currentDelivery.estimatedDeliveryTime,
        zones: updatedZones,
      ),
      commission: _settings.commission,
      notifications: _settings.notifications,
      updatedAt: DateTime.now(),
    );
  }
}

AppSettingsModel _generateMockSettings() {
  return AppSettingsModel(
    id: 'default',
    general: const GeneralSettingsModel(
      appName: 'Delivery Admin',
      appNameAr: 'لوحة التحكم للتوصيل',
      currency: 'SAR',
      currencySymbol: 'ر.س',
      timezone: 'Asia/Riyadh',
      supportEmail: 'support@delivery.com',
      supportPhone: '+966500000000',
      maintenanceMode: false,
    ),
    delivery: const DeliverySettingsModel(
      baseDeliveryFee: 10.0,
      feePerKilometer: 2.0,
      minimumOrderAmount: 20.0,
      freeDeliveryThreshold: 100.0,
      maxDeliveryRadius: 20,
      estimatedDeliveryTime: 45,
      zones: [
        DeliveryZoneModel(
          id: 'zone_1',
          name: 'Zone A',
          nameAr: 'المنطقة أ',
          fee: 10.0,
          isActive: true,
        ),
        DeliveryZoneModel(
          id: 'zone_2',
          name: 'Zone B',
          nameAr: 'المنطقة ب',
          fee: 15.0,
          isActive: true,
        ),
        DeliveryZoneModel(
          id: 'zone_3',
          name: 'Zone C',
          nameAr: 'المنطقة ج',
          fee: 20.0,
          isActive: true,
        ),
      ],
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
