import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/product_entity.dart';
import '../../domain/entities/vendor_entity.dart';
import 'vendors_datasource.dart';

/// Firebase Firestore implementation for vendors.
/// Vendors (stores) are now embedded inside the `users` collection
/// as a `store` map field for users with `role: "seller"`.
class VendorsFirebaseDataSource implements VendorsDataSource {
  final FirebaseFirestore _firestore;
  final String _collection = 'users';

  /// Cached orders snapshot for batch vendor stats calculation.
  /// Avoids redundant reads when computing stats for many vendors at once.
  List<QueryDocumentSnapshot<Map<String, dynamic>>>? _cachedOrderDocs;
  DateTime? _cacheTimestamp;
  static const _cacheDuration = Duration(minutes: 2);

  VendorsFirebaseDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Returns (possibly cached) orders docs for vendor stats calculation.
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      _getOrderDocs() async {
    final now = DateTime.now();
    if (_cachedOrderDocs != null &&
        _cacheTimestamp != null &&
        now.difference(_cacheTimestamp!) < _cacheDuration) {
      return _cachedOrderDocs!;
    }
    final snapshot = await _firestore.collection('orders').get();
    _cachedOrderDocs = snapshot.docs;
    _cacheTimestamp = now;
    return _cachedOrderDocs!;
  }

  /// Invalidates cached orders.
  void _invalidateOrdersCache() {
    _cachedOrderDocs = null;
    _cacheTimestamp = null;
  }

  /// Calculates order count and revenue for a specific vendor.
  ///
  /// Handles both:
  /// - **Single-store orders**: where `store_id == vendorId`
  /// - **Multi-store orders**: where `vendorId` appears in `pickup_stops`
  ///
  /// Revenue calculation:
  /// - Single-store: uses `total` or `subtotal` field
  /// - Multi-store: uses the relevant pickup_stop's `subtotal`
  ({int totalOrders, double totalRevenue}) _calculateVendorOrderStats(
    String vendorId,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> orderDocs,
  ) {
    int totalOrders = 0;
    double totalRevenue = 0.0;

    for (final doc in orderDocs) {
      final data = doc.data();
      final orderType = data['order_type'] as String?;
      final storeId = data['store_id'] as String?;

      if (orderType == 'multi_store') {
        // Multi-store: check pickup_stops array
        final pickupStops = data['pickup_stops'] as List<dynamic>?;
        if (pickupStops != null) {
          for (final stop in pickupStops) {
            if (stop is Map<String, dynamic> && stop['store_id'] == vendorId) {
              totalOrders++;
              totalRevenue += (stop['subtotal'] as num?)?.toDouble() ?? 0.0;
              break; // Count this order once per store
            }
          }
        }
      } else {
        // Single-store order
        if (storeId == vendorId) {
          totalOrders++;
          totalRevenue += (data['total'] as num?)?.toDouble() ??
              (data['subtotal'] as num?)?.toDouble() ??
              (data['totalAmount'] as num?)?.toDouble() ??
              0.0;
        }
      }
    }

    return (totalOrders: totalOrders, totalRevenue: totalRevenue);
  }

  CollectionReference<Map<String, dynamic>> get _vendorsRef =>
      _firestore.collection(_collection);

  /// Base query that filters only seller users (who have stores).
  Query<Map<String, dynamic>> get _sellersQuery =>
      _vendorsRef.where('role', isEqualTo: 'seller');

  /// Extracts vendor-compatible data from a user document that has a `store` map.
  Map<String, dynamic> _extractVendorFromUser(
      String docId, Map<String, dynamic> userData) {
    final storeData =
        (userData['store'] as Map<String, dynamic>?) ?? <String, dynamic>{};

    return {
      'id': docId,
      'name': storeData['name'] ?? userData['full_name'] ?? 'Unknown',
      'description': storeData['description'],
      'category': storeData['category'],
      'categoryLabel': storeData['category'],
      'phone': storeData['phone'] ?? userData['phone'] ?? '',
      'email': storeData['support_email'] ?? userData['email'],
      'logoUrl': storeData['image_url'],
      'rating': storeData['rating'] ?? 0,
      'isApproved': storeData['is_approved'] ?? false,
      'isActive': storeData['is_approved'] ?? false,
      'address': {
        'street': storeData['address'] ?? userData['street'] ?? '',
        'city': userData['city'] ?? '',
        'country': userData['country'] ?? '',
        'latitude': storeData['latitude'],
        'longitude': storeData['longitude'],
      },
      'createdAt': storeData['created_at'] ?? userData['created_at'],
      'updatedAt': storeData['updated_at'] ?? userData['updated_at'],
      'ownerId': docId,
      'ownerName': userData['full_name'],
      'whatsappNumber': storeData['whatsapp_number'],
      'returnPolicy': storeData['return_policy'],
      'openTime': storeData['open_time'],
      'closeTime': storeData['close_time'],
      'workingDays': storeData['working_days'],
    };
  }

