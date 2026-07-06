// lib/home/view/widgets/charts/contracts_pie_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'chart_colors.dart';
import 'chart_shared_widgets.dart';

class ContractsPieChart extends StatelessWidget {
  final String title;
  final String description; // 🌟 1. أضفنا الشرح
  final Map<String, int> data;

  const ContractsPieChart({
    super.key,
    required this.title,
    required this.description, // 🌟 2. أضفناه للمشيد
    required this.data,
  });

  static const _colors = [
    Color(0xFF1A237E),
    Color(0xFF00897B),
    Color(0xFFEF6C00),
    Color(0xFFC62828),
    Color(0xFF6A1B9A),
    Color(0xFF00838F),
  ];

  @override
  Widget build(BuildContext context) {
    String topType = '—';
    int maxCount = 0;
    int total = 0;

    for (final e in data.entries) {
      total += e.value;
      if (e.value > maxCount) {
        maxCount = e.value;
        topType = e.key;
      }
    }

    final entries = data.entries.toList();

    return ChartCard(
      title: title,
      description: description, // 🌟 3. مررنا الشرح إلى كرت العرض المشترك
      titleIcon: Icons.donut_large_rounded,
      iconColor: ChartColors.primary,
      chart: data.isEmpty
          ? const EmptyChart()
          : Column(
              children: [
                SizedBox(
                  height: 180,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 44,
                      startDegreeOffset: -90,
                      sections: entries.asMap().entries.map((e) {
                        final pct = total == 0
                            ? 0.0
                            : e.value.value / total * 100;
                        return PieChartSectionData(
                          color: _colors[e.key % _colors.length],
                          value: e.value.value.toDouble(),
                          title: '${pct.toStringAsFixed(0)}%',
                          radius: 52,
                          titleStyle: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList(),
                    ),
                    duration: Duration.zero, // 👈 تم إلغاء الأنميشن
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: entries.asMap().entries.map((e) {
                    final pct = total == 0 ? 0.0 : e.value.value / total * 100;
                    final c = _colors[e.key % _colors.length];
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${e.value.key} (${pct.toStringAsFixed(1)}%)',
                          style: const TextStyle(
                            fontSize: 11,
                            color: ChartColors.axisLabel,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
      footerRows: [
        FooterRow(
          icon: Icons.emoji_events_rounded,
          iconColor: Colors.amber,
          label: 'الأكثر مبيعاً:',
          value: topType,
        ),
        FooterRow(
          icon: Icons.format_list_numbered_rounded,
          iconColor: ChartColors.primary,
          label: 'إجمالي العقود:',
          value: '$total عقد',
        ),
      ],
    );
  }
}
