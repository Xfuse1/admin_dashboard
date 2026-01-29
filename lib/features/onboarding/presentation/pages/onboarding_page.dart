import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_logger.dart';
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
      // Explicitly load all requests (clear filters) by default
      ..add(const LoadOnboardingRequests(type: null, status: null));
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
          // Log error to console
          logger.error('Onboarding Error: ${state.message}');
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final effectiveState = _getEffectiveState(state);
        
        return Scaffold(
          body: Column(
            children: [
              // Header
              _buildHeader(context, deviceType),

              // Stats Cards
              if (effectiveState != null && effectiveState.stats != null)
                OnboardingStatsCards(stats: effectiveState.stats!),

              // Filters
              _buildFilters(context, effectiveState),

              // Content
              Expanded(
                child: _buildContent(context, state, effectiveState, deviceType),
              ),
            ],
          ),
        );
      },
    );
  }

  OnboardingLoaded? _getEffectiveState(OnboardingState state) {
    if (state is OnboardingLoaded) return state;
    if (state is OnboardingActionSuccess) return state.updatedState;
    if (state is OnboardingActionInProgress) return state.previousState;
    if (state is OnboardingError && state.previousState is OnboardingLoaded) {
      return state.previousState as OnboardingLoaded;
    }
    return null;
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

  Widget _buildFilters(BuildContext context, OnboardingLoaded? state) {
    OnboardingType? currentType;
    OnboardingStatus? currentStatus;

    if (state != null) {
      currentType = state.filterType;
      currentStatus = state.filterStatus;
    }

    return Container(
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        clipBehavior: Clip.none,
        child: Row(
          children: [
            // Type Filter
            Row(
              children: [
                _buildFilterChip(
                  context,
                  label: 'المتاجر',
                  icon: Iconsax.shop,
                  isSelected: currentType == OnboardingType.store,
                  color: Colors.purple,
                  onTap: () => context.read<OnboardingBloc>().add(
                        FilterByType(
                          currentType == OnboardingType.store
                              ? null
                              : OnboardingType.store,
                        ),
                      ),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  label: 'السائقين',
                  icon: Iconsax.car,
                  isSelected: currentType == OnboardingType.driver,
                  color: Colors.teal,
                  onTap: () => context.read<OnboardingBloc>().add(
                        FilterByType(
                          currentType == OnboardingType.driver
                              ? null
                              : OnboardingType.driver,
                        ),
                      ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 1,
                  height: 24,
                  color: AppColors.border,
                ),
                const SizedBox(width: 16),
                // Status Chips
                ...OnboardingStatus.values
                    .where((status) => status != OnboardingStatus.underReview)
                    .map((status) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _buildFilterChip(
                      context,
                      label: status.arabicName,
                      isSelected: currentStatus == status,
                      color: _getStatusColor(status),
                      onTap: () => context.read<OnboardingBloc>().add(
                            FilterByStatus(
                              currentStatus == status ? null : status,
                            ),
                          ),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
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
      avatar: icon != null
          ? Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : chipColor,
            )
          : null,
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: chipColor,
      backgroundColor: chipColor.withValues(alpha: 0.1),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.9),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
        height: 1.4, // Optimal line height for Arabic to avoid clipping
      ),
      side: BorderSide(
        color: isSelected ? chipColor : chipColor.withValues(alpha: 0.5),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      showCheckmark: false,
      // Fine-tuned padding to center text visually considering Arabic metrics
      labelPadding: const EdgeInsets.only(left: 6, right: 6, top: 0, bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
    );
  }

  Widget _buildContent(
    BuildContext context,
    OnboardingState state,
    OnboardingLoaded? effectiveState,
    DeviceType deviceType,
  ) {
    if (state is OnboardingLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is OnboardingError && effectiveState == null) {
      logger.error('UI Onboarding Error Displayed: ${state.message}');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.warning_2, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SelectableText(
                state.message,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                logger.info('Retrying load onboarding requests...');
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

    if (effectiveState == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (effectiveState.requests.isEmpty) {
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
              'لا توجد طلبات حالياً',
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
            effectiveState.hasMore &&
            !effectiveState.isLoadingMore) {
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
            mainAxisExtent: deviceType == DeviceType.mobile ? 260 : 280,
          ),
          itemCount:
              effectiveState.requests.length + (effectiveState.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= effectiveState.requests.length) {
              return const Center(child: CircularProgressIndicator());
            }

            final request = effectiveState.requests[index];
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
      builder: (sheetContext) => RequestDetailsSheet(
        request: request,
        onApprove: () {
          Navigator.pop(sheetContext);
          _showApproveDialog(context, request);
        },
        onReject: () {
          Navigator.pop(sheetContext);
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
    final onboardingBloc = context.read<OnboardingBloc>();

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
              onboardingBloc.add(ApproveRequestEvent(
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
    final onboardingBloc = context.read<OnboardingBloc>();

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
              onboardingBloc.add(RejectRequestEvent(
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
