import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/admin_entity.dart';
import '../bloc/admins_bloc.dart';
import '../bloc/admins_event.dart';
import '../bloc/admins_state.dart';

/// صفحة إدارة المسؤولين
class ManageAdminsPage extends StatelessWidget {
  const ManageAdminsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ManageAdminsView();
  }
}

class _ManageAdminsView extends StatefulWidget {
  const _ManageAdminsView();

  @override
  State<_ManageAdminsView> createState() => _ManageAdminsViewState();
}

class _ManageAdminsViewState extends State<_ManageAdminsView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showAddAdminDialog() {
    final adminsBloc = context.read<AdminsBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: adminsBloc,
        child: _buildAddAdminDialog(dialogContext),
      ),
    );
  }

  void _confirmDeleteAdmin(String adminId, String email) async {
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

    if (confirmed == true && mounted) {
      context.read<AdminsBloc>().add(DeleteAdminRequested(adminId));
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

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveLayout.getDeviceType(context);
    final isDesktop = deviceType == DeviceType.desktop;

    return BlocConsumer<AdminsBloc, AdminsState>(
      listener: (context, state) {
        if (state is AdminActionSuccess) {
          _showSuccessMessage(state.message);
        } else if (state is AdminsError) {
          _showErrorMessage(state.message);
        }
      },
      builder: (context, state) {
        final admins = _getAdminsFromState(state);
        final isLoading = state is AdminsLoading;
        final isActionInProgress = state is AdminActionInProgress;

        return BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            // Get super admin status from auth state
            final isSuperAdmin = authState is AuthAuthenticated &&
                authState.user.role == 'superAdmin';

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
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'إضافة وإدارة حسابات المسؤولين',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                      ],
                    ),
                    if (!isDesktop) const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: isSuperAdmin && !isActionInProgress
                          ? _showAddAdminDialog
                          : null,
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
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
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
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : admins.isEmpty
                              ? _buildEmptyState()
                              : _buildAdminsList(
                                  admins, isDesktop, isSuperAdmin),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<AdminEntity> _getAdminsFromState(AdminsState state) {
    if (state is AdminsLoaded) return state.admins;
    if (state is AdminActionInProgress) return state.admins;
    if (state is AdminActionSuccess) return state.admins;
    return [];
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

  Widget _buildAdminsList(
      List<AdminEntity> admins, bool isDesktop, bool isSuperAdmin) {
    return ListView.separated(
      itemCount: admins.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppConstants.spacingMd),
      itemBuilder: (context, index) {
        final admin = admins[index];
        return _buildAdminCard(admin, isDesktop, isSuperAdmin);
      },
    );
  }

  Widget _buildAdminCard(AdminEntity admin, bool isDesktop, bool isSuperAdmin) {
    // Get current user ID from AuthBloc
    final authState = context.read<AuthBloc>().state;
    final currentUserId =
        authState is AuthAuthenticated ? authState.user.id : '';
    final isCurrentUser = admin.id == currentUserId;

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: isDesktop
            ? Row(
                children: [
                  _buildAdminAvatar(admin.name),
                  const SizedBox(width: AppConstants.spacingMd),
                  Expanded(child: _buildAdminInfo(admin, isCurrentUser)),
                  if (!isCurrentUser && isSuperAdmin) _buildDeleteButton(admin),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildAdminAvatar(admin.name),
                      const SizedBox(width: AppConstants.spacingMd),
                      Expanded(child: _buildAdminInfo(admin, isCurrentUser)),
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

  Widget _buildAdminInfo(AdminEntity admin, bool isCurrentUser) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                admin.name.isNotEmpty ? admin.name : 'غير محدد',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            if (admin.isSuperAdmin) ...[
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
                admin.email,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (admin.createdAt != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Iconsax.calendar, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                'تم الإنشاء: ${_formatDate(admin.createdAt!)}',
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

  Widget _buildDeleteButton(AdminEntity admin) {
    return IconButton(
      onPressed: () => _confirmDeleteAdmin(admin.id, admin.email),
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
        BlocConsumer<AdminsBloc, AdminsState>(
          listener: (context, state) {
            if (state is AdminActionSuccess) {
              _nameController.clear();
              _emailController.clear();
              _passwordController.clear();
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
            }
          },
          builder: (context, state) {
            final isProcessing = state is AdminActionInProgress;
            return ElevatedButton(
              onPressed: isProcessing
                  ? null
                  : () {
                      if (_formKey.currentState!.validate()) {
                        context.read<AdminsBloc>().add(AddAdminRequested(
                              name: _nameController.text.trim(),
                              email: _emailController.text.trim(),
                              password: _passwordController.text,
                            ));
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('إضافة'),
            );
          },
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
