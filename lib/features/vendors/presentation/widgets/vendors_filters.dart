import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/vendor_entity.dart';
import '../bloc/vendors_bloc.dart';
import '../bloc/vendors_event.dart';

/// Filter widgets for vendors page.
class VendorsFilters extends StatefulWidget {
  final VendorStatus? currentStatusFilter;
  final VendorCategory? currentCategoryFilter;
  final String? searchQuery;

  const VendorsFilters({
    super.key,
    this.currentStatusFilter,
    this.currentCategoryFilter,
    this.searchQuery,
  });

  @override
  State<VendorsFilters> createState() => _VendorsFiltersState();
}

class _VendorsFiltersState extends State<VendorsFilters> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 800;

        if (isCompact) {
          return Container(
            padding: const EdgeInsets.all(AppConstants.spacingSm),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Search
                _buildSearchField(),
                const SizedBox(height: AppConstants.spacingSm),

                // Filters Row
                Row(
                  children: [
                    Expanded(child: _buildStatusFilter()),
                    const SizedBox(width: AppConstants.spacingSm),
                    Expanded(child: _buildCategoryFilter()),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingSm),

                // Add Button
                _buildAddButton(isFullWidth: true),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(AppConstants.spacingSm),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Expanded(flex: 2, child: _buildSearchField()),
              const SizedBox(width: AppConstants.spacingSm),
              Expanded(child: _buildStatusFilter()),
              const SizedBox(width: AppConstants.spacingSm),
              Expanded(child: _buildCategoryFilter()),
              const SizedBox(width: AppConstants.spacingSm),
              _buildAddButton(isFullWidth: false),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'البحث عن متجر...',
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () {
                  _searchController.clear();
                  context.read<VendorsBloc>().add(const SearchVendors(''));
                },
              )
            : null,
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMd,
          vertical: AppConstants.spacingSm,
        ),
      ),
      onChanged: (value) {
        setState(() {});
        context.read<VendorsBloc>().add(SearchVendors(value));
      },
    );
  }

  Widget _buildStatusFilter() {
    return _FilterDropdown<VendorStatus?>(
      value: widget.currentStatusFilter,
      hint: 'الحالة',
      items: [
        const DropdownMenuItem(
          value: null,
          child: Text('كل الحالات'),
        ),
        ...VendorStatus.values.map(
          (status) => DropdownMenuItem(
            value: status,
            child: Row(
              children: [
                _StatusIndicator(status: status),
                const SizedBox(width: AppConstants.spacingSm),
                Flexible(
                  child: Text(
                    _getStatusLabel(status),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      onChanged: (value) {
        context.read<VendorsBloc>().add(FilterByStatus(value));
      },
    );
  }

  Widget _buildCategoryFilter() {
    return _FilterDropdown<VendorCategory?>(
      value: widget.currentCategoryFilter,
      hint: 'الفئة',
      items: [
        const DropdownMenuItem(
          value: null,
          child: Text('كل الفئات'),
        ),
        ...VendorCategory.values.map(
          (category) => DropdownMenuItem(
            value: category,
            child: Row(
              children: [
                Icon(_getCategoryIcon(category), size: 18),
                const SizedBox(width: AppConstants.spacingSm),
                Flexible(
                  child: Text(
                    _getCategoryLabel(category),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      onChanged: (value) {
        context.read<VendorsBloc>().add(FilterByCategory(value));
      },
    );
  }

  Widget _buildAddButton({required bool isFullWidth}) {
    final button = ElevatedButton.icon(
      onPressed: () => _showAddVendorDialog(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMd,
          vertical: AppConstants.spacingMd,
        ),
      ),
      icon: const Icon(Icons.add, size: 20),
      label: const Text('إضافة متجر'),
    );

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }

  String _getStatusLabel(VendorStatus status) {
    return switch (status) {
      VendorStatus.active => 'نشط',
      VendorStatus.inactive => 'غير نشط',
      VendorStatus.pending => 'قيد المراجعة',
      VendorStatus.suspended => 'موقوف',
    };
  }

  String _getCategoryLabel(VendorCategory category) {
    return switch (category) {
      VendorCategory.food => 'أغذية',
      VendorCategory.grocery => 'بقالة',
      VendorCategory.health => 'صحة',
      VendorCategory.electronics => 'إلكترونيات',
      VendorCategory.clothes => 'ملابس',
      VendorCategory.furniture => 'أثاث',
      VendorCategory.other => 'أخرى',
    };
  }

  IconData _getCategoryIcon(VendorCategory category) {
    return switch (category) {
      VendorCategory.food => Icons.restaurant,
      VendorCategory.grocery => Icons.local_grocery_store,
      VendorCategory.health => Icons.local_hospital,
      VendorCategory.electronics => Icons.devices,
      VendorCategory.clothes => Icons.checkroom,
      VendorCategory.furniture => Icons.chair,
      VendorCategory.other => Icons.store,
    };
  }

  void _showAddVendorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<VendorsBloc>(),
        child: const _AddVendorDialog(),
      ),
    );
  }
}

class _FilterDropdown<T> extends StatelessWidget {
  final T value;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _FilterDropdown({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingSm),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint),
          isExpanded: true,
          items: items,
          onChanged: onChanged,
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
          dropdownColor: AppColors.surface,
        ),
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final VendorStatus status;

  const _StatusIndicator({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      VendorStatus.active => AppColors.success,
      VendorStatus.inactive => AppColors.textTertiary,
      VendorStatus.pending => AppColors.warning,
      VendorStatus.suspended => AppColors.error,
    };

    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _AddVendorDialog extends StatefulWidget {
  const _AddVendorDialog();

  @override
  State<_AddVendorDialog> createState() => _AddVendorDialogState();
}

class _AddVendorDialogState extends State<_AddVendorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _commissionController = TextEditingController(text: '10');

  VendorCategory _selectedCategory = VendorCategory.food;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _commissionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 600;
    final dialogWidth = isCompact ? screenWidth * 0.95 : 600.0;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      insetPadding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 40,
        vertical: 24,
      ),
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(maxHeight: isCompact ? 600 : 700),
        padding: EdgeInsets.all(
            isCompact ? AppConstants.spacingMd : AppConstants.spacingXl),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'إضافة متجر جديد',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: AppConstants.spacingLg * 2),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildFormContent(context, isCompact),
                ),
              ),
              const Divider(height: AppConstants.spacingLg * 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إلغاء'),
                  ),
                  const SizedBox(width: AppConstants.spacingMd),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingXl,
                        vertical: AppConstants.spacingMd,
                      ),
                    ),
                    child: const Text('إضافة'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent(BuildContext context, bool isCompact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Basic Info Section
        _buildSectionTitle(context, 'المعلومات الأساسية'),
        const SizedBox(height: AppConstants.spacingMd),
        if (isCompact) ...[
          _buildTextField(
            controller: _nameController,
            label: 'اسم المتجر',
            validator: (v) => v?.isEmpty == true ? 'الاسم مطلوب' : null,
          ),
          const SizedBox(height: AppConstants.spacingMd),
          _buildDropdown<VendorCategory>(
            label: 'الفئة',
            value: _selectedCategory,
            items: VendorCategory.values
                .map((c) => DropdownMenuItem(
                      value: c,
                      child: Text(_getCategoryLabel(c)),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _selectedCategory = v!),
          ),
        ] else
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _nameController,
                  label: 'اسم المتجر',
                  validator: (v) => v?.isEmpty == true ? 'الاسم مطلوب' : null,
                ),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              Expanded(
                child: _buildDropdown<VendorCategory>(
                  label: 'الفئة',
                  value: _selectedCategory,
                  items: VendorCategory.values
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(_getCategoryLabel(c)),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v!),
                ),
              ),
            ],
          ),
        const SizedBox(height: AppConstants.spacingMd),
        _buildTextField(
          controller: _descriptionController,
          label: 'الوصف',
          maxLines: 2,
        ),

        const SizedBox(height: AppConstants.spacingLg),

        // Contact Info Section
        _buildSectionTitle(context, 'معلومات التواصل'),
        const SizedBox(height: AppConstants.spacingMd),
        if (isCompact) ...[
          _buildTextField(
            controller: _phoneController,
            label: 'رقم الهاتف',
            keyboardType: TextInputType.phone,
            validator: (v) => v?.isEmpty == true ? 'الهاتف مطلوب' : null,
          ),
          const SizedBox(height: AppConstants.spacingMd),
          _buildTextField(
            controller: _emailController,
            label: 'البريد الإلكتروني',
            keyboardType: TextInputType.emailAddress,
          ),
        ] else
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _phoneController,
                  label: 'رقم الهاتف',
                  keyboardType: TextInputType.phone,
                  validator: (v) => v?.isEmpty == true ? 'الهاتف مطلوب' : null,
                ),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              Expanded(
                child: _buildTextField(
                  controller: _emailController,
                  label: 'البريد الإلكتروني',
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
            ],
          ),

        const SizedBox(height: AppConstants.spacingLg),

        // Address Section
        _buildSectionTitle(context, 'العنوان'),
        const SizedBox(height: AppConstants.spacingMd),
        if (isCompact) ...[
          _buildTextField(
            controller: _streetController,
            label: 'الشارع',
            validator: (v) => v?.isEmpty == true ? 'العنوان مطلوب' : null,
          ),
          const SizedBox(height: AppConstants.spacingMd),
          _buildTextField(
            controller: _cityController,
            label: 'المدينة',
            validator: (v) => v?.isEmpty == true ? 'المدينة مطلوبة' : null,
          ),
        ] else
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildTextField(
                  controller: _streetController,
                  label: 'الشارع',
                  validator: (v) => v?.isEmpty == true ? 'العنوان مطلوب' : null,
                ),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              Expanded(
                child: _buildTextField(
                  controller: _cityController,
                  label: 'المدينة',
                  validator: (v) =>
                      v?.isEmpty == true ? 'المدينة مطلوبة' : null,
                ),
              ),
            ],
          ),

        const SizedBox(height: AppConstants.spacingLg),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: AppConstants.spacingXs),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: AppConstants.spacingMd),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppConstants.radiusSm),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              items: items,
              onChanged: onChanged,
              dropdownColor: AppColors.surface,
            ),
          ),
        ),
      ],
    );
  }

  String _getCategoryLabel(VendorCategory category) {
    return switch (category) {
      VendorCategory.food => 'أغذية',
      VendorCategory.grocery => 'بقالة',
      VendorCategory.health => 'صحة',
      VendorCategory.electronics => 'إلكترونيات',
      VendorCategory.clothes => 'ملابس',
      VendorCategory.furniture => 'أثاث',
      VendorCategory.other => 'أخرى',
    };
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final vendor = VendorEntity(
      id: '',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      category: _selectedCategory,
      status: VendorStatus.pending,
      address: VendorAddress(
        street: _streetController.text.trim(),
        city: _cityController.text.trim(),
        country: 'السعودية',
      ),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      commissionRate: double.parse(_commissionController.text),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    context.read<VendorsBloc>().add(AddVendorEvent(vendor));
    Navigator.pop(context);
  }
}
