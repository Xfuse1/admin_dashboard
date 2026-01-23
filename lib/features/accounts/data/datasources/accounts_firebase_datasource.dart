import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firebase/firebase_service.dart';
import '../../domain/repositories/accounts_repository.dart';
import '../models/account_models.dart';
import 'accounts_datasource.dart';

/// Firebase Firestore implementation of AccountsDataSource.
///
/// Integrates with Deliverzler's Firestore structure:
/// - Users collection: 'users' (drivers only in Deliverzler)
/// - User fields: id, email, name, phone, image
/// - Note: Deliverzler doesn't have separate customers/stores collections
class AccountsFirebaseDataSource implements AccountsDataSource {
  final FirebaseFirestore _firestore;

  AccountsFirebaseDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection(FirestoreCollections.users);

  /// Convert Deliverzler User document to DriverModel
  DriverModel _userToDriver(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final now = DateTime.now();

    return DriverModel(
      id: doc.id,
      name: data[UserFields.name] as String? ?? 'Unknown',
      email: data[UserFields.email] as String? ?? '',
      phone: data[UserFields.phone] as String? ?? '',
      imageUrl: data[UserFields.image] as String?,
      isActive: true, // Deliverzler doesn't have isActive for users
      createdAt: now, // Not stored in Deliverzler
      updatedAt: now,
      isOnline: false, // Not tracked in Deliverzler
      isApproved:
          true, // All users in Deliverzler are approved (they can login)
      rating: 0.0,
      totalRatings: 0,
      totalDeliveries: 0,
      walletBalance: 0.0,
      latitude: null,
      longitude: null,
      vehicleType: null,
      vehiclePlate: null,
      licenseImage: null,
      idCardImage: null,
      vehicleImage: null,
      criminalRecordImage: null,
    );
  }

  // ============================================
  // 👥 CUSTOMERS
  // ============================================
  // Note: Deliverzler doesn't have a separate customers collection
  // Customer data is embedded in orders (userId, userName, userImage)

  @override
  Future<List<CustomerModel>> getCustomers({
    String? searchQuery,
    bool? isActive,
    int limit = 20,
    String? lastId,
  }) async {
    // Deliverzler doesn't have a customers collection
    // We could extract unique customers from orders, but for now return empty
    return [];
  }

  @override
  Future<CustomerModel> getCustomerById(String id) async {
    // Deliverzler doesn't have a customers collection
    throw Exception('Customer collection not available in Deliverzler');
  }

  @override
  Future<void> toggleCustomerStatus(String id, bool isActive) async {
    // Deliverzler doesn't have a customers collection
    throw Exception('Customer collection not available in Deliverzler');
  }

  // ============================================
  // 🏪 STORES
  // ============================================
  // Note: Deliverzler doesn't have a stores/vendors collection

  @override
  Future<List<StoreModel>> getStores({
    String? searchQuery,
    bool? isActive,
    bool? isApproved,
    String? type,
    int limit = 20,
    String? lastId,
  }) async {
    // Deliverzler doesn't have a stores collection
    return [];
  }

  @override
  Future<StoreModel> getStoreById(String id) async {
    // Deliverzler doesn't have a stores collection
    throw Exception('Stores collection not available in Deliverzler');
  }

  @override
  Future<void> toggleStoreStatus(String id, bool isActive) async {
    // Deliverzler doesn't have a stores collection
    throw Exception('Stores collection not available in Deliverzler');
  }

  @override
  Future<void> updateStoreCommission(String id, double rate) async {
    // Deliverzler doesn't have a stores collection
    throw Exception('Stores collection not available in Deliverzler');
  }

  // ============================================
  // 🚗 DRIVERS
  // ============================================
  // Deliverzler uses 'users' collection for drivers

  @override
  Future<List<DriverModel>> getDrivers({
    String? searchQuery,
    bool? isActive,
    bool? isApproved,
    bool? isOnline,
    int limit = 20,
    String? lastId,
  }) async {
    Query<Map<String, dynamic>> query = _usersCollection.limit(limit);

    if (lastId != null) {
      final lastDoc = await _usersCollection.doc(lastId).get();
      if (lastDoc.exists) {
        query = query.startAfterDocument(lastDoc);
      }
    }

    final snapshot = await query.get();
    var drivers = snapshot.docs.map(_userToDriver).toList();

    // Client-side search (Deliverzler User has name, email, phone)
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final queryLower = searchQuery.toLowerCase();
      drivers = drivers.where((d) {
        return d.name.toLowerCase().contains(queryLower) ||
            d.email.toLowerCase().contains(queryLower) ||
            d.phone.contains(queryLower);
      }).toList();
    }

    // Note: isActive, isApproved, isOnline filters not available in Deliverzler

    return drivers;
  }

  @override
  Future<DriverModel> getDriverById(String id) async {
    final doc = await _usersCollection.doc(id).get();

    if (!doc.exists) {
      throw Exception('Driver not found');
    }

    return _userToDriver(doc);
  }

  @override
  Future<void> toggleDriverStatus(String id, bool isActive) async {
    // Deliverzler doesn't have isActive field for users
    // This is a no-op for now
  }

  @override
  Stream<List<DriverModel>> watchOnlineDrivers() {
    // Deliverzler doesn't track online status
    // Return all users as "drivers"
    return _usersCollection.snapshots().map((snapshot) {
      return snapshot.docs.map(_userToDriver).toList();
    });
  }

  // ============================================
  // 📊 STATISTICS
  // ============================================

  @override
  Future<AccountStats> getAccountStats() async {
    // Only users (drivers) collection exists in Deliverzler
    final driversSnapshot = await _usersCollection.get();

    final drivers = driversSnapshot.docs.map(_userToDriver).toList();

    return AccountStats(
      totalCustomers: 0, // Not available in Deliverzler
      activeCustomers: 0,
      totalStores: 0, // Not available in Deliverzler
      activeStores: 0,
      approvedStores: 0,
      totalDrivers: drivers.length,
      activeDrivers: drivers.length, // All users are considered active
      onlineDrivers: 0, // Not tracked in Deliverzler
    );
  }
}
