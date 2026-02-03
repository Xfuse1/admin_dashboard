import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final int ordersCount;
  final bool isAvailable;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.ordersCount,
    required this.isAvailable,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        imageUrl,
        ordersCount,
        isAvailable,
      ];

  // Helper for empty product
  static const empty = ProductEntity(
    id: '',
    name: '',
    description: '',
    price: 0.0,
    imageUrl: '',
    ordersCount: 0,
    isAvailable: false,
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'ordersCount': ordersCount,
      'isAvailable': isAvailable,
    };
  }

  factory ProductEntity.fromMap(Map<String, dynamic> map) {
    return ProductEntity(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['image_url'] ?? '',
      ordersCount: map['ordersCount'] ?? 0,
      isAvailable: map['isAvailable'] ?? true,
    );
  }


}
