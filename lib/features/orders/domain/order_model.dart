import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Order status enum
enum DeliveryStatus {
  pending('pending', 'قيد الانتظار'),
  upcoming('upcoming', 'قادم'),
  onTheWay('onTheWay', 'في الطريق'),
  delivered('delivered', 'تم التوصيل'),
  canceled('canceled', 'ملغي');

  const DeliveryStatus(this.value, this.arabicName);
  final String value;
  final String arabicName;

  static DeliveryStatus fromString(String value) {
    return DeliveryStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => DeliveryStatus.pending,
    );
  }
}

/// Pickup option enum
enum PickupOption {
  delivery('delivery', 'توصيل'),
  pickUp('pickUp', 'استلام'),
  diningRoom('diningRoom', 'طعام في المطعم');

  const PickupOption(this.value, this.arabicName);
  final String value;
  final String arabicName;

  static PickupOption fromString(String value) {
    return PickupOption.values.firstWhere(
      (option) => option.value == value,
      orElse: () => PickupOption.delivery,
    );
  }
}

/// Address model
class Address extends Equatable {
  final String state;
  final String city;
  final String street;
  final String mobile;
  final GeoPoint? geoPoint;

  const Address({
    required this.state,
    required this.city,
    required this.street,
    required this.mobile,
    this.geoPoint,
  });

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      state: map['state'] ?? '',
      city: map['city'] ?? '',
      street: map['street'] ?? '',
      mobile: map['mobile'] ?? '',
      geoPoint: map['geoPoint'] as GeoPoint?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'state': state,
      'city': city,
      'street': street,
      'mobile': mobile,
      'geoPoint': geoPoint,
    };
  }

  @override
  List<Object?> get props => [state, city, street, mobile, geoPoint];
}

/// Order model
class AppOrder extends Equatable {
  final String id;
  final int date;
  final PickupOption pickupOption;
  final String paymentMethod;
  final Address? address;
  final String userId;
  final String userName;
  final String userImage;
  final String userPhone;
  final String userNote;
  final String? employeeCancelNote;
  final DeliveryStatus deliveryStatus;
  final String? deliveryId;
  final String? deliveryName;
  final GeoPoint? deliveryGeoPoint;

  const AppOrder({
    required this.id,
    required this.date,
    required this.pickupOption,
    required this.paymentMethod,
    this.address,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.userPhone,
    required this.userNote,
    this.employeeCancelNote,
    required this.deliveryStatus,
    this.deliveryId,
    this.deliveryName,
    this.deliveryGeoPoint,
  });

  factory AppOrder.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppOrder(
      id: doc.id,
      date: data['date'] ?? 0,
      pickupOption: PickupOption.fromString(data['pickupOption'] ?? ''),
      paymentMethod: data['paymentMethod'] ?? '',
      address:
          data['address'] != null ? Address.fromMap(data['address']) : null,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userImage: data['userImage'] ?? '',
      userPhone: data['userPhone'] ?? '',
      userNote: data['userNote'] ?? '',
      employeeCancelNote: data['employeeCancelNote'],
      deliveryStatus: DeliveryStatus.fromString(data['deliveryStatus'] ?? ''),
      deliveryId: data['deliveryId'],
      deliveryName: data['deliveryName'],
      deliveryGeoPoint: data['deliveryGeoPoint'] as GeoPoint?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'pickupOption': pickupOption.value,
      'paymentMethod': paymentMethod,
      'address': address?.toMap(),
      'userId': userId,
      'userName': userName,
      'userImage': userImage,
      'userPhone': userPhone,
      'userNote': userNote,
      'employeeCancelNote': employeeCancelNote,
      'deliveryStatus': deliveryStatus.value,
      'deliveryId': deliveryId,
      'deliveryName': deliveryName,
      'deliveryGeoPoint': deliveryGeoPoint,
    };
  }

  AppOrder copyWith({
    DeliveryStatus? deliveryStatus,
    String? deliveryId,
    String? deliveryName,
    String? employeeCancelNote,
  }) {
    return AppOrder(
      id: id,
      date: date,
      pickupOption: pickupOption,
      paymentMethod: paymentMethod,
      address: address,
      userId: userId,
      userName: userName,
      userImage: userImage,
      userPhone: userPhone,
      userNote: userNote,
      employeeCancelNote: employeeCancelNote ?? this.employeeCancelNote,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      deliveryId: deliveryId ?? this.deliveryId,
      deliveryName: deliveryName ?? this.deliveryName,
      deliveryGeoPoint: deliveryGeoPoint,
    );
  }

  @override
  List<Object?> get props => [
        id,
        date,
        pickupOption,
        paymentMethod,
        address,
        userId,
        userName,
        userImage,
        userPhone,
        userNote,
        employeeCancelNote,
        deliveryStatus,
        deliveryId,
        deliveryName,
      ];
}
