import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/driver_application_entity.dart';
import '../bloc/accounts_bloc.dart';
import '../bloc/accounts_event.dart';
import '../bloc/accounts_state.dart';
import '../widgets/driver_application_card.dart';
import '../widgets/driver_application_details_sheet.dart';

/// Driver applications management page.
class DriverApplicationsPage extends StatefulWidget {
  const DriverApplicationsPage({super.key});

  @override
  State<DriverApplicationsPage> createState() => _DriverApplicationsPageState();
}

class _DriverApplicationsPageState extends State<DriverApplicationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _tabs = [
    const _ApplicationTab(null, 'الكل', Iconsax.document),
    const _ApplicationTab(
        ApplicationStatus.pending, 'قيد الانتظار', Iconsax.clock),
    const _ApplicationTab(
        ApplicationStatus.underReview, 'قيد المراجعة', Iconsax.eye),
    const _ApplicationTab(
        ApplicationStatus.approved, 'مقبول', Iconsax.tick_circle),
    const _ApplicationTab(
        ApplicationStatus.rejected, 'مرفوض', Iconsax.close_circle),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);

    // Load initial data
    context.read<AccountsBloc>().add(const LoadDriverApplications());
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final selectedTab = _tabs[_tabController.index];
    context
        .read<AccountsBloc>()
        .add(FilterDriverApplications(selectedTab.status));
  }

  @override
  Widget build(BuildContext context) {
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
              _buildHeader(context),
              _buildTabBar(),
              Expanded(child: _buildContent(context, state)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'طلبات السائقين',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'إدارة ومراجعة طلبات انضمام السائقين',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Iconsax.refresh),
            onPressed: () {
              final bloc = context.read<AccountsBloc>();
              final state = bloc.state;
              if (state is AccountsLoaded) {
                bloc.add(
                    LoadDriverApplications(status: state.applicationFilter));
              } else {
                bloc.add(const LoadDriverApplications());
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabs: _tabs.map((tab) {
          return Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(tab.icon, size: 18),
                const SizedBox(width: 8),
                Text(tab.label),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AccountsState state) {
    if (state is AccountsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is AccountsLoaded) {
      final applications = state.driverApplications;

      if (applications.isEmpty) {
        return _buildEmptyState(context);
      }

      return RefreshIndicator(
        onRefresh: () async {
          context.read<AccountsBloc>().add(
                LoadDriverApplications(status: state.applicationFilter),
              );
        },
        child: ResponsiveLayout.isMobile(context)
            ? _buildMobileList(applications)
            : _buildGridView(applications),
      );
    }

    if (state is AccountsError) {
      return _buildErrorState(context, state.message);
    }

    return const SizedBox.shrink();
  }

  Widget _buildMobileList(List<DriverApplicationEntity> applications) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      itemCount: applications.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.spacingSm),
          child: DriverApplicationCard(
            application: applications[index],
            onTap: () => _showApplicationDetails(context, applications[index]),
          ),
        );
      },
    );
  }

  Widget _buildGridView(List<DriverApplicationEntity> applications) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveLayout.isDesktop(context) ? 3 : 2,
        childAspectRatio: ResponsiveLayout.isDesktop(context) ? 1.3 : 1.1,
        crossAxisSpacing: AppConstants.spacingSm,
        mainAxisSpacing: AppConstants.spacingSm,
      ),
      itemCount: applications.length,
      itemBuilder: (context, index) {
        return DriverApplicationCard(
          application: applications[index],
          onTap: () => _showApplicationDetails(context, applications[index]),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.document,
            size: 64,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد طلبات',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.info_circle,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.error,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<AccountsBloc>().add(const LoadDriverApplications());
            },
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  void _showApplicationDetails(
    BuildContext context,
    DriverApplicationEntity application,
  ) {
    // Get admin ID from auth state
    final authState = context.read<AuthBloc>().state;
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

class _ApplicationTab {
  final ApplicationStatus? status;
  final String label;
  final IconData icon;

  const _ApplicationTab(this.status, this.label, this.icon);
}
