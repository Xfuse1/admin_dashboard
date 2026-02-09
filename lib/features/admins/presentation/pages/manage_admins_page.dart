import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toastification/toastification.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

/// صفحة إدارة المسؤولين
class ManageAdminsPage extends StatefulWidget {
  const ManageAdminsPage({super.key});

  @override
  State<ManageAdminsPage> createState() => _ManageAdminsPageState();
}

class _ManageAdminsPageState extends State<ManageAdminsPage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isSaving = false;
  List<Map<String, dynamic>> _admins = [];

  @override
  void initState() {
    super.initState();
    _loadAdmins();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// تحميل قائمة المسؤولين
  Future<void> _loadAdmins() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      // جلب جميع المستخدمين من نوع admin و superAdmin
      final snapshot = await _firestore
          .collection('users')
          .where('role', whereIn: ['admin', 'superAdmin']).get();

      if (!mounted) return;

      // ترتيب البيانات بعد جلبها
      final adminsList = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();

      // ترتيب حسب تاريخ الإنشاء (الأحدث أولاً)
      adminsList.sort((a, b) {
        final aTime = a['createdAt'] as Timestamp?;
        final bTime = b['createdAt'] as Timestamp?;
        if (aTime == null || bTime == null) return 0;
        return bTime.compareTo(aTime); // descending
      });

      setState(() {
        _admins = adminsList;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showErrorMessage('فشل تحميل البيانات: $e');
    }
  }

  /// التحقق من أن المستخدم الحالي هو super admin
  bool _isSuperAdmin(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      return authState.user.role == 'superAdmin';
    }
    return false;
  }

  /// إضافة مسؤول جديد
  Future<void> _addAdmin(BuildContext dialogContext) async {
    if (!_formKey.currentState!.validate()) return;

    // التحقق من الصلاحيات
    if (!_isSuperAdmin(context)) {
      _showErrorMessage('غير مسموح: يجب أن تكون Super Admin لإضافة مسؤولين');
      return;
    }

    if (!mounted) return;
    setState(() => _isSaving = true);

    try {
      // إنشاء حساب في Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // حفظ بيانات المسؤول في Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'role': 'admin',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': _auth.currentUser?.uid,
      });

      if (!mounted) return;

      // مسح الحقول
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();

      setState(() => _isSaving = false);

      // إغلاق الـ dialog باستخدام context الخاص بالـ Dialog
      if (dialogContext.mounted) {
        Navigator.of(dialogContext).pop();
      }

      // الانتظار قليلاً لضمان اكتمال إغلاق الـ Dialog
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      // عرض رسالة النجاح بعد إغلاق الـ Dialog
      _showSuccessMessage('تم إضافة المسؤول بنجاح');

      // إعادة تحميل القائمة
      await _loadAdmins();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      String errorMessage = 'فشل إضافة المسؤول';

      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = 'البريد الإلكتروني مستخدم بالفعل';
            break;
          case 'weak-password':
            errorMessage = 'كلمة المرور ضعيفة جداً';
            break;
          case 'invalid-email':
            errorMessage = 'البريد الإلكتروني غير صالح';
            break;
          default:
            errorMessage = 'خطأ: ${e.message}';
        }
      }

      _showErrorMessage(errorMessage);
    }
  }

  /// حذف مسؤول
  Future<void> _deleteAdmin(String adminId, String email) async {
    // التحقق من الصلاحيات
    if (!_isSuperAdmin(context)) {
      _showErrorMessage('غير مسموح: يجب أن تكون Super Admin لحذف مسؤولين');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف المسؤول: $email؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // حذف من Firestore
      await _firestore.collection('users').doc(adminId).delete();

      _showSuccessMessage('تم حذف المسؤول بنجاح');
      _loadAdmins();
    } catch (e) {
      _showErrorMessage('فشل حذف المسؤول: $e');
    }
  }

  void _showSuccessMessage(String message) {
    if (!mounted) return;
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.flat,
      title: Text(message),
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 3),
      showProgressBar: true,
    );
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;
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

  void _showAddAdminDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => _buildAddAdminDialog(dialogContext),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveLayout.getDeviceType(context);
    final isDesktop = deviceType == DeviceType.desktop;
    final isSuperAdmin = _isSuperAdmin(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: EdgeInsets.all(
            isDesktop ? AppConstants.spacingLg : AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العنوان وزر الإضافة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إدارة المسؤولين',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'إضافة وإدارة حسابات المسؤولين',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
                if (!isDesktop) const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: isSuperAdmin ? _showAddAdminDialog : null,
                  icon: const Icon(Iconsax.add, size: 20),
                  label: Text(isDesktop ? 'إضافة مسؤول' : 'إضافة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppColors.textSecondary.withValues(alpha: 0.3),
                    disabledForegroundColor: AppColors.textSecondary,
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 24 : 16,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            if (!isSuperAdmin) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Iconsax.info_circle,
                      color: AppColors.warning,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'يمكن فقط لـ Super Admin إضافة أو حذف المسؤولين',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.warning,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppConstants.spacingLg),

            // قائمة المسؤولين
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _admins.isEmpty
                      ? _buildEmptyState()
                      : _buildAdminsList(isDesktop, isSuperAdmin),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.profile_2user,
            size: 80,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد حسابات مسؤولين',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'قم بإضافة أول مسؤول للنظام',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminsList(bool isDesktop, bool isSuperAdmin) {
    return ListView.separated(
      itemCount: _admins.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppConstants.spacingMd),
      itemBuilder: (context, index) {
        final admin = _admins[index];
        return _buildAdminCard(admin, isDesktop, isSuperAdmin);
      },
    );
  }

  Widget _buildAdminCard(
      Map<String, dynamic> admin, bool isDesktop, bool isSuperAdmin) {
    final isCurrentUser = admin['id'] == _auth.currentUser?.uid;
    final createdAt = admin['createdAt'] as Timestamp?;

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: isDesktop
            ? Row(
                children: [
                  _buildAdminAvatar(admin['name'] ?? ''),
                  const SizedBox(width: AppConstants.spacingMd),
                  Expanded(child: _buildAdminInfo(admin, createdAt)),
                  if (!isCurrentUser && isSuperAdmin) _buildDeleteButton(admin),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildAdminAvatar(admin['name'] ?? ''),
                      const SizedBox(width: AppConstants.spacingMd),
                      Expanded(child: _buildAdminInfo(admin, createdAt)),
                    ],
                  ),
                  if (!isCurrentUser && isSuperAdmin) ...[
                    const SizedBox(height: AppConstants.spacingMd),
                    _buildDeleteButton(admin),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _buildAdminAvatar(String name) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'A',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildAdminInfo(Map<String, dynamic> admin, Timestamp? createdAt) {
    final isCurrentUser = admin['id'] == _auth.currentUser?.uid;
    final isSuperAdmin = admin['role'] == 'superAdmin';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                admin['name'] ?? 'غير محدد',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            if (isSuperAdmin) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Super Admin',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(width: 4),
            ],
            if (isCurrentUser) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'أنت',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Iconsax.sms, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                admin['email'] ?? '',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (createdAt != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Iconsax.calendar, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                'تم الإنشاء: ${_formatDate(createdAt.toDate())}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDeleteButton(Map<String, dynamic> admin) {
    return IconButton(
      onPressed: () => _deleteAdmin(admin['id'], admin['email'] ?? ''),
      icon: const Icon(Iconsax.trash, color: AppColors.error),
      tooltip: 'حذف المسؤول',
    );
  }

  Widget _buildAddAdminDialog(BuildContext dialogContext) {
    return AlertDialog(
      title: const Text('إضافة مسؤول جديد'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'الاسم',
                  prefixIcon: const Icon(Iconsax.user),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الاسم مطلوب';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  prefixIcon: const Icon(Iconsax.sms),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'البريد الإلكتروني مطلوب';
                  }
                  if (!value.contains('@')) {
                    return 'البريد الإلكتروني غير صالح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور',
                  prefixIcon: const Icon(Iconsax.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'كلمة المرور مطلوبة';
                  }
                  if (value.length < 6) {
                    return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : () => _addAdmin(dialogContext),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('إضافة'),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
