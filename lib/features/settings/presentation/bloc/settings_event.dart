import 'package:equatable/equatable.dart';

/// Settings events using sealed class.
sealed class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

/// Load delivery price.
final class LoadDeliveryPrice extends SettingsEvent {
  const LoadDeliveryPrice();
}

/// Update delivery price.
final class UpdateDeliveryPrice extends SettingsEvent {
  final double price;

  const UpdateDeliveryPrice(this.price);

  @override
  List<Object?> get props => [price];
}

/// Load driver commission.
final class LoadDriverCommission extends SettingsEvent {
  const LoadDriverCommission();
}

/// Update driver commission.
final class UpdateDriverCommission extends SettingsEvent {
  final double rate;

  const UpdateDriverCommission(this.rate);

  @override
  List<Object?> get props => [rate];
}

/// Load all driver commissions.
final class LoadAllDriverCommissions extends SettingsEvent {
  const LoadAllDriverCommissions();
}

/// Update all driver commissions.
final class UpdateAllDriverCommissions extends SettingsEvent {
  final double rate1Order;
  final double rate2Orders;
  final double rate3Orders;
  final double rate4Orders;

  const UpdateAllDriverCommissions({
    required this.rate1Order,
    required this.rate2Orders,
    required this.rate3Orders,
    required this.rate4Orders,
  });

  @override
  List<Object?> get props =>
      [rate1Order, rate2Orders, rate3Orders, rate4Orders];
}
