import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

import '../../../../config/di/injection_container.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/responsive_layout.dart';
import '../../domain/entities/category_entity.dart';
import '../bloc/categories_bloc.dart';
import '../bloc/categories_event.dart';
import '../bloc/categories_state.dart';
import '../widgets/add_category_dialog.dart';
import '../widgets/category_card.dart';
import '../widgets/edit_category_dialog.dart';
import '../widgets/subcategories_view.dart';

/// Categories management page.
class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CategoriesBloc>()..add(const LoadCategories()),
      child: const _CategoriesView(),
    );
  }
}

class _CategoriesView extends StatefulWidget {
  const _CategoriesView();

  @override
  State<_CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<_CategoriesView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveLayout.getDeviceType(context);
    final isMobile = deviceType == DeviceType.mobile;
    final isDesktop = deviceType == DeviceType.desktop;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<CategoriesBloc, CategoriesState>(
        listener: _handleStateChanges,
        builder: (context, state) {
          return Column(
            children: [
              // ─── Header ───
              _buildHeader(context, isMobile),

              // ─── Content ───
              Expanded(
                child: _buildContent(context, state, isMobile, isDesktop),
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================================
  // 🔔 LISTENER
  // ============================================

  void _handleStateChanges(BuildContext context, CategoriesState state) {
    if (state is CategoriesActionSuccess) {
      toastification.show(
        context: context,
        type: ToastificationType.success,
        style: ToastificationStyle.flat,
        title: Text(state.message),
        autoCloseDuration: const Duration(seconds: 3),
        alignment: Alignment.bottomCenter,
      );
    } else if (state is CategoriesError) {
      toastification.show(
        context: context,
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        title: const Text('حدث خطأ'),
        description: Text(state.message),
        autoCloseDuration: const Duration(seconds: 4),
        alignment: Alignment.bottomCenter,
      );
    }
  }

  // ============================================
  // 🏗️ HEADER
  // ============================================

  Widget _buildHeader(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(
        isMobile ? AppConstants.spacingMd : AppConstants.spacingLg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الأقسام والمتاجر',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'إدارة الأقسام والأقسام الفرعية',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              // Refresh button
              IconButton(
                onPressed: () {
                  context.read<CategoriesBloc>().add(const RefreshCategories());
                },
                icon: const Icon(Icons.refresh),
                color: AppColors.primary,
                tooltip: 'تحديث',
              ),
              const SizedBox(width: 8),
              // Add button
              ElevatedButton.icon(
                onPressed: () => _showAddCategoryDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: Text(
                  isMobile ? 'إضافة' : 'إضافة قسم',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile
                        ? AppConstants.spacingSm
                        : AppConstants.spacingMd,
                    vertical: AppConstants.spacingSm,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.spacingMd),

          // Search bar
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _searchController,
            builder: (context, value, _) {
              return TextField(
                controller: _searchController,
                onChanged: (value) {
                  context.read<CategoriesBloc>().add(SearchCategories(value));
                },
                decoration: InputDecoration(
                  hintText: 'بحث عن قسم...',
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.textMuted),
                  suffixIcon: value.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear,
                              color: AppColors.textMuted),
                          onPressed: () {
                            _searchController.clear();
                            context
                                .read<CategoriesBloc>()
                                .add(const SearchCategories(''));
                          },
                        )
                      : null,
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
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================
  // 🏗️ CONTENT
  // ============================================

  Widget _buildContent(
    BuildContext context,
    CategoriesState state,
    bool isMobile,
    bool isDesktop,
  ) {
    if (state is CategoriesLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state is CategoriesError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: AppConstants.spacingMd),
            Text(
              'حدث خطأ',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              state.message,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingMd),
            ElevatedButton.icon(
              onPressed: () {
                context.read<CategoriesBloc>().add(const RefreshCategories());
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (state is CategoriesLoaded) {
      if (state.filteredCategories.isEmpty) {
        return _buildEmptyState(context, state.searchQuery);
      }

      if (isDesktop) {
        return _buildDesktopLayout(context, state);
      }
      return _buildMobileLayout(context, state, isMobile);
    }

    return const SizedBox.shrink();
  }

  // ============================================
  // 📱 MOBILE LAYOUT
  // ============================================

  Widget _buildMobileLayout(
    BuildContext context,
    CategoriesLoaded state,
    bool isMobile,
  ) {
    final crossAxisCount = isMobile ? 2 : 3;

    return Padding(
      padding: EdgeInsets.all(
        isMobile ? AppConstants.spacingSm : AppConstants.spacingMd,
      ),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: AppConstants.spacingSm,
          mainAxisSpacing: AppConstants.spacingSm,
          childAspectRatio: isMobile ? 0.85 : 0.9,
        ),
        itemCount: state.filteredCategories.length,
        itemBuilder: (context, index) {
          final category = state.filteredCategories[index];
          return CategoryCard(
            category: category,
            isSelected: false,
            onTap: () => _showSubcategoriesBottomSheet(context, category),
            onEdit: () => _showEditCategoryDialog(context, category),
            onDelete: () => _showDeleteConfirmation(context, category),
          );
        },
      ),
    );
  }

  // ============================================
  // 🖥️ DESKTOP LAYOUT
  // ============================================

  Widget _buildDesktopLayout(
    BuildContext context,
    CategoriesLoaded state,
  ) {
    return Row(
      children: [
        // Categories grid — main area
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: AppConstants.spacingSm,
                mainAxisSpacing: AppConstants.spacingSm,
                childAspectRatio: 1.0,
              ),
              itemCount: state.filteredCategories.length,
              itemBuilder: (context, index) {
                final category = state.filteredCategories[index];
                return CategoryCard(
                  category: category,
                  isSelected: state.selectedCategory?.id == category.id,
                  onTap: () {
                    context
                        .read<CategoriesBloc>()
                        .add(SelectCategory(category.id));
                  },
                  onEdit: () => _showEditCategoryDialog(context, category),
                  onDelete: () => _showDeleteConfirmation(context, category),
                );
              },
            ),
          ),
        ),

        // Subcategories panel — side panel
        if (state.selectedCategory != null)
          SizedBox(
            width: 380,
            child: Padding(
              padding: const EdgeInsets.only(
                top: AppConstants.spacingMd,
                right: AppConstants.spacingMd,
                bottom: AppConstants.spacingMd,
              ),
              child: SubcategoriesView(
                category: state.selectedCategory!,
              ),
            ),
          ),
      ],
    );
  }

  // ============================================
  // 📭 EMPTY STATE
  // ============================================

  Widget _buildEmptyState(BuildContext context, String? searchQuery) {
    final hasSearch = searchQuery != null && searchQuery.isNotEmpty;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasSearch ? Icons.search_off : Icons.category_outlined,
            size: 64,
            color: AppColors.textMuted.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppConstants.spacingMd),
          Text(
            hasSearch ? 'لا توجد نتائج' : 'لا توجد أقسام',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppConstants.spacingXs),
          Text(
            hasSearch
                ? 'جرب البحث بكلمات مختلفة'
                : 'أضف أقسام جديدة من زر الإضافة',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  // ============================================
  // 💬 DIALOGS
  // ============================================

  void _showAddCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<CategoriesBloc>(),
        child: const AddCategoryDialog(),
      ),
    );
  }

  void _showEditCategoryDialog(BuildContext context, CategoryEntity category) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<CategoriesBloc>(),
        child: EditCategoryDialog(category: category),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, CategoryEntity category) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        ),
        title: const Text('حذف القسم'),
        content: Text(
          'هل أنت متأكد من حذف "${category.name}"؟\n'
          'سيتم حذف جميع الأقسام الفرعية (${category.subcategories.length}) أيضاً.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              context
                  .read<CategoriesBloc>()
                  .add(DeleteCategoryEvent(category.id));
              Navigator.of(dialogContext).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showSubcategoriesBottomSheet(
      BuildContext context, CategoryEntity category) {
    // First select the category in the bloc
    context.read<CategoriesBloc>().add(SelectCategory(category.id));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<CategoriesBloc>(),
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (_, scrollController) {
            return SubcategoriesView(
              category: category,
              isMobile: true,
            );
          },
        ),
      ),
    );
  }
}
