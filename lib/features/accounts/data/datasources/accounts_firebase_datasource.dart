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
    normalized['createdAt'] = toIsoString(normalized['createdAt']) ?? toIsoString(normalized['created_at']) ?? DateTime.now().toIso8601String();
    normalized['updatedAt'] = toIsoString(normalized['updatedAt']) ?? toIsoString(normalized['updated_at']) ?? DateTime.now().toIso8601String();
    
    if (normalized.containsKey('lastOrderDate')) {
      normalized['lastOrderDate'] = toIsoString(normalized['lastOrderDate']);
    }

    // Address construction from top-level fields
    if (!normalized.containsKey('address')) {
      final street = normalized['street'];
      final city = normalized['city'];
      final country = normalized['country'];
      
      final parts = <String>[];
      if (street != null && street.toString().isNotEmpty) parts.add(street.toString());
      if (city != null && city.toString().isNotEmpty) parts.add(city.toString());
      if (country != null && country.toString().isNotEmpty) parts.add(country.toString());
      
      if (parts.isNotEmpty) {
        normalized['address'] = parts.join(', ');
      }
    } else if (normalized.containsKey('address')) {
      normalized['address'] = toString(normalized['address']);
    }

    // Ensure safe types for other potentially problematic fields
    if (normalized['imageUrl'] is! String) normalized['imageUrl'] = null;
    if (normalized['phone'] is! String) normalized['phone'] = '';
    if (normalized['email'] is! String) normalized['email'] = '';
    
    // Name field normalization (Updated for user schema)
    if (normalized['full_name'] is String && (normalized['full_name'] as String).isNotEmpty) {
      // Primary match for user schema
      normalized['name'] = normalized['full_name'];
    } else if (normalized['name'] is Map) {
      final nameMap = normalized['name'] as Map;
      normalized['name'] = nameMap['en'] ?? nameMap['ar'] ?? nameMap.values.firstOrNull ?? 'Unknown';
    } else if (normalized['name'] == null || (normalized['name'] is String && (normalized['name'] as String).isEmpty)) {
        normalized['name'] = 'مستخدم غير معروف';
    } else if (normalized['name'] is! String) {
      normalized['name'] = normalized['name'].toString();
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
    var customers = snapshot.docs.map((doc) {
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

    // Dynamically fetch stats for each customer
    if (customers.isNotEmpty) {
      final statsFutures = customers.map((customer) async {
        int totalOrders = customer.totalOrders;
        double totalSpent = customer.totalSpent;
        String? lastOrderId = customer.lastOrderId;
        DateTime? lastOrderDate = customer.lastOrderDate;

        try {
          // Try both possible field names for customer ID
          var query1 = _firestore
              .collection('orders')
              .where('userId', isEqualTo: customer.id);
          
          var ordersSnapshot = await query1.get();
          
          // If no results with userId, try user_id (snake_case variation)
          if (ordersSnapshot.docs.isEmpty) {
            final query2 = _firestore
                .collection('orders')
                .where('user_id', isEqualTo: customer.id);
            ordersSnapshot = await query2.get();
          }
          
          totalOrders = ordersSnapshot.size;
          
          if (ordersSnapshot.docs.isNotEmpty) {
            totalSpent = ordersSnapshot.docs.fold(0.0, (sum, doc) {
              final data = doc.data();
              // extract total amount safely - try multiple field names
              final amount = (data['total'] as num?)?.toDouble() ?? 
                             (data['totalAmount'] as num?)?.toDouble() ?? 
                             (data['total_price'] as num?)?.toDouble() ?? 0.0;
              return sum + amount;
            });
            
            print('   💰 Total Spent: ${totalSpent.toStringAsFixed(2)} EGP');
          }

          // Get last order
          if (ordersSnapshot.docs.isNotEmpty) {
            // Sort by 'date' field (Unix timestamp in milliseconds)
            final sortedDocs = ordersSnapshot.docs.toList()
              ..sort((a, b) {
                final dateA = a.data()['date'];
                final dateB = b.data()['date'];
                if (dateA is int && dateB is int) {
                  return dateB.compareTo(dateA); // Descending
                }
                return 0;
              });
            
            final lastOrderDoc = sortedDocs.first;
            lastOrderId = lastOrderDoc.id;
            final lastOrderData = lastOrderDoc.data();
            
            // Handle date field which might be int (millis) or Timestamp
            if (lastOrderData['date'] is int) {
              lastOrderDate = DateTime.fromMillisecondsSinceEpoch(lastOrderData['date']);
            } else if (lastOrderData['date'] is Timestamp) {
              lastOrderDate = (lastOrderData['date'] as Timestamp).toDate();
            }
          }
        } catch (e) {
          print('❌ Error fetching orders for ${customer.name}: $e');
          // Fallback to existing if error
        }

        return customer.copyWith(
          totalOrders: totalOrders,
          totalSpent: totalSpent,
          lastOrderId: lastOrderId,
          lastOrderDate: lastOrderDate,
        );
      });
      customers = await Future.wait(statsFutures);
    }

    return customers;
  }

  @override
  Future<CustomerModel> getCustomerById(String id) async {
    final doc = await _customersCollection.doc(id).get();
    if (!doc.exists) {
      throw Exception('Customer not found');
    }
    
    final data = doc.data()!;
    data['id'] = doc.id;
    var customer = CustomerModel.fromJson(_normalizeDateFields(data));

    // Dynamically fetch stats
    try {
      final query = _firestore
          .collection('orders')
          .where('userId', isEqualTo: id);

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
        final lastOrderSnapshot = await query
            .orderBy('date', descending: true)
            .limit(1)
            .get();

        if (lastOrderSnapshot.docs.isNotEmpty) {
          final lastOrderDoc = lastOrderSnapshot.docs.first;
          lastOrderId = lastOrderDoc.id;
          final lastOrderData = lastOrderDoc.data();
          if (lastOrderData['date'] is int) {
            lastOrderDate = DateTime.fromMillisecondsSinceEpoch(lastOrderData['date']);
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

    var stores = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return StoreModel.fromJson(_normalizeDateFields(data));
    }).toList();

    // Dynamically fetch totalOrders for each store
    if (stores.isNotEmpty) {
      final countFutures = stores.map((store) async {
        int totalOrders = store.totalOrders;
        try {
          final orderCountSnapshot = await _firestore
              .collection('orders')
              .where('store_id', isEqualTo: store.id) // Ensure using store_id
              .count()
              .get();
          totalOrders = orderCountSnapshot.count ?? 0;
        } catch (e) {
          // Keep existing value
        }
        return store.copyWith(totalOrders: totalOrders);
      });
      stores = await Future.wait(countFutures);
    }

    return stores;
  }

  @override
  Future<StoreModel> getStoreById(String id) async {
    final doc = await _storesCollection.doc(id).get();
    if (!doc.exists) throw Exception('Store not found');
    
    final data = doc.data()!;
    data['id'] = doc.id;
    
    var store = StoreModel.fromJson(_normalizeDateFields(data));

    // Dynamically fetch totalOrders
    try {
      final orderCountSnapshot = await _firestore
          .collection('orders')
          .where('store_id', isEqualTo: id)
          .count()
          .get();
      final totalOrders = orderCountSnapshot.count ?? 0;
      store = store.copyWith(totalOrders: totalOrders);
    } catch (e) {
      // Ignore
    }

    return store;
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

    var drivers = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return DriverModel.fromJson(_normalizeDateFields(data));
    }).toList();

    // Dynamically fetch totalDeliveries for each driver
    if (drivers.isNotEmpty) {
      final statsFutures = drivers.map((driver) async {
        int totalDeliveries = driver.totalDeliveries;
        try {
          final countSnapshot = await _firestore
              .collection('orders')
              .where('deliveryId', isEqualTo: driver.id)
              .where('status', isEqualTo: 'delivered')
              .count()
              .get();
          totalDeliveries = countSnapshot.count ?? 0;
        } catch (e) {
          // Keep existing
        }
        return driver.copyWith(totalDeliveries: totalDeliveries);
      });
      drivers = await Future.wait(statsFutures);
    }

    return drivers;
  }

  @override
  Future<DriverModel> getDriverById(String id) async {
    final doc = await _driversCollection.doc(id).get();
    if (!doc.exists) throw Exception('Driver not found');
    
    final data = doc.data()!;
    data['id'] = doc.id;
    var driver = DriverModel.fromJson(_normalizeDateFields(data));

    // Dynamically fetch totalDeliveries
    try {
          final countSnapshot = await _firestore
              .collection('orders')
              .where('deliveryId', isEqualTo: driver.id)
              .where('status', isEqualTo: 'delivered')
              .count()
              .get();
          final totalDeliveries = countSnapshot.count ?? 0;
          print('✅ Driver ${driver.name} total deliveries: $totalDeliveries');
          driver = driver.copyWith(totalDeliveries: totalDeliveries);
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
