import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../bloc/fleet_bloc.dart';
import '../bloc/fleet_event.dart';

/// Vehicle details side panel.
class VehicleDetailsPanel extends StatelessWidget {
  final VehicleEntity vehicle;
  final VoidCallback onClose;

  const VehicleDetailsPanel({
    super.key,
    required this.vehicle,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        _buildHeader(context),

        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMainInfo(context),
                const SizedBox(height: AppConstants.spacingLg),
                _buildStatusSection(context),
                const SizedBox(height: AppConstants.spacingLg),
                _buildSpecifications(context),
                const SizedBox(height: AppConstants.spacingLg),
                _buildDriverSection(context),
                const SizedBox(height: AppConstants.spacingLg),
                _buildDatesSection(context),
              ],
            ),
          ),
        ),

        // Actions
        _buildActions(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            ),
            child: Center(
              child: Text(
                vehicle.type.emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${vehicle.brand} ${vehicle.model}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  vehicle.plateNumber,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontFamily: 'monospace',
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }

  Widget _buildMainInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'معلومات المركبة',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: AppConstants.spacingMd),
        _InfoRow(label: 'الماركة', value: vehicle.brand),
        _InfoRow(label: 'الموديل', value: vehicle.model),
        _InfoRow(label: 'سنة الصنع', value: vehicle.year.toString()),
        _InfoRow(label: 'رقم اللوحة', value: vehicle.plateNumber),
        _InfoRow(label: 'اللون', value: vehicle.color),
        _InfoRow(label: 'نوع الوقود', value: _getFuelLabel(vehicle.fuelType)),
      ],
    );
  }

  Widget _buildStatusSection(BuildContext context) {
    final statusColor = Color(vehicle.status.color);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الحالة',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: AppConstants.spacingMd),
        Container(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            border: Border.all(color: statusColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              Text(
                vehicle.status.arabicName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              PopupMenuButton<VehicleStatus>(
                icon: Icon(Icons.edit, size: 18, color: statusColor),
                tooltip: 'تغيير الحالة',
                onSelected: (newStatus) {
                  context.read<FleetBloc>().add(
                        UpdateVehicleStatusEvent(vehicle.id, newStatus),
                      );
                },
                itemBuilder: (context) => VehicleStatus.values
                    .where((s) => s != vehicle.status)
                    .map((status) => PopupMenuItem(
                          value: status,
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Color(status.color),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: AppConstants.spacingSm),
                              Text(status.arabicName),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpecifications(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المواصفات',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: AppConstants.spacingMd),
        _InfoRow(
          label: 'المسافة المقطوعة',
          value: '${_formatNumber(vehicle.totalKilometers)} كم',
        ),
        if (vehicle.fuelCapacity != null)
          _InfoRow(
            label: 'سعة الوقود',
            value: '${vehicle.fuelCapacity!.toStringAsFixed(0)} لتر',
          ),
        if (vehicle.currentFuelLevel != null)
          _InfoRow(
            label: 'مستوى الوقود',
            value: '${vehicle.currentFuelLevel!.toStringAsFixed(0)}%',
          ),
        if (vehicle.maxLoadCapacity != null)
          _InfoRow(
            label: 'الحمولة القصوى',
            value: '${vehicle.maxLoadCapacity!.toStringAsFixed(0)} كجم',
          ),
      ],
    );
  }

  Widget _buildDriverSection(BuildContext context) {
    final isAssigned = vehicle.assignedDriverId != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'السائق',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: AppConstants.spacingMd),
        Container(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: isAssigned
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.textTertiary.withValues(alpha: 0.1),
                child: Icon(
                  isAssigned ? Icons.person : Icons.person_outline,
                  color:
                      isAssigned ? AppColors.primary : AppColors.textTertiary,
                ),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAssigned
                          ? (vehicle.assignedDriverName ?? 'سائق معيّن')
                          : 'غير معيّن',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: isAssigned
                                ? AppColors.textPrimary
                                : AppColors.textTertiary,
                          ),
                    ),
                    if (isAssigned)
                      Text(
                        'ID: ${vehicle.assignedDriverId}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textTertiary,
                              fontFamily: 'monospace',
                            ),
                      ),
                  ],
                ),
              ),
              if (isAssigned)
                IconButton(
                  icon: const Icon(Icons.person_remove, size: 20),
                  tooltip: 'إلغاء التعيين',
                  onPressed: () {
                    context.read<FleetBloc>().add(
                          UnassignDriverEvent(vehicle.id),
                        );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDatesSection(BuildContext context) {
    final dateFormat = DateFormat('yyyy/MM/dd');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'التواريخ المهمة',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: AppConstants.spacingMd),
        if (vehicle.licenseExpiry != null)
          _DateRow(
            label: 'انتهاء الرخصة',
            date: vehicle.licenseExpiry!,
            isExpired: vehicle.isLicenseExpired,
            dateFormat: dateFormat,
          ),
        if (vehicle.insuranceExpiry != null)
          _DateRow(
            label: 'انتهاء التأمين',
            date: vehicle.insuranceExpiry!,
            isExpired: vehicle.isInsuranceExpired,
            dateFormat: dateFormat,
          ),
        if (vehicle.lastMaintenanceDate != null)
          _InfoRow(
            label: 'آخر صيانة',
            value: dateFormat.format(vehicle.lastMaintenanceDate!),
          ),
        if (vehicle.nextMaintenanceDate != null)
          _DateRow(
            label: 'الصيانة القادمة',
            date: vehicle.nextMaintenanceDate!,
            isExpired: vehicle.isMaintenanceDue,
            dateFormat: dateFormat,
          ),
        _InfoRow(
          label: 'تاريخ الإضافة',
          value: dateFormat.format(vehicle.createdAt),
        ),
        _InfoRow(
          label: 'آخر تحديث',
          value: dateFormat.format(vehicle.updatedAt),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.border.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showEditDialog(context),
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('تعديل'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showDeleteConfirmation(context),
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('حذف'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    // TODO: Implement edit dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('قريباً: نافذة التعديل')),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف المركبة'),
        content: Text(
          'هل أنت متأكد من حذف "${vehicle.brand} ${vehicle.model}"؟\n'
          'لا يمكن التراجع عن هذا الإجراء.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<FleetBloc>().add(DeleteVehicleEvent(vehicle.id));
              onClose();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف'),
          ),
        ],
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
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toStringAsFixed(0);
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingXs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  final String label;
  final DateTime date;
  final bool isExpired;
  final DateFormat dateFormat;

  const _DateRow({
    required this.label,
    required this.date,
    required this.isExpired,
    required this.dateFormat,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingXs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Text(
                  dateFormat.format(date),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color:
                            isExpired ? AppColors.error : AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                if (isExpired) ...[
                  const SizedBox(width: AppConstants.spacingXs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingXs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusXs),
                    ),
                    child: Text(
                      'منتهي',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
