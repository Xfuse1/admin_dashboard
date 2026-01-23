import 'dart:async';

import '../../domain/repositories/accounts_repository.dart';
import '../models/account_models.dart';
import 'accounts_datasource.dart';

/// Mock implementation of AccountsDataSource for development.
class AccountsMockDataSource implements AccountsDataSource {
  // Mock data
  late final List<CustomerModel> _mockCustomers;
  late final List<StoreModel> _mockStores;
  late final List<DriverModel> _mockDrivers;

  // Stream controller for online drivers
  final _driversStreamController =
      StreamController<List<DriverModel>>.broadcast();

  AccountsMockDataSource() {
    _mockCustomers = _generateMockCustomers();
    _mockStores = _generateMockStores();
    _mockDrivers = _generateMockDrivers();

    // Initialize stream
    _driversStreamController.add(
      _mockDrivers.where((d) => d.isOnline).toList(),
    );
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
    await Future.delayed(const Duration(milliseconds: 500));

    var customers = List<CustomerModel>.from(_mockCustomers);

    // Apply search
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      customers = customers.where((c) {
        return c.name.toLowerCase().contains(query) ||
            c.email.toLowerCase().contains(query) ||
            c.phone.contains(query);
      }).toList();
    }

    // Apply filters
    if (isActive != null) {
      customers = customers.where((c) => c.isActive == isActive).toList();
    }

    // Sort by creation date
    customers.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Apply pagination
    if (lastId != null) {
      final lastIndex = customers.indexWhere((c) => c.id == lastId);
      if (lastIndex != -1) {
        customers = customers.sublist(lastIndex + 1);
      }
    }

    return customers.take(limit).toList();
  }

  @override
  Future<CustomerModel> getCustomerById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return _mockCustomers.firstWhere(
      (c) => c.id == id,
      orElse: () => throw Exception('Customer not found'),
    );
  }

  @override
  Future<void> toggleCustomerStatus(String id, bool isActive) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _mockCustomers.indexWhere((c) => c.id == id);
    if (index == -1) {
      throw Exception('Customer not found');
    }

    _mockCustomers[index] = _mockCustomers[index].copyWith(
      isActive: isActive,
      updatedAt: DateTime.now(),
    );
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
    await Future.delayed(const Duration(milliseconds: 500));

    var stores = List<StoreModel>.from(_mockStores);

    // Apply search
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      stores = stores.where((s) {
        return s.name.toLowerCase().contains(query) ||
            s.email.toLowerCase().contains(query) ||
            s.phone.contains(query);
      }).toList();
    }

    // Apply filters
    if (isActive != null) {
      stores = stores.where((s) => s.isActive == isActive).toList();
    }
    if (isApproved != null) {
      stores = stores.where((s) => s.isApproved == isApproved).toList();
    }
    if (type != null) {
      stores = stores.where((s) => s.type == type).toList();
    }

    // Sort by creation date
    stores.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Apply pagination
    if (lastId != null) {
      final lastIndex = stores.indexWhere((s) => s.id == lastId);
      if (lastIndex != -1) {
        stores = stores.sublist(lastIndex + 1);
      }
    }

    return stores.take(limit).toList();
  }

  @override
  Future<StoreModel> getStoreById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return _mockStores.firstWhere(
      (s) => s.id == id,
      orElse: () => throw Exception('Store not found'),
    );
  }

  @override
  Future<void> toggleStoreStatus(String id, bool isActive) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _mockStores.indexWhere((s) => s.id == id);
    if (index == -1) {
      throw Exception('Store not found');
    }

    _mockStores[index] = _mockStores[index].copyWith(
      isActive: isActive,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> updateStoreCommission(String id, double rate) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _mockStores.indexWhere((s) => s.id == id);
    if (index == -1) {
      throw Exception('Store not found');
    }

    _mockStores[index] = _mockStores[index].copyWith(
      commissionRate: rate,
      updatedAt: DateTime.now(),
    );
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
    await Future.delayed(const Duration(milliseconds: 500));

    var drivers = List<DriverModel>.from(_mockDrivers);

    // Apply search
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      drivers = drivers.where((d) {
        return d.name.toLowerCase().contains(query) ||
            d.email.toLowerCase().contains(query) ||
            d.phone.contains(query);
      }).toList();
    }

    // Apply filters
    if (isActive != null) {
      drivers = drivers.where((d) => d.isActive == isActive).toList();
    }
    if (isApproved != null) {
      drivers = drivers.where((d) => d.isApproved == isApproved).toList();
    }
    if (isOnline != null) {
      drivers = drivers.where((d) => d.isOnline == isOnline).toList();
    }

    // Sort by creation date
    drivers.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Apply pagination
    if (lastId != null) {
      final lastIndex = drivers.indexWhere((d) => d.id == lastId);
      if (lastIndex != -1) {
        drivers = drivers.sublist(lastIndex + 1);
      }
    }

    return drivers.take(limit).toList();
  }

  @override
  Future<DriverModel> getDriverById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return _mockDrivers.firstWhere(
      (d) => d.id == id,
      orElse: () => throw Exception('Driver not found'),
    );
  }

  @override
  Future<void> toggleDriverStatus(String id, bool isActive) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _mockDrivers.indexWhere((d) => d.id == id);
    if (index == -1) {
      throw Exception('Driver not found');
    }

    _mockDrivers[index] = _mockDrivers[index].copyWith(
      isActive: isActive,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Stream<List<DriverModel>> watchOnlineDrivers() {
    return _driversStreamController.stream;
  }

  // ============================================
  // 📊 STATISTICS
  // ============================================

  @override
  Future<AccountStats> getAccountStats() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return AccountStats(
      totalCustomers: _mockCustomers.length,
      activeCustomers: _mockCustomers.where((c) => c.isActive).length,
      totalStores: _mockStores.length,
      activeStores: _mockStores.where((s) => s.isActive).length,
      approvedStores: _mockStores.where((s) => s.isApproved).length,
      totalDrivers: _mockDrivers.length,
      activeDrivers: _mockDrivers.where((d) => d.isActive).length,
      onlineDrivers: _mockDrivers.where((d) => d.isOnline).length,
    );
  }

  void dispose() {
    _driversStreamController.close();
  }
}

