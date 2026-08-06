// lib/schedule/view/tabs/widgets/traditional/schedule_stats_ribbon.dart
import 'package:flutter/material.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';

class ScheduleStatsRibbon extends StatelessWidget {
  final int totalInstallments;
  final int paidInstallments;
  final int pendingInstallments;
  final int overdueInstallments;
  final bool isPostAllocation;
  final String formattedAgreedAmount;
  final double metersPerInstallment;

  const ScheduleStatsRibbon({
    super.key,
    required this.totalInstallments,
    required this.paidInstallments,
    required this.pendingInstallments,
    required this.overdueInstallments,
    required this.isPostAllocation,
    required this.formattedAgreedAmount,
    required this.metersPerInstallment,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 24,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _buildDesktopStatItem(
                  l10n.scheduleStatRegistered,
                  totalInstallments.toString(),
                  Colors.indigo,
                ),
                _buildDesktopStatItem(
                  l10n.scheduleStatPaid,
                  paidInstallments.toString(),
                  Colors.green,
                ),
                _buildDesktopStatItem(
                  l10n.scheduleStatPending,
                  pendingInstallments.toString(),
                  Colors.orange,
                ),
                _buildDesktopStatItem(
                  l10n.scheduleStatOverdue,
                  overdueInstallments.toString(),
                  Colors.red,
                  isAlert: overdueInstallments > 0,
                ),
                _buildDesktopStatItem(
                  l10n.scheduleStatMonthlyDue,
                  '$formattedAgreedAmount ${l10n.currencySyp}',
                  Colors.teal,
                ),
              ],
            ),
          ),
          Container(
            height: 20,
            width: 1,
            color: Colors.grey.shade300,
            margin: const EdgeInsets.symmetric(horizontal: 12),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLegendItem(Colors.green, l10n.scheduleLegendPaid),
              const SizedBox(width: 12),
              _buildLegendItem(Colors.orange, l10n.scheduleLegendPending),
              const SizedBox(width: 12),
              _buildLegendItem(Colors.red, l10n.scheduleLegendOverdue),
              const SizedBox(width: 12),
              _buildLegendItem(Colors.grey.shade800, l10n.scheduleLegendMissed),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopStatItem(
    String title,
    String value,
    Color color, {
    bool isAlert = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$title: ',
          style: const TextStyle(
            color: Colors.blueGrey,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: isAlert
                ? Border.all(color: Colors.red.withOpacity(0.5))
                : null,
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
