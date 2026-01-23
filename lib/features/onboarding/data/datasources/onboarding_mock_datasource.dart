import '../../domain/entities/onboarding_entities.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../models/onboarding_models.dart';
import 'onboarding_datasource.dart';

/// Mock implementation of OnboardingDataSource for development.
class OnboardingMockDataSource implements OnboardingDataSource {
  late final List<dynamic> _mockRequests;

  OnboardingMockDataSource() {
    _mockRequests = _generateMockRequests();
  }

  @override
  Future<List<dynamic>> getRequests({
    OnboardingType? type,
    OnboardingStatus? status,
    int limit = 20,
    String? lastId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    var requests = List<dynamic>.from(_mockRequests);

    // Apply filters
    if (type != null) {
      requests = requests.where((r) => r.type == type).toList();
    }
    if (status != null) {
      requests = requests.where((r) => r.status == status).toList();
    }

    // Sort by creation date
    requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Apply pagination
    if (lastId != null) {
      final lastIndex = requests.indexWhere((r) => r.id == lastId);
      if (lastIndex != -1) {
        requests = requests.sublist(lastIndex + 1);
      }
    }

    return requests.take(limit).toList();
  }

  @override
  Future<dynamic> getRequestById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return _mockRequests.firstWhere(
      (r) => r.id == id,
      orElse: () => throw Exception('Request not found'),
    );
  }

  @override
  Future<void> approveRequest(String id, {String? notes}) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _mockRequests.indexWhere((r) => r.id == id);
    if (index == -1) {
      throw Exception('Request not found');
    }

    final request = _mockRequests[index];
    if (request is StoreOnboardingModel) {
      _mockRequests[index] = StoreOnboardingModel(
        id: request.id,
        status: OnboardingStatus.approved,
        name: request.name,
        email: request.email,
        phone: request.phone,
        createdAt: request.createdAt,
        reviewedAt: DateTime.now(),
        reviewedBy: 'admin',
        notes: notes,
        storeName: request.storeName,
        storeType: request.storeType,
        address: request.address,
        ownerName: request.ownerName,
        ownerIdNumber: request.ownerIdNumber,
        commercialRegister: request.commercialRegister,
        logoUrl: request.logoUrl,
        commercialRegisterUrl: request.commercialRegisterUrl,
        ownerIdUrl: request.ownerIdUrl,
        categories: request.categories,
      );
    } else if (request is DriverOnboardingModel) {
      _mockRequests[index] = DriverOnboardingModel(
        id: request.id,
        status: OnboardingStatus.approved,
        name: request.name,
        email: request.email,
        phone: request.phone,
        createdAt: request.createdAt,
        reviewedAt: DateTime.now(),
        reviewedBy: 'admin',
        notes: notes,
        idNumber: request.idNumber,
        licenseNumber: request.licenseNumber,
        licenseExpiryDate: request.licenseExpiryDate,
        vehicleType: request.vehicleType,
        vehiclePlate: request.vehiclePlate,
        photoUrl: request.photoUrl,
        idDocumentUrl: request.idDocumentUrl,
        licenseUrl: request.licenseUrl,
        vehicleRegistrationUrl: request.vehicleRegistrationUrl,
        vehicleInsuranceUrl: request.vehicleInsuranceUrl,
      );
    }
  }

  @override
  Future<void> rejectRequest(String id, String reason) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _mockRequests.indexWhere((r) => r.id == id);
    if (index == -1) {
      throw Exception('Request not found');
    }

    final request = _mockRequests[index];
    if (request is StoreOnboardingModel) {
      _mockRequests[index] = StoreOnboardingModel(
        id: request.id,
        status: OnboardingStatus.rejected,
        name: request.name,
        email: request.email,
        phone: request.phone,
        createdAt: request.createdAt,
        reviewedAt: DateTime.now(),
        reviewedBy: 'admin',
        rejectionReason: reason,
        storeName: request.storeName,
        storeType: request.storeType,
        address: request.address,
        ownerName: request.ownerName,
        ownerIdNumber: request.ownerIdNumber,
        commercialRegister: request.commercialRegister,
        logoUrl: request.logoUrl,
        commercialRegisterUrl: request.commercialRegisterUrl,
        ownerIdUrl: request.ownerIdUrl,
        categories: request.categories,
      );
    } else if (request is DriverOnboardingModel) {
      _mockRequests[index] = DriverOnboardingModel(
        id: request.id,
        status: OnboardingStatus.rejected,
        name: request.name,
        email: request.email,
        phone: request.phone,
        createdAt: request.createdAt,
        reviewedAt: DateTime.now(),
        reviewedBy: 'admin',
        rejectionReason: reason,
        idNumber: request.idNumber,
        licenseNumber: request.licenseNumber,
        licenseExpiryDate: request.licenseExpiryDate,
        vehicleType: request.vehicleType,
        vehiclePlate: request.vehiclePlate,
        photoUrl: request.photoUrl,
        idDocumentUrl: request.idDocumentUrl,
        licenseUrl: request.licenseUrl,
        vehicleRegistrationUrl: request.vehicleRegistrationUrl,
        vehicleInsuranceUrl: request.vehicleInsuranceUrl,
      );
    }
  }

  @override
  Future<void> markUnderReview(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _mockRequests.indexWhere((r) => r.id == id);
    if (index == -1) {
      throw Exception('Request not found');
    }

    final request = _mockRequests[index];
    if (request is StoreOnboardingModel) {
      _mockRequests[index] = StoreOnboardingModel(
        id: request.id,
        status: OnboardingStatus.underReview,
        name: request.name,
        email: request.email,
        phone: request.phone,
        createdAt: request.createdAt,
        storeName: request.storeName,
        storeType: request.storeType,
        address: request.address,
        ownerName: request.ownerName,
        ownerIdNumber: request.ownerIdNumber,
        commercialRegister: request.commercialRegister,
        logoUrl: request.logoUrl,
        commercialRegisterUrl: request.commercialRegisterUrl,
        ownerIdUrl: request.ownerIdUrl,
        categories: request.categories,
      );
    } else if (request is DriverOnboardingModel) {
      _mockRequests[index] = DriverOnboardingModel(
        id: request.id,
        status: OnboardingStatus.underReview,
        name: request.name,
        email: request.email,
        phone: request.phone,
        createdAt: request.createdAt,
        idNumber: request.idNumber,
        licenseNumber: request.licenseNumber,
        licenseExpiryDate: request.licenseExpiryDate,
        vehicleType: request.vehicleType,
        vehiclePlate: request.vehiclePlate,
        photoUrl: request.photoUrl,
        idDocumentUrl: request.idDocumentUrl,
        licenseUrl: request.licenseUrl,
        vehicleRegistrationUrl: request.vehicleRegistrationUrl,
        vehicleInsuranceUrl: request.vehicleInsuranceUrl,
      );
    }
  }

  @override
  Future<OnboardingStats> getStats() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final pending = _mockRequests
        .where((r) => r.status == OnboardingStatus.pending)
        .toList();
    final approved = _mockRequests
        .where((r) => r.status == OnboardingStatus.approved)
        .toList();
    final rejected = _mockRequests
        .where((r) => r.status == OnboardingStatus.rejected)
        .toList();

    return OnboardingStats(
      totalRequests: _mockRequests.length,
      pendingRequests: pending.length,
      approvedRequests: approved.length,
      rejectedRequests: rejected.length,
      pendingStoreRequests:
          pending.where((r) => r.type == OnboardingType.store).length,
      pendingDriverRequests:
          pending.where((r) => r.type == OnboardingType.driver).length,
    );
  }
}

