import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../../domain/entities/simulator_settings.dart';
import '../bloc/simulator_settings_bloc.dart';
import '../bloc/simulator_settings_event.dart';
import '../bloc/simulator_settings_state.dart';

/// صفحة إعدادات المحاكي
class SimulatorSettingsPage extends StatefulWidget {
  const SimulatorSettingsPage({super.key});

  @override
  State<SimulatorSettingsPage> createState() => _SimulatorSettingsPageState();
}

class _SimulatorSettingsPageState extends State<SimulatorSettingsPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for simulator settings
  final _rowsController = TextEditingController();
  final _columnsController = TextEditingController();
  final _productsPerRowController = TextEditingController();
  final _productsPerColumnController = TextEditingController();
  final _maxCartItemsController = TextEditingController();
  final _minOrderAmountController = TextEditingController();
  final _cartTimeoutController = TextEditingController();
  final _autoScrollSpeedController = TextEditingController();

  bool _enableSounds = true;
  bool _enableVibration = true;
  bool _isSimulatorEnabled = false;
  bool _controllersInitialized = false;

  @override
  void dispose() {
    _rowsController.dispose();
    _columnsController.dispose();
    _productsPerRowController.dispose();
    _productsPerColumnController.dispose();
    _maxCartItemsController.dispose();
    _minOrderAmountController.dispose();
    _cartTimeoutController.dispose();
    _autoScrollSpeedController.dispose();
    super.dispose();
  }

  /// Populate controllers from loaded settings (only once).
  void _populateControllers(SimulatorSettings settings) {
    if (_controllersInitialized) return;
    _controllersInitialized = true;

    _rowsController.text = settings.rows.toString();
    _columnsController.text = settings.columns.toString();
    _productsPerRowController.text = settings.productsPerRow.toString();
    _productsPerColumnController.text = settings.productsPerColumn.toString();
    _maxCartItemsController.text = settings.maxCartItems.toString();
    _minOrderAmountController.text = settings.minOrderAmount.toString();
    _cartTimeoutController.text = settings.cartTimeout.toString();
    _autoScrollSpeedController.text = settings.autoScrollSpeed.toString();
    _enableSounds = settings.enableSounds;
    _enableVibration = settings.enableVibration;
    _isSimulatorEnabled = settings.enabled;
  }

  /// Build a [SimulatorSettings] from current form values.
  SimulatorSettings _buildSettingsFromForm() {
    return SimulatorSettings(
      enabled: _isSimulatorEnabled,
      rows: int.tryParse(_rowsController.text) ?? 4,
      columns: int.tryParse(_columnsController.text) ?? 3,
      productsPerRow: int.tryParse(_productsPerRowController.text) ?? 5,
      productsPerColumn: int.tryParse(_productsPerColumnController.text) ?? 4,
      maxCartItems: int.tryParse(_maxCartItemsController.text) ?? 20,
      minOrderAmount:
          double.tryParse(_minOrderAmountController.text) ?? 50.0,
      cartTimeout: int.tryParse(_cartTimeoutController.text) ?? 30,
      autoScrollSpeed: int.tryParse(_autoScrollSpeedController.text) ?? 3,
      enableSounds: _enableSounds,
      enableVibration: _enableVibration,
    );
  }

  void _showSuccessMessage(String message) {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.flat,
      title: Text(message),
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 4),
      showProgressBar: true,
    );
  }

  void _showErrorMessage(String message) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.flat,
      title: Text(message),
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 4),
      showProgressBar: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveLayout.getDeviceType(context);
    final isDesktop = deviceType == DeviceType.desktop;
    final crossAxisCount = isDesktop ? 2 : 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<SimulatorSettingsBloc, SimulatorSettingsState>(
        listener: (context, state) {
          if (state is SimulatorSettingsLoaded) {
            _populateControllers(state.settings);
            // Update local toggle state
            setState(() {
              _isSimulatorEnabled = state.settings.enabled;
              _enableSounds = state.settings.enableSounds;
              _enableVibration = state.settings.enableVibration;
            });
          } else if (state is SimulatorSettingsError) {
            _showErrorMessage(state.message);
          }
        },
        builder: (context, state) {
          if (state is SimulatorSettingsLoading ||
              state is SimulatorSettingsInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          final isSaving = state is SimulatorSettingsActionInProgress;

          return SingleChildScrollView(
            padding: EdgeInsets.all(
                isDesktop ? AppConstants.spacingLg : AppConstants.spacingMd),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // العنوان
                  Text(
                    'إعدادات المحاكي',
                    style:
                        Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                  ),
                  const SizedBox(height: AppConstants.spacingMd),

                  // بطاقة تفعيل المحاكي
                  _buildEnableCard(isSaving),
                  const SizedBox(height: AppConstants.spacingMd),

                  // عنوان إعدادات الشبكة
                  _buildSectionTitle('إعدادات الشبكة'),
                  const SizedBox(height: AppConstants.spacingSm),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: AppConstants.spacingMd,
                    mainAxisSpacing: AppConstants.spacingMd,
                    childAspectRatio: isDesktop ? 3.0 : 2.5,
                    children: [
                      _buildNumberField(
                        controller: _rowsController,
                        label: 'عدد الصفوف',
                        icon: Iconsax.row_horizontal,
                        hint: 'مثال: 4',
                      ),
                      _buildNumberField(
                        controller: _columnsController,
                        label: 'عدد الأعمدة',
                        icon: Iconsax.menu,
                        hint: 'مثال: 3',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingMd),

                  // عنوان إعدادات المنتجات
                  _buildSectionTitle('إعدادات المنتجات'),
                  const SizedBox(height: AppConstants.spacingSm),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: AppConstants.spacingMd,
                    mainAxisSpacing: AppConstants.spacingMd,
                    childAspectRatio: isDesktop ? 3.0 : 2.5,
                    children: [
                      _buildNumberField(
                        controller: _productsPerRowController,
                        label: 'عدد المنتجات في كل صف',
                        icon: Iconsax.grid_1,
                        hint: 'مثال: 5',
                      ),
                      _buildNumberField(
                        controller: _productsPerColumnController,
                        label: 'عدد المنتجات في كل عمود',
                        icon: Iconsax.grid_2,
                        hint: 'مثال: 4',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingMd),

                  // عنوان إعدادات السلة والطلبات
                  _buildSectionTitle('إعدادات السلة والطلبات'),
                  const SizedBox(height: AppConstants.spacingSm),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: AppConstants.spacingMd,
                    mainAxisSpacing: AppConstants.spacingMd,
                    childAspectRatio: isDesktop ? 3.0 : 2.5,
                    children: [
                      _buildNumberField(
                        controller: _maxCartItemsController,
                        label: 'الحد الأقصى للسلة',
                        icon: Iconsax.shopping_cart,
                        hint: 'مثال: 20',
                      ),
                      _buildNumberField(
                        controller: _minOrderAmountController,
                        label: 'الحد الأدنى للطلب (ج.م)',
                        icon: Iconsax.money_4,
                        hint: 'مثال: 50',
                        isDecimal: true,
                      ),
                      _buildNumberField(
                        controller: _cartTimeoutController,
                        label: 'وقت انتهاء السلة (دقيقة)',
                        icon: Iconsax.timer_1,
                        hint: 'مثال: 30',
                      ),
                      _buildNumberField(
                        controller: _autoScrollSpeedController,
                        label: 'سرعة التحريك التلقائي',
                        icon: Iconsax.flash_1,
                        hint: 'مثال: 3',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingMd),

                  // عنوان التجربة التفاعلية
                  _buildSectionTitle('التجربة التفاعلية'),
                  const SizedBox(height: AppConstants.spacingSm),

                  // بطاقة الأصوات والاهتزاز
                  _buildInteractiveCard(),
                  const SizedBox(height: AppConstants.spacingLg),

                  // زر الحفظ
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isSaving
                          ? null
                          : () {
                              if (!_formKey.currentState!.validate()) return;
                              final settings = _buildSettingsFromForm();
                              context.read<SimulatorSettingsBloc>().add(
                                    SaveSimulatorSettingsEvent(settings),
                                  );
                              _showSuccessMessage('تم حفظ جميع الإعدادات بنجاح');
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: isSaving
                          ? const CircularProgressIndicator(
                              color: Colors.white)
                          : const Text(
                              'حفظ جميع الإعدادات',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEnableCard(bool isSaving) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              decoration: BoxDecoration(
                color: _isSimulatorEnabled
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _isSimulatorEnabled ? Icons.visibility : Icons.visibility_off,
                color:
                    _isSimulatorEnabled ? AppColors.success : AppColors.error,
                size: 32,
              ),
            ),
            const SizedBox(width: AppConstants.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'عرض المحاكي في الموقع',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isSimulatorEnabled
                        ? 'المحاكي نشط ويظهر في الموقع'
                        : 'المحاكي متوقف ولا يظهر في الموقع',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _isSimulatorEnabled,
              onChanged: isSaving
                  ? null
                  : (value) {
                      setState(() => _isSimulatorEnabled = value);
                      context
                          .read<SimulatorSettingsBloc>()
                          .add(ToggleSimulatorEvent(value));
                      if (value) {
                        _showSuccessMessage(
                            'تم تفعيل المحاكي بنجاح الآن يظهر في الموقع');
                      } else {
                        _showSuccessMessage(
                            'تم إيقاف ظهور المحاكي في الموقع');
                      }
                    },
              activeColor: AppColors.success,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    bool isDecimal = false,
  }) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingSm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: controller,
              keyboardType:
                  TextInputType.numberWithOptions(decimal: isDecimal),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  isDecimal ? RegExp(r'^\d+\.?\d{0,2}') : RegExp(r'^\d+'),
                ),
              ],
              decoration: InputDecoration(
                hintText: hint,
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Colors.grey.withValues(alpha: 0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'مطلوب';
                }
                final number = isDecimal
                    ? double.tryParse(value)
                    : int.tryParse(value);
                if (number == null) {
                  return 'رقم غير صحيح';
                }
                if (number <= 0) {
                  return 'يجب أن يكون أكبر من صفر';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveCard() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          children: [
            SwitchListTile(
              value: _enableSounds,
              onChanged: (value) {
                setState(() => _enableSounds = value);
              },
              title: Row(
                children: [
                  Icon(Iconsax.volume_high,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  const Flexible(child: Text('تفعيل الأصوات')),
                ],
              ),
              subtitle:
                  const Text('تشغيل الأصوات التفاعلية في المحاكي'),
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            SwitchListTile(
              value: _enableVibration,
              onChanged: (value) {
                setState(() => _enableVibration = value);
              },
              title: Row(
                children: [
                  Icon(Iconsax.mobile,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  const Flexible(child: Text('تفعيل الاهتزاز')),
                ],
              ),
              subtitle: const Text(
                  'تشغيل الاهتزاز عند التفاعل مع المحاكي'),
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}
