import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/product_entity.dart';

/// Firebase datasource for products
class ProductsFirebaseDatasource {
  final FirebaseFirestore _firestore;

  ProductsFirebaseDatasource(this._firestore);

  /// Get all products with store information
  Future<List<ProductEntity>> getProducts() async {
    try {
      // Get all products
      final productsSnapshot = await _firestore.collection('products').get();

      // Get all seller users for store lookup (stores are now embedded in users)
      final sellersSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'seller')
          .get();
      final storesMap = <String, Map<String, dynamic>>{};
      for (var doc in sellersSnapshot.docs) {
        final userData = doc.data();
        final storeData = userData['store'] as Map<String, dynamic>?;
        if (storeData != null) {
          storesMap[doc.id] = storeData;
        }
      }

      final products = <ProductEntity>[];

      for (var doc in productsSnapshot.docs) {
        final data = doc.data();
        final storeId = data['store_id'] as String?;

        if (storeId != null && storesMap.containsKey(storeId)) {
          final storeData = storesMap[storeId]!;

          products.add(ProductEntity(
            id: doc.id,
            name: data['name'] as String? ?? 'غير محدد',
            description: data['description'] as String?,
            price: (data['price'] as num?)?.toDouble() ?? 0.0,
            imageUrl: _getImageUrl(data),
            storeId: storeId,
            storeName: storeData['name'] as String? ?? 'غير محدد',
            category: data['category'] as String? ?? 'غير مصنف',
            isAvailable: data['is_available'] as bool? ?? true,
            createdAt: _parseDate(data['created_at']),
          ));
        }
      }

      return products;
    } catch (e) {
      throw Exception('فشل في جلب المنتجات: $e');
    }
  }

  /// Search products by name
  Future<List<ProductEntity>> searchProducts(String query) async {
    try {
      final allProducts = await getProducts();

      if (query.isEmpty) return allProducts;

      return allProducts
          .where((product) =>
              product.name.toLowerCase().contains(query.toLowerCase()) ||
              product.storeName.toLowerCase().contains(query.toLowerCase()) ||
              product.category.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      throw Exception('فشل في البحث عن المنتجات: $e');
    }
  }

  /// Get products by store ID
  Future<List<ProductEntity>> getProductsByStore(String storeId) async {
    try {
      final allProducts = await getProducts();
      return allProducts.where((p) => p.storeId == storeId).toList();
    } catch (e) {
      throw Exception('فشل في جلب منتجات المتجر: $e');
    }
  }

  /// Get products by category
  Future<List<ProductEntity>> getProductsByCategory(String category) async {
    try {
      final allProducts = await getProducts();
      return allProducts.where((p) => p.category == category).toList();
    } catch (e) {
      throw Exception('فشل في جلب منتجات الفئة: $e');
    }
  }

  /// Helper method to parse date from Timestamp or String
  DateTime _parseDate(dynamic value) {
    if (value == null) {
      return DateTime.now();
    }

    // Handle Firestore Timestamp
    if (value is Timestamp) {
      return value.toDate();
    }

    // Handle String (ISO 8601 format)
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }

    return DateTime.now();
  }

  /// Helper method to get image URL from different possible field names
  String? _getImageUrl(Map<String, dynamic> data) {
    // Try multiple possible field names (image_url first as priority)
    final possibleFields = [
      'image_url',
      'imageUrl',
      'image',
      'photoUrl',
      'photo'
    ];

    for (final field in possibleFields) {
      final value = data[field];
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }

    return null;
  }
}
