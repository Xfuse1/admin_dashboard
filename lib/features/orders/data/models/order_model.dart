import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/order_entities.dart';

/// Order model for data layer.
///
/// Supports both Admin Dashboard format and Deliverzler format through
/// separate factory constructors.
class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.customerId,
    required super.customerName,
    required super.customerPhone,
    super.customerImage,
    super.storeId,
    super.storeName,
    super.driverId,
    super.driverName,
    super.driverLatitude,
    super.driverLongitude,
    super.items = const [],
    required super.status,
    super.pickupOption = PickupOption.delivery,
    super.paymentMethod = 'cash',
    super.subtotal,
    super.deliveryFee,
    super.total,
    super.address = DeliveryAddress.empty,
    super.deliveryAddressString,
    super.timeline = const [],
    super.customerNote,
    super.employeeCancelNote,
    required super.createdAt,
    required super.updatedAt,
    super.orderType = OrderType.singleStore,
    super.pickupStops = const [],
    super.driverCommission,
  });

  /// Creates an [OrderModel] from Deliverzler Firestore document.
  ///
  /// This factory handles the field mapping from Deliverzler's format:
  /// - customer_id → customerId
  /// - customer_name → customerName
  /// - customer_phone → customerPhone
  /// - customer_image → customerImage
  /// - driver_id → driverId
  /// - status → status
  /// - created_at (ISO string) → createdAt (DateTime)
  /// - delivery_address, delivery_city, delivery_state → address
  factory OrderModel.fromDeliverzler(
    Map<String, dynamic> json, {
    required String documentId,
  }) {
    // Parse address from separate fields (new schema)
    final address = DeliveryAddressModel(
      state: json['delivery_state'] as String? ?? '',
      city: json['delivery_city'] as String? ?? '',
      street: json['delivery_address'] as String? ?? '',
      mobile: json['customer_phone'] as String? ?? '',
      latitude: (json['delivery_latitude'] as num?)?.toDouble(),
      longitude: (json['delivery_longitude'] as num?)?.toDouble(),
    );

    // Parse driver's GeoPoint
    final geoPoint = json['deliveryGeoPoint'] as GeoPoint?;

    // Parse date - handle both old (date as int) and new (created_at as ISO string)
    DateTime createdAt = DateTime.now();
    if (json['created_at'] != null) {
      try {
        createdAt = DateTime.parse(json['created_at'] as String);
      } catch (e) {
        // Fallback to date field if created_at parse fails
        final dateTimestamp = json['date'] as int?;
        if (dateTimestamp != null) {
          createdAt = DateTime.fromMillisecondsSinceEpoch(dateTimestamp);
        }
      }
    } else {
      final dateTimestamp = json['date'] as int?;
      if (dateTimestamp != null) {
        createdAt = DateTime.fromMillisecondsSinceEpoch(dateTimestamp);
      }
    }

    // Parse updated_at - fallback to created_at if not available
    DateTime updatedAt = createdAt;
    if (json['updated_at'] != null) {
      try {
        updatedAt = DateTime.parse(json['updated_at'] as String);
      } catch (e) {
        // Use createdAt if parse fails
      }
    }

    // Parse order type and pickup stops
    final orderType = OrderType.fromValue(json['order_type'] as String?);
    final pickupStops = PickupStopModel.parseList(
      json['pickup_stops'] as List<dynamic>?,
    );
    final driverCommission = (json['driver_commission'] as num?)?.toDouble();

    // For multi_store orders, flatten items from pickup_stops
    List<OrderItem> items;
    if (orderType == OrderType.multiStore && pickupStops.isNotEmpty) {
      items = pickupStops.expand((stop) => stop.items).toList();
    } else {
      items = (json['items'] as List<dynamic>?)
              ?.map((item) =>
                  OrderItemModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          const [];
    }

    return OrderModel(
      id: documentId,
      customerId: json['customer_id'] as String? ?? '',
      customerName: json['customer_name'] as String? ?? '',
      customerPhone: json['customer_phone'] as String? ?? '',
      customerImage: json['customer_image'] as String?,
      storeId: json['store_id'] as String?,
      storeName: null,
      driverId: json['driver_id'] as String?,
      driverName: json['driver_name'] as String?,
      driverLatitude:
          geoPoint?.latitude ?? (json['delivery_latitude'] as num?)?.toDouble(),
      driverLongitude: geoPoint?.longitude ??
          (json['delivery_longitude'] as num?)?.toDouble(),
      items: items,
      status: OrderStatus.fromValue(
        json['status'] as String? ?? 'pending',
      ),
      pickupOption: PickupOption.fromValue(
        json['pickupOption'] as String? ?? 'delivery',
      ),
      paymentMethod: json['paymentMethod'] as String? ?? 'cash',
      subtotal: (json['subtotal'] as num?)?.toDouble(),
      deliveryFee: (json['delivery_price'] as num?)?.toDouble(),
      total: (json['total'] as num?)?.toDouble(),
      address: address,
      deliveryAddressString: json['delivery_address'] as String?,
      timeline: _parseTimeline(json['timeline'] as List<dynamic>?),
      customerNote: json['customerNote'] as String?,
      employeeCancelNote: json['employeeCancelNote'] as String?,
      createdAt: createdAt,
      updatedAt: updatedAt,
      orderType: orderType,
      pickupStops: pickupStops,
      driverCommission: driverCommission,
    );
  }

  /// Creates an [OrderModel] from Admin Dashboard format JSON.
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      customerPhone: json['customerPhone'] as String,
      customerImage: json['customerImage'] as String?,
      storeId: json['storeId'] as String?,
      storeName: json['storeName'] as String?,
      driverId: json['driverId'] as String?,
      driverName: json['driverName'] as String?,
      driverLatitude: (json['driverLatitude'] as num?)?.toDouble(),
      driverLongitude: (json['driverLongitude'] as num?)?.toDouble(),
      items: (json['items'] as List<dynamic>?)
              ?.map((item) =>
                  OrderItemModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          const [],
      status: OrderStatus.fromValue(json['status'] as String),
      pickupOption: PickupOption.fromValue(
        json['pickupOption'] as String? ?? 'delivery',
      ),
      paymentMethod: json['paymentMethod'] as String? ?? 'cash',
      subtotal: (json['subtotal'] as num?)?.toDouble(),
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble(),
      total: (json['total'] as num?)?.toDouble(),
      address: json['address'] != null
          ? DeliveryAddressModel.fromJson(
              json['address'] as Map<String, dynamic>)
          : DeliveryAddress.empty,
      deliveryAddressString: json['deliveryAddress'] as String?,
      timeline: (json['timeline'] as List<dynamic>?)
              ?.map(
                  (t) => OrderTimelineModel.fromJson(t as Map<String, dynamic>))
              .toList() ??
          const [],
      customerNote: json['customerNote'] as String?,
      employeeCancelNote: json['employeeCancelNote'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Converts to JSON for Admin Dashboard format.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerImage': customerImage,
      'storeId': storeId,
      'storeName': storeName,
      'driverId': driverId,
      'driverName': driverName,
      'driverLatitude': driverLatitude,
      'driverLongitude': driverLongitude,
      'items': items.map((item) => (item as OrderItemModel).toJson()).toList(),
      'status': status.value,
      'pickupOption': pickupOption.value,
      'paymentMethod': paymentMethod,
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'address': (address as DeliveryAddressModel).toJson(),
      'deliveryAddress': deliveryAddressString,
      'timeline':
          timeline.map((t) => (t as OrderTimelineModel).toJson()).toList(),
      'customerNote': customerNote,
      'employeeCancelNote': employeeCancelNote,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Converts to Deliverzler Firestore format for updates.
  Map<String, dynamic> toDeliverzlerUpdate() {
    return {
      'deliveryStatus': _statusToDeliverzler(status),
      if (driverId != null) 'deliveryId': driverId,
      if (employeeCancelNote != null) 'employeeCancelNote': employeeCancelNote,
    };
  }

  /// Converts status to Deliverzler's expected value.
  static String _statusToDeliverzler(OrderStatus status) {
    // For now, use the same values until migration
    // Legacy Deliverzler uses: pending, upcoming, onTheWay, delivered, canceled
    switch (status) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.confirmed:
        return 'upcoming'; // Legacy value
      case OrderStatus.preparing:
        return 'upcoming'; // Map to upcoming for now
      case OrderStatus.ready:
        return 'upcoming'; // Map to upcoming for now
      case OrderStatus.pickedUp:
        return 'onTheWay'; // Legacy value
      case OrderStatus.onTheWay:
        return 'onTheWay'; // Legacy value
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.cancelled:
        return 'canceled'; // Legacy value (single 'l')
    }
  }

  /// Creates a copy with modified fields.
  OrderModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? customerImage,
    String? storeId,
    String? storeName,
    String? driverId,
    String? driverName,
    double? driverLatitude,
    double? driverLongitude,
    List<OrderItem>? items,
    OrderStatus? status,
    PickupOption? pickupOption,
    String? paymentMethod,
    double? subtotal,
    double? deliveryFee,
    double? total,
    DeliveryAddress? address,
    String? deliveryAddressString,
    List<OrderTimeline>? timeline,
    String? customerNote,
    String? employeeCancelNote,
    DateTime? createdAt,
    DateTime? updatedAt,
    OrderType? orderType,
    List<PickupStop>? pickupStops,
    double? driverCommission,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerImage: customerImage ?? this.customerImage,
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      driverLatitude: driverLatitude ?? this.driverLatitude,
      driverLongitude: driverLongitude ?? this.driverLongitude,
      items: items ?? this.items,
      status: status ?? this.status,
      pickupOption: pickupOption ?? this.pickupOption,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      total: total ?? this.total,
      address: address ?? this.address,
      deliveryAddressString:
          deliveryAddressString ?? this.deliveryAddressString,
      timeline: timeline ?? this.timeline,
      customerNote: customerNote ?? this.customerNote,
      employeeCancelNote: employeeCancelNote ?? this.employeeCancelNote,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      orderType: orderType ?? this.orderType,
      pickupStops: pickupStops ?? this.pickupStops,
      driverCommission: driverCommission ?? this.driverCommission,
    );
  }

  /// Parses timeline array from Firestore.
  static List<OrderTimeline> _parseTimeline(List<dynamic>? timelineList) {
    if (timelineList == null || timelineList.isEmpty) {
      return const [];
    }
    return timelineList
        .map((item) {
          if (item is Map<String, dynamic>) {
            return OrderTimelineModel.fromJson(item);
          }
          return null;
        })
        .whereType<OrderTimeline>()
        .toList();
  }
}

