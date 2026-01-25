import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../domain/entities/dashboard_entities.dart';

/// Orders distribution pie chart widget.
class OrdersDistributionChart extends StatefulWidget {
  final OrdersDistribution distribution;

  const OrdersDistributionChart({super.key, required this.distribution});

  @override
  State<OrdersDistributionChart> createState() =>
      _OrdersDistributionChartState();
}

class _OrdersDistributionChartState extends State<OrdersDistributionChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'توزيع الطلبات',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppConstants.spacingMd),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (event, response) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                response == null ||
                                response.touchedSection == null) {
                              _touchedIndex = -1;
                              return;
                            }
                            _touchedIndex =
                                response.touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: _buildSections(),
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.spacingMd),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: _buildLegend(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    final data = [
      _SectionData(
          'قيد الانتظار', widget.distribution.pending, AppColors.warning),
      _SectionData('مؤكد', widget.distribution.confirmed, AppColors.info),
      _SectionData('جاري التحضير', widget.distribution.preparing,
          const Color(0xFF8B5CF6)),
      _SectionData('جاهز', widget.distribution.ready, const Color(0xFFF59E0B)),
      _SectionData(
          'تم الاستلام', widget.distribution.pickedUp, const Color(0xFF06B6D4)),
      _SectionData(
          'تم التوصيل', widget.distribution.delivered, AppColors.success),
      _SectionData('ملغي', widget.distribution.cancelled, AppColors.error),
    ];

    return List.generate(data.length, (index) {
      final isTouched = index == _touchedIndex;
      final radius = isTouched ? 60.0 : 50.0;
      final fontSize = isTouched ? 14.0 : 12.0;

      return PieChartSectionData(
        color: data[index].color,
        value: data[index].value.toDouble(),
        title: data[index].value > 0 ? '${data[index].value}' : '',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }

  Widget _buildLegend() {
    final legendItems = [
      _LegendItem('قيد الانتظار', AppColors.warning),
      _LegendItem('مؤكد', AppColors.info),
      _LegendItem('جاري التحضير', const Color(0xFF8B5CF6)),
      _LegendItem('جاهز', const Color(0xFFF59E0B)),
      _LegendItem('تم الاستلام', const Color(0xFF06B6D4)),
      _LegendItem('تم التوصيل', AppColors.success),
      _LegendItem('ملغي', AppColors.error),
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: legendItems.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                item.label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _SectionData {
  final String label;
  final int value;
  final Color color;

  const _SectionData(this.label, this.value, this.color);
}

class _LegendItem {
  final String label;
  final Color color;

  const _LegendItem(this.label, this.color);
}
