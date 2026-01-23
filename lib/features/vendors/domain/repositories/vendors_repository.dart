import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/vendor_entity.dart';

/// Repository interface for vendors.
abstract class VendorsRepository {
  /// Get all vendors with optional filters and pagination.
  Future<Either<Failure, List<VendorEntity>>> getVendors({
    VendorStatus? status,
    VendorCategory? category,
    String? searchQuery,
    int? limit,
    String? lastDocumentId,
  });

  /// Get a single vendor by ID.
  Future<Either<Failure, VendorEntity>> getVendor(String id);

  /// Add a new vendor.
  Future<Either<Failure, VendorEntity>> addVendor(VendorEntity vendor);

  /// Update an existing vendor.
  Future<Either<Failure, VendorEntity>> updateVendor(VendorEntity vendor);

  /// Delete a vendor.
  Future<Either<Failure, void>> deleteVendor(String id);

  /// Toggle vendor active status.
  Future<Either<Failure, VendorEntity>> toggleVendorStatus(
    String id,
    VendorStatus status,
  );

  /// Update vendor rating.
  Future<Either<Failure, VendorEntity>> updateVendorRating(
    String id,
    double rating,
    int totalRatings,
  );

  /// Get vendor statistics.
  Future<Either<Failure, Map<String, dynamic>>> getVendorStats();

  /// Watch vendors in real-time.
  Stream<Either<Failure, List<VendorEntity>>> watchVendors({
    VendorStatus? status,
    VendorCategory? category,
  });

  /// Get vendors by category.
  Future<Either<Failure, List<VendorEntity>>> getVendorsByCategory(
    VendorCategory category,
  );

  /// Get featured vendors.
  Future<Either<Failure, List<VendorEntity>>> getFeaturedVendors();

  /// Toggle vendor featured status.
  Future<Either<Failure, VendorEntity>> toggleFeaturedStatus(
    String id,
    bool isFeatured,
  );

  /// Verify a vendor.
  Future<Either<Failure, VendorEntity>> verifyVendor(String id);
}
