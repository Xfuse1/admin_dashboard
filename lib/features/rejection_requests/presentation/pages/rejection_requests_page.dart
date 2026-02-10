// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../../domain/entities/rejection_request_entities.dart';
import '../bloc/rejection_requests_bloc.dart';
import '../bloc/rejection_requests_event.dart';
import '../bloc/rejection_requests_state.dart';
import '../widgets/rejection_action_dialogs.dart';
import '../widgets/rejection_request_card.dart';
import '../widgets/rejection_request_details_sheet.dart';
import '../widgets/rejection_stats_cards.dart';

/// Rejection requests management page.
class RejectionRequestsPage extends StatefulWidget {
  const RejectionRequestsPage({super.key});

  @override
  State<RejectionRequestsPage> createState() => _RejectionRequestsPageState();
}

class _RejectionRequestsPageState extends State<RejectionRequestsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _scrollController = ScrollController();
  bool _isInitialized = false; // Guard flag to prevent duplicate calls
  String? _lastLoadedStatus; // Track last loaded status

  final _tabs = [
    const _RejectionTab(
        'pending', 'قيد الانتظار', Iconsax.timer_1, Colors.orange),
    const _RejectionTab(
        'approved', 'تم القبول', Iconsax.tick_circle, Colors.green),
    const _RejectionTab(
        'rejected', 'تم الرفض', Iconsax.close_circle, Colors.red),
    const _RejectionTab(null, 'الكل', Iconsax.document, AppColors.primary),
  ];

  @override
  void initState() {
    super.initState();
    print('🔵 [Page] initState called');

    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabControllerChanged);

    // ✅ Load initial tab only once using postFrameCallback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        _isInitialized = true;
        _loadCurrentTab();
      }
    });
  }

  void _onTabControllerChanged() {
    // Only react when the tab animation completes, not during animation
    if (!_tabController.indexIsChanging && _isInitialized) {
      print('🔄 [Page] Tab changed to index: ${_tabController.index}');
      _loadCurrentTab();
    }
  }

  void _loadCurrentTab() {
    final selectedTab = _tabs[_tabController.index];

    // Prevent loading the same status twice in a row
    if (_lastLoadedStatus == selectedTab.status) {
      print(
          '🔄 [Page] Skipping duplicate load for status: ${selectedTab.status}');
      return;
    }

    _lastLoadedStatus = selectedTab.status;
    print(
        '🔵 [Page] Loading tab: ${selectedTab.label} (status: ${selectedTab.status})');
    context.read<RejectionRequestsBloc>().add(
          WatchRejectionRequestsEvent(adminDecision: selectedTab.status),
        );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RejectionRequestsBloc, RejectionRequestsState>(
      listener: (context, state) {
        if (state is RejectionRequestsOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(AppConstants.spacingMd),
            ),
          );
        } else if (state is RejectionRequestsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(AppConstants.spacingMd),
            ),
          );
        }
      },
      child: ResponsiveLayout(
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
        desktop: _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverToBoxAdapter(child: _buildStatsCards()),
              SliverToBoxAdapter(child: _buildTabBar()),
              SliverToBoxAdapter(child: _buildRequestsList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverToBoxAdapter(child: _buildStatsCards()),
              SliverToBoxAdapter(child: _buildTabBar()),
              SliverToBoxAdapter(child: _buildRequestsDataTable()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader()),
                  SliverToBoxAdapter(child: _buildStatsCards()),
                  SliverToBoxAdapter(child: _buildTabBar()),
                  SliverToBoxAdapter(child: _buildRequestsDataTable()),
                ],
              ),
            ),
          ),
          BlocBuilder<RejectionRequestsBloc, RejectionRequestsState>(
            buildWhen: (prev, curr) {
              if (prev is RejectionRequestsLoaded &&
                  curr is RejectionRequestsLoaded) {
                return prev.selectedRequest != curr.selectedRequest;
              }
              return false;
            },
            builder: (context, state) {
              if (state is RejectionRequestsLoaded &&
                  state.selectedRequest != null) {
                return Container(
                  width: 400,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: AppColors.divider,
                        width: 1,
                      ),
                    ),
                  ),
                  child: RejectionRequestDetailsSheet(
                    request: state.selectedRequest!,
                    onClose: () => context
                        .read<RejectionRequestsBloc>()
                        .add(const ClearSelectedRejectionRequest()),
                    onApprove: () =>
                        _showApproveDialog(context, state.selectedRequest!),
                    onReject: () =>
                        _showRejectDialog(context, state.selectedRequest!),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleRefresh() async {
    final currentState = context.read<RejectionRequestsBloc>().state;
    if (currentState is RejectionRequestsLoaded) {
      context.read<RejectionRequestsBloc>().add(
            LoadRejectionRequests(
              adminDecision: currentState.currentFilter,
            ),
          );
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
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
                      'اعتذارات السائقين',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'مراجعة واتخاذ قرارات بشأن طلبات رفض السائقين',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              BlocBuilder<RejectionRequestsBloc, RejectionRequestsState>(
                builder: (context, state) {
                  final isLoading = state is RejectionRequestsLoading;
                  return IconButton(
                    icon: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Iconsax.refresh),
                    onPressed: isLoading ? null : _handleRefresh,
                    tooltip: 'تحديث',
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return BlocBuilder<RejectionRequestsBloc, RejectionRequestsState>(
      builder: (context, state) {
        if (state is RejectionRequestsLoaded) {
          return RejectionStatsCards(
            totalRequests: state.requests.length,
            pendingCount: state.pendingCount,
            stats: state.stats,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTabBar() {
    return BlocBuilder<RejectionRequestsBloc, RejectionRequestsState>(
      builder: (context, state) {
        return Container(
          margin:
              const EdgeInsets.symmetric(horizontal: AppConstants.spacingLg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          ),
          child: TabBar(
            controller: _tabController,
            tabs: _tabs
                .map((tab) => Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(tab.icon, size: 18),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              tab.label,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (tab.status == 'pending' &&
                              state is RejectionRequestsLoaded &&
                              state.pendingCount > 0)
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: tab.color,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${state.pendingCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ))
                .toList(),
            isScrollable: true,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            tabAlignment: TabAlignment.start,
          ),
        );
      },
    );
  }

  Widget _buildRequestsList() {
    return BlocBuilder<RejectionRequestsBloc, RejectionRequestsState>(
      builder: (context, state) {
        if (state is RejectionRequestsLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppConstants.spacingXl),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is RejectionRequestsError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingXl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Iconsax.danger, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _handleRefresh,
                    icon: const Icon(Iconsax.refresh),
                    label: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is RejectionRequestsLoaded) {
          if (state.requests.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingXl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Iconsax.document_text,
                      size: 64,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد طلبات رفض',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'سيتم عرض الطلبات هنا عندما تكون متوفرة',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(AppConstants.spacingLg),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.requests.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppConstants.spacingMd),
              itemBuilder: (context, index) {
                final request = state.requests[index];
                return RejectionRequestCard(
                  request: request,
                  onTap: () => _showRequestDetails(context, request),
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _showRequestDetails(
      BuildContext context, RejectionRequestEntity request) {
    context.read<RejectionRequestsBloc>().add(
          SelectRejectionRequest(request),
        );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppConstants.radiusLg),
            ),
          ),
          child: RejectionRequestDetailsSheet(
            request: request,
            scrollController: scrollController,
            onClose: () => Navigator.pop(context),
            onApprove: () {
              Navigator.pop(context);
              if (mounted) {
                _showApproveDialog(this.context, request);
              }
            },
            onReject: () {
              Navigator.pop(context);
              if (mounted) {
                _showRejectDialog(this.context, request);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRequestsDataTable() {
    return BlocBuilder<RejectionRequestsBloc, RejectionRequestsState>(
      builder: (context, state) {
        if (state is RejectionRequestsLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppConstants.spacingXl),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is RejectionRequestsError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingXl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Iconsax.danger, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _handleRefresh,
                    icon: const Icon(Iconsax.refresh),
                    label: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is RejectionRequestsLoaded) {
          if (state.requests.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingXl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Iconsax.document_text,
                      size: 64,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد طلبات رفض',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(AppConstants.spacingLg),
            child: GlassCard(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth,
                      ),
                      child: DataTable(
                        columnSpacing: 20,
                        horizontalMargin: 16,
                        columns: const [
                          DataColumn(label: Text('السائق')),
                          DataColumn(label: Text('رقم الطلب')),
                          DataColumn(label: Text('السبب')),
                          DataColumn(label: Text('وقت الانتظار')),
                          DataColumn(label: Text('الحالة')),
                          DataColumn(label: Text('الإجراءات')),
                        ],
                        rows: state.requests.map((request) {
                          return DataRow(
                            selected: state.selectedRequest?.requestId ==
                                request.requestId,
                            onSelectChanged: (_) {
                              context.read<RejectionRequestsBloc>().add(
                                    SelectRejectionRequest(request),
                                  );
                            },
                            cells: [
                              DataCell(
                                Text(
                                  request.driverName,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              DataCell(
                                  Text('#${request.orderId.substring(0, 8)}')),
                              DataCell(
                                SizedBox(
                                  width: 200,
                                  child: Text(
                                    request.reason,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                              ),
                              DataCell(_buildWaitTimeCell(context, request)),
                              DataCell(_buildStatusBadge(context, request)),
                              DataCell(_buildActionButtons(context, request)),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildWaitTimeCell(
    BuildContext context,
    RejectionRequestEntity request,
  ) {
    final minutes = request.waitTimeMinutes;
    final color = _getSLAColor(request.slaStatus);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      ),
      child: Text(
        Formatters.formatDuration(minutes),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(
    BuildContext context,
    RejectionRequestEntity request,
  ) {
    Color color;
    String label;

    switch (request.adminDecision) {
      case 'pending':
        color = Colors.orange;
        label = 'قيد الانتظار';
        break;
      case 'approved':
        color = Colors.green;
        label = 'تم القبول';
        break;
      case 'rejected':
        color = Colors.red;
        label = 'تم الرفض';
        break;
      default:
        color = Colors.grey;
        label = 'غير معروف';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    RejectionRequestEntity request,
  ) {
    if (request.isPending) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon:
                const Icon(Iconsax.tick_circle, color: Colors.green, size: 20),
            onPressed: () => _showApproveDialog(context, request),
            tooltip: 'قبول',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Iconsax.close_circle, color: Colors.red, size: 20),
            onPressed: () => _showRejectDialog(context, request),
            tooltip: 'رفض',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      );
    }

    return const Text('-');
  }

  Color _getSLAColor(String slaStatus) {
    switch (slaStatus) {
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.orange;
      case 'red':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _showApproveDialog(
    BuildContext context,
    RejectionRequestEntity request,
  ) async {
    final comment = await showDialog<String>(
      context: context,
      builder: (context) => ApproveExcuseDialog(driverName: request.driverName),
    );

    if (comment != null && context.mounted) {
      context.read<RejectionRequestsBloc>().add(
            ApproveExcuseEvent(
              requestId: request.requestId,
              adminComment: comment.isEmpty ? null : comment,
            ),
          );
    }
  }

  Future<void> _showRejectDialog(
    BuildContext context,
    RejectionRequestEntity request,
  ) async {
    final comment = await showDialog<String>(
      context: context,
      builder: (context) => RejectExcuseDialog(driverName: request.driverName),
    );

    if (comment != null && context.mounted) {
      context.read<RejectionRequestsBloc>().add(
            RejectExcuseEvent(
              requestId: request.requestId,
              adminComment: comment,
            ),
          );
    }
  }
}

class _RejectionTab {
  final String? status;
  final String label;
  final IconData icon;
  final Color color;

  const _RejectionTab(this.status, this.label, this.icon, this.color);
}

/// Details panel widget
class OrderDetailsPanel extends StatelessWidget {
  final RejectionRequestEntity request;

  const OrderDetailsPanel({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تفاصيل الطلب',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppConstants.spacingMd),
          _buildDetailRow(context, 'السائق', request.driverName),
          _buildDetailRow(context, 'رقم الطلب', '#${request.orderId}'),
          _buildDetailRow(context, 'السبب', request.reason),
          // Add more details as needed
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
