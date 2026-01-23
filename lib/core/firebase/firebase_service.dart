/// Firebase service for centralized Firebase operations.
///
/// Provides a clean interface for Firebase initialization and
/// access to Firestore, Auth, and Storage instances.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'firebase_config.dart';

/// Service class for Firebase initialization and instance access.
///
/// This class follows the Singleton pattern and provides lazy initialization
/// of Firebase services to optimize startup performance.
class FirebaseService {
  /// Private constructor for singleton pattern.
  FirebaseService._();

  /// Singleton instance.
  static final FirebaseService instance = FirebaseService._();

  /// Whether Firebase has been initialized.
  bool _isInitialized = false;

  /// Cached Firestore instance.
  FirebaseFirestore? _firestore;

  /// Cached Auth instance.
  FirebaseAuth? _auth;

  /// Cached Storage instance.
  FirebaseStorage? _storage;

  /// Initializes Firebase with the appropriate platform options.
  ///
  /// This method is idempotent - calling it multiple times has no effect
  /// after the first successful initialization.
  ///
  /// Throws [FirebaseException] if initialization fails.
  Future<void> initialize() async {
    if (_isInitialized) return;

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    _isInitialized = true;
  }

  /// Returns whether Firebase has been initialized.
  bool get isInitialized => _isInitialized;

  /// Returns the Firestore instance.
  ///
  /// Lazily creates the instance on first access for better performance.
  FirebaseFirestore get firestore {
    _firestore ??= FirebaseFirestore.instance;
    return _firestore!;
  }

  /// Returns the Auth instance.
  ///
  /// Lazily creates the instance on first access for better performance.
  FirebaseAuth get auth {
    _auth ??= FirebaseAuth.instance;
    return _auth!;
  }

  /// Returns the Storage instance.
  ///
  /// Lazily creates the instance on first access for better performance.
  FirebaseStorage get storage {
    _storage ??= FirebaseStorage.instance;
    return _storage!;
  }
}

/// Firestore collection paths used across the application.
///
/// Centralized paths ensure consistency and make refactoring easier.
abstract final class FirestoreCollections {
  /// Orders collection - shared with Deliverzler app.
  static const String orders = 'orders';

  /// Users collection - contains drivers from Deliverzler.
  static const String users = 'users';

  /// Admins collection - admin accounts for dashboard.
  static const String admins = 'admins';

  /// Stores collection - registered stores.
  static const String stores = 'stores';

  /// Customers collection - customer accounts.
  static const String customers = 'customers';

  /// Drivers collection - driver accounts.
  static const String drivers = 'drivers';

  /// Store requests collection - pending store applications.
  static const String storeRequests = 'store_requests';

  /// Driver requests collection - pending driver applications.
  static const String driverRequests = 'driver_requests';

  /// Settings collection - app configuration.
  static const String settings = 'settings';

  /// Delivery zones collection - delivery area configuration.
  static const String deliveryZones = 'delivery_zones';
}

/// Firestore field names for Order documents.
///
/// Matches Deliverzler's field naming for compatibility.
abstract final class OrderFields {
  static const String id = 'id';
  static const String date = 'date';
  static const String pickupOption = 'pickupOption';
  static const String paymentMethod = 'paymentMethod';
  static const String addressModel = 'addressModel';
  static const String userId = 'userId';
  static const String userName = 'userName';
  static const String userImage = 'userImage';
  static const String userPhone = 'userPhone';
  static const String userNote = 'userNote';
  static const String employeeCancelNote = 'employeeCancelNote';
  static const String deliveryStatus = 'deliveryStatus';
  static const String deliveryId = 'deliveryId';
  static const String deliveryName = 'deliveryName';
  static const String deliveryGeoPoint = 'deliveryGeoPoint';
}

/// Firestore field names for User documents.
///
/// Matches Deliverzler's field naming for compatibility.
abstract final class UserFields {
  static const String id = 'id';
  static const String email = 'email';
  static const String name = 'name';
  static const String phone = 'phone';
  static const String image = 'image';
}
