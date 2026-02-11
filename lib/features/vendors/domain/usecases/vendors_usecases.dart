import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/product_entity.dart';
import '../entities/vendor_entity.dart';
import '../repositories/vendors_repository.dart';

/// Get vendors use case.
class GetVendors {
  final VendorsRepository repository;

  GetVendors(this.repository);

  Future<Either<Failure, List<VendorEntity>>> call({
    VendorStatus? status,
    VendorCategory? category,
    String? searchQuery,
    int? limit,
    String? lastDocumentId,
  }) {
    return repository.getVendors(
      status: status,
      category: category,
      searchQuery: searchQuery,
      limit: limit,
      lastDocumentId: lastDocumentId,
    );
  }
}

/// Get single vendor use case.
class GetVendor {
  final VendorsRepository repository;

  GetVendor(this.repository);

  Future<Either<Failure, VendorEntity>> call(String id) {
    return repository.getVendor(id);
  }
}

/// Update vendor use case.
class UpdateVendor {
  final VendorsRepository repository;

  UpdateVendor(this.repository);

  Future<Either<Failure, VendorEntity>> call(VendorEntity vendor) {
    return repository.updateVendor(vendor);
  }
}

/// Delete vendor use case.
class DeleteVendor {
  final VendorsRepository repository;

  DeleteVendor(this.repository);

  Future<Either<Failure, void>> call(String id) {
    return repository.deleteVendor(id);
  }
}

/// Toggle vendor status use case.
class ToggleVendorStatus {
  final VendorsRepository repository;

  ToggleVendorStatus(this.repository);

  Future<Either<Failure, VendorEntity>> call(
    String id,
    VendorStatus status,
  ) {
    return repository.toggleVendorStatus(id, status);
  }
}

/// Update vendor rating use case.
class UpdateVendorRating {
  final VendorsRepository repository;

  UpdateVendorRating(this.repository);

  Future<Either<Failure, VendorEntity>> call(
    String id,
    double rating,
    int totalRatings,
  ) {
    return repository.updateVendorRating(id, rating, totalRatings);
  }
}

/// Get vendor stats use case.
class GetVendorStats {
  final VendorsRepository repository;

  GetVendorStats(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call() {
    return repository.getVendorStats();
  }
}

/// Watch vendors use case.
class WatchVendors {
  final VendorsRepository repository;

  WatchVendors(this.repository);

  Stream<Either<Failure, List<VendorEntity>>> call({
    VendorStatus? status,
    VendorCategory? category,
  }) {
    return repository.watchVendors(status: status, category: category);
  }
}

/// Get vendors by category use case.
class GetVendorsByCategory {
  final VendorsRepository repository;

  GetVendorsByCategory(this.repository);

  Future<Either<Failure, List<VendorEntity>>> call(VendorCategory category) {
    return repository.getVendorsByCategory(category);
  }
}

/// Get featured vendors use case.
class GetFeaturedVendors {
  final VendorsRepository repository;

  GetFeaturedVendors(this.repository);

  Future<Either<Failure, List<VendorEntity>>> call() {
    return repository.getFeaturedVendors();
  }
}

/// Toggle featured status use case.
class ToggleFeaturedStatus {
  final VendorsRepository repository;

  ToggleFeaturedStatus(this.repository);

  Future<Either<Failure, VendorEntity>> call(String id, bool isFeatured) {
    return repository.toggleFeaturedStatus(id, isFeatured);
  }
}

/// Verify vendor use case.
class VerifyVendor {
  final VendorsRepository repository;

  VerifyVendor(this.repository);

  Future<Either<Failure, VendorEntity>> call(String id) {
    return repository.verifyVendor(id);
  }
}

/// Get vendor products use case.
class GetVendorProducts {
  final VendorsRepository repository;

  GetVendorProducts(this.repository);

  Future<Either<Failure, List<ProductEntity>>> call(String vendorId) {
    return repository.getVendorProducts(vendorId);
  }
}

/// Bulk update vendor status use case.
class BulkUpdateVendorStatus {
  final VendorsRepository repository;

  BulkUpdateVendorStatus(this.repository);

  Future<Either<Failure, List<VendorEntity>>> call(
    List<String> vendorIds,
    VendorStatus status,
  ) {
    return repository.bulkUpdateStatus(vendorIds, status);
  }
}

/// Bulk delete vendors use case.
class BulkDeleteVendors {
  final VendorsRepository repository;

  BulkDeleteVendors(this.repository);

  Future<Either<Failure, void>> call(List<String> vendorIds) {
    return repository.bulkDeleteVendors(vendorIds);
  }
}

/// Bulk update commission rate use case.
class BulkUpdateCommission {
  final VendorsRepository repository;

  BulkUpdateCommission(this.repository);

  Future<Either<Failure, List<VendorEntity>>> call(
    List<String> vendorIds,
    double commissionRate,
  ) {
    return repository.bulkUpdateCommission(vendorIds, commissionRate);
  }
}
