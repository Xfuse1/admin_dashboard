import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../domain/entities/settings_entities.dart';
import '../../../../core/constants/app_colors.dart';

/// Card for general settings.
class GeneralSettingsCard extends StatefulWidget {
  final GeneralSettings settings;
  final ValueChanged<GeneralSettings> onSave;
  final bool isSaving;

  const GeneralSettingsCard({
    super.key,
    required this.settings,
    required this.onSave,
    this.isSaving = false,
  });

  @override
  State<GeneralSettingsCard> createState() => _GeneralSettingsCardState();
}

class _GeneralSettingsCardState extends State<GeneralSettingsCard> {
  late TextEditingController _appNameController;
  late TextEditingController _supportPhoneController;
  late TextEditingController _supportEmailController;
  late TextEditingController _currencyController;
  late TextEditingController _timezoneController;
  late bool _maintenanceMode;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _appNameController = TextEditingController(text: widget.settings.appName);
    _supportPhoneController =
        TextEditingController(text: widget.settings.supportPhone);
    _supportEmailController =
        TextEditingController(text: widget.settings.supportEmail);
    _currencyController = TextEditingController(text: widget.settings.currency);
    _timezoneController = TextEditingController(text: widget.settings.timezone);
    _maintenanceMode = widget.settings.maintenanceMode;

    _appNameController.addListener(_onChanged);
    _supportPhoneController.addListener(_onChanged);
    _supportEmailController.addListener(_onChanged);
    _currencyController.addListener(_onChanged);
    _timezoneController.addListener(_onChanged);
  }

  void _onChanged() {
    setState(() => _hasChanges = true);
  }

  @override
  void didUpdateWidget(GeneralSettingsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings != widget.settings) {
      _appNameController.text = widget.settings.appName;
      _supportPhoneController.text = widget.settings.supportPhone;
      _supportEmailController.text = widget.settings.supportEmail;
      _currencyController.text = widget.settings.currency;
      _timezoneController.text = widget.settings.timezone;
      _maintenanceMode = widget.settings.maintenanceMode;
      _hasChanges = false;
    }
  }

  @override
  void dispose() {
    _appNameController.dispose();
    _supportPhoneController.dispose();
    _supportEmailController.dispose();
    _currencyController.dispose();
    _timezoneController.dispose();
    super.dispose();
  }

  void _save() {
    final updated = GeneralSettings(
      appName: _appNameController.text.trim(),
      appNameAr: widget.settings.appNameAr,
      supportPhone: _supportPhoneController.text.trim(),
      supportEmail: _supportEmailController.text.trim(),
      currency: _currencyController.text.trim(),
      currencySymbol: widget.settings.currencySymbol,
      timezone: _timezoneController.text.trim(),
      maintenanceMode: _maintenanceMode,
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
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Iconsax.setting_2, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الإعدادات العامة',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'إعدادات التطبيق الأساسية',
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

            // App Name
            _buildTextField(
              label: 'اسم التطبيق',
              controller: _appNameController,
              icon: Iconsax.text,
            ),
            const SizedBox(height: 16),

            // Support Phone
            _buildTextField(
              label: 'رقم الدعم',
              controller: _supportPhoneController,
              icon: Iconsax.call,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            // Support Email
            _buildTextField(
              label: 'بريد الدعم',
              controller: _supportEmailController,
              icon: Iconsax.sms,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'العملة',
                    controller: _currencyController,
                    icon: Iconsax.dollar_circle,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    label: 'المنطقة الزمنية',
                    controller: _timezoneController,
                    icon: Iconsax.clock,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Maintenance Mode
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _maintenanceMode
                    ? AppColors.warning.withValues(alpha: 0.1)
                    : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _maintenanceMode
                      ? AppColors.warning
                      : AppColors.borderLight,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Iconsax.warning_2,
                    color: _maintenanceMode
                        ? AppColors.warning
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'وضع الصيانة',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'عند التفعيل، لن يتمكن المستخدمون من استخدام التطبيق',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _maintenanceMode,
                    onChanged: (value) {
                      setState(() {
                        _maintenanceMode = value;
                        _hasChanges = true;
                      });
                    },
                    activeTrackColor: AppColors.warning,
                    thumbColor: WidgetStateProperty.all(Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
