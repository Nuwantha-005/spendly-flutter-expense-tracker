import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../expenses/domain/monthly_trend_item.dart';

/// Monthly spending trend bar chart showcasing recent 6 months spending.
/// Automatically adapts to theme changes.
class MonthlyTrendBarChart extends StatelessWidget {
  const MonthlyTrendBarChart({
    super.key,
    required this.items,
  });

  final List<MonthlyTrendItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final maxVal = items.fold<double>(
      0.0,
      (max, item) => math.max(max, item.totalAmount),
    );

    // Ceiling to ensure room above highest bar
    final maxY = maxVal > 0 ? maxVal * 1.25 : 1000.0;

    return AspectRatio(
      aspectRatio: 1.8,
      child: Padding(
        padding: const EdgeInsets.only(
          right: AppDimensions.spacingSm,
          top: AppDimensions.spacingSm,
        ),
        child: BarChart(
          BarChartData(
            maxY: maxY,
            minY: 0,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => isDark ? AppColors.surfaceVariantDark : AppColors.onBackground,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final item = items[groupIndex];
                  return BarTooltipItem(
                    '${item.monthLabel}\n${CurrencyFormatter.format(item.totalAmount)}',
                    AppTextStyles.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= items.length) {
                      return const SizedBox.shrink();
                    }
                    final item = items[index];
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        item.monthLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: item.isCurrentMonth
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          fontWeight: item.isCurrentMonth
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barGroups: List.generate(items.length, (i) {
              final item = items[i];
              return BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: item.totalAmount,
                    color: item.isCurrentMonth
                        ? theme.colorScheme.primary
                        : theme.colorScheme.primary.withValues(alpha: 0.45),
                    width: 18,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(5),
                    ),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: maxY,
                      color: isDark
                          ? AppColors.surfaceVariantDark
                          : AppColors.surfaceVariant.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
