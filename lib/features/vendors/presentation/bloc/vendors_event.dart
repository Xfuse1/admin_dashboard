import 'package:equatable/equatable.dart';

import '../../domain/entities/vendor_entity.dart';

/// Base class for vendors events.
abstract class VendorsEvent extends Equatable {
  const VendorsEvent();

  @override
  List<Object?> get props => [];
}

/// Load vendors event.
class LoadVendors extends VendorsEvent {
  final VendorStatus? status;
  final VendorCategory? category;
  final String? searchQuery;

  const LoadVendors({
    this.status,
    this.category,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [status, category, searchQuery];
}

/// Load more vendors for pagination.
class LoadMoreVendors extends VendorsEvent {
  const LoadMoreVendors();
}

/// Search vendors.
class SearchVendors extends VendorsEvent {
  final String query;

  const SearchVendors(this.query);

  @override
  List<Object?> get props => [query];
}

/// Filter by status.
class FilterByStatus extends VendorsEvent {
  final VendorStatus? status;

  const FilterByStatus(this.status);

  @override
  List<Object?> get props => [status];
}

/// Filter by category.
class FilterByCategory extends VendorsEvent {
  final VendorCategory? category;

  const FilterByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

/// Select a vendor.
class SelectVendor extends VendorsEvent {
  final String vendorId;

  const SelectVendor(this.vendorId);

  @override
  List<Object?> get props => [vendorId];
}

/// Clear selected vendor.
class ClearSelectedVendor extends VendorsEvent {
  const ClearSelectedVendor();
}

/// Update vendor.
class UpdateVendorEvent extends VendorsEvent {
  final VendorEntity vendor;

  const UpdateVendorEvent(this.vendor);

  @override
  List<Object?> get props => [vendor];
}

/// Delete vendor.
class DeleteVendorEvent extends VendorsEvent {
  final String vendorId;

  const DeleteVendorEvent(this.vendorId);

  @override
  List<Object?> get props => [vendorId];
}

/// Toggle vendor status.
class ToggleVendorStatusEvent extends VendorsEvent {
  final String vendorId;
  final VendorStatus status;

  const ToggleVendorStatusEvent(this.vendorId, this.status);

  @override
  List<Object?> get props => [vendorId, status];
}

/// Toggle featured status.
class ToggleFeaturedStatusEvent extends VendorsEvent {
  final String vendorId;
  final bool isFeatured;

  const ToggleFeaturedStatusEvent(this.vendorId, this.isFeatured);

  @override
  List<Object?> get props => [vendorId, isFeatured];
}

/// Verify vendor.
class VerifyVendorEvent extends VendorsEvent {
  final String vendorId;

  const VerifyVendorEvent(this.vendorId);

  @override
  List<Object?> get props => [vendorId];
}

/// Watch vendors stream.
class WatchVendorsEvent extends VendorsEvent {
  final VendorStatus? status;
  final VendorCategory? category;

  const WatchVendorsEvent({this.status, this.category});

  @override
  List<Object?> get props => [status, category];
}

/// Refresh vendors.
class RefreshVendors extends VendorsEvent {
  const RefreshVendors();
}

/// Load vendor products.
class LoadVendorProductsEvent extends VendorsEvent {
  final String vendorId;

  const LoadVendorProductsEvent(this.vendorId);

  @override
  List<Object?> get props => [vendorId];
}
