import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/vendor_entity.dart';
import '../../domain/repositories/vendors_repository.dart';
import '../datasources/vendors_datasource.dart';

/// Implementation of [VendorsRepository].
class VendorsRepositoryImpl implements VendorsRepository {
  final VendorsDataSource dataSource;

  VendorsRepositoryImpl(this.dataSource);

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
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, VendorEntity>> getVendor(String id) async {
    try {
      final vendor = await dataSource.getVendor(id);
      return Right(vendor);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, VendorEntity>> addVendor(VendorEntity vendor) async {
    try {
      final newVendor = await dataSource.addVendor(vendor);
      return Right(newVendor);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
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
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteVendor(String id) async {
    try {
      await dataSource.deleteVendor(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
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
      return Left(ServerFailure(message: e.toString()));
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
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getVendorStats() async {
    try {
      final stats = await dataSource.getVendorStats();
      return Right(stats);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<VendorEntity>>> watchVendors({
    VendorStatus? status,
    VendorCategory? category,
  }) {
    return dataSource.watchVendors(status: status, category: category).map(
          (vendors) => Right<Failure, List<VendorEntity>>(vendors),
        );
  }

  @override
  Future<Either<Failure, List<VendorEntity>>> getVendorsByCategory(
    VendorCategory category,
  ) async {
    try {
      final vendors = await dataSource.getVendorsByCategory(category);
      return Right(vendors);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<VendorEntity>>> getFeaturedVendors() async {
    try {
      final vendors = await dataSource.getFeaturedVendors();
      return Right(vendors);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
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
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, VendorEntity>> verifyVendor(String id) async {
    try {
      final vendor = await dataSource.verifyVendor(id);
      return Right(vendor);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
