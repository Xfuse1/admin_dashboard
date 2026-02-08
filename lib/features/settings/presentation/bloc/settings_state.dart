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

class AllDriverCommissionsLoaded extends SettingsState {
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
