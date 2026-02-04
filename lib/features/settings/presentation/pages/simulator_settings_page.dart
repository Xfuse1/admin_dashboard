import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toastification/toastification.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/glass_card.dart';

/// صفحة إعدادات المحاكي
class SimulatorSettingsPage extends StatefulWidget {
  const SimulatorSettingsPage({super.key});

  @override
  State<SimulatorSettingsPage> createState() => _SimulatorSettingsPageState();
}

class _SimulatorSettingsPageState extends State<SimulatorSettingsPage> {
  final _firestore = FirebaseFirestore.instance;
  bool _isSimulatorEnabled = false;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSimulatorStatus();
  }

  /// تحميل حالة المحاكي من Firebase
  Future<void> _loadSimulatorStatus() async {
    try {
      final doc =
          await _firestore.collection('settings').doc('simulator').get();

      if (doc.exists) {
        setState(() {
          _isSimulatorEnabled = doc.data()?['enabled'] ?? false;
          _isLoading = false;
        });
      } else {
        // إنشاء المستند إذا لم يكن موجوداً
        await _firestore.collection('settings').doc('simulator').set({
          'enabled': false,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        setState(() {
          _isSimulatorEnabled = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorMessage('فشل تحميل البيانات: $e');
    }
  }

  /// حفظ حالة المحاكي في Firebase
  Future<void> _toggleSimulator(bool value) async {
    setState(() => _isSaving = true);

    try {
      await _firestore.collection('settings').doc('simulator').set({
        'enabled': value,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      setState(() {
        _isSimulatorEnabled = value;
        _isSaving = false;
      });

      // عرض رسالة النجاح
      if (value) {
        _showSuccessMessage('تم تفعيل المحاكي بنجاح الآن يظهر في الموقع');
      } else {
        _showSuccessMessage('تم إيقاف ظهور المحاكي في الموقع');
      }
    } catch (e) {
      setState(() => _isSaving = false);
      _showErrorMessage('فشل حفظ الإعدادات: $e');
    }
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العنوان
            Text(
              'إعدادات المحاكي',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppConstants.spacingMd),

            // البطاقة الرئيسية
            GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingLg),
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : Row(
                        children: [
                          // الأيقونة
                          Container(
                            padding:
                                const EdgeInsets.all(AppConstants.spacingMd),
                            decoration: BoxDecoration(
                              color: _isSimulatorEnabled
                                  ? AppColors.success.withValues(alpha: 0.1)
                                  : AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _isSimulatorEnabled
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: _isSimulatorEnabled
                                  ? AppColors.success
                                  : AppColors.error,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: AppConstants.spacingLg),

                          // النص
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'عرض المحاكي في الموقع',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: AppConstants.spacingSm),
                                Text(
                                  _isSimulatorEnabled
                                      ? 'المحاكي نشط ويظهر في الموقع'
                                      : 'المحاكي متوقف ولا يظهر في الموقع',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                              ],
                            ),
                          ),

                          // زر التبديل
                          _isSaving
                              ? const SizedBox(
                                  width: 48,
                                  height: 48,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : Switch(
                                  value: _isSimulatorEnabled,
                                  onChanged: _toggleSimulator,
                                  activeColor: AppColors.success,
                                ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
