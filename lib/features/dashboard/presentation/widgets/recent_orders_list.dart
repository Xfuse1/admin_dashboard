import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../domain/entities/dashboard_entities.dart';

/// Recent orders list widget.
class RecentOrdersList extends StatelessWidget {
  final List<RecentOrder> orders;

  const RecentOrdersList({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'آخر الطلبات',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              TextButton(
                onPressed: () { 
                },
                child: const Text('عرض الكل'),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingSm),
          Expanded(
            child: orders.isEmpty
                ? const EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'لا توجد طلبات',
                  )
                : ListView.separated(
                    itemCount: orders.length,
                    separatorBuilder: (_, __) => Divider(
                      color: AppColors.border.withValues(alpha: 0.5),
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      return _OrderListItem(order: orders[index])
                          .animate(delay: Duration(milliseconds: 50 * index))
                          .fadeIn(duration: AppConstants.animationMedium)
                          .slideX(begin: 0.05, end: 0);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _OrderListItem extends StatelessWidget {
  final RecentOrder order;

  const _OrderListItem({required this.order});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingSm),
      child: Row(
        children: [
          // Order icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getStatusColor(order.status).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            ),
            child: Icon(
              Icons.receipt_outlined,
              color: _getStatusColor(order.status),
              size: 20,
            ),
          ),
          const SizedBox(width: AppConstants.spacingSm),
          // Order info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      order.orderNumber,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(width: AppConstants.spacingSm),
                    StatusBadge(
                      label: _getStatusLabel(order.status),
                      type: _getStatusType(order.status),
                      showDot: false,
                    ),
                    if (order.isMultiStore) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${order.storeCount} متاجر',
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${order.customerName} • ${order.vendorName}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Amount & time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Formatters.currency(order.amount),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                Formatters.timeAgo(order.createdAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    return switch (status) {
      OrderStatus.pending => AppColors.warning,
      OrderStatus.confirmed => AppColors.info,
      OrderStatus.preparing => const Color(0xFF8B5CF6),
      OrderStatus.ready => const Color(0xFFF59E0B),
      OrderStatus.pickedUp => const Color(0xFF06B6D4),
      OrderStatus.delivered => AppColors.success,
      OrderStatus.cancelled => AppColors.error,
    };
  }

  String _getStatusLabel(OrderStatus status) {
    return switch (status) {
      OrderStatus.pending => 'قيد الانتظار',
      OrderStatus.confirmed => 'مؤكد',
      OrderStatus.preparing => 'جاري التحضير',
      OrderStatus.ready => 'جاهز',
      OrderStatus.pickedUp => 'تم الاستلام',
      OrderStatus.delivered => 'تم التوصيل',
      OrderStatus.cancelled => 'ملغي',
    };
  }

  StatusType _getStatusType(OrderStatus status) {
    return switch (status) {
      OrderStatus.pending => StatusType.warning,
      OrderStatus.confirmed => StatusType.info,
      OrderStatus.preparing => StatusType.info,
      OrderStatus.ready => StatusType.warning,
      OrderStatus.pickedUp => StatusType.info,
      OrderStatus.delivered => StatusType.success,
      OrderStatus.cancelled => StatusType.error,
    };
  }
}
