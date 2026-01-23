import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../domain/entities/settings_entities.dart';
import '../../../../core/constants/app_colors.dart';

/// Card for commission settings.
class CommissionSettingsCard extends StatefulWidget {
  final CommissionSettings settings;
  final ValueChanged<CommissionSettings> onSave;
  final bool isSaving;

  const CommissionSettingsCard({
    super.key,
    required this.settings,
    required this.onSave,
    this.isSaving = false,
  });

  @override
  State<CommissionSettingsCard> createState() => _CommissionSettingsCardState();
}

class _CommissionSettingsCardState extends State<CommissionSettingsCard> {
  late TextEditingController _defaultStoreController;
  late TextEditingController _defaultDriverController;
  late TextEditingController _minPayoutController;
  late TextEditingController _payoutFrequencyController;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _defaultStoreController = TextEditingController(
      text: (widget.settings.defaultStoreCommission * 100).toStringAsFixed(0),
    );
    _defaultDriverController = TextEditingController(
      text: (widget.settings.defaultDriverCommission * 100).toStringAsFixed(0),
    );
    _minPayoutController = TextEditingController(
      text: widget.settings.minimumPayout.toString(),
    );
    _payoutFrequencyController = TextEditingController(
      text: widget.settings.payoutFrequency,
    );

    _defaultStoreController.addListener(_onChanged);
    _defaultDriverController.addListener(_onChanged);
    _minPayoutController.addListener(_onChanged);
    _payoutFrequencyController.addListener(_onChanged);
  }

  void _onChanged() {
    setState(() => _hasChanges = true);
  }

  @override
  void didUpdateWidget(CommissionSettingsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings != widget.settings) {
      _defaultStoreController.text =
          (widget.settings.defaultStoreCommission * 100).toStringAsFixed(0);
      _defaultDriverController.text =
          (widget.settings.defaultDriverCommission * 100).toStringAsFixed(0);
      _minPayoutController.text = widget.settings.minimumPayout.toString();
      _payoutFrequencyController.text = widget.settings.payoutFrequency;
      _hasChanges = false;
    }
  }

  @override
  void dispose() {
    _defaultStoreController.dispose();
    _defaultDriverController.dispose();
    _minPayoutController.dispose();
    _payoutFrequencyController.dispose();
    super.dispose();
  }

  void _save() {
    final storePercent = double.tryParse(_defaultStoreController.text) ?? 0;
    final driverPercent = double.tryParse(_defaultDriverController.text) ?? 0;

    final updated = CommissionSettings(
      defaultStoreCommission: storePercent / 100,
      defaultDriverCommission: driverPercent / 100,
      minimumPayout: double.tryParse(_minPayoutController.text) ?? 0,
      payoutFrequency: _payoutFrequencyController.text,
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
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      Icon(Iconsax.percentage_circle, color: AppColors.success),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إعدادات العمولات',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'عمولات المتاجر والسائقين',
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

            // Commission Percentages
            Row(
              children: [
                Expanded(
                  child: _buildCommissionField(
                    label: 'عمولة المتاجر',
                    controller: _defaultStoreController,
                    icon: Iconsax.shop,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCommissionField(
                    label: 'عمولة السائقين',
                    controller: _defaultDriverController,
                    icon: Iconsax.car,
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Commission Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppColors.info.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.info_circle, color: AppColors.info, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'العمولات هي النسبة المئوية التي يتم خصمها من كل طلب. يمكن تخصيص العمولة لكل متجر أو سائق بشكل منفصل.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Payout Settings
            Text(
              'إعدادات الدفع',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildNumberField(
              label: 'الحد الأدنى للتحويل',
              controller: _minPayoutController,
              suffix: 'ر.س',
              icon: Iconsax.wallet,
            ),
            const SizedBox(height: 16),

            // Payout Frequency
            TextField(
              controller: _payoutFrequencyController,
              decoration: InputDecoration(
                labelText: 'تكرار الدفع',
                hintText: 'weekly',
                prefixIcon: const Icon(Iconsax.calendar),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommissionField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 60,
                child: TextField(
                  controller: controller,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              Text(
                '%',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    required TextEditingController controller,
    String? suffix,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
