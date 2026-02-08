import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../domain/entities/order_entities.dart';

/// Order card widget for displaying order summary.
class OrderCard extends StatelessWidget {
  final OrderEntity order;
  final VoidCallback? onTap;
  final void Function(OrderStatus)? onStatusChange;

  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
    this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Order ID, Status, Time
          Row(
            children: [
              // Order ID
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                ),
                child: Text(
                  '#${order.id.replaceAll('order_', '')}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const Spacer(),

              // Status badge
              _buildStatusBadge(context),
            ],
          ),

          const SizedBox(height: AppConstants.spacingSm),

          // Multi-store badge
          if (order.isMultiStore)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusSm),
                      border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Iconsax.shop,
                            size: 12, color: AppColors.secondary),
                        const SizedBox(width: 4),
                        Text(
                          'متعدد المتاجر (${order.storeCount})',
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Customer info
          Row(
            children: [
              const Icon(Iconsax.user,
                  size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.customerName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Store info
          if (!order.isMultiStore && order.storeName != null)
            Row(
              children: [
                const Icon(Iconsax.shop,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.storeName!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          // Multi-store: show store names summary
          if (order.isMultiStore)
            Row(
              children: [
                const Icon(Iconsax.shop,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.pickupStops.map((s) => s.storeName).join(' • '),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),

          const Spacer(),

          // Footer: Items count, Total, Time
          Row(
            children: [
              // Items count
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Iconsax.shopping_bag, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${order.allItems.length} منتجات',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Total
              Text(
                Formatters.currency(order.total ?? 0.0),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.spacingSm),

          // Time ago
          Row(
            children: [
              Icon(
                Iconsax.clock,
                size: 14,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                Formatters.timeAgo(order.createdAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
              ),
              if (order.driverName != null) ...[
                const Spacer(),
                Icon(
                  Iconsax.truck_fast,
                  size: 14,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    order.driverName!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final color = _getStatusColor(order.status);

    return PopupMenuButton<OrderStatus>(
      enabled: order.status.isActive,
      initialValue: order.status,
      onSelected: onStatusChange,
      itemBuilder: (context) => OrderStatus.values
          .where((s) => s != order.status && !s.isCancelled)
          .map((status) => PopupMenuItem(
                value: status,
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getStatusColor(status),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(status.arabicName),
                  ],
                ),
              ))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppConstants.radiusFull),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            )
                .animate(onPlay: (c) => c.repeat())
                .fadeIn()
                .then()
                .fadeOut()
                .then()
                .fadeIn(),
            const SizedBox(width: 6),
            Text(
              order.status.arabicName,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (order.status.isActive) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down,
                size: 16,
                color: color,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    return switch (status) {
      OrderStatus.pending => AppColors.warning,
      OrderStatus.confirmed => AppColors.info,
      OrderStatus.preparing => AppColors.secondary,
      OrderStatus.ready => AppColors.success,
      OrderStatus.pickedUp => AppColors.primary,
      OrderStatus.onTheWay => AppColors.primary,
      OrderStatus.delivered => AppColors.success,
      OrderStatus.cancelled => AppColors.error,
    };
  }
}