/// Delivery address model.
class DeliveryAddressModel extends DeliveryAddress {
  const DeliveryAddressModel({
    required super.state,
    required super.city,
    required super.street,
    required super.mobile,
    super.latitude,
    super.longitude,
  });

  /// Creates from Deliverzler's addressModel JSON.
  factory DeliveryAddressModel.fromJson(Map<String, dynamic> json) {
    // Handle GeoPoint from Firestore
    final geoPoint = json['geoPoint'] as GeoPoint?;

    return DeliveryAddressModel(
      state: json['state'] as String? ?? '',
      city: json['city'] as String? ?? '',
      street: json['street'] as String? ?? '',
      mobile: json['mobile'] as String? ?? '',
      latitude: geoPoint?.latitude,
      longitude: geoPoint?.longitude,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() {
    return {
      'state': state,
      'city': city,
      'street': street,
      'mobile': mobile,
      if (latitude != null && longitude != null)
        'geoPoint': GeoPoint(latitude!, longitude!),
    };
  }
}

/// Order item model.
class OrderItemModel extends OrderItem {
  const OrderItemModel({
    required super.id,
    required super.name,
    super.imageUrl,
    required super.quantity,
    required super.price,
    required super.total,
    super.notes,
    super.category,
    super.storeName,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ??
          json['title'] as String? ??
          'Unknown Product',
      imageUrl: json['imageUrl'] as String? ?? json['image'] as String?,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String? ?? json['description'] as String?,
      category: json['category'] as String?,
      storeName: json['store_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'price': price,
      'total': total,
      'notes': notes,
      'category': category,
      if (storeName != null) 'store_name': storeName,
    };
  }

  /// Creates a copy with a different store name.
  OrderItemModel withStoreName(String? storeName) => OrderItemModel(
        id: id,
        name: name,
        imageUrl: imageUrl,
        quantity: quantity,
        price: price,
        total: total,
        notes: notes,
        category: category,
        storeName: storeName,
      );
}

/// Order timeline model.
class OrderTimelineModel extends OrderTimeline {
  const OrderTimelineModel({
    required super.status,
    required super.timestamp,
    super.note,
  });

  factory OrderTimelineModel.fromJson(Map<String, dynamic> json) {
    return OrderTimelineModel(
      status: OrderStatus.fromValue(json['status'] as String),
      timestamp: DateTime.parse(json['timestamp'] as String),
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.value,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
    };
  }
}

/// Pickup stop model for multi-store orders.
class PickupStopModel extends PickupStop {
  const PickupStopModel({
    required super.storeId,
    required super.storeName,
    required super.subtotal,
    super.status = PickupStopStatus.pending,
    super.items = const [],
    super.confirmedAt,
    super.pickedUpAt,
    super.rejectedAt,
    super.rejectionReason,
  });

  /// Creates from a Firestore pickup_stop map.
  factory PickupStopModel.fromJson(Map<String, dynamic> json) {
    final price = (json['subtotal'] as num?)?.toDouble() ?? 0.0;
    final stopStoreName = json['store_name'] as String? ?? '';

    // Parse items from within the pickup stop
    final rawItems = json['items'] as List<dynamic>?;
    final items = rawItems
            ?.map((item) {
              if (item is Map<String, dynamic>) {
                final itemPrice = (item['price'] as num?)?.toDouble() ?? 0.0;
                final quantity = (item['quantity'] as num?)?.toInt() ?? 1;
                return OrderItemModel(
                  id: item['product_id'] as String? ?? '',
                  name: item['name'] as String? ?? '',
                  imageUrl: item['image_url'] as String?,
                  quantity: quantity,
                  price: itemPrice,
                  total: itemPrice * quantity,
                  storeName: stopStoreName,
                );
              }
              return null;
            })
            .whereType<OrderItemModel>()
            .toList() ??
        const [];

    return PickupStopModel(
      storeId: json['store_id'] as String? ?? '',
      storeName: stopStoreName,
      subtotal: price,
      status:
          PickupStopStatus.fromValue(json['status'] as String? ?? 'pending'),
      items: items,
      confirmedAt: _parseDateTime(json['confirmed_at']),
      pickedUpAt: _parseDateTime(json['picked_up_at']),
      rejectedAt: _parseDateTime(json['rejected_at']),
      rejectionReason: json['rejection_reason'] as String?,
    );
  }

  /// Parses a list of pickup stops from Firestore data.
  static List<PickupStop> parseList(List<dynamic>? raw) {
    if (raw == null || raw.isEmpty) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map((json) => PickupStopModel.fromJson(json))
        .toList();
  }

  /// Safely parses a datetime string or null.
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
    return null;
  }

  /// Converts to Firestore-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'store_id': storeId,
      'store_name': storeName,
      'subtotal': subtotal,
      'status': status.value,
      'confirmed_at': confirmedAt?.toIso8601String(),
      'picked_up_at': pickedUpAt?.toIso8601String(),
      'rejected_at': rejectedAt?.toIso8601String(),
      'rejection_reason': rejectionReason,
      'items': items
          .map((item) => {
                'product_id': item.id,
                'name': item.name,
                'image_url': item.imageUrl,
                'price': item.price,
                'quantity': item.quantity,
              })
          .toList(),
    };
  }
}
