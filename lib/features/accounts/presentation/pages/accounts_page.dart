import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../../domain/entities/account_entities.dart';
import '../bloc/accounts_bloc.dart';
import '../bloc/accounts_event.dart';
import '../bloc/accounts_state.dart';
import '../widgets/customer_card.dart';
import '../widgets/driver_card.dart';
import '../widgets/store_card.dart';
import '../widgets/account_stats_cards.dart';
import '../widgets/customer_details_panel.dart';
import '../widgets/driver_details_panel.dart';

/// Accounts management page with 3 tabs: Customers, Stores, Drivers.
class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);

    // Note: All data (stats, customers, stores, drivers) is loaded
    // in app_router.dart BlocProvider.create for instant tab switching
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;

    final tab = switch (_tabController.index) {
      0 => AccountType.customer,
      1 => AccountType.store,
      2 => AccountType.driver,
      _ => AccountType.customer,
    };

    context.read<AccountsBloc>().add(SwitchAccountTab(tab));
    _searchController.clear();
  }

  void _onSearch(String query) {
    final bloc = context.read<AccountsBloc>();
    final state = bloc.state;

    if (state is AccountsLoaded) {
      switch (state.currentTab) {
        case AccountType.customer:
          bloc.add(SearchCustomers(query));
          break;
        case AccountType.store:
          bloc.add(SearchStores(query));
          break;
        case AccountType.driver:
          bloc.add(SearchDrivers(query));
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = ResponsiveLayout.getDeviceType(context);
        return BlocConsumer<AccountsBloc, AccountsState>(
          listenWhen: (previous, current) {
            // Check for customer selection only on mobile
            if (deviceType == DeviceType.mobile) {
              if (previous is AccountsLoaded && current is AccountsLoaded) {
                return (previous.selectedCustomer != current.selectedCustomer &&
                        current.selectedCustomer != null) ||
                    (previous.selectedDriver != current.selectedDriver &&
                        current.selectedDriver != null) ||
                    (previous.selectedStore != current.selectedStore &&
                        current.selectedStore != null);
              }
            }
            return current is AccountActionSuccess || current is AccountsError;
          },
          listener: (context, state) {
            if (state is AccountActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.success,
                ),
              );
            } else if (state is AccountsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            } else if (state is AccountsLoaded &&
                state.selectedCustomer != null &&
                deviceType == DeviceType.mobile) {
              _showCustomerDetailsSheet(context, state.selectedCustomer!);
            } else if (state is AccountsLoaded &&
                state.selectedDriver != null &&
                deviceType == DeviceType.mobile) {
              _showDriverDetailsSheet(context, state.selectedDriver!);
            }
          },
          builder: (context, state) {
            // Unwrap state to keep showing content during actions or after success
            final effectiveState = switch (state) {
              AccountActionSuccess(updatedState: final s) => s,
              AccountActionInProgress(previousState: final s) => s,
              AccountsLoaded() => state,
              _ => state is AccountsLoaded ? state : null,
            };

            // If we are still loading initial data or error
            if (effectiveState == null) {
              if (state is AccountsLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is AccountsError) {
                return Center(child: Text(state.message));
              }
              return const SizedBox.shrink();
            }

            return Scaffold(
              body: Column(
                children: [
                  // Header
                  _buildHeader(deviceType),

                  // Stats Cards
                  if (effectiveState.stats != null)
                    AccountStatsCards(stats: effectiveState.stats!),

                  // Tab Bar
                  _buildTabBar(deviceType),

                  // Content
                  Expanded(
                    child:
                        _buildContentWithSidePanel(effectiveState, deviceType),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCustomerDetailsSheet(
      BuildContext context, CustomerEntity customer) {
    final bloc = context.read<AccountsBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider.value(
        value: bloc,
        child: DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) => Container(
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: CustomerDetailsPanel(
              customer: customer,
              onClose: () {
                Navigator.pop(ctx);
                bloc.add(const SelectCustomer(null));
              },
            ),
          ),
        ),
      ),
    ).whenComplete(() {
      if (mounted) {
        bloc.add(const SelectCustomer(null));
      }
    });
  }

  void _showDriverDetailsSheet(BuildContext context, DriverEntity driver) {
    final bloc = context.read<AccountsBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider.value(
        value: bloc,
        child: DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) => Container(
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: DriverDetailsPanel(
              driver: driver,
              onClose: () {
                Navigator.pop(ctx);
                bloc.add(const SelectDriver(null));
              },
            ),
          ),
        ),
      ),
    ).whenComplete(() {
      if (mounted) {
        bloc.add(const SelectDriver(null));
      }
    });
  }

  Widget _buildContentWithSidePanel(
      AccountsLoaded state, DeviceType deviceType) {
    bool showSidePanel = deviceType != DeviceType.mobile &&
        (state.selectedCustomer != null || state.selectedDriver != null);

    Widget? sidePanel;
    if (state.selectedCustomer != null) {
      sidePanel = CustomerDetailsPanel(
        customer: state.selectedCustomer!,
        onClose: () =>
            context.read<AccountsBloc>().add(const SelectCustomer(null)),
      );
    } else if (state.selectedDriver != null) {
      sidePanel = DriverDetailsPanel(
        driver: state.selectedDriver!,
        onClose: () =>
            context.read<AccountsBloc>().add(const SelectDriver(null)),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main List
        Expanded(
          flex: showSidePanel ? 7 : 1,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildCustomersTab(state, deviceType),
              _buildStoresTab(state, deviceType),
              _buildDriversTab(state, deviceType),
            ],
          ),
        ),

        // Side Panel (Desktop/Tablet)
        if (showSidePanel && sidePanel != null) ...[
          Container(
            width: 1,
            color: AppColors.border,
          ),
          Expanded(
            flex: 3,
            child: Container(
              color: AppColors.surface,
              child: sidePanel,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHeader(DeviceType deviceType) {
    final isCompact = deviceType == DeviceType.mobile;

    return Container(
      padding: EdgeInsets.all(isCompact ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إدارة الحسابات',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'إدارة حسابات العملاء والمتاجر والسائقين',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search Bar
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _searchController,
            builder: (context, value, _) {
              return TextField(
                controller: _searchController,
                onChanged: _onSearch,
                decoration: InputDecoration(
                  hintText: 'البحث...',
                  prefixIcon: const Icon(Iconsax.search_normal_1),
                  suffixIcon: value.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _onSearch('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(DeviceType deviceType) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerHeight: 0,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        tabs: const [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Iconsax.people, size: 18),
                SizedBox(width: 8),
                Text('العملاء'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Iconsax.shop, size: 18),
                SizedBox(width: 8),
                Text('المتاجر'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Iconsax.car, size: 18),
                SizedBox(width: 8),
                Text('السائقين'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Removed old _buildContent as it is replaced by _buildContentWithSidePanel called inside build

  Widget _buildCustomersTab(AccountsState state, DeviceType deviceType) {
    // Cast to AccountsLoaded is safe here because we check before calling
    final loadedState = state as AccountsLoaded;

    if (loadedState.customers.isEmpty) {
      return _buildEmptyState('لا يوجد عملاء', Iconsax.people);
    }

    return _buildAccountList(
      items: loadedState.customers,
      isLoadingMore: loadedState.isLoadingMoreCustomers,
      hasMore: loadedState.hasMoreCustomers,
      onLoadMore: () =>
          context.read<AccountsBloc>().add(const LoadMoreCustomers()),
      itemBuilder: (customer) => CustomerCard(
        customer: customer,
        onTap: () => context.read<AccountsBloc>().add(SelectCustomer(customer)),
        onToggleStatus: (isActive) => context.read<AccountsBloc>().add(
              ToggleCustomerStatusEvent(
                  customerId: customer.id, isActive: isActive),
            ),
      ),
      deviceType: deviceType,
    );
  }

  Widget _buildStoresTab(AccountsState state, DeviceType deviceType) {
    if (state is! AccountsLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.stores.isEmpty) {
      return _buildEmptyState('لا يوجد متاجر', Iconsax.shop);
    }

    return _buildAccountList(
      items: state.stores,
      isLoadingMore: state.isLoadingMoreStores,
      hasMore: state.hasMoreStores,
      onLoadMore: () =>
          context.read<AccountsBloc>().add(const LoadMoreStores()),
      itemBuilder: (store) => StoreCard(
        store: store,
        onTap: () => context.read<AccountsBloc>().add(SelectStore(store)),
        onToggleStatus: (isActive) => context.read<AccountsBloc>().add(
              ToggleStoreStatusEvent(storeId: store.id, isActive: isActive),
            ),
      ),
      deviceType: deviceType,
    );
  }

  Widget _buildDriversTab(AccountsState state, DeviceType deviceType) {
    if (state is! AccountsLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.drivers.isEmpty) {
      return _buildEmptyState('لا يوجد سائقين', Iconsax.car);
    }

    return _buildAccountList(
      items: state.drivers,
      isLoadingMore: state.isLoadingMoreDrivers,
      hasMore: state.hasMoreDrivers,
      onLoadMore: () =>
          context.read<AccountsBloc>().add(const LoadMoreDrivers()),
      itemBuilder: (driver) => DriverCard(
        driver: driver,
        onTap: () => context.read<AccountsBloc>().add(SelectDriver(driver)),
        onToggleStatus: (isActive) => context.read<AccountsBloc>().add(
              ToggleDriverStatusEvent(driverId: driver.id, isActive: isActive),
            ),
        onViewLocation: () => _showDriverLocation(driver),
      ),
      deviceType: deviceType,
    );
  }

  Widget _buildAccountList<T>({
    required List<T> items,
    required bool isLoadingMore,
    required bool hasMore,
    required VoidCallback onLoadMore,
    required Widget Function(T item) itemBuilder,
    required DeviceType deviceType,
  }) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.extentAfter < 200 &&
            hasMore &&
            !isLoadingMore) {
          onLoadMore();
        }
        return false;
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 600,
            mainAxisExtent: 160,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          itemCount: items.length + (isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= items.length) {
              return const Center(child: CircularProgressIndicator());
            }
            return itemBuilder(items[index]);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              size: 80, color: AppColors.textSecondary.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  void _showDriverLocation(DriverEntity driver) {
    if (driver.latitude == null || driver.longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا يوجد موقع متاح لهذا السائق'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    backgroundImage:
                        driver.imageUrl != null && driver.imageUrl!.isNotEmpty
                            ? CachedNetworkImageProvider(driver.imageUrl!)
                            : null,
                    child: (driver.imageUrl == null || driver.imageUrl!.isEmpty)
                        ? Text(
                            driver.name.isNotEmpty ? driver.name[0] : '؟',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driver.name,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: driver.isOnline
                                    ? AppColors.success
                                    : AppColors.textSecondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                driver.isOnline ? 'متصل الآن' : 'غير متصل',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: driver.isOnline
                                          ? AppColors.success
                                          : AppColors.textSecondary,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Map
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildMapWidget(driver.latitude!, driver.longitude!),
                ),
              ),
              const SizedBox(height: 12),
              // Location info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Iconsax.location, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'الإحداثيات: ${driver.latitude!.toStringAsFixed(6)}, ${driver.longitude!.toStringAsFixed(6)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapWidget(double latitude, double longitude) {
    // Using Google Maps Flutter for web
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: 15,
      ),
      markers: {
        Marker(
          markerId: const MarkerId('driver_location'),
          position: LatLng(latitude, longitude),
          infoWindow: const InfoWindow(title: 'موقع السائق'),
        ),
      },
      zoomControlsEnabled: true,
      mapToolbarEnabled: false,
    );
  }
}
