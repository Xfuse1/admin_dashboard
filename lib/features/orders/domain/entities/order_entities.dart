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

/// Type of order — single store or multi-store with pickup stops.
enum OrderType {
  singleStore('single_store', 'متجر واحد'),
  multiStore('multi_store', 'متعدد المتاجر');

  final String value;
  final String arabicName;

  const OrderType(this.value, this.arabicName);

  static OrderType fromValue(String? value) {
    if (value == 'multi_store') return OrderType.multiStore;
    return OrderType.singleStore;
  }
}

/// Status of a single pickup stop within a multi-store order.
enum PickupStopStatus {
  pending('pending', 'قيد الانتظار'),
  confirmed('confirmed', 'تم التأكيد'),
  pickedUp('picked_up', 'تم الاستلام'),
  rejected('rejected', 'مرفوض');

  final String value;
  final String arabicName;

  const PickupStopStatus(this.value, this.arabicName);

  static PickupStopStatus fromValue(String value) {
    return PickupStopStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => PickupStopStatus.pending,
    );
  }
}

/// A single pickup stop in a multi-store order.
///
/// Each stop represents one store the driver needs to visit.
class PickupStop extends Equatable {
  final String storeId;
  final String storeName;
  final double subtotal;
  final PickupStopStatus status;
  final List<OrderItem> items;
  final DateTime? confirmedAt;
  final DateTime? pickedUpAt;
  final DateTime? rejectedAt;
  final String? rejectionReason;

  const PickupStop({
    required this.storeId,
    required this.storeName,
    required this.subtotal,
    this.status = PickupStopStatus.pending,
    this.items = const [],
    this.confirmedAt,
    this.pickedUpAt,
    this.rejectedAt,
    this.rejectionReason,
  });

  /// Whether this stop has been picked up.
  bool get isPickedUp => status == PickupStopStatus.pickedUp;

  /// Whether this stop was rejected.
  bool get isRejected => status == PickupStopStatus.rejected;

  /// Whether this stop is still active (pending or confirmed).
  bool get isActive =>
      status == PickupStopStatus.pending ||
      status == PickupStopStatus.confirmed;

  @override
  List<Object?> get props => [storeId, status, subtotal];
}

/// Order entity representing a delivery order.
///
/// This entity is designed to be compatible with both Admin Dashboard
/// and Deliverzler order structures. Supports both single-store and
/// multi-store orders with pickup stops.
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

  /// Store ID (optional - for single-store orders or legacy orders).
  final String? storeId;

  /// Store name (optional - for single-store orders or legacy orders).
  final String? storeName;

  /// Assigned driver/delivery ID.
  final String? driverId;

  /// Assigned driver name (optional).
  final String? driverName;

  /// Driver's current location latitude.
  final double? driverLatitude;

  /// Driver's current location longitude.
  final double? driverLongitude;

  /// Order items list (for single-store orders or legacy orders).
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

  /// Order type — single store or multi-store.
  final OrderType orderType;

  /// Pickup stops for multi-store orders.
  final List<PickupStop> pickupStops;

  /// Driver commission for the delivery.
  final double? driverCommission;

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
    this.orderType = OrderType.singleStore,
    this.pickupStops = const [],
    this.driverCommission,
  });

  /// Whether this is a multi-store order.
  bool get isMultiStore => orderType == OrderType.multiStore;

  /// Returns all items: from pickup stops for multi-store, or direct items otherwise.
  List<OrderItem> get allItems {
    if (!isMultiStore || pickupStops.isEmpty) return items;
    return pickupStops.expand((stop) => stop.items).toList();
  }

  /// Number of stores involved (from pickup stops).
  int get storeCount =>
      isMultiStore ? pickupStops.length : (storeId != null ? 1 : 0);

  /// Number of picked up stops.
  int get pickedUpStopsCount =>
      pickupStops.where((stop) => stop.isPickedUp).length;

  /// Number of active (non-rejected) stops.
  int get activeStopsCount =>
      pickupStops.where((stop) => !stop.isRejected).length;

  /// Whether all non-rejected stores have been picked up.
  bool get allStoresPickedUp {
    if (!isMultiStore || pickupStops.isEmpty) return false;
    return pickupStops
        .where((stop) => !stop.isRejected)
        .every((stop) => stop.isPickedUp);
  }

  /// Returns the formatted delivery address.
  String get formattedAddress => deliveryAddressString ?? address.formatted;

  /// Returns whether this order has driver location data.
  bool get hasDriverLocation =>
      driverLatitude != null && driverLongitude != null;

  /// Returns all unique store IDs from this order.
  List<String> get allStoreIds {
    if (isMultiStore) {
      return pickupStops.map((s) => s.storeId).toList();
    }
    return storeId != null ? [storeId!] : [];
  }

  /// Revenue for a specific store from this order.
  double revenueForStore(String targetStoreId) {
    if (isMultiStore) {
      final stop = pickupStops.where((s) => s.storeId == targetStoreId);
      if (stop.isEmpty) return 0;
      return stop.first.subtotal;
    }
    if (storeId == targetStoreId) return subtotal ?? 0;
    return 0;
  }

  /// Whether this order involves a specific store.
  bool involvesStore(String targetStoreId) {
    if (isMultiStore) {
      return pickupStops.any((s) => s.storeId == targetStoreId);
    }
    return storeId == targetStoreId;
  }

  @override
  List<Object?> get props => [
        id,
        customerId,
        storeId,
        driverId,
        status,
        total,
        createdAt,
        orderType,
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
  final String? category;

  /// Store name that this item belongs to.
  final String? storeName;

  const OrderItem({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.quantity,
    required this.price,
    required this.total,
    this.notes,
    this.category,
    this.storeName,
  });

  @override
  List<Object?> get props =>
      [id, name, quantity, price, total, category, storeName];
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
