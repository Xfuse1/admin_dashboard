import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../domain/entities/settings_entities.dart';
import '../../../../core/constants/app_colors.dart';

/// Card for delivery settings.
class DeliverySettingsCard extends StatefulWidget {
  final DeliverySettings settings;
  final ValueChanged<DeliverySettings> onSave;
  final VoidCallback onAddZone;
  final ValueChanged<DeliveryZone> onEditZone;
  final ValueChanged<String> onDeleteZone;
  final bool isSaving;

  const DeliverySettingsCard({
    super.key,
    required this.settings,
    required this.onSave,
    required this.onAddZone,
    required this.onEditZone,
    required this.onDeleteZone,
    this.isSaving = false,
  });

  @override
  State<DeliverySettingsCard> createState() => _DeliverySettingsCardState();
}

class _DeliverySettingsCardState extends State<DeliverySettingsCard> {
  late TextEditingController _baseFeeController;
  late TextEditingController _feePerKmController;
  late TextEditingController _minOrderController;
  late TextEditingController _freeDeliveryController;
  late TextEditingController _maxRadiusController;
  late TextEditingController _estimatedTimeController;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _baseFeeController =
        TextEditingController(text: widget.settings.baseDeliveryFee.toString());
    _feePerKmController =
        TextEditingController(text: widget.settings.feePerKilometer.toString());
    _minOrderController = TextEditingController(
        text: widget.settings.minimumOrderAmount.toString());
    _freeDeliveryController = TextEditingController(
        text: widget.settings.freeDeliveryThreshold > 0
            ? widget.settings.freeDeliveryThreshold.toString()
            : '');
    _maxRadiusController = TextEditingController(
        text: widget.settings.maxDeliveryRadius.toString());
    _estimatedTimeController = TextEditingController(
        text: widget.settings.estimatedDeliveryTime.toString());

    _baseFeeController.addListener(_onChanged);
    _feePerKmController.addListener(_onChanged);
    _minOrderController.addListener(_onChanged);
    _freeDeliveryController.addListener(_onChanged);
    _maxRadiusController.addListener(_onChanged);
    _estimatedTimeController.addListener(_onChanged);
  }

  void _onChanged() {
    setState(() => _hasChanges = true);
  }

  @override
  void didUpdateWidget(DeliverySettingsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings != widget.settings) {
      _baseFeeController.text = widget.settings.baseDeliveryFee.toString();
      _feePerKmController.text = widget.settings.feePerKilometer.toString();
      _minOrderController.text = widget.settings.minimumOrderAmount.toString();
      _freeDeliveryController.text = widget.settings.freeDeliveryThreshold > 0
          ? widget.settings.freeDeliveryThreshold.toString()
          : '';
      _maxRadiusController.text = widget.settings.maxDeliveryRadius.toString();
      _estimatedTimeController.text =
          widget.settings.estimatedDeliveryTime.toString();
      _hasChanges = false;
    }
  }

  @override
  void dispose() {
    _baseFeeController.dispose();
    _feePerKmController.dispose();
    _minOrderController.dispose();
    _freeDeliveryController.dispose();
    _maxRadiusController.dispose();
    _estimatedTimeController.dispose();
    super.dispose();
  }

  void _save() {
    final updated = DeliverySettings(
      baseDeliveryFee: double.tryParse(_baseFeeController.text) ?? 0,
      feePerKilometer: double.tryParse(_feePerKmController.text) ?? 0,
      minimumOrderAmount: double.tryParse(_minOrderController.text) ?? 0,
      freeDeliveryThreshold: double.tryParse(_freeDeliveryController.text) ?? 0,
      maxDeliveryRadius: int.tryParse(_maxRadiusController.text) ?? 0,
      estimatedDeliveryTime: int.tryParse(_estimatedTimeController.text) ?? 30,
      zones: widget.settings.zones,
    );
    widget.onSave(updated);
    setState(() => _hasChanges = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Iconsax.truck_fast, color: AppColors.info),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إعدادات التوصيل',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'رسوم ومناطق التوصيل',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_hasChanges)
                  ElevatedButton.icon(
                    onPressed: widget.isSaving ? null : _save,
                    icon: widget.isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Iconsax.tick_circle, size: 18),
                    label: const Text('حفظ'),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),

            // Delivery Fees
            Row(
              children: [
                Expanded(
                  child: _buildNumberField(
                    label: 'رسوم التوصيل الأساسية',
                    controller: _baseFeeController,
                    suffix: 'ر.س',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildNumberField(
                    label: 'رسوم لكل كيلومتر',
                    controller: _feePerKmController,
                    suffix: 'ر.س/كم',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildNumberField(
                    label: 'الحد الأدنى للطلب',
                    controller: _minOrderController,
                    suffix: 'ر.س',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildNumberField(
                    label: 'حد التوصيل المجاني',
                    controller: _freeDeliveryController,
                    suffix: 'ر.س',
                    hint: 'اختياري',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildNumberField(
                    label: 'أقصى نطاق توصيل',
                    controller: _maxRadiusController,
                    suffix: 'كم',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildNumberField(
                    label: 'وقت التوصيل المتوقع',
                    controller: _estimatedTimeController,
                    suffix: 'دقيقة',
                    allowDecimals: false,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Delivery Zones
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'مناطق التوصيل',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: widget.onAddZone,
                  icon: const Icon(Iconsax.add_circle, size: 18),
                  label: const Text('إضافة منطقة'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (widget.settings.zones.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Iconsax.location,
                        size: 48,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد مناطق توصيل',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.settings.zones.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final zone = widget.settings.zones[index];
                  return _buildZoneItem(zone);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    required TextEditingController controller,
    String? suffix,
    String? hint,
    bool allowDecimals = true,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: allowDecimals),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          allowDecimals ? RegExp(r'^\d*\.?\d*') : RegExp(r'^\d*'),
        ),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildZoneItem(DeliveryZone zone) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: zone.isActive
            ? AppColors.success.withValues(alpha: 0.05)
            : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: zone.isActive ? AppColors.success : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: zone.isActive
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.textSecondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Iconsax.location,
              color:
                  zone.isActive ? AppColors.success : AppColors.textSecondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      zone.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: zone.isActive
                            ? AppColors.success.withValues(alpha: 0.1)
                            : AppColors.textSecondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        zone.isActive ? 'نشط' : 'غير نشط',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: zone.isActive
                              ? AppColors.success
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'رسوم: ${zone.fee} ر.س',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => widget.onEditZone(zone),
            icon: Icon(Iconsax.edit_2, size: 20, color: AppColors.info),
            tooltip: 'تعديل',
          ),
          IconButton(
            onPressed: () => widget.onDeleteZone(zone.id),
            icon: Icon(Iconsax.trash, size: 20, color: AppColors.error),
            tooltip: 'حذف',
          ),
        ],
      ),
    );
  }
}
