import 'package:equatable/equatable.dart';

/// Product entity
class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final String storeId;
  final String storeName;
  final String category;
  final bool isAvailable;
  final DateTime createdAt;

  const ProductEntity({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    required this.storeId,
    required this.storeName,
    required this.category,
    required this.isAvailable,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        imageUrl,
        storeId,
        storeName,
        category,
        isAvailable,
        createdAt,
      ];

  ProductEntity copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? storeId,
    String? storeName,
    String? category,
    bool? isAvailable,
    DateTime? createdAt,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
