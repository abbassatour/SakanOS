// lib/home/view/widgets/charts/meters_progress_chart.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';
import 'chart_shared_widgets.dart';

class MetersProgressChart extends StatelessWidget {
  final double totalSold;
  final double paid;
  final double unpaid;
  final double undelivered;

  final double allocatedSold;
  final double allocatedPaid;
  final double allocatedDebt;
  final double allocatedUndelivered;
  final double unallocatedPaid;
  final double totalAvailableArea;

  const MetersProgressChart({
    super.key,
    this.totalSold = 0,
    this.paid = 0,
    this.unpaid = 0,
    this.undelivered = 0,
    required this.allocatedSold,
    required this.allocatedPaid,
    required this.allocatedDebt,
    required this.allocatedUndelivered,
    required this.unallocatedPaid,
    required this.totalAvailableArea,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;
    final numberFormatter = NumberFormat.decimalPattern(locale);

    final double allocatedPaidPct = allocatedSold == 0
        ? 0
        : (allocatedPaid / allocatedSold).clamp(0.0, 1.0);
    final double allocatedDebtPct = allocatedSold == 0
        ? 0
        : (allocatedDebt / allocatedSold).clamp(0.0, 1.0);
    final double allocatedUndeliveredPct = allocatedSold == 0
        ? 0
        : (allocatedUndelivered / allocatedSold).clamp(0.0, 1.0);

    return ChartCard(
      title: l10n.chartMetersProgressTitle,
      description: l10n.chartMetersProgressDesc,
      titleIcon: Icons.balance_rounded,
      iconColor: Colors.teal.shade800,
      chart: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.apartment_rounded,
                  color: Colors.amber.shade800,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.chartMetersSectionAllocated,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.amber.shade900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _buildProgressRow(
            title: l10n.chartMetersAllocatedPaid,
            value: '${numberFormatter.format(allocatedPaid.toInt())} m²',
            percentage: allocatedPaidPct,
            color: Colors.teal.shade600,
            icon: Icons.monetization_on_rounded,
          ),
          const SizedBox(height: 16),
          _buildProgressRow(
            title: l10n.chartMetersAllocatedDebt,
            value: '${numberFormatter.format(allocatedDebt.toInt())} m²',
            percentage: allocatedDebtPct,
            color: Colors.orange.shade700,
            icon: Icons.badge_outlined,
          ),
          const SizedBox(height: 16),
          _buildProgressRow(
            title: l10n.chartMetersAllocatedUndelivered,
            value: '${numberFormatter.format(allocatedUndelivered.toInt())} m²',
            percentage: allocatedUndeliveredPct,
            color: Colors.purple.shade600,
            icon: Icons.construction_rounded,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(color: Colors.black12, height: 1),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.savings_rounded,
                  color: Colors.amber.shade900,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.chartMetersSectionUnallocated,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.amber.shade900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _buildStaticPortfolioRow(
            title: l10n.chartMetersUnallocatedPaid,
            value: '${numberFormatter.format(unallocatedPaid.toInt())} m²',
            color: Colors.blue.shade700,
            icon: Icons.pie_chart_rounded,
            subtitle: l10n.chartMetersUnallocatedSubtitle,
          ),
        ],
      ),
      footerRows: [
        FooterRow(
          icon: Icons.architecture,
          iconColor: Colors.indigo,
          label: l10n.chartMetersTotalAvailable,
          value: '${numberFormatter.format(totalAvailableArea.toInt())} m²',
        ),
      ],
    );
  }

  Widget _buildProgressRow({
    required String title,
    required String value,
    required double percentage,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutCubic,
                  height: 8,
                  width: constraints.maxWidth * percentage,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStaticPortfolioRow({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      color: color.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
