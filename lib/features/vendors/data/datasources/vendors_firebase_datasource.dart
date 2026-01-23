import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/vendor_entity.dart';
import 'vendors_datasource.dart';

/// Firebase Firestore implementation for vendors.
class VendorsFirebaseDataSource implements VendorsDataSource {
  final FirebaseFirestore _firestore;
  final String _collection = 'vendors';

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
    var vendors = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return VendorEntity.fromMap(data);
    }).toList();

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
  }

  @override
  Future<VendorEntity> getVendor(String id) async {
    final doc = await _vendorsRef.doc(id).get();
    if (!doc.exists) {
      throw Exception('Vendor not found');
    }
    final data = doc.data()!;
    data['id'] = doc.id;
    return VendorEntity.fromMap(data);
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
    return VendorEntity.fromMap(newData);
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
    final vendors =
        snapshot.docs.map((doc) => VendorEntity.fromMap(doc.data())).toList();

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

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return VendorEntity.fromMap(data);
      }).toList();
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
      return VendorEntity.fromMap(data);
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
      return VendorEntity.fromMap(data);
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
}