// ============================================
// MOCK DATA GENERATORS
// ============================================

List<dynamic> _generateMockRequests() {
  final now = DateTime.now();
  final storeNames = [
    'مطعم الأصيل',
    'كافيه روزا',
    'مخبز السعادة',
    'سوبرماركت الخير',
    'صيدلية النور',
  ];
  final driverNames = [
    'محمد العتيبي',
    'سعد الحربي',
    'خالد الشمري',
    'فهد القحطاني',
    'عبدالله الدوسري',
  ];
  final storeTypes = [
    'restaurant',
    'cafe',
    'bakery',
    'supermarket',
    'pharmacy'
  ];
  final vehicleTypes = ['دراجة نارية', 'سيارة صغيرة', 'سيارة كبيرة'];
  final statuses = [
    OnboardingStatus.pending,
    OnboardingStatus.pending,
    OnboardingStatus.pending,
    OnboardingStatus.underReview,
    OnboardingStatus.approved,
    OnboardingStatus.rejected,
  ];

  final List<dynamic> requests = [];

  // Generate store requests
  for (var i = 0; i < storeNames.length; i++) {
    requests.add(StoreOnboardingModel(
      id: 'store_request_${100 + i}',
      status: statuses[i % statuses.length],
      name: 'صاحب ${storeNames[i]}',
      email: 'store${i + 1}@example.com',
      phone: '050${1000000 + i}',
      createdAt: now.subtract(Duration(days: i * 2)),
      storeName: storeNames[i],
      storeType: storeTypes[i],
      address:
          'حي ${['النزهة', 'الروضة', 'السلامة', 'الفيصلية', 'الزهراء'][i]}',
      ownerName: 'صاحب المتجر ${i + 1}',
      ownerIdNumber: '10${50000000 + i}',
      commercialRegister: 'CR${1000 + i}',
      categories: ['طعام', 'مشروبات'],
      rejectionReason:
          statuses[i % statuses.length] == OnboardingStatus.rejected
              ? 'وثائق غير مكتملة'
              : null,
    ));
  }

  // Generate driver requests
  for (var i = 0; i < driverNames.length; i++) {
    requests.add(DriverOnboardingModel(
      id: 'driver_request_${100 + i}',
      status: statuses[(i + 1) % statuses.length],
      name: driverNames[i],
      email: 'driver${i + 1}@example.com',
      phone: '055${1000000 + i}',
      createdAt: now.subtract(Duration(days: i * 3)),
      idNumber: '11${50000000 + i}',
      licenseNumber: 'DL${5000 + i}',
      licenseExpiryDate: now.add(Duration(days: 365 + i * 30)),
      vehicleType: vehicleTypes[i % vehicleTypes.length],
      vehiclePlate: 'أ ب ج ${1000 + i}',
      rejectionReason:
          statuses[(i + 1) % statuses.length] == OnboardingStatus.rejected
              ? 'رخصة منتهية الصلاحية'
              : null,
    ));
  }

  return requests;
}
