import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/subcategory_entity.dart';
import '../bloc/categories_bloc.dart';
import '../bloc/categories_event.dart';
import 'subcategory_chip.dart';

/// Dialog for adding a new category with subcategories.
///
/// Subcategories are added locally in the form state before the final save.
/// When the user presses "إضافة" for a subcategory, it's appended to a local list
/// and the input fields are cleared. Only when "حفظ" is pressed, everything is
/// sent to Firestore in a single batch write.
class AddCategoryDialog extends StatefulWidget {
  const AddCategoryDialog({super.key});

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _subNameController = TextEditingController();
  final _subDescriptionController = TextEditingController();

  /// Local list of subcategories added before saving
  final List<SubcategoryInput> _subcategories = [];

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _subNameController.dispose();
    _subDescriptionController.dispose();
    super.dispose();
  }

  void _addSubcategory() {
    final name = _subNameController.text.trim();
    if (name.isEmpty) return;

    setState(() {
      _subcategories.add(SubcategoryInput(
        name: name,
        description: _subDescriptionController.text.trim(),
      ));
      _subNameController.clear();
      _subDescriptionController.clear();
    });
  }

  void _removeSubcategory(int index) {
    setState(() {
      _subcategories.removeAt(index);
    });
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    context.read<CategoriesBloc>().add(AddCategoryEvent(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          subcategories: List.of(_subcategories),
        ));

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 600;
    final dialogWidth = isCompact ? screenWidth * 0.95 : 560.0;

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
      ),
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ─── Title ───
            _buildTitle(context),
            const Divider(height: 1, color: AppColors.border),

            // ─── Form ───
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(
                  isCompact ? AppConstants.spacingMd : AppConstants.spacingLg,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section: بيانات القسم
                      _buildSectionTitle(context, 'بيانات القسم'),
                      const SizedBox(height: AppConstants.spacingSm),
                      _buildTextField(
                        controller: _nameController,
                        label: 'اسم القسم',
                        hint: 'مثال: الملابس',
                        icon: Icons.category,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'اسم القسم مطلوب';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppConstants.spacingSm),
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'وصف القسم',
                        hint: 'وصف مختصر للقسم',
                        icon: Icons.description_outlined,
                        maxLines: 2,
                      ),

                      const SizedBox(height: AppConstants.spacingLg),

                      // Section: الأقسام الفرعية
                      _buildSectionTitle(context, 'الأقسام الفرعية'),
                      const SizedBox(height: AppConstants.spacingSm),

                      // Display added subcategories
                      if (_subcategories.isNotEmpty) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(
                            _subcategories.length,
                            (index) => SubcategoryChip(
                              subcategory: _subcategories[index],
                              onDelete: () => _removeSubcategory(index),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacingSm),
                      ],

                      // Subcategory input fields
                      _buildTextField(
                        controller: _subNameController,
                        label: 'اسم القسم الفرعي',
                        hint: 'مثال: بنطلونات',
                        icon: Icons.subdirectory_arrow_left,
                      ),
                      const SizedBox(height: AppConstants.spacingXs),
                      _buildTextField(
                        controller: _subDescriptionController,
                        label: 'وصف القسم الفرعي',
                        hint: 'وصف مختصر (اختياري)',
                        icon: Icons.description_outlined,
                      ),
                      const SizedBox(height: AppConstants.spacingSm),

                      // Add subcategory button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _addSubcategory,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('إضافة قسم فرعي'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(
                              color: AppColors.primary.withValues(alpha: 0.4),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppConstants.radiusMd),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: AppConstants.spacingSm,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ─── Actions ───
            const Divider(height: 1, color: AppColors.border),
            _buildActions(context, isCompact),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            ),
            child: const Icon(
              Icons.add_circle_outline,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: AppConstants.spacingSm),
          Text(
            'إضافة قسم جديد',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: AppColors.textSecondary),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon, size: 20) : null,
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          borderSide: BorderSide(
            color: AppColors.border.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          borderSide: BorderSide(
            color: AppColors.border.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingSm,
          vertical: AppConstants.spacingSm,
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, bool isCompact) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.spacingSm,
                ),
              ),
              child: const Text('إلغاء'),
            ),
          ),
          const SizedBox(width: AppConstants.spacingSm),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submitForm,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save, size: 18),
              label: Text(_isSubmitting ? 'جاري الحفظ...' : 'حفظ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.spacingSm,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusMd),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
