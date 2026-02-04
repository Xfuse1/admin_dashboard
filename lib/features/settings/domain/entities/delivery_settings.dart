import 'package:equatable/equatable.dart';

class DeliverySettings extends Equatable {
  final double deliveryPrice;

  const DeliverySettings({required this.deliveryPrice});

  @override
  List<Object?> get props => [deliveryPrice];
}
