import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

import '../../../../config/di/injection_container.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/vendor_entity.dart';
import '../bloc/vendors_bloc.dart';
import '../bloc/vendors_event.dart';
import '../bloc/vendors_state.dart';
import '../widgets/vendor_card.dart';
import '../widgets/vendor_details_panel.dart';
import '../widgets/vendors_filters.dart';
import '../widgets/vendors_stats_cards.dart';
import '../../../../shared/widgets/common_widgets.dart';

/// Vendors management page.
class VendorsPage extends StatelessWidget {
  const VendorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<VendorsBloc>()
        ..add(const LoadVendors())
        ..add(const WatchVendorsEvent()),
      child: const VendorsView(),
    );
  }
}

class VendorsView extends StatelessWidget {
  const VendorsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VendorsBloc, VendorsState>(
      listenWhen: (previous, current) =>
          current is VendorsActionSuccess || current is VendorsError,
      listener: (context, state) {
        if (state is VendorsActionSuccess) {
          toastification.show(
            context: context,
            title: Text(state.successMessage),
            type: ToastificationType.success,
            autoCloseDuration: const Duration(seconds: 3),
          );
        } else if (state is VendorsError) {
          toastification.show(
            context: context,
            title: Text(state.message),
            type: ToastificationType.error,
            autoCloseDuration: const Duration(seconds: 3),
          );
        }
      },
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isWideScreen = constraints.maxWidth > 900;
            final showPanelInline = isWideScreen &&
                state is VendorsLoaded &&
                state.selectedVendor != null;

            return Row(
              children: [
                // Main content
                Expanded(
                  flex: showPanelInline ? 3 : 1,
                  child: Column(
                    children: [
                      // Stats Cards
                      if (state is VendorsLoaded && state.stats != null)
                        VendorsStatsCards(stats: state.stats!),

                      // Filters
                      Padding(
                        padding: const EdgeInsets.all(AppConstants.spacingMd),
                        child: VendorsFilters(
                          currentStatusFilter: state is VendorsLoaded
                              ? state.currentStatusFilter
                              : null,
                          currentCategoryFilter: state is VendorsLoaded
                              ? state.currentCategoryFilter
                              : null,
                          searchQuery:
                              state is VendorsLoaded ? state.searchQuery : null,
                        ),
                      ),

                      // Vendors List
                      Expanded(
                        child: _buildContent(context, state, isWideScreen),
                      ),
                    ],
                  ),
                ),

                // Details Panel (only on wide screens)
                if (showPanelInline && state is VendorsLoaded)
                  Container(
                    width: 380,
                    constraints: const BoxConstraints(maxWidth: 420),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border(
                        left: BorderSide(
                          color: AppColors.border.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    child: VendorDetailsPanel(
                      vendor: state.selectedVendor!,
                      onClose: () => context
                          .read<VendorsBloc>()
                          .add(const ClearSelectedVendor()),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildContent(
      BuildContext context, VendorsState state, bool isWideScreen) {
    if (state is VendorsLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state is VendorsError) {
      return ErrorState(
        message: state.message,
        onRetry: () => context.read<VendorsBloc>().add(const LoadVendors()),
      );
    }

    if (state is VendorsLoaded) {
      if (state.vendors.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.store_outlined,
                size: 64,
                color: AppColors.textTertiary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: AppConstants.spacingMd),
              Text(
                'لا توجد متاجر',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: AppConstants.spacingSm),
              Text(
                'قم بإضافة متجر جديد للبدء',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textTertiary,
                    ),
              ),
            ],
          ),
        );
      }

      return NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification &&
              notification.metrics.extentAfter < 200 &&
              state.hasMore) {
            context.read<VendorsBloc>().add(const LoadMoreVendors());
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          itemCount: state.vendors.length + (state.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == state.vendors.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppConstants.spacingMd),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );
            }

            final vendor = state.vendors[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.spacingMd),
              child: VendorCard(
                vendor: vendor,
                isSelected: state.selectedVendor?.id == vendor.id,
                onTap: () {
                  context.read<VendorsBloc>().add(SelectVendor(vendor.id));
                  if (!isWideScreen) {
                    _showVendorDetailsSheet(context, vendor);
                  }
                },
              ),
            );
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _showVendorDetailsSheet(BuildContext context, VendorEntity vendor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppConstants.radiusLg),
            ),
          ),
          child: BlocProvider.value(
            value: context.read<VendorsBloc>(),
            child: VendorDetailsPanel(
              vendor: vendor,
              onClose: () => Navigator.pop(sheetContext),
            ),
          ),
        ),
      ),
    );
  }
}