// ============================================
// MOCK DATA GENERATORS
// ============================================

List<CustomerModel> _generateMockCustomers() {
  final now = DateTime.now();
  final names = [
    'أحمد محمد',
    'سارة علي',
    'خالد عبدالله',
    'فاطمة حسن',
    'يوسف عمر',
    'نورة سعيد',
    'محمد خالد',
    'لينا أحمد',
    'عبدالرحمن فهد',
    'ريم عبدالله',
    'طارق محمود',
    'هند سالم',
    'عمر ياسر',
    'مريم نايف',
    'سلمان راشد',
  ];

  return List.generate(names.length, (index) {
    return CustomerModel(
      id: 'customer_${100 + index}',
      name: names[index],
      email: 'customer${index + 1}@example.com',
      phone: '050${1000000 + index}',
      isActive: index % 5 != 0,
      createdAt: now.subtract(Duration(days: index * 10)),
      updatedAt: now.subtract(Duration(days: index * 2)),
      totalOrders: (index + 1) * 5,
      totalSpent: (index + 1) * 150.0,
      lastOrderDate: now.subtract(Duration(days: index)),
    );
  });
}

List<StoreModel> _generateMockStores() {
  final now = DateTime.now();
  final stores = [
    {'name': 'مطعم البيت', 'type': 'restaurant'},
    {'name': 'كافيه الصباح', 'type': 'cafe'},
    {'name': 'مطعم الشام', 'type': 'restaurant'},
    {'name': 'بيتزا هت', 'type': 'restaurant'},
    {'name': 'ماكدونالدز', 'type': 'fast_food'},
    {'name': 'سوبرماركت النجمة', 'type': 'supermarket'},
    {'name': 'مخبز الفرن', 'type': 'bakery'},
    {'name': 'صيدلية الشفاء', 'type': 'pharmacy'},
    {'name': 'متجر الإلكترونيات', 'type': 'electronics'},
    {'name': 'محل الزهور', 'type': 'flowers'},
  ];

  return List.generate(stores.length, (index) {
    final store = stores[index];
    return StoreModel(
      id: 'store_${100 + index}',
      name: store['name']!,
      email: 'store${index + 1}@example.com',
      phone: '011${1000000 + index}',
      type: store['type']!,
      address: 'حي ${[
        'النزهة',
        'الروضة',
        'السلامة',
        'الفيصلية',
        'الزهراء'
      ][index % 5]}',
      isActive: index % 4 != 0,
      isApproved: index % 3 != 0,
      isOpen: index % 2 == 0,
      rating: 3.5 + (index % 15) / 10,
      totalRatings: (index + 1) * 20,
      totalOrders: (index + 1) * 100,
      totalRevenue: (index + 1) * 5000.0,
      commissionRate: 0.15,
      createdAt: now.subtract(Duration(days: index * 30)),
      updatedAt: now.subtract(Duration(days: index * 5)),
      categories: ['طعام', 'مشروبات'],
    );
  });
}

List<DriverModel> _generateMockDrivers() {
  final now = DateTime.now();
  final names = [
    'سعود المطيري',
    'فهد العتيبي',
    'ناصر القحطاني',
    'عبدالله الشمري',
    'بندر الحربي',
    'تركي الدوسري',
    'ماجد الغامدي',
    'سلطان العنزي',
    'راكان السبيعي',
    'وليد الزهراني',
    'فيصل المالكي',
    'نواف العمري',
  ];

  final vehicles = ['دراجة نارية', 'سيارة صغيرة', 'سيارة كبيرة'];

  return List.generate(names.length, (index) {
    return DriverModel(
      id: 'driver_${100 + index}',
      name: names[index],
      email: 'driver${index + 1}@example.com',
      phone: '055${1000000 + index}',
      isActive: index % 4 != 0,
      isApproved: index % 3 != 0,
      isOnline: index % 2 == 0,
      rating: 4.0 + (index % 10) / 10,
      totalRatings: (index + 1) * 15,
      totalDeliveries: (index + 1) * 50,
      walletBalance: (index + 1) * 100.0,
      latitude: 24.7136 + (index * 0.02),
      longitude: 46.6753 + (index * 0.02),
      vehicleType: vehicles[index % vehicles.length],
      vehiclePlate: 'أ ب ج ${1000 + index}',
      createdAt: now.subtract(Duration(days: index * 20)),
      updatedAt: now.subtract(Duration(days: index * 3)),
    );
  });
}
