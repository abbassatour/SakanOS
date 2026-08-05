// lib/home/view/widgets/charts/inventory_pie_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';
import 'chart_colors.dart';
import 'chart_shared_widgets.dart';

class InventoryPieChart extends StatelessWidget {
  final Map<String, int> data;

  const InventoryPieChart({
    super.key,
    required this.data,
  });

  String _getLocalizedStatusName(BuildContext context, String rawStatus) {
    final l10n = context.l10n;
    if (rawStatus == 'متاحة') return l10n.chartInventoryStatusAvailable;
    if (rawStatus == 'مباعة') return l10n.chartInventoryStatusSold;
    if (rawStatus == 'مُسلّمة') return l10n.chartInventoryStatusDelivered;
    return rawStatus;
  }

  Color _getColorForStatus(String status) {
    if (status == 'متاحة') return Colors.teal.shade400;
    if (status == 'مباعة') return Colors.orange.shade500;
    if (status == 'مُسلّمة') return Colors.indigo.shade600;
    return Colors.grey;
  }

  IconData _getIconForStatus(String status) {
    if (status == 'متاحة') return Icons.check_circle_outline;
    if (status == 'مباعة') return Icons.construction_rounded;
    if (status == 'مُسلّمة') return Icons.vpn_key_rounded;
    return Icons.circle;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    int total = data.values.fold(0, (sum, val) => sum + val);
    final validData = data.entries.where((e) => e.value > 0).toList();

    return ChartCard(
      title: l10n.chartInventoryTitle,
      description: l10n.chartInventoryDesc,
      titleIcon: Icons.apartment_rounded,
      iconColor: Colors.teal.shade700,
      chart: total == 0 || validData.isEmpty
          ? const EmptyChart()
          : Column(
              children: [
                SizedBox(
                  height: 180,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$total',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: ChartColors.titleColor,
                            ),
                          ),
                          Text(
                            l10n.chartInventoryUnit,
                            style: const TextStyle(
                              fontSize: 11,
                              color: ChartColors.axisLabel,
                            ),
                          ),
                        ],
                      ),
                      PieChart(
                        PieChartData(
                          sectionsSpace: 4,
                          centerSpaceRadius: 55,
                          startDegreeOffset: 270,
                          sections: validData.map((e) {
                            final pct = (e.value / total) * 100;
                            return PieChartSectionData(
                              color: _getColorForStatus(e.key),
                              value: e.value.toDouble(),
                              title: '${pct.toStringAsFixed(0)}%',
                              radius: 25,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              badgeWidget: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _getIconForStatus(e.key),
                                  size: 14,
                                  color: _getColorForStatus(e.key),
                                ),
                              ),
                              badgePositionPercentageOffset: 1.4,
                            );
                          }).toList(),
                        ),
                        duration: const Duration(milliseconds: 800),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: data.entries.map((e) {
                    final pct = total == 0 ? 0.0 : (e.value / total) * 100;
                    final localizedName = _getLocalizedStatusName(
                      context,
                      e.key,
                    );
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getColorForStatus(e.key).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _getColorForStatus(e.key).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getIconForStatus(e.key),
                            size: 16,
                            color: _getColorForStatus(e.key),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$localizedName (${pct.toStringAsFixed(1)}%)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _getColorForStatus(e.key),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
    );
  }
}
