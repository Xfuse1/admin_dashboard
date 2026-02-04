import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/product_entity.dart';
import '../../domain/entities/vendor_entity.dart';
import 'vendors_datasource.dart';

/// Firebase Firestore implementation for vendors.
class VendorsFirebaseDataSource implements VendorsDataSource {
  final FirebaseFirestore _firestore;
  final String _collection = 'stores';

  VendorsFirebaseDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _vendorsRef =>
      _firestore.collection(_collection);

  @override
  Future<List<VendorEntity>> getVendors({
    VendorStatus? status,
    VendorCategory? category,
    String? searchQuery,
    int? limit,
    String? lastDocumentId,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _vendorsRef;

      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }

      if (category != null) {
        query = query.where('category', isEqualTo: category.name);
      }

      query = query.orderBy('createdAt', descending: true);

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

      // Use stored rating values for list performance
      // Detailed ratings are fetched in getVendor() for individual vendor details
      var vendors = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return VendorEntity.fromMap(_processVendorData(data));
      }).toList();

      // Fetch products and orders count for each vendor
      if (vendors.isNotEmpty) {
        final countFutures = vendors.map((vendor) async {
          int productsCount = vendor.productsCount;
          int totalOrders = vendor.totalOrders;

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

          try {
            final orderCountSnapshot = await _firestore
                .collection('orders')
                .where('store_id', isEqualTo: vendor.id)
                .count()
                .get();
            totalOrders = orderCountSnapshot.count ?? 0;
          } catch (e) {
            // Keep default/existing value on error
          }

          return vendor.copyWith(
            productsCount: productsCount,
            totalOrders: totalOrders,
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
    final data = doc.data()!;
    data['id'] = doc.id;

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

    // Fetch orders count from orders collection
    try {
      final orderCountSnapshot = await _firestore
          .collection('orders')
          .where('store_id', isEqualTo: id)
          .count()
          .get();
      data['totalOrders'] = orderCountSnapshot.count ?? 0;
    } catch (e) {
      // Keep existing value if available or default to 0
      if (data['totalOrders'] == null) data['totalOrders'] = 0;
    }

    return VendorEntity.fromMap(_processVendorData(data));
  }

  @override
  Future<VendorEntity> addVendor(VendorEntity vendor) async {
    final data = vendor.toMap();
    data.remove('id');
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();

    final docRef = await _vendorsRef.add(data);
    final newDoc = await docRef.get();
    final newData = newDoc.data()!;
    newData['id'] = newDoc.id;
    return VendorEntity.fromMap(_processVendorData(newData));
  }

  @override
  Future<VendorEntity> updateVendor(VendorEntity vendor) async {
    final data = vendor.toMap();
    data.remove('id');
    data['updatedAt'] = FieldValue.serverTimestamp();

    await _vendorsRef.doc(vendor.id).update(data);
    return getVendor(vendor.id);
  }

  @override
  Future<void> deleteVendor(String id) async {
    await _vendorsRef.doc(id).delete();
  }

  @override
  Future<VendorEntity> toggleVendorStatus(
    String id,
    VendorStatus status,
  ) async {
    await _vendorsRef.doc(id).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
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
      'rating': rating,
      'totalRatings': totalRatings,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return getVendor(id);
  }

  @override
  Future<Map<String, dynamic>> getVendorStats() async {
    final snapshot = await _vendorsRef.get();
    final vendors = snapshot.docs
        .map((doc) => VendorEntity.fromMap(_processVendorData(doc.data())))
        .toList();

    final activeCount =
        vendors.where((v) => v.status == VendorStatus.active).length;
    final inactiveCount =
        vendors.where((v) => v.status == VendorStatus.inactive).length;
    final pendingCount =
        vendors.where((v) => v.status == VendorStatus.pending).length;
    final suspendedCount =
        vendors.where((v) => v.status == VendorStatus.suspended).length;

    final totalRevenue =
        vendors.fold<double>(0, (sum, v) => sum + v.totalRevenue);
    final totalOrders = vendors.fold<int>(0, (sum, v) => sum + v.totalOrders);

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
    Query<Map<String, dynamic>> query = _vendorsRef;

    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }

    if (category != null) {
      query = query.where('category', isEqualTo: category.name);
    }

    query = query.orderBy('createdAt', descending: true);

    return query.snapshots().asyncMap((snapshot) async {
      var vendors = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return VendorEntity.fromMap(_processVendorData(data));
      }).toList();

      // Fetch products and orders count for each vendor
      if (vendors.isNotEmpty) {
        final countFutures = vendors.map((vendor) async {
          int productsCount = vendor.productsCount;
          int totalOrders = vendor.totalOrders;

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

          try {
            final orderCountSnapshot = await _firestore
                .collection('orders')
                .where('store_id', isEqualTo: vendor.id)
                .count()
                .get();
            totalOrders = orderCountSnapshot.count ?? 0;
          } catch (e) {
            // Keep default
          }

          return vendor.copyWith(
            productsCount: productsCount,
            totalOrders: totalOrders,
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
    final snapshot = await _vendorsRef
        .where('category', isEqualTo: category.name)
        .where('status', isEqualTo: VendorStatus.active.name)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return VendorEntity.fromMap(_processVendorData(data));
    }).toList();
  }

  @override
  Future<List<VendorEntity>> getFeaturedVendors() async {
    final snapshot = await _vendorsRef
        .where('isFeatured', isEqualTo: true)
        .where('status', isEqualTo: VendorStatus.active.name)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return VendorEntity.fromMap(_processVendorData(data));
    }).toList();
  }

  @override
  Future<VendorEntity> toggleFeaturedStatus(String id, bool isFeatured) async {
    await _vendorsRef.doc(id).update({
      'isFeatured': isFeatured,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return getVendor(id);
  }

  @override
  Future<VendorEntity> verifyVendor(String id) async {
    await _vendorsRef.doc(id).update({
      'isVerified': true,
      'updatedAt': FieldValue.serverTimestamp(),
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

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
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
