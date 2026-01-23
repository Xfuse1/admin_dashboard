import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../bloc/fleet_bloc.dart';
import '../bloc/fleet_event.dart';

/// Filter widgets for fleet page.
class FleetFilters extends StatefulWidget {
  final VehicleStatus? currentStatusFilter;
  final VehicleType? currentTypeFilter;
  final String? searchQuery;

  const FleetFilters({
    super.key,
    this.currentStatusFilter,
    this.currentTypeFilter,
    this.searchQuery,
  });

  @override
  State<FleetFilters> createState() => _FleetFiltersState();
}

class _FleetFiltersState extends State<FleetFilters> {
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
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Search
          Expanded(
            flex: 2,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'البحث عن مركبة...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          context
                              .read<FleetBloc>()
                              .add(const SearchVehiclesEvent(''));
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
                context.read<FleetBloc>().add(SearchVehiclesEvent(value));
              },
            ),
          ),
          const SizedBox(width: AppConstants.spacingMd),

          // Status Filter
          Expanded(
            child: _FilterDropdown<VehicleStatus?>(
              value: widget.currentStatusFilter,
              hint: 'الحالة',
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('كل الحالات'),
                ),
                ...VehicleStatus.values.map(
                  (status) => DropdownMenuItem(
                    value: status,
                    child: Row(
                      children: [
                        _StatusIndicator(status: status),
                        const SizedBox(width: AppConstants.spacingSm),
                        Text(status.arabicName),
                      ],
                    ),
                  ),
                ),
              ],
              onChanged: (value) {
                context.read<FleetBloc>().add(FilterByStatus(value));
              },
            ),
          ),
          const SizedBox(width: AppConstants.spacingMd),

          // Type Filter
          Expanded(
            child: _FilterDropdown<VehicleType?>(
              value: widget.currentTypeFilter,
              hint: 'النوع',
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('كل الأنواع'),
                ),
                ...VehicleType.values.map(
                  (type) => DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(_getTypeIcon(type), size: 18),
                        const SizedBox(width: AppConstants.spacingSm),
                        Text(type.arabicName),
                      ],
                    ),
                  ),
                ),
              ],
              onChanged: (value) {
                context.read<FleetBloc>().add(FilterByType(value));
              },
            ),
          ),
          const SizedBox(width: AppConstants.spacingMd),

          // Add Vehicle Button
          ElevatedButton.icon(
            onPressed: () => _showAddVehicleDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingLg,
                vertical: AppConstants.spacingMd,
              ),
            ),
            icon: const Icon(Icons.add, size: 20),
            label: const Text('إضافة مركبة'),
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(VehicleType type) {
    return switch (type) {
      VehicleType.car => Icons.directions_car,
      VehicleType.motorcycle => Icons.two_wheeler,
      VehicleType.bicycle => Icons.pedal_bike,
      VehicleType.truck => Icons.local_shipping,
      VehicleType.van => Icons.airport_shuttle,
    };
  }

  void _showAddVehicleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<FleetBloc>(),
        child: const _AddVehicleDialog(),
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
  final VehicleStatus status;

  const _StatusIndicator({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: Color(status.color),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _AddVehicleDialog extends StatefulWidget {
  const _AddVehicleDialog();

  @override
  State<_AddVehicleDialog> createState() => _AddVehicleDialogState();
}

class _AddVehicleDialogState extends State<_AddVehicleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _plateController = TextEditingController();
  final _colorController = TextEditingController();
  final _totalKmController = TextEditingController();

  VehicleType _selectedType = VehicleType.car;
  String _selectedFuelType = 'petrol';
  bool _isLoading = false;

  static const _fuelTypes = [
    ('petrol', 'بنزين'),
    ('diesel', 'ديزل'),
    ('electric', 'كهرباء'),
    ('hybrid', 'هجين'),
  ];

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _plateController.dispose();
    _colorController.dispose();
    _totalKmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(AppConstants.spacingXl),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'إضافة مركبة جديدة',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingLg),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown<VehicleType>(
                      label: 'النوع',
                      value: _selectedType,
                      items: VehicleType.values
                          .map((t) => DropdownMenuItem(
                                value: t,
                                child: Text(t.arabicName),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedType = v!),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingMd),
                  Expanded(
                    child: _buildDropdown<String>(
                      label: 'نوع الوقود',
                      value: _selectedFuelType,
                      items: _fuelTypes
                          .map((t) => DropdownMenuItem(
                                value: t.$1,
                                child: Text(t.$2),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedFuelType = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingMd),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _brandController,
                      label: 'الماركة',
                      validator: (v) =>
                          v?.isEmpty == true ? 'الماركة مطلوبة' : null,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingMd),
                  Expanded(
                    child: _buildTextField(
                      controller: _modelController,
                      label: 'الموديل',
                      validator: (v) =>
                          v?.isEmpty == true ? 'الموديل مطلوب' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingMd),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _yearController,
                      label: 'سنة الصنع',
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v?.isEmpty == true) return 'السنة مطلوبة';
                        final year = int.tryParse(v!);
                        if (year == null || year < 1900 || year > 2030) {
                          return 'سنة غير صالحة';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingMd),
                  Expanded(
                    child: _buildTextField(
                      controller: _plateController,
                      label: 'رقم اللوحة',
                      validator: (v) =>
                          v?.isEmpty == true ? 'رقم اللوحة مطلوب' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingMd),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _colorController,
                      label: 'اللون',
                      validator: (v) =>
                          v?.isEmpty == true ? 'اللون مطلوب' : null,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingMd),
                  Expanded(
                    child: _buildTextField(
                      controller: _totalKmController,
                      label: 'المسافة المقطوعة (كم)',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingXl),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إلغاء'),
                  ),
                  const SizedBox(width: AppConstants.spacingMd),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingXl,
                        vertical: AppConstants.spacingMd,
                      ),
                    ),
                    child: _isLoading
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
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

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final now = DateTime.now();
    final vehicle = VehicleEntity(
      id: '',
      type: _selectedType,
      brand: _brandController.text.trim(),
      model: _modelController.text.trim(),
      year: int.parse(_yearController.text),
      plateNumber: _plateController.text.trim(),
      status: VehicleStatus.available,
      fuelType: _selectedFuelType,
      color: _colorController.text.trim(),
      totalKilometers: _totalKmController.text.isEmpty
          ? 0.0
          : double.tryParse(_totalKmController.text) ?? 0.0,
      createdAt: now,
      updatedAt: now,
    );

    context.read<FleetBloc>().add(AddVehicleEvent(vehicle));
    Navigator.pop(context);
  }
}
