import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../config/di/injection_container.dart';
import '../../../../core/services/firestore_lookup_service.dart';
import '../../../../core/firebase/firebase_service.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../domain/entities/order_entities.dart';
import '../bloc/orders_bloc.dart';
import '../bloc/orders_event.dart';

/// Order details bottom sheet for mobile/tablet.
class OrderDetailsSheet extends StatelessWidget {
  final OrderEntity order;

  const OrderDetailsSheet({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppConstants.radiusXl),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(AppConstants.spacingMd),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'تفاصيل الطلب',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              if (order.isMultiStore) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(
                                        AppConstants.radiusSm),
                                    border: Border.all(
                                      color: AppColors.secondary
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Text(
                                    'متعدد المتاجر (${order.storeCount})',
                                    style: const TextStyle(
                                      color: AppColors.secondary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            '#${order.id}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(context),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Iconsax.close_circle),
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppConstants.spacingMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customer section
                      _buildSection(
                        context,
                        'معلومات العميل',
                        Iconsax.user,
                        [
                          _buildInfoRow(context, 'الاسم', order.customerName),
                          _buildInfoRow(context, 'الهاتف', order.customerPhone),
                          _buildInfoRow(
                              context, 'العنوان', order.address.fullAddress),
                        ],
                      ),

                      const SizedBox(height: AppConstants.spacingMd),

                      // Store section — single store or multi-store pickup stops
                      if (order.isMultiStore)
                        _buildPickupStopsSection(context)
                      else if (order.storeId != null)
                        _buildStoreSection(context),

                      const SizedBox(height: AppConstants.spacingMd),

                      // Driver section
                      if (order.driverId != null)
                        _DriverInfoCard(
                          driverId: order.driverId!,
                          driverName: order.driverName,
                        ),

                      const SizedBox(height: AppConstants.spacingMd),

                      // Items section
                      _buildItemsSection(context),

                      const SizedBox(height: AppConstants.spacingMd),

                      // Total section
                      _buildTotalSection(context),

                      const SizedBox(height: AppConstants.spacingMd),

                      // Timeline section
                      _buildTimelineSection(context),

                      const SizedBox(height: AppConstants.spacingLg),

                      // Actions
                      if (order.status.isActive) _buildActionsSection(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final color = _getStatusColor(order.status);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            order.status.arabicName,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreSection(BuildContext context) {
    if (order.storeId == null || order.storeId!.isEmpty) {
      return _buildSection(
        context,
        'المتجر',
        Iconsax.shop,
        [
          _buildInfoRow(
              context, 'اسم المتجر', order.storeName ?? 'متجر غير معروف')
        ],
      );
    }

    return FutureBuilder<Map<String, dynamic>?>(
      future: sl<FirestoreLookupService>().getUserById(order.storeId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Iconsax.shop,
                        size: 20, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'المتجر',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return _buildSection(
            context,
            'المتجر',
            Iconsax.shop,
            [
              _buildInfoRow(
                  context, 'اسم المتجر', order.storeName ?? 'متجر غير معروف')
            ],
          );
        }

        final userData = snapshot.data!;
        // ignore: unnecessary_null_comparison
        if (userData == null) {
          return _buildSection(
            context,
            'المتجر',
            Iconsax.shop,
            [
              _buildInfoRow(
                  context, 'اسم المتجر', order.storeName ?? 'متجر غير معروف')
            ],
          );
        }

        // Store data is now nested inside the user document
        final storeData =
            (userData['store'] as Map<String, dynamic>?) ?? <String, dynamic>{};

        // Extract store information from nested store map
        final storeName =
            storeData['name'] as String? ?? order.storeName ?? 'متجر غير معروف';
        final storePhone = storeData['phone'] as String? ?? 'غير متوفر';

        // Address is now a simple string in the store map
        String storeAddress = storeData['address'] as String? ?? 'غير متوفر';
        if (storeAddress.isEmpty) {
          storeAddress = 'غير متوفر';
        }

        final storeCategory = storeData['category'] as String? ?? 'متجر';
        final storeRating = (storeData['rating'] as num?)?.toDouble() ?? 0.0;

        return GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Iconsax.shop,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          storeName,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Row(
                          children: [
                            Text(
                              storeCategory,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                  ),
                            ),
                            if (storeRating > 0) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.star,
                                  size: 12, color: Colors.amber),
                              const SizedBox(width: 2),
                              Text(
                                storeRating.toStringAsFixed(1),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              _buildInfoRow(context, 'الهاتف', storePhone),
              _buildInfoRow(context, 'العنوان', storeAddress),
            ],
          ),
        );
      },
    );
  }

  /// Pickup stops section for multi-store orders
  Widget _buildPickupStopsSection(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.shop, size: 20, color: AppColors.secondary),
              const SizedBox(width: 8),
              Text(
                'محلات الاستلام',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              Text(
                '${order.pickedUpStopsCount}/${order.storeCount} تم الاستلام',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: order.allStoresPickedUp
                          ? AppColors.success
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingSm),
          const Divider(),
          ...order.pickupStops.asMap().entries.map((entry) {
            final index = entry.key;
            final stop = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  // Stop number
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _getPickupStopStatusColor(stop.status)
                          .withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: _getPickupStopStatusColor(stop.status),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Store info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stop.storeName,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${stop.items.length} منتجات',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        if (stop.status == PickupStopStatus.rejected &&
                            stop.rejectionReason != null)
                          Text(
                            'سبب الرفض: ${stop.rejectionReason}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.error),
                          ),
                      ],
                    ),
                  ),
                  // Status + subtotal
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _getPickupStopStatusColor(stop.status)
                              .withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusSm),
                        ),
                        child: Text(
                          stop.status.arabicName,
                          style: TextStyle(
                            color: _getPickupStopStatusColor(stop.status),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Formatters.currency(stop.subtotal),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingSm),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSection(BuildContext context) {
    // For multi-store orders, show items grouped by store
    if (order.isMultiStore && order.pickupStops.isNotEmpty) {
      return _buildMultiStoreItemsSection(context);
    }

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.shopping_bag,
                  size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'المنتجات',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              Text(
                '${order.allItems.length} منتجات',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingSm),
          const Divider(),
          ...order.allItems.map((item) => _buildItemTile(context, item)),
        ],
      ),
    );
  }

  Widget _buildMultiStoreItemsSection(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.shopping_bag,
                  size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'المنتجات',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              Text(
                '${order.allItems.length} منتجات من ${order.storeCount} متاجر',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingSm),
          const Divider(),
          // Group items by store (pickup_stop)
          ...order.pickupStops.map((stop) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  // Store header with status
                  Row(
                    children: [
                      Icon(
                        Iconsax.shop,
                        size: 16,
                        color: _getPickupStopStatusColor(stop.status),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        stop.storeName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: _getPickupStopStatusColor(stop.status),
                            ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getPickupStopStatusColor(stop.status)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          stop.status.arabicName,
                          style: TextStyle(
                            color: _getPickupStopStatusColor(stop.status),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        Formatters.currency(stop.subtotal),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Store items
                  ...stop.items.map((item) => _buildItemTile(context, item)),
                  const Divider(),
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildItemTile(BuildContext context, OrderItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
            ),
            child: Center(
              child: Text(
                '${item.quantity}x',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (item.storeName != null && item.storeName!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      children: [
                        const Icon(Iconsax.shop,
                            size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            item.storeName!,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                    ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (item.notes != null)
                  Text(
                    item.notes!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
              ],
            ),
          ),
          Text(
            Formatters.currency(item.total),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Color _getPickupStopStatusColor(PickupStopStatus status) {
    return switch (status) {
      PickupStopStatus.pending => AppColors.warning,
      PickupStopStatus.confirmed => AppColors.info,
      PickupStopStatus.pickedUp => AppColors.success,
      PickupStopStatus.rejected => AppColors.error,
    };
  }

  Widget _buildTotalSection(BuildContext context) {
    // Calculate actual subtotal from items (handles both single and multi-store)
    final calculatedSubtotal = order.allItems.fold<double>(
      0.0,
      (sum, item) => sum + item.total,
    );

    // Use calculated subtotal if order subtotal is missing or incorrect
    final displaySubtotal = (order.subtotal == null ||
            order.subtotal == 0.0 ||
            (calculatedSubtotal > 0 &&
                (calculatedSubtotal - (order.subtotal ?? 0.0)).abs() > 0.01))
        ? calculatedSubtotal
        : order.subtotal!;

    return FutureBuilder<double>(
      future: sl<FirestoreLookupService>().getDriverCommissionRate(),
      builder: (context, snapshot) {
        // Get delivery fee from settings/driverCommission/rate
        double deliveryFee = snapshot.data ?? 0.0;

        final calculatedTotal = displaySubtotal + deliveryFee;
        // Always use calculated total to ensure delivery fee is included
        final displayTotal = calculatedTotal;

        return GlassCard(
          child: Column(
            children: [
              _buildTotalRow(context, 'المجموع الفرعي', displaySubtotal),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'رسوم التوصيل',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (snapshot.connectionState == ConnectionState.waiting)
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                    ],
                  ),
                  Text(
                    Formatters.currency(deliveryFee),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const Divider(height: 24),
              _buildTotalRow(context, 'الإجمالي', displayTotal, isBold: true),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTotalRow(
    BuildContext context,
    String label,
    double amount, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isBold ? FontWeight.bold : null,
              ),
        ),
        Text(
          Formatters.currency(amount),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isBold ? FontWeight.bold : null,
                color: isBold ? AppColors.primary : null,
              ),
        ),
      ],
    );
  }

  Widget _buildTimelineSection(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.timer_1, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'مسار الطلب',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingSm),
          ...order.timeline.asMap().entries.map((entry) {
            final index = entry.key;
            final timeline = entry.value;
            final isLast = index == order.timeline.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getStatusColor(timeline.status),
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 40,
                        color: AppColors.divider,
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          timeline.status.arabicName,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        Text(
                          Formatters.dateTimeWithSeconds(timeline.timestamp),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                        if (timeline.note != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              timeline.note!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.textMuted,
                                    fontStyle: FontStyle.italic,
                                  ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context) {
    return Column(
      children: [
        // Update status button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showStatusPicker(context),
            icon: const Icon(Iconsax.refresh),
            label: const Text('تحديث الحالة'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spacingSm),
        // Cancel button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showCancelDialog(context),
            icon: const Icon(Iconsax.close_circle, color: AppColors.error),
            label: const Text(
              'إلغاء الطلب',
              style: TextStyle(color: AppColors.error),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              side: const BorderSide(color: AppColors.error),
            ),
          ),
        ),
      ],
    );
  }

  void _showStatusPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'تحديث الحالة',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            ...OrderStatus.values
                .where((s) => s != order.status && !s.isCancelled)
                .map((status) => ListTile(
                      leading: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getStatusColor(status),
                          shape: BoxShape.circle,
                        ),
                      ),
                      title: Text(status.arabicName),
                      onTap: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context).pop();
                        context.read<OrdersBloc>().add(
                              UpdateOrderStatusEvent(
                                orderId: order.id,
                                newStatus: status,
                              ),
                            );
                      },
                    )),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إلغاء الطلب'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('هل أنت متأكد من إلغاء هذا الطلب؟'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'سبب الإلغاء',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('تراجع'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
              context.read<OrdersBloc>().add(
                    CancelOrderEvent(
                      orderId: order.id,
                      reason: reasonController.text.isNotEmpty
                          ? reasonController.text
                          : 'تم الإلغاء من لوحة التحكم',
                    ),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('إلغاء الطلب'),
          ),
        ],
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

class _DriverInfoCard extends StatefulWidget {
  final String driverId;
  final String? driverName;

  const _DriverInfoCard({
    required this.driverId,
    this.driverName,
  });

  @override
  State<_DriverInfoCard> createState() => _DriverInfoCardState();
}

class _DriverInfoCardState extends State<_DriverInfoCard> {
  late Future<Map<String, dynamic>?> _driverDataFuture;

  @override
  void initState() {
    super.initState();
    _driverDataFuture = _fetchDriverData();
  }

  @override
  void didUpdateWidget(covariant _DriverInfoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.driverId != widget.driverId) {
      _driverDataFuture = _fetchDriverData();
    }
  }

  /// Fetches driver data from 'drivers' collection
  Future<Map<String, dynamic>?> _fetchDriverData() async {
    final firestore = FirebaseService.instance.firestore;

    final driversDoc = await firestore
        .collection(FirestoreCollections.drivers)
        .doc(widget.driverId)
        .get();

    if (driversDoc.exists) {
      return driversDoc.data();
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _driverDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        String name = widget.driverName ?? 'غير معروف';
        String? phone;
        String? image;
        bool isActive = false;

        if (snapshot.hasData && snapshot.data != null) {
          final data = snapshot.data!;
          print("Driver Data: $data"); // Debug print
          name = data['name'] as String? ?? name;
          // Get phone - could be stored as 'phone' or empty
          final phoneValue = data['phone'] as String?;
          phone =
              (phoneValue != null && phoneValue.isNotEmpty) ? phoneValue : null;
          image = data['image'] as String?;
          isActive = data['isActive'] as bool? ?? false;
        }

        return GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Iconsax.truck,
                          size: 20, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'بيانات السائق',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  if (isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'نشط',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingMd),
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surfaceLight,
                    ),
                    child: image != null
                        ? ClipOval(
                            child: Image.network(
                              image,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Iconsax.user,
                                    color: AppColors.textSecondary);
                              },
                            ),
                          )
                        : const Icon(Iconsax.user,
                            color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: Theme.of(context).textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (phone != null)
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  phone,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                        fontFamily: 'Roboto',
                                      ),
                                  textDirection: TextDirection.ltr,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  Clipboard.setData(
                                      ClipboardData(text: phone!));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('تم نسخ رقم الهاتف'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                                icon: const Icon(Iconsax.copy, size: 18),
                                color: AppColors.primary,
                                tooltip: 'نسخ الرقم',
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(8),
                              ),
                            ],
                          )
                        else
                          Text(
                            'رقم الهاتف غير متوفر',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontStyle: FontStyle.italic,
                                    ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
