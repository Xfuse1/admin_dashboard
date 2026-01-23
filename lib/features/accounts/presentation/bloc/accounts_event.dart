import 'package:equatable/equatable.dart';

import '../../domain/entities/account_entities.dart';
import '../../domain/entities/driver_application_entity.dart';

/// Base class for Accounts events.
sealed class AccountsEvent extends Equatable {
  const AccountsEvent();

  @override
  List<Object?> get props => [];
}

// ============================================
// 📊 GENERAL
// ============================================

/// Load account statistics.
class LoadAccountStats extends AccountsEvent {
  const LoadAccountStats();
}

// ============================================
// 👥 CUSTOMERS
// ============================================

/// Load customers list.
class LoadCustomers extends AccountsEvent {
  final String? searchQuery;
  final bool? isActive;

  const LoadCustomers({this.searchQuery, this.isActive});

  @override
  List<Object?> get props => [searchQuery, isActive];
}

/// Load more customers (pagination).
class LoadMoreCustomers extends AccountsEvent {
  const LoadMoreCustomers();
}

/// Search customers.
class SearchCustomers extends AccountsEvent {
  final String query;

  const SearchCustomers(this.query);

  @override
  List<Object?> get props => [query];
}

/// Toggle customer active status.
class ToggleCustomerStatusEvent extends AccountsEvent {
  final String customerId;
  final bool isActive;

  const ToggleCustomerStatusEvent({
    required this.customerId,
    required this.isActive,
  });

  @override
  List<Object?> get props => [customerId, isActive];
}

/// Select a customer to view details.
class SelectCustomer extends AccountsEvent {
  final CustomerEntity? customer;

  const SelectCustomer(this.customer);

  @override
  List<Object?> get props => [customer];
}

// ============================================
// 🏪 STORES
// ============================================

/// Load stores list.
class LoadStores extends AccountsEvent {
  final String? searchQuery;
  final bool? isActive;
  final bool? isApproved;
  final String? type;

  const LoadStores({
    this.searchQuery,
    this.isActive,
    this.isApproved,
    this.type,
  });

  @override
  List<Object?> get props => [searchQuery, isActive, isApproved, type];
}

/// Load more stores (pagination).
class LoadMoreStores extends AccountsEvent {
  const LoadMoreStores();
}

/// Search stores.
class SearchStores extends AccountsEvent {
  final String query;

  const SearchStores(this.query);

  @override
  List<Object?> get props => [query];
}

/// Toggle store active status.
class ToggleStoreStatusEvent extends AccountsEvent {
  final String storeId;
  final bool isActive;

  const ToggleStoreStatusEvent({
    required this.storeId,
    required this.isActive,
  });

  @override
  List<Object?> get props => [storeId, isActive];
}

/// Update store commission rate.
class UpdateStoreCommissionEvent extends AccountsEvent {
  final String storeId;
  final double rate;

  const UpdateStoreCommissionEvent({
    required this.storeId,
    required this.rate,
  });

  @override
  List<Object?> get props => [storeId, rate];
}

/// Select a store to view details.
class SelectStore extends AccountsEvent {
  final StoreEntity? store;

  const SelectStore(this.store);

  @override
  List<Object?> get props => [store];
}

// ============================================
// 🚗 DRIVERS
// ============================================

/// Load drivers list.
class LoadDrivers extends AccountsEvent {
  final String? searchQuery;
  final bool? isActive;
  final bool? isApproved;
  final bool? isOnline;

  const LoadDrivers({
    this.searchQuery,
    this.isActive,
    this.isApproved,
    this.isOnline,
  });

  @override
  List<Object?> get props => [searchQuery, isActive, isApproved, isOnline];
}

/// Load more drivers (pagination).
class LoadMoreDrivers extends AccountsEvent {
  const LoadMoreDrivers();
}

/// Search drivers.
class SearchDrivers extends AccountsEvent {
  final String query;

  const SearchDrivers(this.query);

  @override
  List<Object?> get props => [query];
}

/// Toggle driver active status.
class ToggleDriverStatusEvent extends AccountsEvent {
  final String driverId;
  final bool isActive;

  const ToggleDriverStatusEvent({
    required this.driverId,
    required this.isActive,
  });

  @override
  List<Object?> get props => [driverId, isActive];
}

/// Select a driver to view details.
class SelectDriver extends AccountsEvent {
  final DriverEntity? driver;

  const SelectDriver(this.driver);

  @override
  List<Object?> get props => [driver];
}

/// Switch account tab.
class SwitchAccountTab extends AccountsEvent {
  final AccountType tab;

  const SwitchAccountTab(this.tab);

  @override
  List<Object?> get props => [tab];
}

/// Clear error state.
class ClearAccountsError extends AccountsEvent {
  const ClearAccountsError();
}

// ============================================
// 📋 DRIVER APPLICATIONS
// ============================================

/// Load driver applications list.
class LoadDriverApplications extends AccountsEvent {
  final ApplicationStatus? status;

  const LoadDriverApplications({this.status});

  @override
  List<Object?> get props => [status];
}

/// Filter driver applications by status.
class FilterDriverApplications extends AccountsEvent {
  final ApplicationStatus? status;

  const FilterDriverApplications(this.status);

  @override
  List<Object?> get props => [status];
}

/// Update driver application status.
class UpdateApplicationStatusEvent extends AccountsEvent {
  final String applicationId;
  final ApplicationStatus newStatus;
  final String reviewedBy;
  final String? rejectionReason;

  const UpdateApplicationStatusEvent({
    required this.applicationId,
    required this.newStatus,
    required this.reviewedBy,
    this.rejectionReason,
  });

  @override
  List<Object?> get props =>
      [applicationId, newStatus, reviewedBy, rejectionReason];
}

/// Select a driver application to view details.
class SelectDriverApplication extends AccountsEvent {
  final DriverApplicationEntity? application;

  const SelectDriverApplication(this.application);

  @override
  List<Object?> get props => [application];
}
