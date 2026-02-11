import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/vendor_entity.dart';
import '../bloc/vendors_bloc.dart';
import '../bloc/vendors_event.dart';
import '../utils/vendor_utils.dart';

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
                    VendorUtils.getStatusLabel(status),
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
                Icon(VendorUtils.getCategoryIcon(category), size: 18),
                const SizedBox(width: AppConstants.spacingSm),
                Flexible(
                  child: Text(
                    VendorUtils.getCategoryLabel(category),
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
    final color = VendorUtils.getStatusColor(status);

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
