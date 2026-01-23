import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/account_entities.dart';
import '../bloc/accounts_bloc.dart';
import '../bloc/accounts_event.dart';
import '../bloc/accounts_state.dart';
import '../widgets/customer_card.dart';
import '../widgets/driver_application_card.dart';
import '../widgets/driver_application_details_sheet.dart';
import '../widgets/driver_card.dart';
import '../widgets/store_card.dart';
import '../widgets/account_stats_cards.dart';

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
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);

    // Load initial data
    context.read<AccountsBloc>()
      ..add(const LoadAccountStats())
      ..add(const LoadCustomers());
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

    if (_tabController.index == 3) {
      // Driver Applications tab
      context.read<AccountsBloc>().add(const LoadDriverApplications());
      _searchController.clear();
      return;
    }

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
            }
          },
          builder: (context, state) {
            return Scaffold(
              body: Column(
                children: [
                  // Header
                  _buildHeader(deviceType),

                  // Stats Cards
                  if (state is AccountsLoaded && state.stats != null)
                    AccountStatsCards(stats: state.stats!),

                  // Tab Bar
                  _buildTabBar(deviceType),

                  // Content
                  Expanded(
                    child: _buildContent(state, deviceType),
                  ),
                ],
              ),
            );
          },
        );
      },
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
          TextField(
            controller: _searchController,
            onChanged: _onSearch,
            decoration: InputDecoration(
              hintText: 'البحث...',
              prefixIcon: const Icon(Iconsax.search_normal_1),
              suffixIcon: _searchController.text.isNotEmpty
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
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.people, size: 18),
                SizedBox(width: 8),
                Text('العملاء'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.shop, size: 18),
                SizedBox(width: 8),
                Text('المتاجر'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.car, size: 18),
                SizedBox(width: 8),
                Text('السائقين'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.document_text, size: 18),
                SizedBox(width: 8),
                Text('طلبات السائقين'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AccountsState state, DeviceType deviceType) {
    if (state is AccountsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is AccountsError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.warning_2, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(state.message, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<AccountsBloc>().add(const LoadAccountStats());
              },
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildCustomersTab(state, deviceType),
        _buildStoresTab(state, deviceType),
        _buildDriversTab(state, deviceType),
        _buildDriverApplicationsTab(state, deviceType),
      ],
    );
  }

  Widget _buildCustomersTab(AccountsState state, DeviceType deviceType) {
    if (state is! AccountsLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.customers.isEmpty) {
      return _buildEmptyState('لا يوجد عملاء', Iconsax.people);
    }

    return _buildAccountList(
      items: state.customers,
      isLoadingMore: state.isLoadingMoreCustomers,
      hasMore: state.hasMoreCustomers,
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
    final crossAxisCount = switch (deviceType) {
      DeviceType.mobile => 1,
      DeviceType.tablet => 2,
      DeviceType.desktop => 3,
    };

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
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: deviceType == DeviceType.mobile ? 2.5 : 2.2,
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

  Widget _buildDriverApplicationsTab(
      AccountsState state, DeviceType deviceType) {
    if (state is! AccountsLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    final applications = state.driverApplications;

    if (applications.isEmpty) {
      return _buildEmptyState('لا توجد طلبات', Iconsax.document_text);
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: deviceType == DeviceType.mobile
              ? 1
              : deviceType == DeviceType.tablet
                  ? 2
                  : 3,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: deviceType == DeviceType.mobile ? 1.8 : 1.5,
        ),
        itemCount: applications.length,
        itemBuilder: (context, index) {
          return DriverApplicationCard(
            application: applications[index],
            onTap: () => _showApplicationDetails(applications[index]),
          );
        },
      ),
    );
  }

  void _showApplicationDetails(application) {
    // Get admin ID from auth state
    final authBloc = context.read<AuthBloc>();
    final authState = authBloc.state;
    final adminId = authState is AuthAuthenticated ? authState.user.id : '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider.value(
        value: context.read<AccountsBloc>(),
        child: DriverApplicationDetailsSheet(
          application: application,
          reviewerId: adminId,
        ),
      ),
    );
  }
}