  @override
  Future<List<VendorEntity>> getVendors({
    VendorStatus? status,
    VendorCategory? category,
    String? searchQuery,
    int? limit,
    String? lastDocumentId,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _sellersQuery;

      // Filter by status using nested store fields
      if (status != null) {
        switch (status) {
          case VendorStatus.active:
            query = query.where('store.is_approved', isEqualTo: true);
            break;
          case VendorStatus.pending:
            query = query.where('store.is_approved', isEqualTo: false);
            break;
          case VendorStatus.inactive:
          case VendorStatus.suspended:
            // Client-side filtering for these statuses
            break;
        }
      }

      // Category is now a plain string in store map - filter client-side
      // since values are Arabic strings, not enum names

      query = query.orderBy('created_at', descending: true);

      if (lastDocumentId != null) {
        final lastDoc = await _vendorsRef.doc(lastDocumentId).get();
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();

      // Extract vendor data from user documents with embedded store map
      var vendors = snapshot.docs
          .where((doc) =>
              doc.data()['store'] != null) // Only users with store data
          .map((doc) {
        final vendorData = _extractVendorFromUser(doc.id, doc.data());
        return VendorEntity.fromMap(_processVendorData(vendorData));
      }).toList();

      // Fetch products count and accurate order stats for each vendor
      if (vendors.isNotEmpty) {
        // Pre-fetch all orders once (cached)
        final orderDocs = await _getOrderDocs();

        final countFutures = vendors.map((vendor) async {
          int productsCount = vendor.productsCount;

          try {
            final productCountSnapshot = await _firestore
                .collection('products')
                .where('store_id', isEqualTo: vendor.id)
                .count()
                .get();
            productsCount = productCountSnapshot.count ?? 0;
          } catch (e) {
            // Keep default/existing value on error
          }

          // Calculate orders & revenue using the efficient helper
          final stats = _calculateVendorOrderStats(vendor.id, orderDocs);

          return vendor.copyWith(
            productsCount: productsCount,
            totalOrders: stats.totalOrders,
            totalRevenue: stats.totalRevenue,
          );
        });

        vendors = await Future.wait(countFutures);
      }

      // Client-side search filtering
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final queryLower = searchQuery.toLowerCase();
        vendors = vendors.where((v) {
          return v.name.toLowerCase().contains(queryLower) ||
              (v.description?.toLowerCase().contains(queryLower) ?? false) ||
              v.address.city.toLowerCase().contains(queryLower);
        }).toList();
      }

      return vendors;
    } catch (e) {
      // Print Firebase index error with link to console
      if (e.toString().contains('index')) {
        print('\n🔴 Firebase Index Required!');
        print('Error: $e');
        print('\n📋 Copy this link to create the index:');
        print(
            '👉 Check your browser console for the Firebase index creation link\n');
      }
      rethrow;
    }
  }

