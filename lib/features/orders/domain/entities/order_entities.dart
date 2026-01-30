import 'package:equatable/equatable.dart';

/// Pickup option for an order.
///
/// Matches Deliverzler's PickupOption enum.
enum PickupOption {
  delivery('delivery', 'توصيل'),
  pickUp('pickUp', 'استلام'),
  diningRoom('diningRoom', 'تناول في المطعم');

  final String value;
  final String arabicName;

  const PickupOption(this.value, this.arabicName);

  /// Creates a [PickupOption] from Firestore value.
  static PickupOption fromValue(String value) {
    return PickupOption.values.firstWhere(
      (option) => option.value == value,
      orElse: () => PickupOption.delivery,
    );
  }
}

/// Address details for delivery.
///
/// Matches Deliverzler's addressModel structure.
class DeliveryAddress extends Equatable {
  final String state;
  final String city;
  final String street;
  final String mobile;
  final double? latitude;
  final double? longitude;

  const DeliveryAddress({
    required this.state,
    required this.city,
    required this.street,
    required this.mobile,
    this.latitude,
    this.longitude,
  });

  /// Returns formatted address string.
  String get formatted => '$street, $city, $state';

  /// Returns full address string (alias for formatted).
  String get fullAddress => formatted;

  /// Creates an empty address.
  static const DeliveryAddress empty = DeliveryAddress(
    state: '',
    city: '',
    street: '',
    mobile: '',
  );

  @override
  List<Object?> get props => [state, city, street, mobile, latitude, longitude];
}

/// Order entity representing a delivery order.
///
/// This entity is designed to be compatible with both Admin Dashboard
/// and Deliverzler order structures.
class OrderEntity extends Equatable {
  /// Unique order identifier.
  final String id;

  /// Customer/User ID who placed the order.
  final String customerId;

  /// Customer/User name.
  final String customerName;

  /// Customer/User phone number.
  final String customerPhone;

  /// Customer/User profile image URL.
  final String? customerImage;

  /// Store ID (optional - may not exist in Deliverzler orders).
  final String? storeId;

  /// Store name (optional - may not exist in Deliverzler orders).
  final String? storeName;

  /// Assigned driver/delivery ID.
  final String? driverId;

  /// Assigned driver name (optional).
  final String? driverName;

  /// Driver's current location latitude.
  final double? driverLatitude;

  /// Driver's current location longitude.
  final double? driverLongitude;

  /// Order items list (optional - may not exist in Deliverzler orders).
  final List<OrderItem> items;

  /// Current order status.
  final OrderStatus status;

  /// Pickup option for the order.
  final PickupOption pickupOption;

  /// Payment method used.
  final String paymentMethod;

  /// Order subtotal (optional).
  final double? subtotal;

  /// Delivery fee (optional).
  final double? deliveryFee;

  /// Order total (optional).
  final double? total;

  /// Delivery address details.
  final DeliveryAddress address;

  /// Legacy delivery address string (for backwards compatibility).
  final String? deliveryAddressString;

  /// Order timeline entries (optional).
  final List<OrderTimeline> timeline;

  /// Customer's note for the order.
  final String? customerNote;

  /// Employee's cancellation note.
  final String? employeeCancelNote;

  /// Order creation timestamp.
  final DateTime createdAt;

  /// Order last update timestamp.
  final DateTime updatedAt;

  const OrderEntity({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    this.customerImage,
    this.storeId,
    this.storeName,
    this.driverId,
    this.driverName,
    this.driverLatitude,
    this.driverLongitude,
    this.items = const [],
    required this.status,
    this.pickupOption = PickupOption.delivery,
    this.paymentMethod = 'cash',
    this.subtotal,
    this.deliveryFee,
    this.total,
    this.address = DeliveryAddress.empty,
    this.deliveryAddressString,
    this.timeline = const [],
    this.customerNote,
    this.employeeCancelNote,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Returns the formatted delivery address.
  String get formattedAddress => deliveryAddressString ?? address.formatted;

  /// Returns whether this order has driver location data.
  bool get hasDriverLocation =>
      driverLatitude != null && driverLongitude != null;

  @override
  List<Object?> get props => [
        id,
        customerId,
        storeId,
        driverId,
        status,
        total,
        createdAt,
      ];
}

/// Order item within an order.
class OrderItem extends Equatable {
  final String id;
  final String name;
  final String? imageUrl;
  final int quantity;
  final double price;
  final double total;
  final String? notes;

  const OrderItem({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.quantity,
    required this.price,
    required this.total,
    this.notes,
  });

  @override
  List<Object?> get props => [id, name, quantity, price, total];
}

/// Order timeline entry.
class OrderTimeline extends Equatable {
  final OrderStatus status;
  final DateTime timestamp;
  final String? note;

  const OrderTimeline({
    required this.status,
    required this.timestamp,
    this.note,
  });

  @override
  List<Object?> get props => [status, timestamp];
}

/// Order status enumeration.
///
/// Values are designed to be compatible with Deliverzler's DeliveryStatus.
/// Includes mapping for legacy values.
enum OrderStatus {
  pending('pending', 'قيد الانتظار'),
  confirmed('confirmed', 'تم التأكيد'),
  preparing('preparing', 'قيد التجهيز'),
  ready('ready', 'جاهز'),
  pickedUp('picked_up', 'تم الاستلام'),
  onTheWay('on_the_way', 'في الطريق'),
  delivered('delivered', 'تم التسليم'),
  cancelled('cancelled', 'ملغي');

  final String value;
  final String arabicName;

  const OrderStatus(this.value, this.arabicName);

  /// Creates an [OrderStatus] from Firestore value.
  ///
  /// Handles both new and legacy Deliverzler values:
  /// - 'upcoming' → confirmed
  /// - 'onTheWay' → onTheWay
  /// - 'canceled' → cancelled
  static OrderStatus fromValue(String value) {
    // Handle legacy Deliverzler values
    final mappedValue = _legacyMapping[value] ?? value;

    return OrderStatus.values.firstWhere(
      (status) => status.value == mappedValue,
      orElse: () => OrderStatus.pending,
    );
  }

  /// Mapping from legacy Deliverzler values to new unified values.
  static const Map<String, String> _legacyMapping = {
    'upcoming': 'preparing',
    'onTheWay': 'on_the_way',
    'canceled': 'cancelled',
  };

  /// Returns whether this status represents an active order.
  bool get isActive => [
        OrderStatus.pending,
        OrderStatus.confirmed,
        OrderStatus.preparing,
        OrderStatus.ready,
        OrderStatus.pickedUp,
        OrderStatus.onTheWay,
      ].contains(this);

  /// Returns whether this order has been completed.
  bool get isCompleted => this == OrderStatus.delivered;

  /// Returns whether this order has been cancelled.
  bool get isCancelled => this == OrderStatus.cancelled;

  /// Returns whether this order is waiting for driver pickup.
  bool get isWaitingForDriver => [
        OrderStatus.ready,
      ].contains(this);

  /// Returns whether this order is in delivery phase.
  bool get isInDelivery => [
        OrderStatus.pickedUp,
        OrderStatus.onTheWay,
      ].contains(this);
}
