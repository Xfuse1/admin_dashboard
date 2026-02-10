import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../bloc/orders_bloc.dart';
import '../bloc/orders_state.dart';

/// Order statistics cards widget.
class OrderStatsCards extends StatelessWidget {
  const OrderStatsCards({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersBloc, OrdersState>(
      buildWhen: (prev, curr) {
        if (prev is OrdersLoaded && curr is OrdersLoaded) {
          return prev.stats != curr.stats;
        }
        return false;
      },
      builder: (context, state) {
        if (state is! OrdersLoaded || state.stats == null) {
          return const SizedBox.shrink();
        }

        final stats = state.stats!;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _StatCard(
                icon: Iconsax.document_text,
                label: 'إجمالي الطلبات',
                value: Formatters.number(stats.totalOrders.toDouble()),
                color: AppColors.primary,
                index: 0,
              ),
              const SizedBox(width: AppConstants.spacingSm),
              _StatCard(
                icon: Iconsax.timer_1,
                label: 'قيد الانتظار',
                value: Formatters.number(stats.pendingOrders.toDouble()),
                color: AppColors.warning,
                index: 1,
              ),
              const SizedBox(width: AppConstants.spacingSm),
              _StatCard(
                icon: Iconsax.activity,
                label: 'نشط',
                value: Formatters.number(stats.activeOrders.toDouble()),
                color: AppColors.info,
                index: 2,
              ),
              const SizedBox(width: AppConstants.spacingSm),
              _StatCard(
                icon: Iconsax.tick_circle,
                label: 'مكتمل',
                value: Formatters.number(stats.completedOrders.toDouble()),
                color: AppColors.success,
                index: 3,
              ),
              const SizedBox(width: AppConstants.spacingSm),
              _StatCard(
                icon: Iconsax.money,
                label: 'الإيرادات',
                value: Formatters.compactCurrency(stats.totalRevenue),
                color: AppColors.secondary,
                index: 4,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final int index;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: AppConstants.spacingSm),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}
