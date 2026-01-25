import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/repositories/accounts_repository.dart';

/// Widget for displaying account statistics cards.
class AccountStatsCards extends StatelessWidget {
  final AccountStats stats;

  const AccountStatsCards({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildStatCard(
            context,
            icon: Iconsax.people,
            iconColor: Colors.blue,
            title: 'العملاء',
            value: stats.totalCustomers.toString(),
            subtitle: '${stats.activeCustomers} نشط',
          ),
          _buildStatCard(
            context,
            icon: Iconsax.shop,
            iconColor: Colors.purple,
            title: 'المتاجر',
            value: stats.totalStores.toString(),
            subtitle: '${stats.activeStores} نشط',
          ),
          _buildStatCard(
            context,
            icon: Iconsax.tick_circle,
            iconColor: Colors.green,
            title: 'متاجر معتمدة',
            value: stats.approvedStores.toString(),
            subtitle: 'من ${stats.totalStores}',
          ),
          _buildStatCard(
            context,
            icon: Iconsax.car,
            iconColor: Colors.orange,
            title: 'السائقين',
            value: stats.totalDrivers.toString(),
            subtitle: '${stats.activeDrivers} نشط',
          ),
          _buildStatCard(
            context,
            icon: Iconsax.gps,
            iconColor: Colors.teal,
            title: 'سائقين متصلين',
            value: stats.onlineDrivers.toString(),
            subtitle: 'الآن',
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      width: 170,
      margin: const EdgeInsets.only(left: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  title,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  maxLines: 1,
                  minFontSize: 8,
                  overflow: TextOverflow.ellipsis,
                ),
                AutoSizeText(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: iconColor,
                      ),
                  maxLines: 1,
                ),
                AutoSizeText(
                  subtitle,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                  maxLines: 1,
                  minFontSize: 7,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
