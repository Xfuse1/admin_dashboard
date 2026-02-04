import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/account_entities.dart';

/// Card widget for displaying driver information.
class DriverCard extends StatelessWidget {
  final DriverEntity driver;
  final VoidCallback? onTap;
  final void Function(bool isActive)? onToggleStatus;
  final VoidCallback? onViewLocation;

  const DriverCard({
    super.key,
    required this.driver,
    this.onTap,
    this.onToggleStatus,
    this.onViewLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppColors.border.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar with online indicator
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    backgroundImage:
                        driver.imageUrl != null && driver.imageUrl!.isNotEmpty
                            ? CachedNetworkImageProvider(driver.imageUrl!)
                            : null,
                    child: (driver.imageUrl == null || driver.imageUrl!.isEmpty)
                        ? Text(
                            driver.name.isNotEmpty ? driver.name[0] : '؟',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: driver.isOnline
                            ? AppColors.success
                            : AppColors.textSecondary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).cardColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            driver.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          fit: FlexFit.loose,
                          child: _buildStatusBadge(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildRating(context),
                        const SizedBox(width: 12),
                        Icon(
                          _getVehicleIcon(),
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            driver.vehicleType ?? 'غير محدد',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Flexible(
                          child: FutureBuilder<AggregateQuerySnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('orders')
                                .where('deliveryId', isEqualTo: driver.id)
                                .where('status', isEqualTo: 'delivered')
                                .count()
                                .get(),
                            builder: (context, snapshot) {
                              final count = snapshot.data?.count ??
                                  driver.totalDeliveries;
                              return _buildStatChip(
                                context,
                                icon: Iconsax.truck,
                                label: '$count توصيلة',
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: _buildStatChip(
                            context,
                            icon: Iconsax.wallet_3,
                            label:
                                '${driver.walletBalance.toStringAsFixed(0)} ج.م',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: FutureBuilder<AggregateQuerySnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('orders')
                                .where('rejected_by_drivers',
                                    arrayContains: driver.id)
                                .count()
                                .get(),
                            builder: (context, snapshot) {
                              final rejections = snapshot.data?.count ?? 0;
                              if (rejections == 0) {
                                return const SizedBox.shrink();
                              }
                              return _buildStatChip(
                                context,
                                icon: Iconsax.close_circle,
                                label: '$rejections رفض',
                                color: AppColors.error,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'toggle') {
                    onToggleStatus?.call(!driver.isActive);
                  } else if (value == 'location') {
                    onViewLocation?.call();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'toggle',
                    child: Row(
                      children: [
                        Icon(
                          driver.isActive ? Iconsax.slash : Iconsax.tick_circle,
                          size: 20,
                          color: driver.isActive
                              ? AppColors.error
                              : AppColors.success,
                        ),
                        const SizedBox(width: 8),
                        Text(driver.isActive ? 'تعطيل' : 'تفعيل'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'wallet',
                    child: Row(
                      children: [
                        Icon(Iconsax.wallet_add, size: 20),
                        SizedBox(width: 8),
                        Text('إدارة المحفظة'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'location',
                    child: Row(
                      children: [
                        Icon(Iconsax.location, size: 20),
                        SizedBox(width: 8),
                        Text('عرض الموقع'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (driver.isOnline)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            margin: const EdgeInsets.only(left: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'متصل',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: driver.isActive
                ? AppColors.success.withValues(alpha: 0.1)
                : AppColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            driver.isActive ? 'نشط' : 'معطل',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: driver.isActive ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildRating(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.star_rounded,
          size: 16,
          color: Colors.amber,
        ),
        const SizedBox(width: 2),
        Flexible(
          child: Text(
            driver.rating.toStringAsFixed(1),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Flexible(
          child: Text(
            ' (${driver.totalRatings})',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    Color? color,
  }) {
    final chipColor = color ?? AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color != null ? color.withValues(alpha: 0.1) : AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: chipColor),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: chipColor,
                    fontWeight: color != null ? FontWeight.bold : null,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getVehicleIcon() {
    if (driver.vehicleType == null) return Iconsax.car;

    final type = driver.vehicleType!.toLowerCase();
    if (type.contains('دراجة') ||
        type.contains('motor') ||
        type.contains('bike')) {
      return Iconsax.ship;
    } else if (type.contains('كبيرة') ||
        type.contains('truck') ||
        type.contains('van')) {
      return Iconsax.truck;
    }
    return Iconsax.car;
  }
}
