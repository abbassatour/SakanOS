// lib/home/view/widgets/charts/revenue_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'chart_colors.dart';
import 'chart_shared_widgets.dart';

class RevenueChart extends StatelessWidget {
  final String title;
  final String description;
  final Map<String, double> data;

  const RevenueChart({
    super.key,
    required this.title,
    required this.description,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final axisFormatter = NumberFormat.compact(locale: 'en_US');
    final textFormatter = NumberFormat.currency(locale: 'ar_SY', symbol: 'ل.س');

    String bestPeriod = '—';
    double maxRevenueAbsolute =
        0.0; // سنبحث عن أكبر قيمة (سواء كانت موجبة أو سالبة) لرسم المحور Y
    double totalRevenue = 0.0;

    for (final e in data.entries) {
      totalRevenue += e.value;

      // نحدد أفضل فترة (كأكبر تحصيل موجب)
      if (e.value > 0 && e.value > maxRevenueAbsolute) {
        bestPeriod = e.key;
      }

      // نبحث عن أقصى ارتفاع للعمود (بالقيمة المطلقة)
      if (e.value.abs() > maxRevenueAbsolute) {
        maxRevenueAbsolute = e.value.abs();
      }
    }

    final maxY = maxRevenueAbsolute <= 0 ? 1000.0 : maxRevenueAbsolute * 1.25;

    final yInterval = (maxY / 5).abs();
    final safeInterval = yInterval == 0 ? 1000.0 : yInterval;

    return ChartCard(
      title: title,
      description: description,
      titleIcon: Icons.account_balance_wallet_rounded,
      iconColor: ChartColors.teal,
      chart: SizedBox(
        height: 230,
        child: data.isEmpty
            ? const EmptyChart()
            : BarChart(
                BarChartData(
                  maxY: maxY,
                  minY: 0, // 🌟 دائماً يبدأ من الصفر
                  alignment: BarChartAlignment.spaceAround,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (BarChartGroupData group) =>
                          Colors.blueGrey.shade900,
                      getTooltipItem: (group, _, rod, _) {
                        final period = data.keys.elementAt(group.x);
                        // 🌟 نجلب القيمة الحقيقية (بالسالب أو الموجب) من البيانات الأصلية
                        final actualValue = data.values.elementAt(group.x);

                        return BarTooltipItem(
                          '$period\n',
                          const TextStyle(color: Colors.white70, fontSize: 11),
                          children: [
                            TextSpan(
                              // 🌟 نعرض القيمة الحقيقية
                              text: textFormatter.format(actualValue),
                              style: TextStyle(
                                color: actualValue >= 0
                                    ? Colors.greenAccent
                                    : Colors.redAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  barGroups: data.entries.toList().asMap().entries.map((e) {
                    final bool isPositive = e.value.value >= 0;

                    return BarChartGroupData(
                      x: e.key,
                      barRods: [
                        BarChartRodData(
                          toY: e.value.value
                              .abs(), // 🌟 نرسم العمود بناءً على القيمة المطلقة (دائماً للأعلى)
                          width: 14,
                          // بما أنه دائماً للأعلى، التدوير دائماً في القمة
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),

                          // 🌟 الألوان تحدد إذا كان إيداع أم سحب
                          gradient: LinearGradient(
                            colors: isPositive
                                ? [
                                    ChartColors.teal.withOpacity(0.7),
                                    ChartColors.teal,
                                  ]
                                : [
                                    Colors.red.shade400.withOpacity(0.7),
                                    Colors.red.shade600,
                                  ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (value, _) {
                          final i = value.toInt();
                          if (i < 0 || i >= data.length)
                            return const SizedBox.shrink();
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
                        interval: safeInterval,
                        getTitlesWidget: (value, meta) {
                          if (value == 0 || value == maxY)
                            return const SizedBox.shrink();
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
                    horizontalInterval: safeInterval,
                    getDrawingHorizontalLine: (value) {
                      return const FlLine(
                        color: ChartColors.gridLine,
                        strokeWidth: 1,
                      );
                    },
                  ),
                ),
                duration: Duration.zero,
              ),
      ),
      footerRows: [
        FooterRow(
          icon: Icons.star_rounded,
          iconColor: Colors.amber,
          label: 'أعلى فترة تحصيل:',
          // إذا لم يكن هناك تحصيل موجب أبداً، نعرض القيمة العظمى المطلقة (والتي ستكون سالبة)
          value: bestPeriod != '—'
              ? '$bestPeriod (${textFormatter.format(data[bestPeriod])})'
              : 'لا يوجد',
        ),
        FooterRow(
          icon: Icons.functions_rounded,
          iconColor: totalRevenue >= 0 ? ChartColors.teal : Colors.red,
          label: 'صافي التدفق (الإجمالي):',
          value: textFormatter.format(totalRevenue),
        ),
      ],
    );
  }
}
