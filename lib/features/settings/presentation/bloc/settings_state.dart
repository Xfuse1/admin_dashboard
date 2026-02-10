import 'package:equatable/equatable.dart';

/// Settings states using sealed class.
sealed class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object> get props => [];
}

/// Initial state.
final class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

/// Loading state.
final class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

/// Delivery settings loaded.
final class DeliverySettingsLoaded extends SettingsState {
  final double deliveryPrice;

  const DeliverySettingsLoaded(this.deliveryPrice);

  @override
  List<Object> get props => [deliveryPrice];
}

/// Driver commission loaded.
final class DriverCommissionLoaded extends SettingsState {
  final double commissionRate;

  const DriverCommissionLoaded(this.commissionRate);

  @override
  List<Object> get props => [commissionRate];
}

/// All driver commissions loaded.
final class AllDriverCommissionsLoaded extends SettingsState {
  final double rate1Order;
  final double rate2Orders;
  final double rate3Orders;
  final double rate4Orders;

  const AllDriverCommissionsLoaded({
    required this.rate1Order,
    required this.rate2Orders,
    required this.rate3Orders,
    required this.rate4Orders,
  });

  @override
  List<Object> get props => [rate1Order, rate2Orders, rate3Orders, rate4Orders];
}

/// Error state.
final class SettingsError extends SettingsState {
  final String message;

  const SettingsError(this.message);

  @override
  List<Object> get props => [message];
}

/// Success state.
final class SettingsSuccess extends SettingsState {
  final String message;

  const SettingsSuccess(this.message);

  @override
  List<Object> get props => [message];
}
