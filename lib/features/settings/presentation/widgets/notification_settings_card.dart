import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../domain/entities/settings_entities.dart';
import '../../../../core/constants/app_colors.dart';

/// Card for notification settings.
class NotificationSettingsCard extends StatefulWidget {
  final NotificationSettings settings;
  final ValueChanged<NotificationSettings> onSave;
  final bool isSaving;

  const NotificationSettingsCard({
    super.key,
    required this.settings,
    required this.onSave,
    this.isSaving = false,
  });

  @override
  State<NotificationSettingsCard> createState() =>
      _NotificationSettingsCardState();
}

class _NotificationSettingsCardState extends State<NotificationSettingsCard> {
  late bool _pushEnabled;
  late bool _emailEnabled;
  late bool _smsEnabled;
  late bool _onNewOrder;
  late bool _onStatusChange;
  late bool _onNewDriver;
  late bool _onNewStore;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _initValues();
  }

  void _initValues() {
    _pushEnabled = widget.settings.enablePushNotifications;
    _emailEnabled = widget.settings.enableEmailNotifications;
    _smsEnabled = widget.settings.enableSmsNotifications;
    _onNewOrder = widget.settings.notifyOnNewOrder;
    _onStatusChange = widget.settings.notifyOnOrderStatusChange;
    _onNewDriver = widget.settings.notifyOnNewDriver;
    _onNewStore = widget.settings.notifyOnNewStore;
  }

  @override
  void didUpdateWidget(NotificationSettingsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings != widget.settings) {
      _initValues();
      _hasChanges = false;
    }
  }

  void _save() {
    final updated = NotificationSettings(
      enablePushNotifications: _pushEnabled,
      enableEmailNotifications: _emailEnabled,
      enableSmsNotifications: _smsEnabled,
      notifyOnNewOrder: _onNewOrder,
      notifyOnOrderStatusChange: _onStatusChange,
      notifyOnNewDriver: _onNewDriver,
      notifyOnNewStore: _onNewStore,
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
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Iconsax.notification, color: AppColors.warning),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إعدادات الإشعارات',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'قنوات وأنواع الإشعارات',
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

            // Notification Channels
            Text(
              'قنوات الإشعارات',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildChannelToggle(
              icon: Iconsax.notification,
              title: 'إشعارات الدفع',
              subtitle: 'إرسال إشعارات عبر التطبيق',
              value: _pushEnabled,
              color: AppColors.primary,
              onChanged: (value) {
                setState(() {
                  _pushEnabled = value;
                  _hasChanges = true;
                });
              },
            ),
            const SizedBox(height: 12),

            _buildChannelToggle(
              icon: Iconsax.sms,
              title: 'البريد الإلكتروني',
              subtitle: 'إرسال إشعارات عبر البريد',
              value: _emailEnabled,
              color: AppColors.info,
              onChanged: (value) {
                setState(() {
                  _emailEnabled = value;
                  _hasChanges = true;
                });
              },
            ),
            const SizedBox(height: 12),

            _buildChannelToggle(
              icon: Iconsax.message_text,
              title: 'الرسائل النصية',
              subtitle: 'إرسال إشعارات عبر SMS',
              value: _smsEnabled,
              color: AppColors.success,
              onChanged: (value) {
                setState(() {
                  _smsEnabled = value;
                  _hasChanges = true;
                });
              },
            ),

            const SizedBox(height: 32),

            // Notification Types
            Text(
              'أنواع الإشعارات',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildTypeToggle(
              icon: Iconsax.shopping_bag,
              title: 'طلبات جديدة',
              subtitle: 'إشعارات عند استلام طلبات جديدة',
              value: _onNewOrder,
              onChanged: (value) {
                setState(() {
                  _onNewOrder = value;
                  _hasChanges = true;
                });
              },
            ),
            const SizedBox(height: 12),

            _buildTypeToggle(
              icon: Iconsax.refresh,
              title: 'تغيير حالة الطلب',
              subtitle: 'إشعارات عند تغيير حالة الطلبات',
              value: _onStatusChange,
              onChanged: (value) {
                setState(() {
                  _onStatusChange = value;
                  _hasChanges = true;
                });
              },
            ),
            const SizedBox(height: 12),

            _buildTypeToggle(
              icon: Iconsax.car,
              title: 'سائق جديد',
              subtitle: 'إشعارات عند تسجيل سائق جديد',
              value: _onNewDriver,
              onChanged: (value) {
                setState(() {
                  _onNewDriver = value;
                  _hasChanges = true;
                });
              },
            ),
            const SizedBox(height: 12),

            _buildTypeToggle(
              icon: Iconsax.shop,
              title: 'متجر جديد',
              subtitle: 'إشعارات عند تسجيل متجر جديد',
              value: _onNewStore,
              onChanged: (value) {
                setState(() {
                  _onNewStore = value;
                  _hasChanges = true;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Color color,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: value ? color.withValues(alpha: 0.05) : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? color.withValues(alpha: 0.3) : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
                  value ? color.withValues(alpha: 0.1) : AppColors.borderLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: value ? color : AppColors.textSecondary,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: color,
            thumbColor: WidgetStateProperty.all(Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: value ? AppColors.primary : AppColors.textSecondary,
            size: 22,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Checkbox(
            value: value,
            onChanged: (v) => onChanged(v ?? false),
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
