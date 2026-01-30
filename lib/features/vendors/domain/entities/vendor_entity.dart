import 'package:equatable/equatable.dart';

/// Vendor category type.
enum VendorCategory {
  restaurant,
  grocery,
  pharmacy,
  electronics,
  fashion,
  other,
}

/// Vendor status.
enum VendorStatus {
  active,
  inactive,
  pending,
  suspended,
}

/// Day of week for operating hours.
enum DayOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}

/// Operating hours for a day.
class OperatingHours extends Equatable {
  final DayOfWeek day;
  final String openTime;
  final String closeTime;
  final bool isClosed;

  const OperatingHours({
    required this.day,
    required this.openTime,
    required this.closeTime,
    this.isClosed = false,
  });

  @override
  List<Object?> get props => [day, openTime, closeTime, isClosed];

  OperatingHours copyWith({
    DayOfWeek? day,
    String? openTime,
    String? closeTime,
    bool? isClosed,
  }) {
    return OperatingHours(
      day: day ?? this.day,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      isClosed: isClosed ?? this.isClosed,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'day': day.name,
      'openTime': openTime,
      'closeTime': closeTime,
      'isClosed': isClosed,
    };
  }

  factory OperatingHours.fromMap(Map<String, dynamic> map) {
    return OperatingHours(
      day: DayOfWeek.values.firstWhere(
        (e) => e.name == map['day'],
        orElse: () => DayOfWeek.monday,
      ),
      openTime: map['openTime'] ?? '09:00',
      closeTime: map['closeTime'] ?? '22:00',
      isClosed: map['isClosed'] ?? false,
    );
  }
}

/// Address model for vendor location.
class VendorAddress extends Equatable {
  final String street;
  final String city;
  final String? state;
  final String? zipCode;
  final String country;
  final double? latitude;
  final double? longitude;

  const VendorAddress({
    required this.street,
    required this.city,
    this.state,
    this.zipCode,
    required this.country,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props =>
      [street, city, state, zipCode, country, latitude, longitude];

  String get fullAddress {
    final parts = [street, city];
    if (state != null) parts.add(state!);
    if (zipCode != null) parts.add(zipCode!);
    parts.add(country);
    return parts.join(', ');
  }

  Map<String, dynamic> toMap() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory VendorAddress.fromMap(Map<String, dynamic> map) {
    return VendorAddress(
      street: map['street'] ?? '',
      city: map['city'] ?? '',
      state: map['state'],
      zipCode: map['zipCode'],
      country: map['country'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
    );
  }
}

/// Vendor entity representing a store/supplier.
class VendorEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final VendorCategory category;
  final VendorStatus status;
  final VendorAddress address;
  final String phone;
  final String? email;
  final String? website;
  final String? logoUrl;
  final String? coverImageUrl;
  final double rating;
  final int totalRatings;
  final int totalOrders;
  final double totalRevenue;
  final double commissionRate;
  final List<OperatingHours> operatingHours;
  final List<String> tags;
  final bool isVerified;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? ownerId;
  final Map<String, dynamic>? metadata;

  const VendorEntity({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    required this.status,
    required this.address,
    required this.phone,
    this.email,
    this.website,
    this.logoUrl,
    this.coverImageUrl,
    this.rating = 0.0,
    this.totalRatings = 0,
    this.totalOrders = 0,
    this.totalRevenue = 0.0,
    this.commissionRate = 10.0,
    this.operatingHours = const [],
    this.tags = const [],
    this.isVerified = false,
    this.isFeatured = false,
    required this.createdAt,
    required this.updatedAt,
    this.ownerId,
    this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        category,
        status,
        address,
        phone,
        email,
        website,
        logoUrl,
        coverImageUrl,
        rating,
        totalRatings,
        totalOrders,
        totalRevenue,
        commissionRate,
        operatingHours,
        tags,
        isVerified,
        isFeatured,
        createdAt,
        updatedAt,
        ownerId,
        metadata,
      ];

  VendorEntity copyWith({
    String? id,
    String? name,
    String? description,
    VendorCategory? category,
    VendorStatus? status,
    VendorAddress? address,
    String? phone,
    String? email,
    String? website,
    String? logoUrl,
    String? coverImageUrl,
    double? rating,
    int? totalRatings,
    int? totalOrders,
    double? totalRevenue,
    double? commissionRate,
    List<OperatingHours>? operatingHours,
    List<String>? tags,
    bool? isVerified,
    bool? isFeatured,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? ownerId,
    Map<String, dynamic>? metadata,
  }) {
    return VendorEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      logoUrl: logoUrl ?? this.logoUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      rating: rating ?? this.rating,
      totalRatings: totalRatings ?? this.totalRatings,
      totalOrders: totalOrders ?? this.totalOrders,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      commissionRate: commissionRate ?? this.commissionRate,
      operatingHours: operatingHours ?? this.operatingHours,
      tags: tags ?? this.tags,
      isVerified: isVerified ?? this.isVerified,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      ownerId: ownerId ?? this.ownerId,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category.name,
      'status': status.name,
      'address': address.toMap(),
      'phone': phone,
      'email': email,
      'website': website,
      'logoUrl': logoUrl,
      'coverImageUrl': coverImageUrl,
      'rating': rating,
      'totalRatings': totalRatings,
      'totalOrders': totalOrders,
      'totalRevenue': totalRevenue,
      'commissionRate': commissionRate,
      'operatingHours': operatingHours.map((h) => h.toMap()).toList(),
      'tags': tags,
      'isVerified': isVerified,
      'isFeatured': isFeatured,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'ownerId': ownerId,
      'metadata': metadata,
    };
  }

  factory VendorEntity.fromMap(Map<String, dynamic> map) {
    return VendorEntity(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      category: VendorCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => VendorCategory.other,
      ),
      status: VendorStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => VendorStatus.pending,
      ),
      address: VendorAddress.fromMap(map['address'] ?? {}),
      phone: map['phone'] ?? '',
      email: map['email'],
      website: map['website'],
      logoUrl: map['logoUrl'],
      coverImageUrl: map['coverImageUrl'],
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      totalRatings: map['totalRatings'] ?? 0,
      totalOrders: map['totalOrders'] ?? 0,
      totalRevenue: (map['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      commissionRate: (map['commissionRate'] as num?)?.toDouble() ?? 10.0,
      operatingHours: (map['operatingHours'] as List?)
              ?.map((h) => OperatingHours.fromMap(h))
              .toList() ??
          [],
      tags: List<String>.from(map['tags'] ?? []),
      isVerified: map['isVerified'] ?? false,
      isFeatured: map['isFeatured'] ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
      ownerId: map['ownerId'],
      metadata: map['metadata'],
    );
  }
}
