import 'dart:async';

import '../../domain/entities/vendor_entity.dart';
import 'vendors_datasource.dart';

/// Mock data source for vendors (development/testing).
class VendorsMockDataSource implements VendorsDataSource {
  final List<VendorEntity> _vendors = [
    VendorEntity(
      id: 'vendor_1',
      name: 'مطعم الشرق',
      description: 'أفضل المأكولات الشرقية والعربية',
      category: VendorCategory.restaurant,
      status: VendorStatus.active,
      address: const VendorAddress(
        street: 'شارع الملك فيصل',
        city: 'الرياض',
        country: 'السعودية',
        latitude: 24.7136,
        longitude: 46.6753,
      ),
      phone: '+966501234567',
      email: 'info@sharq.com',
      logoUrl: 'https://via.placeholder.com/150',
      rating: 4.5,
      totalRatings: 234,
      totalOrders: 1520,
      totalRevenue: 125000,
      commissionRate: 12.0,
      operatingHours: [
        const OperatingHours(
          day: DayOfWeek.sunday,
          openTime: '10:00',
          closeTime: '23:00',
        ),
        const OperatingHours(
          day: DayOfWeek.monday,
          openTime: '10:00',
          closeTime: '23:00',
        ),
        const OperatingHours(
          day: DayOfWeek.tuesday,
          openTime: '10:00',
          closeTime: '23:00',
        ),
        const OperatingHours(
          day: DayOfWeek.wednesday,
          openTime: '10:00',
          closeTime: '23:00',
        ),
        const OperatingHours(
          day: DayOfWeek.thursday,
          openTime: '10:00',
          closeTime: '00:00',
        ),
        const OperatingHours(
          day: DayOfWeek.friday,
          openTime: '14:00',
          closeTime: '00:00',
        ),
        const OperatingHours(
          day: DayOfWeek.saturday,
          openTime: '10:00',
          closeTime: '23:00',
        ),
      ],
      tags: ['عربي', 'شرقي', 'مشويات'],
      isVerified: true,
      isFeatured: true,
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    VendorEntity(
      id: 'vendor_2',
      name: 'سوبر ماركت الخير',
      description: 'كل احتياجاتك من البقالة',
      category: VendorCategory.grocery,
      status: VendorStatus.active,
      address: const VendorAddress(
        street: 'شارع العليا',
        city: 'الرياض',
        country: 'السعودية',
        latitude: 24.6918,
        longitude: 46.6850,
      ),
      phone: '+966502345678',
      email: 'contact@alkhayr.com',
      logoUrl: 'https://via.placeholder.com/150',
      rating: 4.2,
      totalRatings: 156,
      totalOrders: 2340,
      totalRevenue: 450000,
      commissionRate: 8.0,
      tags: ['بقالة', 'خضروات', 'فواكه'],
      isVerified: true,
      isFeatured: false,
      createdAt: DateTime.now().subtract(const Duration(days: 200)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    VendorEntity(
      id: 'vendor_3',
      name: 'صيدلية الحياة',
      description: 'صيدلية متكاملة على مدار الساعة',
      category: VendorCategory.pharmacy,
      status: VendorStatus.active,
      address: const VendorAddress(
        street: 'شارع التحلية',
        city: 'جدة',
        country: 'السعودية',
        latitude: 21.5433,
        longitude: 39.1728,
      ),
      phone: '+966503456789',
      email: 'pharmacy@alhayat.com',
      logoUrl: 'https://via.placeholder.com/150',
      rating: 4.8,
      totalRatings: 89,
      totalOrders: 876,
      totalRevenue: 95000,
      commissionRate: 5.0,
      tags: ['صيدلية', 'أدوية', 'مستلزمات طبية'],
      isVerified: true,
      isFeatured: true,
      createdAt: DateTime.now().subtract(const Duration(days: 150)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    VendorEntity(
      id: 'vendor_4',
      name: 'تك زون',
      description: 'أحدث الأجهزة الإلكترونية',
      category: VendorCategory.electronics,
      status: VendorStatus.inactive,
      address: const VendorAddress(
        street: 'مركز غرناطة',
        city: 'الرياض',
        country: 'السعودية',
        latitude: 24.7640,
        longitude: 46.7386,
      ),
      phone: '+966504567890',
      email: 'sales@techzone.com',
      website: 'https://techzone.com',
      logoUrl: 'https://via.placeholder.com/150',
      rating: 4.0,
      totalRatings: 45,
      totalOrders: 234,
      totalRevenue: 180000,
      commissionRate: 10.0,
      tags: ['إلكترونيات', 'هواتف', 'لابتوب'],
      isVerified: false,
      isFeatured: false,
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      updatedAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    VendorEntity(
      id: 'vendor_5',
      name: 'أزياء النخبة',
      description: 'أحدث صيحات الموضة',
      category: VendorCategory.fashion,
      status: VendorStatus.pending,
      address: const VendorAddress(
        street: 'مول العرب',
        city: 'جدة',
        country: 'السعودية',
        latitude: 21.4858,
        longitude: 39.1925,
      ),
      phone: '+966505678901',
      email: 'info@nokhba.com',
      logoUrl: 'https://via.placeholder.com/150',
      rating: 0.0,
      totalRatings: 0,
      totalOrders: 0,
      totalRevenue: 0,
      commissionRate: 15.0,
      tags: ['ملابس', 'أزياء', 'موضة'],
      isVerified: false,
      isFeatured: false,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  final _vendorsController = StreamController<List<VendorEntity>>.broadcast();

  @override
  Future<List<VendorEntity>> getVendors({
    VendorStatus? status,
    VendorCategory? category,
    String? searchQuery,
    int? limit,
    String? lastDocumentId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    var result = List<VendorEntity>.from(_vendors);

    if (status != null) {
      result = result.where((v) => v.status == status).toList();
    }

    if (category != null) {
      result = result.where((v) => v.category == category).toList();
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      result = result.where((v) {
        return v.name.toLowerCase().contains(query) ||
            (v.description?.toLowerCase().contains(query) ?? false) ||
            v.address.city.toLowerCase().contains(query);
      }).toList();
    }

    if (lastDocumentId != null) {
      final index = result.indexWhere((v) => v.id == lastDocumentId);
      if (index != -1) {
        result = result.sublist(index + 1);
      }
    }

    if (limit != null) {
      result = result.take(limit).toList();
    }

    return result;
  }

  @override
  Future<VendorEntity> getVendor(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _vendors.firstWhere(
      (v) => v.id == id,
      orElse: () => throw Exception('Vendor not found'),
    );
  }

  @override
  Future<VendorEntity> addVendor(VendorEntity vendor) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newVendor = vendor.copyWith(
      id: 'vendor_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _vendors.add(newVendor);
    _vendorsController.add(_vendors);
    return newVendor;
  }

  @override
  Future<VendorEntity> updateVendor(VendorEntity vendor) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _vendors.indexWhere((v) => v.id == vendor.id);
    if (index == -1) throw Exception('Vendor not found');

    final updatedVendor = vendor.copyWith(updatedAt: DateTime.now());
    _vendors[index] = updatedVendor;
    _vendorsController.add(_vendors);
    return updatedVendor;
  }

  @override
  Future<void> deleteVendor(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _vendors.removeWhere((v) => v.id == id);
    _vendorsController.add(_vendors);
  }

  @override
  Future<VendorEntity> toggleVendorStatus(
    String id,
    VendorStatus status,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _vendors.indexWhere((v) => v.id == id);
    if (index == -1) throw Exception('Vendor not found');

    final updatedVendor = _vendors[index].copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );
    _vendors[index] = updatedVendor;
    _vendorsController.add(_vendors);
    return updatedVendor;
  }

  @override
  Future<VendorEntity> updateVendorRating(
    String id,
    double rating,
    int totalRatings,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _vendors.indexWhere((v) => v.id == id);
    if (index == -1) throw Exception('Vendor not found');

    final updatedVendor = _vendors[index].copyWith(
      rating: rating,
      totalRatings: totalRatings,
      updatedAt: DateTime.now(),
    );
    _vendors[index] = updatedVendor;
    _vendorsController.add(_vendors);
    return updatedVendor;
  }

  @override
  Future<Map<String, dynamic>> getVendorStats() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final activeCount =
        _vendors.where((v) => v.status == VendorStatus.active).length;
    final inactiveCount =
        _vendors.where((v) => v.status == VendorStatus.inactive).length;
    final pendingCount =
        _vendors.where((v) => v.status == VendorStatus.pending).length;
    final suspendedCount =
        _vendors.where((v) => v.status == VendorStatus.suspended).length;

    final totalRevenue =
        _vendors.fold<double>(0, (sum, v) => sum + v.totalRevenue);
    final totalOrders = _vendors.fold<int>(0, (sum, v) => sum + v.totalOrders);

    final categoryDistribution = <String, int>{};
    for (final category in VendorCategory.values) {
      categoryDistribution[category.name] =
          _vendors.where((v) => v.category == category).length;
    }

    return {
      'totalVendors': _vendors.length,
      'activeVendors': activeCount,
      'inactiveVendors': inactiveCount,
      'pendingVendors': pendingCount,
      'suspendedVendors': suspendedCount,
      'totalRevenue': totalRevenue,
      'totalOrders': totalOrders,
      'averageRating': _vendors.fold<double>(0, (sum, v) => sum + v.rating) /
          _vendors.length,
      'categoryDistribution': categoryDistribution,
      'verifiedCount': _vendors.where((v) => v.isVerified).length,
      'featuredCount': _vendors.where((v) => v.isFeatured).length,
    };
  }

  @override
  Stream<List<VendorEntity>> watchVendors({
    VendorStatus? status,
    VendorCategory? category,
  }) {
    // Initial emit
    Future.delayed(const Duration(milliseconds: 100), () {
      var result = List<VendorEntity>.from(_vendors);
      if (status != null) {
        result = result.where((v) => v.status == status).toList();
      }
      if (category != null) {
        result = result.where((v) => v.category == category).toList();
      }
      _vendorsController.add(result);
    });

    return _vendorsController.stream.map((vendors) {
      var result = vendors;
      if (status != null) {
        result = result.where((v) => v.status == status).toList();
      }
      if (category != null) {
        result = result.where((v) => v.category == category).toList();
      }
      return result;
    });
  }

  @override
  Future<List<VendorEntity>> getVendorsByCategory(
    VendorCategory category,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _vendors.where((v) => v.category == category).toList();
  }

  @override
  Future<List<VendorEntity>> getFeaturedVendors() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _vendors.where((v) => v.isFeatured).toList();
  }

  @override
  Future<VendorEntity> toggleFeaturedStatus(String id, bool isFeatured) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _vendors.indexWhere((v) => v.id == id);
    if (index == -1) throw Exception('Vendor not found');

    final updatedVendor = _vendors[index].copyWith(
      isFeatured: isFeatured,
      updatedAt: DateTime.now(),
    );
    _vendors[index] = updatedVendor;
    _vendorsController.add(_vendors);
    return updatedVendor;
  }

  @override
  Future<VendorEntity> verifyVendor(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _vendors.indexWhere((v) => v.id == id);
    if (index == -1) throw Exception('Vendor not found');

    final updatedVendor = _vendors[index].copyWith(
      isVerified: true,
      updatedAt: DateTime.now(),
    );
    _vendors[index] = updatedVendor;
    _vendorsController.add(_vendors);
    return updatedVendor;
  }
}
