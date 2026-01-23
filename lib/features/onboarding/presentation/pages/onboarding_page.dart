import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../../domain/entities/onboarding_entities.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';
import '../widgets/onboarding_request_card.dart';
import '../widgets/onboarding_stats_cards.dart';
import '../widgets/request_details_sheet.dart';

/// Onboarding requests management page.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  @override
  void initState() {
    super.initState();
    context.read<OnboardingBloc>()
      ..add(const LoadOnboardingStats())
      ..add(const LoadOnboardingRequests());
  }

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveLayout.getDeviceType(context);
    return BlocConsumer<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is OnboardingError) {
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
              _buildHeader(context, deviceType),

              // Stats Cards
              if (state is OnboardingLoaded && state.stats != null)
                OnboardingStatsCards(stats: state.stats!),

              // Filters
              _buildFilters(context, state),

              // Content
              Expanded(
                child: _buildContent(context, state, deviceType),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, DeviceType deviceType) {
    final isCompact = deviceType == DeviceType.mobile;

    return Container(
      padding: EdgeInsets.all(isCompact ? 16 : 24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'طلبات الانضمام',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'مراجعة طلبات انضمام المتاجر والسائقين',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context, OnboardingState state) {
    OnboardingType? currentType;
    OnboardingStatus? currentStatus;

    if (state is OnboardingLoaded) {
      currentType = state.filterType;
      currentStatus = state.filterStatus;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Type Filter
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    context,
                    label: 'الكل',
                    isSelected: currentType == null,
                    onTap: () => context
                        .read<OnboardingBloc>()
                        .add(const FilterByType(null)),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    context,
                    label: 'المتاجر',
                    icon: Iconsax.shop,
                    isSelected: currentType == OnboardingType.store,
                    onTap: () => context
                        .read<OnboardingBloc>()
                        .add(const FilterByType(OnboardingType.store)),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    context,
                    label: 'السائقين',
                    icon: Iconsax.car,
                    isSelected: currentType == OnboardingType.driver,
                    onTap: () => context
                        .read<OnboardingBloc>()
                        .add(const FilterByType(OnboardingType.driver)),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 1,
                    height: 24,
                    color: AppColors.border,
                  ),
                  const SizedBox(width: 16),
                  // Status Chips
                  ...OnboardingStatus.values.map((status) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _buildFilterChip(
                        context,
                        label: status.arabicName,
                        isSelected: currentStatus == status,
                        color: _getStatusColor(status),
                        onTap: () =>
                            context.read<OnboardingBloc>().add(FilterByStatus(
                                  currentStatus == status ? null : status,
                                )),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    IconData? icon,
    bool isSelected = false,
    Color? color,
    required VoidCallback onTap,
  }) {
    final chipColor = color ?? AppColors.primary;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : chipColor,
            ),
            const SizedBox(width: 4),
          ],
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: chipColor,
      backgroundColor: chipColor.withValues(alpha: 0.1),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : chipColor,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? chipColor : chipColor.withValues(alpha: 0.3),
        ),
      ),
      showCheckmark: false,
    );
  }

  Widget _buildContent(
    BuildContext context,
    OnboardingState state,
    DeviceType deviceType,
  ) {
    if (state is OnboardingLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is OnboardingError) {
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
                context
                    .read<OnboardingBloc>()
                    .add(const LoadOnboardingRequests());
              },
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (state is! OnboardingLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.document,
              size: 80,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد طلبات',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      );
    }

    final crossAxisCount = switch (deviceType) {
      DeviceType.mobile => 1,
      DeviceType.tablet => 2,
      DeviceType.desktop => 3,
    };

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.extentAfter < 200 &&
            state.hasMore &&
            !state.isLoadingMore) {
          context.read<OnboardingBloc>().add(const LoadMoreRequests());
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
            childAspectRatio: deviceType == DeviceType.mobile ? 2.2 : 1.8,
          ),
          itemCount: state.requests.length + (state.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= state.requests.length) {
              return const Center(child: CircularProgressIndicator());
            }

            final request = state.requests[index];
            return OnboardingRequestCard(
              request: request,
              onTap: () => _showRequestDetails(context, request),
              onApprove: () => _showApproveDialog(context, request),
              onReject: () => _showRejectDialog(context, request),
            );
          },
        ),
      ),
    );
  }

  void _showRequestDetails(
    BuildContext context,
    OnboardingRequestEntity request,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RequestDetailsSheet(
        request: request,
        onApprove: () {
          Navigator.pop(context);
          _showApproveDialog(context, request);
        },
        onReject: () {
          Navigator.pop(context);
          _showRejectDialog(context, request);
        },
      ),
    );
  }

  void _showApproveDialog(
    BuildContext context,
    OnboardingRequestEntity request,
  ) {
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تأكيد الموافقة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'هل تريد الموافقة على طلب انضمام "${request.name}"؟',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'ملاحظات (اختياري)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<OnboardingBloc>().add(ApproveRequestEvent(
                    requestId: request.id,
                    notes: notesController.text.isNotEmpty
                        ? notesController.text
                        : null,
                  ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
            child: const Text('موافقة'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(
    BuildContext context,
    OnboardingRequestEntity request,
  ) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تأكيد الرفض'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'هل تريد رفض طلب انضمام "${request.name}"؟',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'سبب الرفض *',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('يرجى إدخال سبب الرفض'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }
              Navigator.pop(dialogContext);
              context.read<OnboardingBloc>().add(RejectRequestEvent(
                    requestId: request.id,
                    reason: reasonController.text,
                  ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('رفض'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(OnboardingStatus status) {
    return switch (status) {
      OnboardingStatus.pending => Colors.orange,
      OnboardingStatus.approved => AppColors.success,
      OnboardingStatus.rejected => AppColors.error,
      OnboardingStatus.underReview => Colors.blue,
    };
  }
}
