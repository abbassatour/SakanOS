// lib/home/view/widgets/charts/chart_shared_widgets.dart
import 'package:flutter/material.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';
import 'chart_colors.dart';

class ChartCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData titleIcon;
  final Color iconColor;
  final Widget chart;
  final List<Widget> footerRows;

  final VoidCallback? onActionTap;
  final IconData? actionIcon;
  final String? actionTooltip;

  const ChartCard({
    super.key,
    required this.title,
    required this.description,
    required this.titleIcon,
    required this.iconColor,
    required this.chart,
    this.footerRows = const [],
    this.onActionTap,
    this.actionIcon,
    this.actionTooltip,
  });

  void _showInfoDialog(BuildContext context) {
    final l10n = context.l10n;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.chartAboutTitle(title),
                style: const TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          description,
          style: const TextStyle(
            height: 1.6,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.chartDialogUnderstand),
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
        color: ChartColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(titleIcon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: ChartColors.titleColor,
                    ),
                  ),
                ),
                if (onActionTap != null && actionIcon != null) ...[
                  IconButton(
                    icon: Icon(
                      actionIcon,
                      color: Colors.indigo.shade400,
                      size: 22,
                    ),
                    tooltip: actionTooltip ?? l10n.chartOpenDetailsTooltip,
                    splashRadius: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: onActionTap,
                  ),
                  const SizedBox(width: 8),
                ],
                IconButton(
                  icon: const Icon(
                    Icons.info_outline,
                    color: Colors.grey,
                    size: 22,
                  ),
                  tooltip: l10n.chartExplainTooltip,
                  splashRadius: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _showInfoDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            chart,
            if (footerRows.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFF0F0F0),
                ),
              ),
              ...footerRows,
            ],
          ],
        ),
      ),
    );
  }
}

class FooterRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const FooterRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(color: ChartColors.axisLabel, fontSize: 13),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: ChartColors.titleColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyChart extends StatelessWidget {
  const EmptyChart({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SizedBox(
      height: 180,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bar_chart_rounded,
              size: 40,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 10),
            Text(
              l10n.chartNoData,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class ChartRow extends StatelessWidget {
  final List<Widget> children;
  const ChartRow({super.key, required this.children});
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: children,
  );
}
