import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

import '../../../../config/di/injection_container.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../bloc/fleet_bloc.dart';
import '../bloc/fleet_event.dart';
import '../bloc/fleet_state.dart';
import '../widgets/fleet_filters.dart';
import '../widgets/fleet_stats_cards.dart';
import '../widgets/vehicle_card.dart';
import '../widgets/vehicle_details_panel.dart';

/// Fleet management page.
class FleetPage extends StatelessWidget {
  const FleetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<FleetBloc>()..add(const LoadVehicles()),
      child: const FleetView(),
    );
  }
}

class FleetView extends StatelessWidget {
  const FleetView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FleetBloc, FleetState>(
      listenWhen: (previous, current) =>
          current is FleetActionSuccess || current is FleetError,
      listener: (context, state) {
        if (state is FleetActionSuccess) {
          toastification.show(
            context: context,
            title: Text(state.successMessage),
            type: ToastificationType.success,
            autoCloseDuration: const Duration(seconds: 3),
          );
        } else if (state is FleetError) {
          toastification.show(
            context: context,
            title: Text(state.message),
            type: ToastificationType.error,
            autoCloseDuration: const Duration(seconds: 3),
          );
        }
      },
      builder: (context, state) {
        return Row(
          children: [
            // Main content
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  // Stats Cards
                  if (state is FleetLoaded && state.stats != null)
                    FleetStatsCards(stats: state.stats!),

                  // Filters
                  Padding(
                    padding: const EdgeInsets.all(AppConstants.spacingMd),
                    child: FleetFilters(
                      currentStatusFilter: state is FleetLoaded
                          ? state.currentStatusFilter
                          : null,
                      currentTypeFilter:
                          state is FleetLoaded ? state.currentTypeFilter : null,
                      searchQuery:
                          state is FleetLoaded ? state.searchQuery : null,
                    ),
                  ),

                  // Vehicles Grid
                  Expanded(
                    child: _buildContent(context, state),
                  ),
                ],
              ),
            ),

            // Details Panel
            if (state is FleetLoaded && state.selectedVehicle != null)
              Container(
                width: 400,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                    left: BorderSide(
                      color: AppColors.border.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                child: VehicleDetailsPanel(
                  vehicle: state.selectedVehicle!,
                  onClose: () => context
                      .read<FleetBloc>()
                      .add(const ClearSelectedVehicle()),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, FleetState state) {
    if (state is FleetLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state is FleetError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            Text(
              state.message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            ElevatedButton.icon(
              onPressed: () =>
                  context.read<FleetBloc>().add(const LoadVehicles()),
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (state is FleetLoaded) {
      if (state.vehicles.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.directions_car_outlined,
                size: 64,
                color: AppColors.textTertiary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: AppConstants.spacingMd),
              Text(
                'لا توجد مركبات',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: AppConstants.spacingSm),
              Text(
                'قم بإضافة مركبة جديدة للبدء',
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
            context.read<FleetBloc>().add(const LoadMoreVehicles());
          }
          return false;
        },
        child: GridView.builder(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 400,
            childAspectRatio: 1.4,
            crossAxisSpacing: AppConstants.spacingMd,
            mainAxisSpacing: AppConstants.spacingMd,
          ),
          itemCount: state.vehicles.length,
          itemBuilder: (context, index) {
            final vehicle = state.vehicles[index];
            return VehicleCard(
              vehicle: vehicle,
              isSelected: state.selectedVehicle?.id == vehicle.id,
              onTap: () =>
                  context.read<FleetBloc>().add(SelectVehicle(vehicle.id)),
            );
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
