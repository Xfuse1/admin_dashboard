part of 'settings_cubit.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class DeliverySettingsLoaded extends SettingsState {
  final double deliveryPrice;

  const DeliverySettingsLoaded(this.deliveryPrice);

  @override
  List<Object> get props => [deliveryPrice];
}

class DriverCommissionLoaded extends SettingsState {
  final double commissionRate;

  const DriverCommissionLoaded(this.commissionRate);

  @override
  List<Object> get props => [commissionRate];
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError(this.message);

  @override
  List<Object> get props => [message];
}

class SettingsSuccess extends SettingsState {
  final String message;

  const SettingsSuccess(this.message);

  @override
  List<Object> get props => [message];
}
