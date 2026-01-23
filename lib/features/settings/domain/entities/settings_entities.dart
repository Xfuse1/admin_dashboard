import 'package:equatable/equatable.dart';

/// App settings entity.
class AppSettingsEntity extends Equatable {
  final String id;
  final GeneralSettings general;
  final DeliverySettings delivery;
  final CommissionSettings commission;
  final NotificationSettings notifications;
  final DateTime updatedAt;

  const AppSettingsEntity({
    required this.id,
    required this.general,
    required this.delivery,
    required this.commission,
    required this.notifications,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        general,
        delivery,
        commission,
        notifications,
        updatedAt,
      ];
}

/// General app settings.
class GeneralSettings extends Equatable {
  final String appName;
  final String appNameAr;
  final String currency;
  final String currencySymbol;
  final String timezone;
  final String supportEmail;
  final String supportPhone;
  final bool maintenanceMode;

  const GeneralSettings({
    required this.appName,
    required this.appNameAr,
    required this.currency,
    required this.currencySymbol,
    required this.timezone,
    required this.supportEmail,
    required this.supportPhone,
    this.maintenanceMode = false,
  });

  GeneralSettings copyWith({
    String? appName,
    String? appNameAr,
    String? currency,
    String? currencySymbol,
    String? timezone,
    String? supportEmail,
    String? supportPhone,
    bool? maintenanceMode,
  }) {
    return GeneralSettings(
      appName: appName ?? this.appName,
      appNameAr: appNameAr ?? this.appNameAr,
      currency: currency ?? this.currency,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      timezone: timezone ?? this.timezone,
      supportEmail: supportEmail ?? this.supportEmail,
      supportPhone: supportPhone ?? this.supportPhone,
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
    );
  }

  @override
  List<Object?> get props => [
        appName,
        appNameAr,
        currency,
        currencySymbol,
        timezone,
        supportEmail,
        supportPhone,
        maintenanceMode,
      ];
}

/// Delivery settings.
class DeliverySettings extends Equatable {
  final double baseDeliveryFee;
  final double feePerKilometer;
  final double minimumOrderAmount;
  final double freeDeliveryThreshold;
  final int maxDeliveryRadius; // in km
  final int estimatedDeliveryTime; // in minutes
  final List<DeliveryZone> zones;

  const DeliverySettings({
    required this.baseDeliveryFee,
    required this.feePerKilometer,
    required this.minimumOrderAmount,
    required this.freeDeliveryThreshold,
    required this.maxDeliveryRadius,
    required this.estimatedDeliveryTime,
    this.zones = const [],
  });

  DeliverySettings copyWith({
    double? baseDeliveryFee,
    double? feePerKilometer,
    double? minimumOrderAmount,
    double? freeDeliveryThreshold,
    int? maxDeliveryRadius,
    int? estimatedDeliveryTime,
    List<DeliveryZone>? zones,
  }) {
    return DeliverySettings(
      baseDeliveryFee: baseDeliveryFee ?? this.baseDeliveryFee,
      feePerKilometer: feePerKilometer ?? this.feePerKilometer,
      minimumOrderAmount: minimumOrderAmount ?? this.minimumOrderAmount,
      freeDeliveryThreshold:
          freeDeliveryThreshold ?? this.freeDeliveryThreshold,
      maxDeliveryRadius: maxDeliveryRadius ?? this.maxDeliveryRadius,
      estimatedDeliveryTime:
          estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      zones: zones ?? this.zones,
    );
  }

  @override
  List<Object?> get props => [
        baseDeliveryFee,
        feePerKilometer,
        minimumOrderAmount,
        freeDeliveryThreshold,
        maxDeliveryRadius,
        estimatedDeliveryTime,
        zones,
      ];
}

/// Delivery zone.
class DeliveryZone extends Equatable {
  final String id;
  final String name;
  final String nameAr;
  final double fee;
  final bool isActive;

  const DeliveryZone({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.fee,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, name, nameAr, fee, isActive];
}

/// Commission settings.
class CommissionSettings extends Equatable {
  final double defaultStoreCommission;
  final double defaultDriverCommission;
  final double minimumPayout;
  final String payoutFrequency; // daily, weekly, monthly

  const CommissionSettings({
    required this.defaultStoreCommission,
    required this.defaultDriverCommission,
    required this.minimumPayout,
    required this.payoutFrequency,
  });

  CommissionSettings copyWith({
    double? defaultStoreCommission,
    double? defaultDriverCommission,
    double? minimumPayout,
    String? payoutFrequency,
  }) {
    return CommissionSettings(
      defaultStoreCommission:
          defaultStoreCommission ?? this.defaultStoreCommission,
      defaultDriverCommission:
          defaultDriverCommission ?? this.defaultDriverCommission,
      minimumPayout: minimumPayout ?? this.minimumPayout,
      payoutFrequency: payoutFrequency ?? this.payoutFrequency,
    );
  }

  @override
  List<Object?> get props => [
        defaultStoreCommission,
        defaultDriverCommission,
        minimumPayout,
        payoutFrequency,
      ];
}

/// Notification settings.
class NotificationSettings extends Equatable {
  final bool enablePushNotifications;
  final bool enableEmailNotifications;
  final bool enableSmsNotifications;
  final bool notifyOnNewOrder;
  final bool notifyOnOrderStatusChange;
  final bool notifyOnNewDriver;
  final bool notifyOnNewStore;

  const NotificationSettings({
    this.enablePushNotifications = true,
    this.enableEmailNotifications = true,
    this.enableSmsNotifications = false,
    this.notifyOnNewOrder = true,
    this.notifyOnOrderStatusChange = true,
    this.notifyOnNewDriver = true,
    this.notifyOnNewStore = true,
  });

  NotificationSettings copyWith({
    bool? enablePushNotifications,
    bool? enableEmailNotifications,
    bool? enableSmsNotifications,
    bool? notifyOnNewOrder,
    bool? notifyOnOrderStatusChange,
    bool? notifyOnNewDriver,
    bool? notifyOnNewStore,
  }) {
    return NotificationSettings(
      enablePushNotifications:
          enablePushNotifications ?? this.enablePushNotifications,
      enableEmailNotifications:
          enableEmailNotifications ?? this.enableEmailNotifications,
      enableSmsNotifications:
          enableSmsNotifications ?? this.enableSmsNotifications,
      notifyOnNewOrder: notifyOnNewOrder ?? this.notifyOnNewOrder,
      notifyOnOrderStatusChange:
          notifyOnOrderStatusChange ?? this.notifyOnOrderStatusChange,
      notifyOnNewDriver: notifyOnNewDriver ?? this.notifyOnNewDriver,
      notifyOnNewStore: notifyOnNewStore ?? this.notifyOnNewStore,
    );
  }

  @override
  List<Object?> get props => [
        enablePushNotifications,
        enableEmailNotifications,
        enableSmsNotifications,
        notifyOnNewOrder,
        notifyOnOrderStatusChange,
        notifyOnNewDriver,
        notifyOnNewStore,
      ];
}
