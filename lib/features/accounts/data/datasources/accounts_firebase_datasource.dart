import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firebase/firebase_service.dart';
import '../../domain/repositories/accounts_repository.dart';
import '../models/account_models.dart';
import 'accounts_datasource.dart';

/// Firebase Firestore implementation of AccountsDataSource.
class AccountsFirebaseDataSource implements AccountsDataSource {
  final FirebaseFirestore _firestore;

  AccountsFirebaseDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _driversCollection =>
      _firestore.collection(FirestoreCollections.drivers);

  // Helper to convert Timestamp to ISO String for models
  Map<String, dynamic> _normalizeDateFields(Map<String, dynamic> data) {
    final normalized = Map<String, dynamic>.from(data);

    // Helper to safely convert a field to ISO string
    String? toIsoString(dynamic value) {
      if (value is Timestamp) {
        return value.toDate().toIso8601String();
      } else if (value is String) {
        return value;
      }
      return null;
    }

    // Helper to safely convert complex fields to string (e.g. address map)
    String? toString(dynamic value) {
      if (value == null) return null;
      if (value is String) return value;
      if (value is Map) {
        // If address is a map, try to extract relevant parts or format it
        final street = value['street'] ?? '';
        final city = value['city'] ?? '';
        final country = value['country'] ?? '';
        if (street != '') {
          return '$street, $city, $country'
              .replaceAll(RegExp(r', , '), ', ')
              .trim();
        }
        return value.toString();
      }
      return value.toString();
    }

    // Normalize dates safely
    normalized['createdAt'] = toIsoString(normalized['createdAt']) ??
        toIsoString(normalized['created_at']) ??
        DateTime.now().toIso8601String();
    normalized['updatedAt'] = toIsoString(normalized['updatedAt']) ??
        toIsoString(normalized['updated_at']) ??
        DateTime.now().toIso8601String();

    if (normalized.containsKey('lastOrderDate')) {
      normalized['lastOrderDate'] = toIsoString(normalized['lastOrderDate']);
    }

    // Address construction
    if (!normalized.containsKey('address')) {
      final parts = ['street', 'city', 'country']
          .map((k) => normalized[k]?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
      if (parts.isNotEmpty) {
        normalized['address'] = parts.join(', ');
      }
    } else {
      normalized['address'] = toString(normalized['address']);
    }

    // Image URL normalization
    if (normalized['imageUrl'] is! String) {
      normalized['imageUrl'] = normalized['profile_image'] ??
          normalized['image_url'] ??
          normalized['photo_url'];
    }
    if (normalized['imageUrl'] is! String) normalized['imageUrl'] = null;

    if (normalized['phone'] is! String) normalized['phone'] = '';
    if (normalized['email'] is! String) normalized['email'] = '';

    // Name field normalization
    if (normalized['full_name'] is String &&
        (normalized['full_name'] as String).isNotEmpty) {
      normalized['name'] = normalized['full_name'];
    } else if (normalized['name'] is Map) {
      final nameMap = normalized['name'] as Map;
      normalized['name'] = nameMap['en'] ??
          nameMap['ar'] ??
          nameMap.values.firstOrNull ??
          'Unknown';
    } else if (normalized['name'] == null ||
        (normalized['name'] is String &&
            (normalized['name'] as String).isEmpty)) {
      normalized['name'] = 'Ù…Ø³ØªØ®Ø¯Ù… ØºÙŠØ± Ù…Ø¹Ø±ÙˆÙ';
    } else if (normalized['name'] is! String) {
      normalized['name'] = normalized['name'].toString();
    }

    return normalized;
  }

  // ============================================
  // ðŸ‘¥ CUSTOMERS
  // ============================================

  @override
  Future<List<CustomerModel>> getCustomers({
    String? searchQuery,
    bool? isActive,
    int limit = 20,
    String? lastId,
  }) async {
    Query<Map<String, dynamic>> query =
        _usersCollection.where('role', isEqualTo: 'customer');

    if (isActive != null) {
      query = query.where('isActive', isEqualTo: isActive);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      // Basic prefix search on 'full_name'
      // Note: This requires an index on 'full_name' if combined with other equality filters
      query = query
          .where('full_name', isGreaterThanOrEqualTo: searchQuery)
          .where('full_name', isLessThan: '$searchQuery\uf8ff')
          .orderBy('full_name');
    } else {
      query = query.orderBy('created_at', descending: true);
    }

    query = query.limit(limit);

    if (lastId != null) {
      final lastDoc = await _usersCollection.doc(lastId).get();
      if (lastDoc.exists) {
        query = query.startAfterDocument(lastDoc);
      }
    }

    final snapshot = await query.get();

    // Client-side mapping - only basic profile data, NO per-customer order queries
    final customers = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      final normalizedData = _normalizeDateFields(data);

      // Ensure required fields exist
      if (!normalizedData.containsKey('name')) {
        normalizedData['name'] = 'مستخدم ${doc.id.substring(0, 4)}';
      }
      if (!normalizedData.containsKey('email')) {
        normalizedData['email'] = '';
      }
      if (!normalizedData.containsKey('phone')) {
        normalizedData['phone'] = '';
      }
      if (!normalizedData.containsKey('isActive')) {
        normalizedData['isActive'] = true;
      }

      return CustomerModel.fromJson(normalizedData);
    }).toList();
    // Stats (totalOrders, totalSpent) are fetched only in getCustomerById
    // to avoid N+1 query performance issues in list view
    return customers;
  }

  @override
  Future<CustomerModel> getCustomerById(String id) async {
    final doc = await _usersCollection.doc(id).get();
    if (!doc.exists) {
      throw Exception('Customer not found');
    }

    final data = doc.data()!;

    // Verify this is a customer user
    if (data['role'] != 'customer') {
      throw Exception('User is not a customer');
    }

    data['id'] = doc.id;
    var customer = CustomerModel.fromJson(_normalizeDateFields(data));

    // Dynamically fetch stats
    try {
      final query =
          _firestore.collection('orders').where('userId', isEqualTo: id);

      /*
      final aggregateQuery = await query.aggregate(sum('total'), count()).get();
      final totalOrders = aggregateQuery.count ?? 0;
      final totalSpent = aggregateQuery.getSum('total') ?? 0.0;
      */

      final countQuery = await query.count().get();
      final totalOrders = countQuery.count ?? 0;
      final totalSpent = 0.0;

      // Get last order
      String? lastOrderId = customer.lastOrderId;
      DateTime? lastOrderDate = customer.lastOrderDate;

      try {
        final lastOrderSnapshot =
            await query.orderBy('date', descending: true).limit(1).get();

        if (lastOrderSnapshot.docs.isNotEmpty) {
          final lastOrderDoc = lastOrderSnapshot.docs.first;
          lastOrderId = lastOrderDoc.id;
          final lastOrderData = lastOrderDoc.data();
          if (lastOrderData['date'] is int) {
            lastOrderDate =
                DateTime.fromMillisecondsSinceEpoch(lastOrderData['date']);
          } else if (lastOrderData['date'] is Timestamp) {
            lastOrderDate = (lastOrderData['date'] as Timestamp).toDate();
          }
        }
      } catch (e) {
        // Ignore
      }

      customer = customer.copyWith(
        totalOrders: totalOrders,
        totalSpent: totalSpent,
        lastOrderId: lastOrderId,
        lastOrderDate: lastOrderDate,
      );
    } catch (e) {
      // Ignore
    }

    return customer;
  }

  @override
  Future<void> toggleCustomerStatus(String id, bool isActive) async {
    await _usersCollection.doc(id).update({'isActive': isActive});
  }

  // ============================================
  // ðŸª STORES
  // ============================================

  @override
  Future<List<StoreModel>> getStores({
    String? searchQuery,
    bool? isActive,
    bool? isApproved,
    String? type,
    int limit = 20,
    String? lastId,
  }) async {
    // Filter only seller users (who have stores)
    Query<Map<String, dynamic>> query =
        _usersCollection.where('role', isEqualTo: 'seller');

    if (isApproved != null) {
      query = query.where('store.is_approved', isEqualTo: isApproved);
    }

    if (isActive != null) {
      query = query.where('store.is_approved', isEqualTo: isActive);
    }

    // Category/type and search filtering done client-side
    // since store data is nested

    query = query.orderBy('created_at', descending: true);

    query = query.limit(limit);

    if (lastId != null) {
      final lastDoc = await _usersCollection.doc(lastId).get();
      if (lastDoc.exists) {
        query = query.startAfterDocument(lastDoc);
      }
    }

    final snapshot = await query.get();

    var stores =
        snapshot.docs.where((doc) => doc.data()['store'] != null).map((doc) {
      return StoreModel.fromJson(_normalizeDateFields(
        _mapStoreData(doc.id, doc.data()),
      ));
    }).toList();

    // Client-side search filtering
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final queryLower = searchQuery.toLowerCase();
      stores = stores
          .where((s) =>
              s.name.toLowerCase().contains(queryLower) ||
              s.email.toLowerCase().contains(queryLower) ||
              (s.address?.toLowerCase().contains(queryLower) ?? false))
          .toList();
    }

    // Client-side type filtering
    if (type != null && type.isNotEmpty) {
      stores = stores.where((s) => s.type == type).toList();
    }

    return stores;
  }

  @override
  Future<StoreModel> getStoreById(String id) async {
    final doc = await _usersCollection.doc(id).get();
    if (!doc.exists) throw Exception('Store not found');

    var store = StoreModel.fromJson(_normalizeDateFields(
      _mapStoreData(doc.id, doc.data()!),
    ));

    // Fetch totalOrders on detail view only
    try {
      final count = await _firestore
          .collection('orders')
          .where('store_id', isEqualTo: id)
          .count()
          .get();
      store = store.copyWith(totalOrders: count.count ?? 0);
    } catch (_) {}

    return store;
  }

  /// Maps Firestore user+store data into a flat map for [StoreModel.fromJson].
  Map<String, dynamic> _mapStoreData(
      String docId, Map<String, dynamic> userData) {
    final storeData =
        (userData['store'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    return {
      'id': docId,
      'name': storeData['name'] ?? userData['full_name'] ?? 'Unknown',
      'email': storeData['support_email'] ?? userData['email'] ?? '',
      'phone': storeData['phone'] ?? userData['phone'] ?? '',
      'imageUrl': storeData['image_url'],
      'isActive': storeData['is_approved'] ?? false,
      'isApproved': storeData['is_approved'] ?? false,
      'type': storeData['category'] ?? 'other',
      'description': storeData['description'],
      'address': storeData['address'] ?? userData['street'] ?? '',
      'latitude': storeData['latitude'],
      'longitude': storeData['longitude'],
      'rating': storeData['rating'] ?? 0,
      'created_at': storeData['created_at'] ?? userData['created_at'],
      'updated_at': storeData['updated_at'] ?? userData['updated_at'],
    };
  }

  @override
  Future<void> toggleStoreStatus(String id, bool isActive) async {
    await _usersCollection.doc(id).update({
      'store.is_approved': isActive,
      'store.updated_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateStoreCommission(String id, double rate) async {
    await _usersCollection.doc(id).update({
      'store.commissionRate': rate,
      'store.updated_at': FieldValue.serverTimestamp(),
    });
  }

  // ============================================
  // ðŸš— DRIVERS
  // ============================================

  @override
  Future<List<DriverModel>> getDrivers({
    String? searchQuery,
    bool? isActive,
    bool? isApproved,
    bool? isOnline,
    int limit = 20,
    String? lastId,
  }) async {
    Query<Map<String, dynamic>> query = _driversCollection;

    if (isActive != null) {
      query = query.where('isActive', isEqualTo: isActive);
    }

    if (isApproved != null) {
      query = query.where('isApproved', isEqualTo: isApproved);
    }

    if (isOnline != null) {
      query = query.where('isOnline', isEqualTo: isOnline);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query
          .where('name', isGreaterThanOrEqualTo: searchQuery)
          .where('name', isLessThan: '$searchQuery\uf8ff')
          .orderBy('name');
    } else {
      query = query.orderBy('createdAt', descending: true);
    }

    query = query.limit(limit);

    if (lastId != null) {
      final lastDoc = await _driversCollection.doc(lastId).get();
      if (lastDoc.exists) {
        query = query.startAfterDocument(lastDoc);
      }
    }

    final snapshot = await query.get();

    final drivers = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return DriverModel.fromJson(_normalizeDateFields(data));
    }).toList();

    // Stats (totalDeliveries, rejectionsCounter) are fetched only in getDriverById
    // to avoid N+1 query performance issues in list view
    return drivers;
  }

  @override
  Future<DriverModel> getDriverById(String id) async {
    final doc = await _driversCollection.doc(id).get();
    if (!doc.exists) throw Exception('Driver not found');

    final data = doc.data()!;
    data['id'] = doc.id;
    var driver = DriverModel.fromJson(_normalizeDateFields(data));

    // Dynamically fetch totalDeliveries and rejections
    try {
      // Get total delivered orders
      final countSnapshot = await _firestore
          .collection('orders')
          .where('deliveryId', isEqualTo: driver.id)
          .where('status', isEqualTo: 'delivered')
          .count()
          .get();
      final totalDeliveries = countSnapshot.count ?? 0;

      // Get actual rejections count from orders where driver is in rejected_by_drivers array
      final rejectedSnapshot = await _firestore
          .collection('orders')
          .where('rejected_by_drivers', arrayContains: driver.id)
          .count()
          .get();
      final actualRejections = rejectedSnapshot.count ?? 0;

      driver = driver.copyWith(
        totalDeliveries: totalDeliveries,
        rejectionsCounter: actualRejections,
      );
    } catch (e) {
      // Ignore
    }

    return driver;
  }

  @override
  Future<void> toggleDriverStatus(String id, bool isActive) async {
    await _driversCollection.doc(id).update({'isActive': isActive});
  }

  @override
  Stream<List<DriverModel>> watchOnlineDrivers() {
    return _driversCollection
        .where('isOnline', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return DriverModel.fromJson(_normalizeDateFields(data));
      }).toList();
    });
  }

  // ============================================
  // ðŸ“Š STATISTICS
  // ============================================

  @override
  Future<AccountStats> getAccountStats() async {
    // Customers are now inside users collection with role=customer
    final customersQuery =
        _usersCollection.where('role', isEqualTo: 'customer');

    // Stores are now inside users collection with role=seller
    final sellersQuery = _usersCollection.where('role', isEqualTo: 'seller');

    // Parallel fetch for aggregates
    final results = await Future.wait([
      customersQuery.count().get(),
      customersQuery.where('isActive', isEqualTo: true).count().get(),
      sellersQuery.count().get(),
      sellersQuery.where('store.is_approved', isEqualTo: true).count().get(),
      sellersQuery.where('store.is_approved', isEqualTo: true).count().get(),
      _driversCollection.count().get(),
      _driversCollection.where('isActive', isEqualTo: true).count().get(),
      _driversCollection.where('isOnline', isEqualTo: true).count().get(),
    ]);

    return AccountStats(
      totalCustomers: results[0].count ?? 0,
      activeCustomers: results[1].count ?? 0,
      totalStores: results[2].count ?? 0,
      activeStores: results[3].count ?? 0,
      approvedStores: results[4].count ?? 0,
      totalDrivers: results[5].count ?? 0,
      activeDrivers: results[6].count ?? 0,
      onlineDrivers: results[7].count ?? 0,
    );
  }
}
