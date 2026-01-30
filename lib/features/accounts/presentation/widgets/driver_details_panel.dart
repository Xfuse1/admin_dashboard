import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/account_entities.dart';
import '../bloc/accounts_bloc.dart';
import '../bloc/accounts_event.dart';

/// Driver details side panel.
class DriverDetailsPanel extends StatelessWidget {
  final DriverEntity driver;
  final VoidCallback onClose;

  const DriverDetailsPanel({
    super.key,
    required this.driver,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMainInfo(context),
                const SizedBox(height: 24),
                _buildStatusSection(context),
                const SizedBox(height: 24),
                _buildVehicleInfo(context),
                const SizedBox(height: 24),
                _buildContactInfo(context),
                const SizedBox(height: 24),
                _buildStatisticsSection(context),
              ],
            ),
          ),
        ),
        _buildActions(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
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
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: driver.imageUrl != null && driver.imageUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      driver.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Iconsax.user,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                  )
                : const Icon(
                    Iconsax.user,
                    color: AppColors.primary,
                    size: 28,
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        driver.name,
                        style: Response.isMobile(context)
                            ? Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                )
                            : Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (driver.isOnline)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'متصل',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                  ],
                ),
                Text(
                  'سائق منذ ${DateFormat.yMMMd('ar').format(driver.createdAt)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
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
          'معلومات السائق',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 400 || Response.isMobile(context);
            if (isMobile) {
              return Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: _InfoCard(
                      icon: Iconsax.star_1,
                      label: 'التقييم',
                      value: '${driver.rating.toStringAsFixed(1)} / 5.0',
                      iconColor: Colors.amber,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: _InfoCard(
                      icon: Iconsax.timer_1,
                      label: 'آخر نشاط',
                      value: DateFormat.yMMMd('ar').format(driver.updatedAt),
                      iconColor: AppColors.primary,
                    ),
                  ),
                ],
              );
            }
            return Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    icon: Iconsax.star_1,
                    label: 'التقييم',
                    value: '${driver.rating.toStringAsFixed(1)} / 5.0',
                    iconColor: Colors.amber,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _InfoCard(
                    icon: Iconsax.timer_1,
                    label: 'آخر نشاط',
                    value: DateFormat.yMMMd('ar').format(driver.updatedAt),
                    iconColor: AppColors.primary,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatusSection(BuildContext context) {
    final statusColor = driver.isActive ? AppColors.success : AppColors.error;
    final statusLabel = driver.isActive ? 'نشط' : 'معطل';

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
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
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
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  statusLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Switch(
                value: driver.isActive,
                activeColor: AppColors.success,
                onChanged: (value) {
                  context.read<AccountsBloc>().add(
                        ToggleDriverStatusEvent(
                          driverId: driver.id,
                          isActive: value,
                        ),
                      );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleInfo(BuildContext context) {
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
        const SizedBox(height: 16),
        _InfoCard(
          icon: _getVehicleIcon(driver.vehicleType),
          label: 'نوع المركبة',
          value: driver.vehicleType ?? 'غير محدد',
          iconColor: AppColors.textSecondary,
        ),
      ],
    );
  }

  Widget _buildContactInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'معلومات التواصل',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: 16),
        _ContactRow(icon: Iconsax.call, value: driver.phone),
        _ContactRow(icon: Iconsax.sms, value: driver.email),
      ],
    );
  }

  Widget _buildStatisticsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الإحصائيات',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile =
                constraints.maxWidth < 400 || Response.isMobile(context);

            return FutureBuilder<AggregateQuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('orders')
                  .where('deliveryId', isEqualTo: driver.id)
                  .where('deliveryStatus', isEqualTo: 'delivered')
                  .count()
                  .get(),
              builder: (context, snapshot) {
                final count = snapshot.data?.count ?? driver.totalDeliveries;
                
                final children = [
                  isMobile
                      ? SizedBox(
                          width: double.infinity,
                          child: _StatCard(
                            icon: Iconsax.box,
                            label: 'توصيلات ناجحة',
                            value: '$count',
                          ),
                        )
                      : Expanded(
                          child: _StatCard(
                            icon: Iconsax.box,
                            label: 'توصيلات ناجحة',
                            value: '$count',
                          ),
                        ),
                  SizedBox(
                      width: isMobile ? 0 : 16, height: isMobile ? 16 : 0),
                  isMobile
                      ? SizedBox(
                          width: double.infinity,
                          child: _StatCard(
                            icon: Iconsax.wallet_3,
                            label: 'رصيد المحفظة',
                            value:
                                '${driver.walletBalance.toStringAsFixed(0)} ج.م',
                            color: AppColors.success,
                          ),
                        )
                      : Expanded(
                          child: _StatCard(
                            icon: Iconsax.wallet_3,
                            label: 'رصيد المحفظة',
                            value:
                                '${driver.walletBalance.toStringAsFixed(0)} ج.م',
                            color: AppColors.success,
                          ),
                        ),
                ];

                if (isMobile) {
                  return Column(children: children);
                } else {
                  return Row(children: children);
                }
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.border.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: View driver location on map
              },
              icon: const Icon(Iconsax.location),
              label: const Text('عرض الموقع'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onClose,
              icon: const Icon(Iconsax.close_circle),
              label: const Text('إغلاق'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(vertical: 16),
                foregroundColor: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getVehicleIcon(String? type) {
    if (type == null) return Iconsax.car;
    final t = type.toLowerCase();
    if (t.contains('دراجة') || t.contains('bike') || t.contains('motor')) {
      return Iconsax.ship; // Or bike icon if available in your font
    } else if (t.contains('كبيرة') ||
        t.contains('truck') ||
        t.contains('van')) {
      return Iconsax.truck;
    }
    return Iconsax.car;
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String value;

  const _ContactRow({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 12),
          SelectableText(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (color ?? AppColors.primary).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color ?? AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
                  (iconColor ?? AppColors.textSecondary).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: iconColor ?? AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Response {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;
}