  @override
  Future<VendorEntity> getVendor(String id) async {
    final doc = await _vendorsRef.doc(id).get();
    if (!doc.exists) {
      throw Exception('Vendor not found');
    }
    final userData = doc.data()!;
    final data = _extractVendorFromUser(doc.id, userData);

    // Fetch ratings from store_reviews
    try {
      final reviewsSnapshot = await _firestore
          .collection('store_reviews')
          .where('storeId', isEqualTo: id)
          .get();

      if (reviewsSnapshot.docs.isNotEmpty) {
        final totalRatings = reviewsSnapshot.docs.length;
        final ratingSum = reviewsSnapshot.docs.fold<double>(
          0.0,
          (sum, doc) => sum + (doc.data()['rating'] as num).toDouble(),
        );
        final averageRating = ratingSum / totalRatings;

        data['rating'] = averageRating;
        data['totalRatings'] = totalRatings;
      }
    } catch (e) {
      // Ignore error if reviews fail to load
    }

    // Fetch products count from products collection
    try {
      final countSnapshot = await _firestore
          .collection('products')
          .where('store_id', isEqualTo: id)
          .count()
          .get();
      data['productsCount'] = countSnapshot.count ?? 0;
    } catch (e) {
      data['productsCount'] = 0;
    }

    // Fetch orders count and total revenue — handles both single & multi-store
    try {
      final orderDocs = await _getOrderDocs();
      final stats = _calculateVendorOrderStats(id, orderDocs);
      data['totalOrders'] = stats.totalOrders;
      data['totalRevenue'] = stats.totalRevenue;
    } catch (e) {
      // Keep existing value if available or default to 0
      if (data['totalOrders'] == null) data['totalOrders'] = 0;
      if (data['totalRevenue'] == null) data['totalRevenue'] = 0.0;
    }

    return VendorEntity.fromMap(_processVendorData(data));
  }

  @override
  Future<VendorEntity> addVendor(VendorEntity vendor) async {
    // Create a new user document with store data embedded
    final storeData = {
      'name': vendor.name,
      'description': vendor.description,
      'category': vendor.category.name,
      'phone': vendor.phone,
      'support_email': vendor.email,
      'image_url': vendor.logoUrl,
      'is_approved': vendor.status == VendorStatus.active,
      'address': vendor.address.street,
      'latitude': vendor.address.latitude,
      'longitude': vendor.address.longitude,
      'rating': vendor.rating,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };

    final userData = {
      'role': 'seller',
      'full_name': vendor.name,
      'email': vendor.email ?? '',
      'phone': vendor.phone,
      'city': vendor.address.city,
      'country': vendor.address.country,
      'street': vendor.address.street,
      'store': storeData,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };

    final docRef = await _vendorsRef.add(userData);
    return getVendor(docRef.id);
  }

  @override
  Future<VendorEntity> updateVendor(VendorEntity vendor) async {
    // Update store data inside the user document using dot notation
    await _vendorsRef.doc(vendor.id).update({
      'store.name': vendor.name,
      'store.description': vendor.description,
      'store.category': vendor.category.name,
      'store.phone': vendor.phone,
      'store.support_email': vendor.email,
      'store.image_url': vendor.logoUrl,
      'store.is_approved': vendor.status == VendorStatus.active,
      'store.address': vendor.address.street,
      'store.latitude': vendor.address.latitude,
      'store.longitude': vendor.address.longitude,
      'store.updated_at': FieldValue.serverTimestamp(),
      'city': vendor.address.city,
      'country': vendor.address.country,
      'street': vendor.address.street,
      'updated_at': FieldValue.serverTimestamp(),
    });
    return getVendor(vendor.id);
  }

