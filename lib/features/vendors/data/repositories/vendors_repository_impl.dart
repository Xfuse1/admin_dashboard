import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/vendor_entity.dart';
import '../../domain/repositories/vendors_repository.dart';
import '../datasources/vendors_datasource.dart';

/// Implementation of [VendorsRepository].
class VendorsRepositoryImpl implements VendorsRepository {
  final VendorsDataSource dataSource;

  VendorsRepositoryImpl(this.dataSource);

  /// Converts exceptions to appropriate Failure types.
  Failure _handleError(dynamic error, [String? context]) {
    // Handle Firebase-specific errors
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return FirebaseFailure.permissionDenied();
        case 'not-found':
          return NotFoundFailure.vendor();
        case 'unavailable':
          return NetworkFailure.noConnection();
        case 'deadline-exceeded':
          return NetworkFailure.timeout();
        case 'resource-exhausted':
          return FirebaseFailure.quotaExceeded();
        case 'already-exists':
          return DuplicateFailure.generic('المتجر');
        default:
          return FirebaseFailure(
            message: error.message ?? 'حدث خطأ في قاعدة البيانات',
            code: error.code,
          );
      }
    }

    // Handle not found errors
    if (error.toString().contains('not found') ||
        error.toString().contains('غير موجود')) {
      return NotFoundFailure.vendor();
    }

    // Handle network errors
    if (error.toString().contains('network') ||
        error.toString().contains('connection')) {
      return NetworkFailure.noConnection();
    }

    // Handle timeout errors
    if (error.toString().contains('timeout')) {
      return NetworkFailure.timeout();
    }

    // Default to server failure with context
    final message = context != null
        ? 'خطأ في $context: ${error.toString()}'
        : error.toString();
    return ServerFailure(message: message);
  }

  @override
  Future<Either<Failure, List<VendorEntity>>> getVendors({
    VendorStatus? status,
    VendorCategory? category,
    String? searchQuery,
    int? limit,
    String? lastDocumentId,
  }) async {
    try {
      final vendors = await dataSource.getVendors(
        status: status,
        category: category,
        searchQuery: searchQuery,
        limit: limit,
        lastDocumentId: lastDocumentId,
      );
      return Right(vendors);
    } catch (e) {
      return Left(_handleError(e, 'جلب المتاجر'));
    }
  }

  @override
  Future<Either<Failure, VendorEntity>> getVendor(String id) async {
    try {
      final vendor = await dataSource.getVendor(id);
      return Right(vendor);
    } catch (e) {
      return Left(_handleError(e, 'جلب بيانات المتجر'));
    }
  }

  @override
  Future<Either<Failure, VendorEntity>> updateVendor(
    VendorEntity vendor,
  ) async {
    try {
      final updatedVendor = await dataSource.updateVendor(vendor);
      return Right(updatedVendor);
    } catch (e) {
      return Left(_handleError(e, 'تحديث المتجر'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteVendor(String id) async {
    try {
      await dataSource.deleteVendor(id);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e, 'حذف المتجر'));
    }
  }

  @override
  Future<Either<Failure, VendorEntity>> toggleVendorStatus(
    String id,
    VendorStatus status,
  ) async {
    try {
      final vendor = await dataSource.toggleVendorStatus(id, status);
      return Right(vendor);
    } catch (e) {
      return Left(_handleError(e, 'تغيير حالة المتجر'));
    }
  }

  @override
  Future<Either<Failure, VendorEntity>> updateVendorRating(
    String id,
    double rating,
    int totalRatings,
  ) async {
    try {
      final vendor =
          await dataSource.updateVendorRating(id, rating, totalRatings);
      return Right(vendor);
    } catch (e) {
      return Left(_handleError(e, 'تحديث تقييم المتجر'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getVendorStats() async {
    try {
      final stats = await dataSource.getVendorStats();
      return Right(stats);
    } catch (e) {
      return Left(_handleError(e, 'جلب إحصائيات المتاجر'));
    }
  }

  @override
  Stream<Either<Failure, List<VendorEntity>>> watchVendors({
    VendorStatus? status,
    VendorCategory? category,
  }) {
    try {
      return dataSource
          .watchVendors(status: status, category: category)
          .map((vendors) => Right<Failure, List<VendorEntity>>(vendors))
          .handleError((error) {
        return Left<Failure, List<VendorEntity>>(
          _handleError(error, 'مراقبة المتاجر'),
        );
      });
    } catch (e) {
      return Stream.value(
        Left<Failure, List<VendorEntity>>(
          _handleError(e, 'مراقبة المتاجر'),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<VendorEntity>>> getVendorsByCategory(
    VendorCategory category,
  ) async {
    try {
      final vendors = await dataSource.getVendorsByCategory(category);
      return Right(vendors);
    } catch (e) {
      return Left(_handleError(e, 'جلب متاجر الفئة'));
    }
  }

  @override
  Future<Either<Failure, List<VendorEntity>>> getFeaturedVendors() async {
    try {
      final vendors = await dataSource.getFeaturedVendors();
      return Right(vendors);
    } catch (e) {
      return Left(_handleError(e, 'جلب المتاجر المميزة'));
    }
  }

  @override
  Future<Either<Failure, VendorEntity>> toggleFeaturedStatus(
    String id,
    bool isFeatured,
  ) async {
    try {
      final vendor = await dataSource.toggleFeaturedStatus(id, isFeatured);
      return Right(vendor);
    } catch (e) {
      return Left(_handleError(e, 'تغيير حالة المتجر المميز'));
    }
  }

  @override
  Future<Either<Failure, VendorEntity>> verifyVendor(String id) async {
    try {
      final vendor = await dataSource.verifyVendor(id);
      return Right(vendor);
    } catch (e) {
      return Left(_handleError(e, 'التحقق من المتجر'));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getVendorProducts(
    String vendorId,
  ) async {
    try {
      final products = await dataSource.getVendorProducts(vendorId);
      return Right(products);
    } catch (e) {
      return Left(_handleError(e, 'جلب منتجات المتجر'));
    }
  }

  @override
  Future<Either<Failure, List<VendorEntity>>> bulkUpdateStatus(
    List<String> vendorIds,
    VendorStatus status,
  ) async {
    try {
      if (vendorIds.isEmpty) {
        return Left(
          ValidationFailure(
            message: 'يجب اختيار متجر واحد على الأقل',
            code: 'no-vendors-selected',
          ),
        );
      }

      final vendors = await dataSource.bulkUpdateStatus(vendorIds, status);
      return Right(vendors);
    } catch (e) {
      return Left(_handleError(e, 'تحديث حالة المتاجر'));
    }
  }

  @override
  Future<Either<Failure, void>> bulkDeleteVendors(
    List<String> vendorIds,
  ) async {
    try {
      if (vendorIds.isEmpty) {
        return Left(
          ValidationFailure(
            message: 'يجب اختيار متجر واحد على الأقل',
            code: 'no-vendors-selected',
          ),
        );
      }

      await dataSource.bulkDeleteVendors(vendorIds);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e, 'حذف المتاجر'));
    }
  }

  @override
  Future<Either<Failure, List<VendorEntity>>> bulkUpdateCommission(
    List<String> vendorIds,
    double commissionRate,
  ) async {
    try {
      if (vendorIds.isEmpty) {
        return Left(
          ValidationFailure(
            message: 'يجب اختيار متجر واحد على الأقل',
            code: 'no-vendors-selected',
          ),
        );
      }

      if (commissionRate < 0 || commissionRate > 100) {
        return Left(
          ValidationFailure(
            message: 'نسبة العمولة يجب أن تكون بين 0 و 100',
            code: 'invalid-commission-rate',
          ),
        );
      }

      final vendors =
          await dataSource.bulkUpdateCommission(vendorIds, commissionRate);
      return Right(vendors);
    } catch (e) {
      return Left(_handleError(e, 'تحديث عمولة المتاجر'));
    }
  }
}
