import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/product_entity.dart';

/// Firebase datasource for products with in-memory caching
class ProductsFirebaseDatasource {
  final FirebaseFirestore _firestore;

  ProductsFirebaseDatasource(this._firestore);

  /// Cache duration - 5 minutes
  static const _cacheDuration = Duration(minutes: 5);

  /// In-memory cache
  List<ProductEntity>? _cachedProducts;
  DateTime? _lastFetchTime;

  /// Cached stores map to avoid redundant seller queries
  Map<String, Map<String, dynamic>>? _cachedStoresMap;

  /// Check if cache is still valid
  bool get _isCacheValid =>
      _cachedProducts != null &&
      _lastFetchTime != null &&
      DateTime.now().difference(_lastFetchTime!) < _cacheDuration;

  /// Invalidate cache manually (e.g. after add/update/delete)
  void invalidateCache() {
    _cachedProducts = null;
    _lastFetchTime = null;
    _cachedStoresMap = null;
  }

  /// Get stores map (cached)
  Future<Map<String, Map<String, dynamic>>> _getStoresMap() async {
    if (_cachedStoresMap != null && _isCacheValid) {
      return _cachedStoresMap!;
    }

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

    _cachedStoresMap = storesMap;
    return storesMap;
  }

  /// Parse a single product document with store data
  ProductEntity? _parseProduct(
    DocumentSnapshot<Map<String, dynamic>> doc,
    Map<String, Map<String, dynamic>> storesMap,
  ) {
    final data = doc.data();
    if (data == null) return null;

    final storeId = data['store_id'] as String?;
    if (storeId == null || !storesMap.containsKey(storeId)) return null;

    final storeData = storesMap[storeId]!;
    return ProductEntity(
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
    );
  }

  /// Get all products with store information (uses cache)
  Future<List<ProductEntity>> getProducts({bool forceRefresh = false}) async {
    if (!forceRefresh && _isCacheValid) {
      return _cachedProducts!;
    }

    try {
      final storesMap = await _getStoresMap();
      final productsSnapshot = await _firestore.collection('products').get();

      final products = <ProductEntity>[];
      for (var doc in productsSnapshot.docs) {
        final product = _parseProduct(doc, storesMap);
        if (product != null) {
          products.add(product);
        }
      }

      // Update cache
      _cachedProducts = products;
      _lastFetchTime = DateTime.now();

      return products;
    } catch (e) {
      // Return stale cache on error if available
      if (_cachedProducts != null) return _cachedProducts!;
      throw Exception('فشل في جلب المنتجات: $e');
    }
  }

  /// Search products locally from cache (no extra Firestore calls)
  Future<List<ProductEntity>> searchProducts(String query) async {
    try {
      final allProducts = await getProducts();

      if (query.isEmpty) return allProducts;

      final lowerQuery = query.toLowerCase();
      return allProducts
          .where((product) =>
              product.name.toLowerCase().contains(lowerQuery) ||
              product.storeName.toLowerCase().contains(lowerQuery) ||
              product.category.toLowerCase().contains(lowerQuery))
          .toList();
    } catch (e) {
      throw Exception('فشل في البحث عن المنتجات: $e');
    }
  }

  /// Get products by store ID using Firestore query (optimized)
  Future<List<ProductEntity>> getProductsByStore(String storeId) async {
    try {
      // If cache is valid, filter locally (faster)
      if (_isCacheValid) {
        return _cachedProducts!.where((p) => p.storeId == storeId).toList();
      }

      // Otherwise, use targeted Firestore query
      final storesMap = await _getStoresMap();
      if (!storesMap.containsKey(storeId)) return [];

      final snapshot = await _firestore
          .collection('products')
          .where('store_id', isEqualTo: storeId)
          .get();

      final products = <ProductEntity>[];
      for (var doc in snapshot.docs) {
        final product = _parseProduct(doc, storesMap);
        if (product != null) products.add(product);
      }
      return products;
    } catch (e) {
      throw Exception('فشل في جلب منتجات المتجر: $e');
    }
  }

  /// Get products by category using Firestore query (optimized)
  Future<List<ProductEntity>> getProductsByCategory(String category) async {
    try {
      // If cache is valid, filter locally (faster)
      if (_isCacheValid) {
        return _cachedProducts!.where((p) => p.category == category).toList();
      }

      // Otherwise, use targeted Firestore query
      final storesMap = await _getStoresMap();
      final snapshot = await _firestore
          .collection('products')
          .where('category', isEqualTo: category)
          .get();

      final products = <ProductEntity>[];
      for (var doc in snapshot.docs) {
        final product = _parseProduct(doc, storesMap);
        if (product != null) products.add(product);
      }
      return products;
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
