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

  CollectionReference<Map<String, dynamic>> get _customersCollection =>
      _firestore.collection('profiles');

  CollectionReference<Map<String, dynamic>> get _storesCollection =>
      _firestore.collection(FirestoreCollections.stores);

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
        if (street != '') return '$street, $city, $country'.replaceAll(RegExp(r', , '), ', ').trim();
        return value.toString();
      }
      return value.toString();
    }
    
    // Normalize dates safely
    normalized['createdAt'] = toIsoString(normalized['createdAt']) ?? DateTime.now().toIso8601String();
    normalized['updatedAt'] = toIsoString(normalized['updatedAt']) ?? DateTime.now().toIso8601String();
    
    if (normalized.containsKey('lastOrderDate')) {
      normalized['lastOrderDate'] = toIsoString(normalized['lastOrderDate']);
    }

    // Handle address specifically as it might be a Map in Firestore
    if (normalized.containsKey('address')) {
      normalized['address'] = toString(normalized['address']);
    }

    // Ensure safe types for other potentially probelmatic fields
    if (normalized['imageUrl'] is! String) normalized['imageUrl'] = null;
    if (normalized['phone'] is! String) normalized['phone'] = '';
    if (normalized['email'] is! String) normalized['email'] = '';
    
    // Name might be localized (Map) in some collections
    if (normalized['name'] is Map) {
      final nameMap = normalized['name'] as Map;
      normalized['name'] = nameMap['en'] ?? nameMap['ar'] ?? nameMap.values.firstOrNull ?? 'Unknown';
    } else if (normalized['name'] is! String) {
      normalized['name'] = 'Unknown';
    }

    return normalized;
  }

  // ============================================
  // 👥 CUSTOMERS
  // ============================================

  @override
  Future<List<CustomerModel>> getCustomers({
    String? searchQuery,
    bool? isActive,
    int limit = 20,
    String? lastId,
  }) async {
    Query<Map<String, dynamic>> query = _customersCollection;

    if (isActive != null) {
      query = query.where('isActive', isEqualTo: isActive);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      // Basic prefix search on 'name'
      // Note: This requires an index on 'name' if combined with other equality filters
      query = query
          .where('name', isGreaterThanOrEqualTo: searchQuery)
          .where('name', isLessThan: '$searchQuery\uf8ff')
          .orderBy('name');
    } else {
      query = query.orderBy('createdAt', descending: true);
    }

    query = query.limit(limit);

    if (lastId != null) {
      final lastDoc = await _customersCollection.doc(lastId).get();
      if (lastDoc.exists) {
        query = query.startAfterDocument(lastDoc);
      }
    }

    final snapshot = await query.get();
    
    // Client-side mapping
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      final normalizedData = _normalizeDateFields(data);
      
      // Ensure required fields exist
      if (!normalizedData.containsKey('name')) normalizedData['name'] = 'مستخدم ${doc.id.substring(0, 4)}';
      if (!normalizedData.containsKey('email')) normalizedData['email'] = '';
      if (!normalizedData.containsKey('phone')) normalizedData['phone'] = '';
      if (!normalizedData.containsKey('isActive')) normalizedData['isActive'] = true;

      return CustomerModel.fromJson(normalizedData);
    }).toList();
  }

  @override
  Future<CustomerModel> getCustomerById(String id) async {
    final doc = await _customersCollection.doc(id).get();
    if (!doc.exists) {
      throw Exception('Customer not found');
    }
    
    final data = doc.data()!;
    data['id'] = doc.id;
    return CustomerModel.fromJson(_normalizeDateFields(data));
  }

  @override
  Future<void> toggleCustomerStatus(String id, bool isActive) async {
    await _customersCollection.doc(id).update({'isActive': isActive});
  }

  // ============================================
  // 🏪 STORES
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
    Query<Map<String, dynamic>> query = _storesCollection;

    if (isActive != null) {
      query = query.where('isActive', isEqualTo: isActive);
    }
    
    if (isApproved != null) {
      query = query.where('isApproved', isEqualTo: isApproved);
    }
    
    if (type != null && type.isNotEmpty) {
      query = query.where('type', isEqualTo: type);
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
      final lastDoc = await _storesCollection.doc(lastId).get();
      if (lastDoc.exists) {
        query = query.startAfterDocument(lastDoc);
      }
    }

    final snapshot = await query.get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return StoreModel.fromJson(_normalizeDateFields(data));
    }).toList();
  }

  @override
  Future<StoreModel> getStoreById(String id) async {
    final doc = await _storesCollection.doc(id).get();
    if (!doc.exists) throw Exception('Store not found');
    
    final data = doc.data()!;
    data['id'] = doc.id;
    return StoreModel.fromJson(_normalizeDateFields(data));
  }

  @override
  Future<void> toggleStoreStatus(String id, bool isActive) async {
    await _storesCollection.doc(id).update({
      'isActive': isActive,
      'status': isActive ? 'active' : 'inactive',
    });
  }

  @override
  Future<void> updateStoreCommission(String id, double rate) async {
    await _storesCollection.doc(id).update({'commissionRate': rate});
  }

  // ============================================
  // 🚗 DRIVERS
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

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return DriverModel.fromJson(_normalizeDateFields(data));
    }).toList();
  }

  @override
  Future<DriverModel> getDriverById(String id) async {
    final doc = await _driversCollection.doc(id).get();
    if (!doc.exists) throw Exception('Driver not found');
    
    final data = doc.data()!;
    data['id'] = doc.id;
    return DriverModel.fromJson(_normalizeDateFields(data));
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
  // 📊 STATISTICS
  // ============================================

  @override
  Future<AccountStats> getAccountStats() async {
    // Parallel fetch for aggregates
    final results = await Future.wait([
      _customersCollection.count().get(),
      _customersCollection.where('isActive', isEqualTo: true).count().get(),
      
      _storesCollection.count().get(),
      _storesCollection.where('isActive', isEqualTo: true).count().get(),
      _storesCollection.where('isApproved', isEqualTo: true).count().get(),
      
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
