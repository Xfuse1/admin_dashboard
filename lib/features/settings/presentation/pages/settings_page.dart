import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/settings_entities.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';
import '../widgets/general_settings_card.dart';
import '../widgets/delivery_settings_card.dart';
import '../widgets/commission_settings_card.dart';
import '../widgets/notification_settings_card.dart';

/// Settings page with tabs for different settings sections.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<_SettingsTab> _tabs = [
    _SettingsTab(
      title: 'عام',
      icon: Iconsax.setting_2,
    ),
    _SettingsTab(
      title: 'التوصيل',
      icon: Iconsax.truck_fast,
    ),
    _SettingsTab(
      title: 'العمولات',
      icon: Iconsax.percentage_circle,
    ),
    _SettingsTab(
      title: 'الإشعارات',
      icon: Iconsax.notification,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    context.read<SettingsBloc>().add(SwitchSettingsTab(_tabController.index));
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return BlocConsumer<SettingsBloc, SettingsState>(
      listener: _handleStateChanges,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(isDesktop ? 32 : 16),
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
                          child: Icon(
                            Iconsax.setting,
                            color: AppColors.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'الإعدادات',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'إدارة إعدادات التطبيق والنظام',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Tabs
              Container(
                margin: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  tabs: _tabs.map((tab) {
                    return Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(tab.icon, size: 18),
                          if (isDesktop) ...[
                            const SizedBox(width: 8),
                            Text(tab.title),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // Content
              Expanded(
                child: _buildContent(state),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleStateChanges(BuildContext context, SettingsState state) {
    if (state is SettingsActionSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Iconsax.tick_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(state.message),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } else if (state is SettingsError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Iconsax.warning_2, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(state.message)),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          action: SnackBarAction(
            label: 'إغلاق',
            textColor: Colors.white,
            onPressed: () {
              context.read<SettingsBloc>().add(const ClearSettingsError());
            },
          ),
        ),
      );
    }
  }

  Widget _buildContent(SettingsState state) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final padding = EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 16);

    if (state is SettingsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is SettingsError && state.previousState == null) {
      return _buildErrorState(state.message);
    }

    AppSettingsEntity? settings;
    bool isSaving = false;

    if (state is SettingsLoaded) {
      settings = state.settings;
    } else if (state is SettingsActionInProgress) {
      settings = state.previousState.settings;
      isSaving = true;
    } else if (state is SettingsActionSuccess) {
      settings = state.updatedState.settings;
    } else if (state is SettingsError &&
        state.previousState is SettingsLoaded) {
      settings = (state.previousState as SettingsLoaded).settings;
    }

    if (settings == null) {
      return _buildEmptyState();
    }

    return TabBarView(
      controller: _tabController,
      children: [
        // General Settings
        SingleChildScrollView(
          padding: padding.copyWith(bottom: 32),
          child: GeneralSettingsCard(
            settings: settings.general,
            isSaving: isSaving,
            onSave: (updated) {
              context
                  .read<SettingsBloc>()
                  .add(UpdateGeneralSettingsEvent(updated));
            },
          ),
        ),

        // Delivery Settings
        SingleChildScrollView(
          padding: padding.copyWith(bottom: 32),
          child: DeliverySettingsCard(
            settings: settings.delivery,
            isSaving: isSaving,
            onSave: (updated) {
              context
                  .read<SettingsBloc>()
                  .add(UpdateDeliverySettingsEvent(updated));
            },
            onAddZone: () => _showZoneDialog(null),
            onEditZone: (zone) => _showZoneDialog(zone),
            onDeleteZone: (zoneId) => _confirmDeleteZone(zoneId),
          ),
        ),

        // Commission Settings
        SingleChildScrollView(
          padding: padding.copyWith(bottom: 32),
          child: CommissionSettingsCard(
            settings: settings.commission,
            isSaving: isSaving,
            onSave: (updated) {
              context
                  .read<SettingsBloc>()
                  .add(UpdateCommissionSettingsEvent(updated));
            },
          ),
        ),

        // Notification Settings
        SingleChildScrollView(
          padding: padding.copyWith(bottom: 32),
          child: NotificationSettingsCard(
            settings: settings.notifications,
            isSaving: isSaving,
            onSave: (updated) {
              context
                  .read<SettingsBloc>()
                  .add(UpdateNotificationSettingsEvent(updated));
            },
          ),
        ),
      ],
    );
  }

  void _showZoneDialog(DeliveryZone? zone) {
    final isEditing = zone != null;
    final nameController = TextEditingController(text: zone?.name ?? '');
    final nameArController = TextEditingController(text: zone?.nameAr ?? '');
    final feeController =
        TextEditingController(text: zone?.fee.toString() ?? '');
    bool isActive = zone?.isActive ?? true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title:
                  Text(isEditing ? 'تعديل منطقة التوصيل' : 'إضافة منطقة توصيل'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'اسم المنطقة (إنجليزي)',
                      prefixIcon: const Icon(Iconsax.location),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameArController,
                    decoration: InputDecoration(
                      labelText: 'اسم المنطقة (عربي)',
                      prefixIcon: const Icon(Iconsax.location),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: feeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'رسوم التوصيل',
                      suffixText: 'ر.س',
                      prefixIcon: const Icon(Iconsax.dollar_circle),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    value: isActive,
                    onChanged: (value) {
                      setDialogState(() => isActive = value);
                    },
                    title: const Text('منطقة نشطة'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final newZone = DeliveryZone(
                      id: zone?.id ??
                          DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameController.text.trim(),
                      nameAr: nameArController.text.trim(),
                      fee: double.tryParse(feeController.text) ?? 0,
                      isActive: isActive,
                    );

                    if (isEditing) {
                      this
                          .context
                          .read<SettingsBloc>()
                          .add(UpdateDeliveryZoneEvent(newZone));
                    } else {
                      this
                          .context
                          .read<SettingsBloc>()
                          .add(AddDeliveryZoneEvent(newZone));
                    }
                    Navigator.pop(context);
                  },
                  child: Text(isEditing ? 'تحديث' : 'إضافة'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteZone(String zoneId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('حذف منطقة التوصيل'),
          content: const Text('هل أنت متأكد من حذف هذه المنطقة؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                this
                    .context
                    .read<SettingsBloc>()
                    .add(DeleteDeliveryZoneEvent(zoneId));
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.warning_2, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            'حدث خطأ',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<SettingsBloc>().add(const LoadSettings());
            },
            icon: const Icon(Iconsax.refresh),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.setting, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            'لا توجد إعدادات',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<SettingsBloc>().add(const LoadSettings());
            },
            icon: const Icon(Iconsax.refresh),
            label: const Text('تحميل الإعدادات'),
          ),
        ],
      ),
    );
  }
}

class _SettingsTab {
  final String title;
  final IconData icon;

  const _SettingsTab({
    required this.title,
    required this.icon,
  });
}
