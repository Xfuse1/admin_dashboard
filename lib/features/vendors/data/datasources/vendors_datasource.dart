import '../../domain/entities/vendor_entity.dart';

/// Abstract data source for vendors.
abstract class VendorsDataSource {
  /// Get all vendors with optional filters and pagination.
  Future<List<VendorEntity>> getVendors({
    VendorStatus? status,
    VendorCategory? category,
    String? searchQuery,
    int? limit,
    String? lastDocumentId,
  });

  /// Get a single vendor by ID.
  Future<VendorEntity> getVendor(String id);

  /// Add a new vendor.
  Future<VendorEntity> addVendor(VendorEntity vendor);

  /// Update an existing vendor.
  Future<VendorEntity> updateVendor(VendorEntity vendor);

  /// Delete a vendor.
  Future<void> deleteVendor(String id);

  /// Toggle vendor status.
  Future<VendorEntity> toggleVendorStatus(String id, VendorStatus status);

  /// Update vendor rating.
  Future<VendorEntity> updateVendorRating(
    String id,
    double rating,
    int totalRatings,
  );

  /// Get vendor statistics.
  Future<Map<String, dynamic>> getVendorStats();

  /// Watch vendors in real-time.
  Stream<List<VendorEntity>> watchVendors({
    VendorStatus? status,
    VendorCategory? category,
  });

  /// Get vendors by category.
  Future<List<VendorEntity>> getVendorsByCategory(VendorCategory category);

  /// Get featured vendors.
  Future<List<VendorEntity>> getFeaturedVendors();

  /// Toggle featured status.
  Future<VendorEntity> toggleFeaturedStatus(String id, bool isFeatured);

  /// Verify a vendor.
  Future<VendorEntity> verifyVendor(String id);
}
