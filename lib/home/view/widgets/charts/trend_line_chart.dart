// lib/home/view/widgets/charts/trend_line_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';
import 'chart_colors.dart';
import 'chart_shared_widgets.dart';

class TrendLineChart extends StatelessWidget {
  final String title;
  final String description;
  final Map<String, double> data;
  final Color color;
  final IconData icon;
  final String peakLabel;
  final bool isCost;

  final VoidCallback? onActionTap;
  final IconData? actionIcon;
  final String? actionTooltip;

  const TrendLineChart({
    super.key,
    required this.title,
    required this.description,
    required this.data,
    required this.color,
    required this.icon,
    required this.peakLabel,
    this.isCost = false,
    this.onActionTap,
    this.actionIcon,
    this.actionTooltip,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;
    final axisFormatter = NumberFormat.compact(locale: locale);
    final textFormatter = NumberFormat.currency(locale: locale, symbol: '');

    String peakPeriod = '—';
    double maxValue = 0;
    double minValue = double.infinity;
    bool hasZero = false;

    for (final e in data.entries) {
      if (e.value > maxValue) {
        maxValue = e.value;
        peakPeriod = e.key;
      }
      if (e.value < minValue && e.value != 0) minValue = e.value;
      if (e.value == 0) hasZero = true;
    }

    final maxY = maxValue <= 0 ? 1000.0 : maxValue * 1.12;
    final minY = hasZero
        ? 0.0
        : ((minValue == double.infinity || minValue <= 0)
              ? 0.0
              : minValue * 0.88);
    final range = maxY - minY;
    final yInterval = range <= 0 ? 1000.0 : range / 4;

    double xInterval = 1;
    if (data.length > 15) {
      xInterval = (data.length / 8).ceilToDouble();
    }

    final spots = data.entries.toList().asMap().entries.map((e) {
      if (e.value.value == 0) return FlSpot.nullSpot;
      return FlSpot(e.key.toDouble(), e.value.value);
    }).toList();

    return ChartCard(
      title: title,
      description: description,
      titleIcon: icon,
      iconColor: color,
      onActionTap: onActionTap,
      actionIcon: actionIcon,
      actionTooltip: actionTooltip,
      chart: SizedBox(
        height: 230,
        child: data.isEmpty
            ? const EmptyChart()
            : LineChart(
                LineChartData(
                  maxY: maxY,
                  minY: minY,
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (spots) => spots.map((spot) {
                        final period = data.keys.elementAt(spot.x.toInt());
                        return LineTooltipItem(
                          '$period\n',
                          const TextStyle(color: Colors.white70, fontSize: 11),
                          children: [
                            TextSpan(
                              text: textFormatter.format(spot.y),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      preventCurveOverShooting: true,
                      curveSmoothness: 0.35,
                      color: color,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: data.length <= 12,
                        getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: color,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            color.withOpacity(0.18),
                            color.withOpacity(0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: xInterval,
                        getTitlesWidget: (value, _) {
                          if (value != value.toInt()) {
                            return const SizedBox.shrink();
                          }
                          final i = value.toInt();
                          if (i < 0 || i >= data.length) {
                            return const SizedBox.shrink();
                          }

                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              data.keys.elementAt(i),
                              style: const TextStyle(
                                fontSize: 9,
                                color: ChartColors.axisLabel,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 52,
                        interval: yInterval,
                        getTitlesWidget: (value, meta) {
                          if (value == minY || value == maxY) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            axisFormatter.format(value),
                            style: const TextStyle(
                              fontSize: 10,
                              color: ChartColors.axisLabel,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: yInterval,
                    getDrawingHorizontalLine: (_) => const FlLine(
                      color: ChartColors.gridLine,
                      strokeWidth: 1,
                    ),
                  ),
                ),
                duration: Duration.zero,
              ),
      ),
      footerRows: [
        FooterRow(
          icon: icon,
          iconColor: color,
          label: peakLabel,
          value: '$peakPeriod (${textFormatter.format(maxValue)})',
        ),
        FooterRow(
          icon: Icons.bar_chart_rounded,
          iconColor: ChartColors.axisLabel,
          label: l10n.chartTrendPeriodsCount,
          value: '${data.length} ${l10n.chartTrendPeriodsUnit}',
        ),
      ],
    );
  }
}
