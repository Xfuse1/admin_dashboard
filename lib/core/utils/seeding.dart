import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/vendors/domain/entities/vendor_entity.dart';

class SeedingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> seedStores() async {
    final storesCollection = _firestore.collection('stores');
    final reviewsCollection = _firestore.collection('store_reviews');

    // Sample data to seed
    final List<Map<String, dynamic>> storesData = [
      {
        'name': 'مطعم الشيف المميز',
        'description': 'أشهى المأكولات الشرقية والغربية',
        'category': VendorCategory.restaurant.name,
        'status': VendorStatus.active.name,
        'address': {
          'street': 'شارع التخصصي',
          'city': 'الرياض',
          'country': 'السعودية',
          'latitude': 24.6953,
          'longitude': 46.6806,
        },
        'phone': '+966509876543',
        'email': 'chef@example.com',
        'logoUrl': 'https://placehold.co/400x400/png?text=Chef',
        'commissionRate': 15.0,
        'operatingHours': [
          {'day': DayOfWeek.sunday.index, 'openTime': '09:00', 'closeTime': '23:00', 'isClosed': false},
          {'day': DayOfWeek.monday.index, 'openTime': '09:00', 'closeTime': '23:00', 'isClosed': false},
          {'day': DayOfWeek.tuesday.index, 'openTime': '09:00', 'closeTime': '23:00', 'isClosed': false},
          {'day': DayOfWeek.wednesday.index, 'openTime': '09:00', 'closeTime': '23:00', 'isClosed': false},
          {'day': DayOfWeek.thursday.index, 'openTime': '09:00', 'closeTime': '00:00', 'isClosed': false},
          {'day': DayOfWeek.friday.index, 'openTime': '13:00', 'closeTime': '01:00', 'isClosed': false},
          {'day': DayOfWeek.saturday.index, 'openTime': '09:00', 'closeTime': '23:00', 'isClosed': false},
        ],
        'tags': ['مطعم', 'شرقي', 'عائلي'],
        'isVerified': true,
        'isFeatured': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'سوبر ماركت النجمة',
        'description': 'كل ما يحتاجه منزلك',
        'category': VendorCategory.grocery.name,
        'status': VendorStatus.active.name,
        'address': {
          'street': 'طريق الملك فهد',
          'city': 'الرياض',
          'country': 'السعودية',
          'latitude': 24.7136,
          'longitude': 46.6753,
        },
        'phone': '+966551234567',
        'email': 'star_market@example.com',
        'logoUrl': 'https://placehold.co/400x400/png?text=Market',
        'commissionRate': 10.0,
        'operatingHours': [
          {'day': DayOfWeek.sunday.index, 'openTime': '07:00', 'closeTime': '02:00', 'isClosed': false},
          // ... simpler hours for mock
        ],
        'tags': ['بقالة', 'خضروات', 'فواكه'],
        'isVerified': true,
        'isFeatured': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'صيدلية الشفاء',
        'description': 'دواؤك عندنا',
        'category': VendorCategory.pharmacy.name,
        'status': VendorStatus.active.name,
        'address': {
          'street': 'شارع العروبة',
          'city': 'الرياض',
          'country': 'السعودية',
          'latitude': 24.7210,
          'longitude': 46.6600,
        },
        'phone': '+966543210987',
        'email': 'shifa_pharm@example.com',
        'logoUrl': 'https://placehold.co/400x400/png?text=Pharma',
        'commissionRate': 8.0,
        'operatingHours': [], // 24/7 or unspecified
        'tags': ['صيدلية', 'أدوية', 'تجميل'],
        'isVerified': true,
        'isFeatured': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }
    ];


    for (final storeData in storesData) {
      // 1. Add store
      final docRef = await storesCollection.add(storeData);
      final storeId = docRef.id;

      // 2. Add reviews for this store
      final List<Map<String, dynamic>> reviews = [
        {
          'storeId': storeId,
          'userId': 'user_1',
          'userName': 'أحمد محمد',
          'rating': 5.0,
          'comment': 'خدمة ممتازة',
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'storeId': storeId,
          'userId': 'user_2',
          'userName': 'سارة علي',
          'rating': 4.0,
          'comment': 'جيد جدا',
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'storeId': storeId,
          'userId': 'user_3',
          'userName': 'خالد عمر',
          'rating': (storeData['name'].toString().contains('مطعم') ? 5.0 : 3.0),
          'comment': 'تجربة مقبولة',
          'createdAt': FieldValue.serverTimestamp(),
        }
      ];

      for (final review in reviews) {
        await reviewsCollection.add(review);
      }

      // 3. Add dummy products (optional but helpful for the new feature)
      final List<Map<String, dynamic>> products = [
        {
          'name': 'منتج 1',
          'description': 'وصف منتج 1',
          'price': 100.0,
          'imageUrl': 'https://placehold.co/200x200/png?text=Prod1',
          'ordersCount': 50,
          'isAvailable': true,
        },
        {
          'name': 'منتج 2',
          'description': 'وصف منتج 2',
          'price': 250.0,
          'imageUrl': 'https://placehold.co/200x200/png?text=Prod2',
          'ordersCount': 120,
          'isAvailable': true,
        }
      ];

      for (final product in products) {
        await docRef.collection('products').add(product);
      }
    }
  }

  /// Fixes data consistency issues by ensuring all documents have required fields.
  Future<void> fixDataConsistency() async {

    final now = DateTime.now().toIso8601String();

    // 1. Fix Customers (profiles)
    final profiles = await _firestore.collection('profiles').get();
    int fixedProfiles = 0;
    for (final doc in profiles.docs) {
      final data = doc.data();
      final updates = <String, dynamic>{};
      
      if (!data.containsKey('isActive')) updates['isActive'] = true;
      if (!data.containsKey('createdAt')) updates['createdAt'] = now;
      if (!data.containsKey('updatedAt')) updates['updatedAt'] = now;

      if (updates.isNotEmpty) {
        await doc.reference.update(updates);
        fixedProfiles++;
      }
    }

    // 2. Fix Stores (stores)
    final stores = await _firestore.collection('stores').get();
    int fixedStores = 0;
    for (final doc in stores.docs) {
      final data = doc.data();
      final updates = <String, dynamic>{};
      
      if (!data.containsKey('isActive')) updates['isActive'] = true;
      if (!data.containsKey('createdAt')) updates['createdAt'] = now;
      if (!data.containsKey('updatedAt')) updates['updatedAt'] = now;
      
      // Fix status based on isApproved and isActive
      if (!data.containsKey('status')) {
        final isApproved = data['isApproved'] ?? false;
        final isActive = data['isActive'] ?? true;
        
        if (!isApproved) {
          updates['status'] = 'pending';
        } else {
          updates['status'] = isActive ? 'active' : 'inactive';
        }
      }

      if (updates.isNotEmpty) {
        await doc.reference.update(updates);
        fixedStores++;
      }
    }

    // 3. Fix Drivers (drivers)
    final drivers = await _firestore.collection('drivers').get();
    int fixedDrivers = 0;
    for (final doc in drivers.docs) {
      final data = doc.data();
      final updates = <String, dynamic>{};
      
      if (!data.containsKey('isActive')) updates['isActive'] = true;
      if (!data.containsKey('createdAt')) updates['createdAt'] = now;
      if (!data.containsKey('updatedAt')) updates['updatedAt'] = now;

      if (updates.isNotEmpty) {
        await doc.reference.update(updates);
        fixedDrivers++;
      }
    }

  }
}
