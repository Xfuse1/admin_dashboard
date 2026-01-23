import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/vehicle_entity.dart';

/// Vehicle card widget for the fleet grid.
class VehicleCard extends StatelessWidget {
  final VehicleEntity vehicle;
  final bool isSelected;
  final VoidCallback onTap;

  const VehicleCard({
    super.key,
    required this.vehicle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(
          color: isSelected
              ? AppColors.primary
              : AppColors.border.withValues(alpha: 0.5),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: isSelected ? 16 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _VehicleTypeIcon(type: vehicle.type),
                    _StatusBadge(status: vehicle.status),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingMd),

                // Vehicle Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${vehicle.brand} ${vehicle.model}',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppConstants.spacingXs),
                      Text(
                        vehicle.plateNumber,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              fontFamily: 'monospace',
                            ),
                      ),
                      const Spacer(),

                      // Details Row
                      Row(
                        children: [
                          _InfoChip(
                            icon: Icons.calendar_today,
                            label: vehicle.year.toString(),
                          ),
                          const SizedBox(width: AppConstants.spacingSm),
                          _InfoChip(
                            icon: Icons.local_gas_station,
                            label: _getFuelLabel(vehicle.fuelType),
                          ),
                          const SizedBox(width: AppConstants.spacingSm),
                          _InfoChip(
                            icon: Icons.color_lens,
                            label: vehicle.color,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Footer
                if (vehicle.assignedDriverId != null ||
                    vehicle.totalKilometers > 0) ...[
                  const Divider(height: AppConstants.spacingMd * 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (vehicle.assignedDriverId != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.person,
                              size: 14,
                              color: AppColors.textTertiary,
                            ),
                            const SizedBox(width: AppConstants.spacingXs),
                            Text(
                              vehicle.assignedDriverName ?? 'مُعيّن',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.textTertiary,
                                  ),
                            ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 14,
                              color: AppColors.textTertiary,
                            ),
                            const SizedBox(width: AppConstants.spacingXs),
                            Text(
                              'غير مُعيّن',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.textTertiary,
                                  ),
                            ),
                          ],
                        ),
                      if (vehicle.totalKilometers > 0)
                        Text(
                          '${_formatNumber(vehicle.totalKilometers)} كم',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textTertiary,
                                  ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getFuelLabel(String fuelType) {
    return switch (fuelType) {
      'petrol' => 'بنزين',
      'diesel' => 'ديزل',
      'electric' => 'كهرباء',
      'hybrid' => 'هجين',
      _ => fuelType,
    };
  }

  String _formatNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)}K';
    }
    return number.toStringAsFixed(0);
  }
}

class _VehicleTypeIcon extends StatelessWidget {
  final VehicleType type;

  const _VehicleTypeIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      ),
      child: Center(
        child: Text(
          type.emoji,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final VehicleStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingSm,
        vertical: AppConstants.spacingXs,
      ),
      decoration: BoxDecoration(
        color: Color(status.color).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      ),
      child: Text(
        status.arabicName,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Color(status.color),
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingSm,
        vertical: AppConstants.spacingXs,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppConstants.radiusXs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textTertiary),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
          ),
        ],
      ),
    );
  }
}
