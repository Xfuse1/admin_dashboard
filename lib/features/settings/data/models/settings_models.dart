import '../../domain/entities/settings_entities.dart';

/// Model for app settings.
class AppSettingsModel extends AppSettingsEntity {
  const AppSettingsModel({
    required super.id,
    required super.general,
    required super.delivery,
    required super.commission,
    required super.notifications,
    required super.updatedAt,
  });

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) {
    return AppSettingsModel(
      id: json['id'] as String? ?? 'default',
      general: GeneralSettingsModel.fromJson(
        json['general'] as Map<String, dynamic>? ?? {},
      ),
      delivery: DeliverySettingsModel.fromJson(
        json['delivery'] as Map<String, dynamic>? ?? {},
      ),
      commission: CommissionSettingsModel.fromJson(
        json['commission'] as Map<String, dynamic>? ?? {},
      ),
      notifications: NotificationSettingsModel.fromJson(
        json['notifications'] as Map<String, dynamic>? ?? {},
      ),
      updatedAt: json['updatedAt'] is DateTime
          ? json['updatedAt']
          : DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
              DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'general': (general as GeneralSettingsModel).toJson(),
      'delivery': (delivery as DeliverySettingsModel).toJson(),
      'commission': (commission as CommissionSettingsModel).toJson(),
      'notifications': (notifications as NotificationSettingsModel).toJson(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

/// Model for general settings.
class GeneralSettingsModel extends GeneralSettings {
  const GeneralSettingsModel({
    required super.appName,
    required super.appNameAr,
    required super.currency,
    required super.currencySymbol,
    required super.timezone,
    required super.supportEmail,
    required super.supportPhone,
    super.maintenanceMode,
  });

  factory GeneralSettingsModel.fromJson(Map<String, dynamic> json) {
    return GeneralSettingsModel(
      appName: json['appName'] as String? ?? 'Delivery App',
      appNameAr: json['appNameAr'] as String? ?? 'تطبيق التوصيل',
      currency: json['currency'] as String? ?? 'SAR',
      currencySymbol: json['currencySymbol'] as String? ?? 'ر.س',
      timezone: json['timezone'] as String? ?? 'Asia/Riyadh',
      supportEmail: json['supportEmail'] as String? ?? 'support@example.com',
      supportPhone: json['supportPhone'] as String? ?? '+966500000000',
      maintenanceMode: json['maintenanceMode'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appName': appName,
      'appNameAr': appNameAr,
      'currency': currency,
      'currencySymbol': currencySymbol,
      'timezone': timezone,
      'supportEmail': supportEmail,
      'supportPhone': supportPhone,
      'maintenanceMode': maintenanceMode,
    };
  }
}

/// Model for delivery settings.
class DeliverySettingsModel extends DeliverySettings {
  const DeliverySettingsModel({
    required super.baseDeliveryFee,
    required super.feePerKilometer,
    required super.minimumOrderAmount,
    required super.freeDeliveryThreshold,
    required super.maxDeliveryRadius,
    required super.estimatedDeliveryTime,
    super.zones,
  });

  factory DeliverySettingsModel.fromJson(Map<String, dynamic> json) {
    return DeliverySettingsModel(
      baseDeliveryFee: (json['baseDeliveryFee'] as num?)?.toDouble() ?? 10.0,
      feePerKilometer: (json['feePerKilometer'] as num?)?.toDouble() ?? 2.0,
      minimumOrderAmount:
          (json['minimumOrderAmount'] as num?)?.toDouble() ?? 20.0,
      freeDeliveryThreshold:
          (json['freeDeliveryThreshold'] as num?)?.toDouble() ?? 100.0,
      maxDeliveryRadius: json['maxDeliveryRadius'] as int? ?? 20,
      estimatedDeliveryTime: json['estimatedDeliveryTime'] as int? ?? 45,
      zones: (json['zones'] as List<dynamic>?)
              ?.map(
                  (e) => DeliveryZoneModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'baseDeliveryFee': baseDeliveryFee,
      'feePerKilometer': feePerKilometer,
      'minimumOrderAmount': minimumOrderAmount,
      'freeDeliveryThreshold': freeDeliveryThreshold,
      'maxDeliveryRadius': maxDeliveryRadius,
      'estimatedDeliveryTime': estimatedDeliveryTime,
      'zones': zones.map((z) => (z as DeliveryZoneModel).toJson()).toList(),
    };
  }
}

/// Model for delivery zone.
class DeliveryZoneModel extends DeliveryZone {
  const DeliveryZoneModel({
    required super.id,
    required super.name,
    required super.nameAr,
    required super.fee,
    super.isActive,
  });

  factory DeliveryZoneModel.fromJson(Map<String, dynamic> json) {
    return DeliveryZoneModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nameAr: json['nameAr'] as String? ?? '',
      fee: (json['fee'] as num?)?.toDouble() ?? 0.0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameAr': nameAr,
      'fee': fee,
      'isActive': isActive,
    };
  }
}

/// Model for commission settings.
class CommissionSettingsModel extends CommissionSettings {
  const CommissionSettingsModel({
    required super.defaultStoreCommission,
    required super.defaultDriverCommission,
    required super.minimumPayout,
    required super.payoutFrequency,
  });

  factory CommissionSettingsModel.fromJson(Map<String, dynamic> json) {
    return CommissionSettingsModel(
      defaultStoreCommission:
          (json['defaultStoreCommission'] as num?)?.toDouble() ?? 0.15,
      defaultDriverCommission:
          (json['defaultDriverCommission'] as num?)?.toDouble() ?? 0.80,
      minimumPayout: (json['minimumPayout'] as num?)?.toDouble() ?? 100.0,
      payoutFrequency: json['payoutFrequency'] as String? ?? 'weekly',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'defaultStoreCommission': defaultStoreCommission,
      'defaultDriverCommission': defaultDriverCommission,
      'minimumPayout': minimumPayout,
      'payoutFrequency': payoutFrequency,
    };
  }
}

/// Model for notification settings.
class NotificationSettingsModel extends NotificationSettings {
  const NotificationSettingsModel({
    super.enablePushNotifications,
    super.enableEmailNotifications,
    super.enableSmsNotifications,
    super.notifyOnNewOrder,
    super.notifyOnOrderStatusChange,
    super.notifyOnNewDriver,
    super.notifyOnNewStore,
  });

  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsModel(
      enablePushNotifications: json['enablePushNotifications'] as bool? ?? true,
      enableEmailNotifications:
          json['enableEmailNotifications'] as bool? ?? true,
      enableSmsNotifications: json['enableSmsNotifications'] as bool? ?? false,
      notifyOnNewOrder: json['notifyOnNewOrder'] as bool? ?? true,
      notifyOnOrderStatusChange:
          json['notifyOnOrderStatusChange'] as bool? ?? true,
      notifyOnNewDriver: json['notifyOnNewDriver'] as bool? ?? true,
      notifyOnNewStore: json['notifyOnNewStore'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enablePushNotifications': enablePushNotifications,
      'enableEmailNotifications': enableEmailNotifications,
      'enableSmsNotifications': enableSmsNotifications,
      'notifyOnNewOrder': notifyOnNewOrder,
      'notifyOnOrderStatusChange': notifyOnOrderStatusChange,
      'notifyOnNewDriver': notifyOnNewDriver,
      'notifyOnNewStore': notifyOnNewStore,
    };
  }
}