  @override
  Future<void> deleteVendor(String id) async {
    // Remove the store field from the user document
    await _vendorsRef.doc(id).update({
      'store': FieldValue.delete(),
      'role': 'customer', // Demote to customer
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<VendorEntity> toggleVendorStatus(
    String id,
    VendorStatus status,
  ) async {
    await _vendorsRef.doc(id).update({
      'store.is_approved': status == VendorStatus.active,
      'store.updated_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
    return getVendor(id);
  }

  @override
  Future<VendorEntity> updateVendorRating(
    String id,
    double rating,
    int totalRatings,
  ) async {
    await _vendorsRef.doc(id).update({
      'store.rating': rating,
      'store.updated_at': FieldValue.serverTimestamp(),
    });
    return getVendor(id);
  }

  @override
  Future<Map<String, dynamic>> getVendorStats() async {
    final snapshot = await _sellersQuery.get();
    final vendors =
        snapshot.docs.where((doc) => doc.data()['store'] != null).map((doc) {
      final vendorData = _extractVendorFromUser(doc.id, doc.data());
      return VendorEntity.fromMap(_processVendorData(vendorData));
    }).toList();

    final activeCount =
        vendors.where((v) => v.status == VendorStatus.active).length;
    final inactiveCount =
        vendors.where((v) => v.status == VendorStatus.inactive).length;
    final pendingCount =
        vendors.where((v) => v.status == VendorStatus.pending).length;
    final suspendedCount =
        vendors.where((v) => v.status == VendorStatus.suspended).length;

    // Calculate accurate totals from orders collection (handles multi-store)
    double totalRevenue = 0.0;
    int totalOrders = 0;

    try {
      // Invalidate cache to get fresh data for stats
      _invalidateOrdersCache();
      final orderDocs = await _getOrderDocs();

      // Aggregate per-vendor revenue
      for (final vendor in vendors) {
        final stats = _calculateVendorOrderStats(vendor.id, orderDocs);
        totalRevenue += stats.totalRevenue;
      }

      // Count distinct orders (an order counted once regardless of stores)
      totalOrders = orderDocs.length;
    } catch (e) {
      print('Error calculating global vendor stats: $e');
      // Fallback to local sum if fetch fails
      totalRevenue = vendors.fold<double>(0, (sum, v) => sum + v.totalRevenue);
      totalOrders = vendors.fold<int>(0, (sum, v) => sum + v.totalOrders);
    }

    final categoryDistribution = <String, int>{};
    for (final category in VendorCategory.values) {
      categoryDistribution[category.name] =
          vendors.where((v) => v.category == category).length;
    }

    final avgRating = vendors.isNotEmpty
        ? vendors.fold<double>(0, (sum, v) => sum + v.rating) / vendors.length
        : 0.0;

    return {
      'totalVendors': vendors.length,
      'activeVendors': activeCount,
      'inactiveVendors': inactiveCount,
      'pendingVendors': pendingCount,
      'suspendedVendors': suspendedCount,
      'totalRevenue': totalRevenue,
      'totalOrders': totalOrders,
      'averageRating': avgRating,
      'categoryDistribution': categoryDistribution,
      'verifiedCount': vendors.where((v) => v.isVerified).length,
      'featuredCount': vendors.where((v) => v.isFeatured).length,
    };
  }

  @override
  Stream<List<VendorEntity>> watchVendors({
    VendorStatus? status,
    VendorCategory? category,
  }) {
    Query<Map<String, dynamic>> query = _sellersQuery;

    if (status != null) {
      switch (status) {
        case VendorStatus.active:
          query = query.where('store.is_approved', isEqualTo: true);
          break;
        case VendorStatus.pending:
          query = query.where('store.is_approved', isEqualTo: false);
          break;
        case VendorStatus.inactive:
        case VendorStatus.suspended:
          break;
      }
    }

    query = query.orderBy('created_at', descending: true);

    return query.snapshots().asyncMap((snapshot) async {
      var vendors =
          snapshot.docs.where((doc) => doc.data()['store'] != null).map((doc) {
        final vendorData = _extractVendorFromUser(doc.id, doc.data());
        return VendorEntity.fromMap(_processVendorData(vendorData));
      }).toList();

      // Fetch products count and accurate order stats for each vendor
      if (vendors.isNotEmpty) {
        // Invalidate cache for fresh data on stream update
        _invalidateOrdersCache();
        final orderDocs = await _getOrderDocs();

        final countFutures = vendors.map((vendor) async {
          int productsCount = vendor.productsCount;

          try {
            final productCountSnapshot = await _firestore
                .collection('products')
                .where('store_id', isEqualTo: vendor.id)
                .count()
                .get();
            productsCount = productCountSnapshot.count ?? 0;
          } catch (e) {
            // Keep default
          }

          // Calculate orders & revenue for both single & multi-store
          final stats = _calculateVendorOrderStats(vendor.id, orderDocs);

          return vendor.copyWith(
            productsCount: productsCount,
            totalOrders: stats.totalOrders,
            totalRevenue: stats.totalRevenue,
          );
        });

        vendors = await Future.wait(countFutures);
      }

      return vendors;
    });
  }

  @override
  Future<List<VendorEntity>> getVendorsByCategory(
    VendorCategory category,
  ) async {
    // Fetch all active sellers and filter by category client-side
    final snapshot =
        await _sellersQuery.where('store.is_approved', isEqualTo: true).get();

    return snapshot.docs
        .where((doc) => doc.data()['store'] != null)
        .map((doc) {
          final vendorData = _extractVendorFromUser(doc.id, doc.data());
          return VendorEntity.fromMap(_processVendorData(vendorData));
        })
        .where((v) => v.category == category)
        .toList();
  }

  @override
  Future<List<VendorEntity>> getFeaturedVendors() async {
    final snapshot = await _sellersQuery
        .where('store.is_approved', isEqualTo: true)
        .where('store.isFeatured', isEqualTo: true)
        .get();

    return snapshot.docs.where((doc) => doc.data()['store'] != null).map((doc) {
      final vendorData = _extractVendorFromUser(doc.id, doc.data());
      return VendorEntity.fromMap(_processVendorData(vendorData));
    }).toList();
  }

  @override
  Future<VendorEntity> toggleFeaturedStatus(String id, bool isFeatured) async {
    await _vendorsRef.doc(id).update({
      'store.isFeatured': isFeatured,
      'store.updated_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
    return getVendor(id);
  }

  @override
  Future<VendorEntity> verifyVendor(String id) async {
    await _vendorsRef.doc(id).update({
      'store.isVerified': true,
      'store.updated_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
    return getVendor(id);
  }

  @override
  Future<List<ProductEntity>> getVendorProducts(String vendorId) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('store_id', isEqualTo: vendorId)
          .get();

      // Get all product IDs for this vendor
      final productIds = snapshot.docs.map((doc) => doc.id).toList();

      if (productIds.isEmpty) {
        return [];
      }

      // Fetch order_items to calculate sales count for each product
      // We need to count how many times each product was sold (sum of quantities)
      final Map<String, int> productSalesCount = {};

      // Firestore 'whereIn' has a limit of 30 items, so we batch if needed
      for (int i = 0; i < productIds.length; i += 30) {
        final batch = productIds.skip(i).take(30).toList();
        try {
          final orderItemsSnapshot = await _firestore
              .collection('order_items')
              .where('product_id', whereIn: batch)
              .get();

          for (final doc in orderItemsSnapshot.docs) {
            final data = doc.data();
            final productId = data['product_id'] as String?;
            final quantity = (data['quantity'] as num?)?.toInt() ?? 1;

            if (productId != null) {
              productSalesCount[productId] =
                  (productSalesCount[productId] ?? 0) + quantity;
            }
          }
        } catch (e) {
          // Continue with default 0 if order_items query fails
        }
      }

      // Map products with calculated sales count
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        // Override ordersCount with calculated sales from order_items
        final calculatedSalesCount = productSalesCount[doc.id] ?? 0;
        data['ordersCount'] = calculatedSalesCount;

        return ProductEntity.fromMap(data);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Map<String, dynamic> _processVendorData(Map<String, dynamic> data) {
    if (data['createdAt'] is Timestamp) {
      data['createdAt'] =
          (data['createdAt'] as Timestamp).toDate().toIso8601String();
    }
    if (data['updatedAt'] is Timestamp) {
      data['updatedAt'] =
          (data['updatedAt'] as Timestamp).toDate().toIso8601String();
    }

    // Derive status from isApproved and isActive if missing
    if (data['status'] == null) {
      final isApproved = data['isApproved'] ?? false;
      final isActive = data['isActive'] ?? false;

      if (!isApproved) {
        data['status'] = VendorStatus.pending.name;
      } else {
        data['status'] =
            isActive ? VendorStatus.active.name : VendorStatus.inactive.name;
      }
    }
    // Handle address being a String instead of Map
    if (data['address'] is String) {
      final addressStr = data['address'] as String;
      data['address'] = {
        'street': addressStr,
        'city': addressStr, // Use address string as city for display
        'country': '',
      };
    } else if (data['address'] == null) {
      data['address'] = {
        'street': '',
        'city': '',
        'country': '',
      };
    } else if (data['address'] is Map) {
      // If city is empty but street has data, use street as city for display
      final address = data['address'] as Map;
      if ((address['city'] == null || address['city'].toString().isEmpty) &&
          address['street'] != null &&
          address['street'].toString().isNotEmpty) {
        address['city'] = address['street'];
        data['address'] = address;
      }
    }

    // Ensure name is String (handle localized map)
    if (data['name'] is Map) {
      final nameMap = data['name'] as Map;
      data['name'] = nameMap['en'] ??
          nameMap['ar'] ??
          nameMap.values.firstOrNull ??
          'Unknown';
    } else if (data['name'] == null) {
      data['name'] = 'Unknown';
    }

    return data;
  }
}
