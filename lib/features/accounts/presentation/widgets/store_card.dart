import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/account_entities.dart';

/// Card widget for displaying store information.
class StoreCard extends StatelessWidget {
  final StoreEntity store;
  final VoidCallback? onTap;
  final void Function(bool isActive)? onToggleStatus;

  const StoreCard({
    super.key,
    required this.store,
    this.onTap,
    this.onToggleStatus,
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
              // Logo
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _getStoreTypeColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: store.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          store.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            _getStoreTypeIcon(),
                            color: _getStoreTypeColor(),
                          ),
                        ),
                      )
                    : Icon(
                        _getStoreTypeIcon(),
                        color: _getStoreTypeColor(),
                        size: 28,
                      ),
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
                            store.name,
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
                          child: _buildStatusBadges(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildRating(context),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            _getStoreTypeName(),
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
                          child: _buildStatChip(
                            context,
                            icon: Iconsax.shopping_cart,
                            label: '${store.totalOrders} طلب',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: _buildStatChip(
                            context,
                            icon: Iconsax.money,
                            label:
                                '${(store.commissionRate * 100).toInt()}% عمولة',
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
                    onToggleStatus?.call(!store.isActive);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'toggle',
                    child: Row(
                      children: [
                        Icon(
                          store.isActive ? Iconsax.slash : Iconsax.tick_circle,
                          size: 20,
                          color: store.isActive
                              ? AppColors.error
                              : AppColors.success,
                        ),
                        const SizedBox(width: 8),
                        Text(store.isActive ? 'تعطيل' : 'تفعيل'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'commission',
                    child: Row(
                      children: [
                        Icon(Iconsax.percentage_circle, size: 20),
                        SizedBox(width: 8),
                        Text('تعديل العمولة'),
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

  Widget _buildStatusBadges(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (store.isOpen)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            margin: const EdgeInsets.only(left: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'مفتوح',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.success,
                          fontSize: 10,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: store.isActive
                ? AppColors.success.withValues(alpha: 0.1)
                : AppColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            store.isActive ? 'نشط' : 'معطل',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: store.isActive ? AppColors.success : AppColors.error,
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
            store.rating.toStringAsFixed(1),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Flexible(
          child: Text(
            ' (${store.totalRatings})',
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
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStoreTypeIcon() {
    return switch (store.type) {
      'restaurant' => Iconsax.reserve,
      'cafe' => Iconsax.coffee,
      'fast_food' => Iconsax.flash_1,
      'supermarket' => Iconsax.shop,
      'bakery' => Iconsax.cake,
      'pharmacy' => Iconsax.health,
      'electronics' => Iconsax.cpu,
      'flowers' => Iconsax.gift,
      _ => Iconsax.shop,
    };
  }

  Color _getStoreTypeColor() {
    return switch (store.type) {
      'restaurant' => AppColors.primary,
      'cafe' => Colors.brown,
      'fast_food' => Colors.orange,
      'supermarket' => AppColors.success,
      'bakery' => Colors.pink,
      'pharmacy' => Colors.teal,
      'electronics' => Colors.indigo,
      'flowers' => Colors.purple,
      _ => AppColors.primary,
    };
  }

  String _getStoreTypeName() {
    return switch (store.type) {
      'restaurant' => 'مطعم',
      'cafe' => 'كافيه',
      'fast_food' => 'وجبات سريعة',
      'supermarket' => 'سوبرماركت',
      'bakery' => 'مخبز',
      'pharmacy' => 'صيدلية',
      'electronics' => 'إلكترونيات',
      'flowers' => 'زهور',
      _ => 'متجر',
    };
  }
}
