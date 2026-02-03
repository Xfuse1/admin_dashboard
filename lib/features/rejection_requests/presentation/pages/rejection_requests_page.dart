import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../../domain/entities/rejection_request_entities.dart';
import '../bloc/rejection_requests_bloc.dart';
import '../bloc/rejection_requests_event.dart';
import '../bloc/rejection_requests_state.dart';
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
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);

    // Start watching rejection requests (real-time)
    context.read<RejectionRequestsBloc>().add(
          const WatchRejectionRequestsEvent(adminDecision: 'pending'),
        );
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final selectedTab = _tabs[_tabController.index];
    context.read<RejectionRequestsBloc>().add(
          FilterRejectionsByStatus(selectedTab.status),
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
            ),
          );
        } else if (state is RejectionRequestsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
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
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            _buildHeader(),
            _buildStatsCards(),
            _buildTabBar(),
            _buildRequestsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            _buildHeader(),
            _buildStatsCards(),
            _buildTabBar(),
            _buildRequestsDataTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main content
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  _buildHeader(),
                  _buildStatsCards(),
                  _buildTabBar(),
                  _buildRequestsDataTable(),
                ],
              ),
            ),
          ),

          // Details panel
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
                      'طلبات الرفض',
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
              // Refresh button
              IconButton(
                icon: const Icon(Iconsax.refresh),
                onPressed: () {
                  final currentState =
                      context.read<RejectionRequestsBloc>().state;
                  if (currentState is RejectionRequestsLoaded) {
                    context.read<RejectionRequestsBloc>().add(
                          LoadRejectionRequests(
                            adminDecision: currentState.currentFilter,
                          ),
                        );
                  }
                },
                tooltip: 'تحديث',
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(tab.icon, size: 18),
                          const SizedBox(width: 8),
                          Text(tab.label),
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
                children: [
                  const Icon(Iconsax.danger, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
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
                  children: [
                    const Icon(Iconsax.document_text,
                        size: 48, color: AppColors.textSecondary),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد طلبات رفض',
                      style: Theme.of(context).textTheme.bodyLarge,
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
                  onTap: () {
                    context.read<RejectionRequestsBloc>().add(
                          SelectRejectionRequest(request),
                        );
                  },
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
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
                children: [
                  const Icon(Iconsax.danger, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
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
                  children: [
                    const Icon(Iconsax.document_text,
                        size: 48, color: AppColors.textSecondary),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد طلبات رفض',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(AppConstants.spacingLg),
            child: GlassCard(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
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
                      selected:
                          state.selectedRequest?.requestId == request.requestId,
                      onSelectChanged: (_) {
                        context.read<RejectionRequestsBloc>().add(
                              SelectRejectionRequest(request),
                            );
                      },
                      cells: [
                        DataCell(Text(request.driverName)),
                        DataCell(Text('#${request.orderId.substring(0, 8)}')),
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      ),
      child: Text(
        Formatters.formatDuration(minutes),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
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
            icon: const Icon(Iconsax.tick_circle, color: Colors.green),
            onPressed: () => _showApproveDialog(context, request),
            tooltip: 'قبول',
          ),
          IconButton(
            icon: const Icon(Iconsax.close_circle, color: Colors.red),
            onPressed: () => _showRejectDialog(context, request),
            tooltip: 'رفض',
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
    final commentController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('قبول الاعتذار'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('هل تريد قبول اعتذار السائق ${request.driverName}؟'),
            const SizedBox(height: 16),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(
                labelText: 'تعليق (اختياري)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('قبول'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<RejectionRequestsBloc>().add(
            ApproveExcuseEvent(
              requestId: request.requestId,
              adminComment: commentController.text.isEmpty
                  ? null
                  : commentController.text,
            ),
          );
    }
  }

  Future<void> _showRejectDialog(
    BuildContext context,
    RejectionRequestEntity request,
  ) async {
    final commentController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('رفض الاعتذار'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('هل تريد رفض اعتذار السائق ${request.driverName}؟'),
            const SizedBox(height: 16),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(
                labelText: 'سبب الرفض (مطلوب)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (commentController.text.trim().isNotEmpty) {
                Navigator.pop(context, true);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('رفض'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<RejectionRequestsBloc>().add(
            RejectExcuseEvent(
              requestId: request.requestId,
              adminComment: commentController.text,
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
    return const Placeholder();
  }
}
