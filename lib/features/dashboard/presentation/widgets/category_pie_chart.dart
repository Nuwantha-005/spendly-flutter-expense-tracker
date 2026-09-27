import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../expenses/domain/category_spending.dart';

/// Donut chart rendering category spending distribution with interactive center callout.
/// Adapts gracefully to light and dark themes.
class CategoryPieChart extends StatefulWidget {
  const CategoryPieChart({
    super.key,
    required this.items,
    this.centerText,
  });

  final List<CategorySpending> items;
  final String? centerText;

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return AspectRatio(
      aspectRatio: 1.35,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex = pieTouchResponse
                        .touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2.5,
              centerSpaceRadius: 45,
              sections: List.generate(widget.items.length, (i) {
                final isTouched = i == _touchedIndex;
                final item = widget.items[i];
                final radius = isTouched ? 34.0 : 26.0;

                return PieChartSectionData(
                  color: item.color,
                  value: item.totalAmount,
                  title: isTouched
                      ? '${item.percentage.toStringAsFixed(0)}%'
                      : '',
                  radius: radius,
                  titleStyle: AppTextStyles.labelSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }),
            ),
          ),
          // Interactive Center Hole Indicator
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_touchedIndex >= 0 &&
                    _touchedIndex < widget.items.length) ...[
                  Icon(
                    widget.items[_touchedIndex].icon,
                    size: 20,
                    color: widget.items[_touchedIndex].color,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.items[_touchedIndex].categoryName,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ] else ...[
                  Icon(
                    Icons.pie_chart_outline_rounded,
                    size: 22,
                    color: theme.colorScheme.primary,
                  ),
                  if (widget.centerText != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.centerText!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
