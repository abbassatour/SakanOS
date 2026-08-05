// lib/home/view/widgets/kpi_section.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:our_home_erp_app/home/cubit/home_cubit.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';

class KpiSection extends StatelessWidget {
  const KpiSection({required this.state, super.key});
  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final numberFormatter = NumberFormat.decimalPattern(
      Localizations.localeOf(context).languageCode,
    );

    final kpis = [
      _KpiData(
        icon: Icons.account_balance_wallet_rounded,
        mainColor: Colors.teal.shade600,
        title: l10n.kpiNetLiquidityTitle,
        value: '${numberFormatter.format(state.totalRevenue.toInt())} ',
        subtitle: l10n.kpiNetLiquiditySubtitle,
      ),
      _KpiData(
        icon: Icons.money_off_rounded,
        mainColor: Colors.red.shade600,
        title: l10n.kpiRefundedTitle,
        value: '${numberFormatter.format(state.totalRefundedAmount.toInt())} ',
        subtitle: l10n.kpiRefundedSubtitle,
        infoDetails: l10n.kpiRefundedDetails,
      ),
      _KpiData(
        icon: Icons.hourglass_bottom_rounded,
        mainColor: Colors.orange.shade600,
        title: l10n.kpiPreHandoverDebtTitle,
        value: '${numberFormatter.format(state.overduePreHandover.toInt())} ',
        subtitle: l10n.kpiPreHandoverDebtSubtitle,
        infoDetails: l10n.kpiPreHandoverDebtDetails,
      ),
      _KpiData(
        icon: Icons.warning_amber_rounded,
        mainColor: Colors.red.shade800,
        title: l10n.kpiPostHandoverDebtTitle,
        value: '${numberFormatter.format(state.overduePostHandover.toInt())} ',
        subtitle: l10n.kpiPostHandoverDebtSubtitle,
        infoDetails: l10n.kpiPostHandoverDebtDetails,
      ),
      _KpiData(
        icon: Icons.vpn_key_outlined,
        mainColor: Colors.blue.shade600,
        title: l10n.kpiAvailableUnitsTitle,
        value: numberFormatter.format(state.inventoryStatus['متاحة'] ?? 0),
        subtitle: l10n.kpiAvailableUnitsSubtitle,
        infoDetails: l10n.kpiAvailableUnitsDetails,
      ),
      _KpiData(
        icon: Icons.description_rounded,
        mainColor: Colors.purple.shade600,
        title: l10n.kpiActiveContractsTitle,
        value: numberFormatter.format(state.activeContractsCount),
        subtitle: l10n.kpiActiveContractsSubtitle,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        if (constraints.maxWidth >= 1300) {
          crossAxisCount = 6;
        } else if (constraints.maxWidth >= 900) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth >= 550) {
          crossAxisCount = 2;
        } else {
          crossAxisCount = 1;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 135,
          ),
          itemCount: kpis.length,
          itemBuilder: (context, index) => _KpiCard(data: kpis[index]),
        );
      },
    );
  }
}

class _KpiData {
  const _KpiData({
    required this.icon,
    required this.mainColor,
    required this.title,
    required this.value,
    required this.subtitle,
    this.infoDetails,
  });
  final IconData icon;
  final Color mainColor;
  final String title;
  final String value;
  final String subtitle;
  final String? infoDetails;
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.data});
  final _KpiData data;

  void _showInfoDialog(BuildContext context) {
    final l10n = context.l10n;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.analytics_outlined,
              color: Colors.blue.shade700,
              size: 28,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.kpiDialogTitle(data.title),
                style: TextStyle(
                  color: Colors.blue.shade900,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          data.infoDetails!,
          style: const TextStyle(
            height: 1.6,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.kpiDialogDismiss),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.lightBlue.shade100,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade900.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          data.title,
                          style: TextStyle(
                            color: Colors.blueGrey.shade600,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (data.infoDetails != null) ...[
                        const SizedBox(width: 6),
                        Tooltip(
                          message: l10n.kpiTooltipInfo,
                          child: InkWell(
                            onTap: () => _showInfoDialog(context),
                            borderRadius: BorderRadius.circular(12),
                            child: Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade300,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: data.mainColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(data.icon, color: data.mainColor, size: 20),
                ),
              ],
            ),
            Text(
              data.value,
              style: TextStyle(
                color: Colors.blue.shade900,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              data.subtitle,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
