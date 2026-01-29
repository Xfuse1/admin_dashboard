import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../bloc/orders_bloc.dart';
import '../bloc/orders_event.dart';

/// Order filters bottom sheet.
class OrderFiltersSheet extends StatefulWidget {
  const OrderFiltersSheet({super.key});

  @override
  State<OrderFiltersSheet> createState() => _OrderFiltersSheetState();
}

class _OrderFiltersSheetState extends State<OrderFiltersSheet> {
  DateTimeRange? _dateRange;
  OrdersBloc? _ordersBloc;

  @override
  Widget build(BuildContext context) {
    // Capture bloc at build time safely
    if (_ordersBloc == null) {
      try {
        _ordersBloc = context.read<OrdersBloc>();
      } catch (e) {
        // Bloc not available in this context, will try again later
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusXl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            child: Row(
              children: [
                Text(
                  'فلتر الطلبات',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _resetFilters,
                  child: const Text('إعادة تعيين'),
                ),
              ],
            ),
          ),

          const Divider(),

          // Date range filter
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'نطاق التاريخ',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppConstants.spacingSm),
                InkWell(
                  onTap: _selectDateRange,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  child: Container(
                    padding: const EdgeInsets.all(AppConstants.spacingMd),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.divider),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusMd),
                    ),
                    child: Row(
                      children: [
                        const Icon(Iconsax.calendar, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _dateRange != null
                                ? '${_formatDate(_dateRange!.start)} - ${_formatDate(_dateRange!.end)}'
                                : 'اختر نطاق التاريخ',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: _dateRange != null
                                      ? null
                                      : AppColors.textSecondary,
                                ),
                          ),
                        ),
                        if (_dateRange != null)
                          IconButton(
                            onPressed: () {
                              setState(() => _dateRange = null);
                            },
                            icon: const Icon(Icons.close, size: 18),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Quick date filters
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingMd,
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildQuickDateChip('اليوم', _getTodayRange()),
                _buildQuickDateChip('الأمس', _getYesterdayRange()),
                _buildQuickDateChip('آخر 7 أيام', _getLast7DaysRange()),
                _buildQuickDateChip('آخر 30 يوم', _getLast30DaysRange()),
                _buildQuickDateChip('هذا الشهر', _getThisMonthRange()),
              ],
            ),
          ),

          const SizedBox(height: AppConstants.spacingLg),

          // Apply button
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                child: const Text('تطبيق'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickDateChip(String label, DateTimeRange range) {
    final isSelected =
        _dateRange?.start == range.start && _dateRange?.end == range.end;

    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (_) {
        setState(() => _dateRange = range);
      },
    );
  }

  Future<void> _selectDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
      locale: const Locale('ar'),
    );

    if (range != null) {
      setState(() => _dateRange = range);
    }
  }

  void _resetFilters() {
    setState(() {
      _dateRange = null;
    });
    Navigator.of(context).pop();
    _ordersBloc?.add(const LoadOrders());
  }

  void _applyFilters() {
    Navigator.of(context).pop();

    if (_dateRange != null) {
      _ordersBloc?.add(FilterOrdersByDate(
            fromDate: _dateRange!.start,
            toDate: _dateRange!.end,
          ));
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  DateTimeRange _getTodayRange() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return DateTimeRange(start: start, end: end);
  }

  DateTimeRange _getYesterdayRange() {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final start = DateTime(yesterday.year, yesterday.month, yesterday.day);
    final end =
        DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);
    return DateTimeRange(start: start, end: end);
  }

  DateTimeRange _getLast7DaysRange() {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 7));
    return DateTimeRange(start: start, end: now);
  }

  DateTimeRange _getLast30DaysRange() {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 30));
    return DateTimeRange(start: start, end: now);
  }

  DateTimeRange _getThisMonthRange() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    return DateTimeRange(start: start, end: now);
  }
}
