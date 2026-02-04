import '../../domain/entities/delivery_settings.dart';

class DeliverySettingsModel extends DeliverySettings {
  const DeliverySettingsModel({required super.deliveryPrice});

  factory DeliverySettingsModel.fromMap(Map<String, dynamic> map) {
    return DeliverySettingsModel(
      deliveryPrice: (map['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'price': deliveryPrice,
    };
  }
}
