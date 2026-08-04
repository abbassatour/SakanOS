// lib/home/view/widgets/charts/section_header.dart
import 'package:flutter/material.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';
import '../../../cubit/home_cubit.dart';
import 'chart_colors.dart';

class SectionHeader extends StatelessWidget {
  final String periodLabel;
  final TimeFilter timeFilter;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<TimeFilter> onFilterChanged;

  const SectionHeader({
    super.key,
    required this.periodLabel,
    required this.timeFilter,
    required this.onPrevious,
    required this.onNext,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 22,
              decoration: BoxDecoration(
                color: ChartColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              l10n.chartSectionTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ChartColors.titleColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.indigo.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.withOpacity(0.07),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _NavButton(
                    icon: Icons.chevron_left_rounded,
                    tooltip: l10n.chartNavNextPeriod,
                    onTap: onNext,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    constraints: const BoxConstraints(minWidth: 160),
                    child: Text(
                      periodLabel,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: ChartColors.primary,
                      ),
                    ),
                  ),
                  _NavButton(
                    icon: Icons.chevron_right_rounded,
                    tooltip: l10n.chartNavPrevPeriod,
                    onTap: onPrevious,
                  ),
                ],
              ),
            ),
            SegmentedButton<TimeFilter>(
              style: SegmentedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: ChartColors.primary,
                selectedForegroundColor: Colors.white,
                selectedBackgroundColor: ChartColors.primary,
                side: BorderSide(color: Colors.indigo.shade100),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 0,
                ),
              ),
              segments: [
                ButtonSegment(
                  value: TimeFilter.daily,
                  label: Text(l10n.filterDaily),
                ),
                ButtonSegment(
                  value: TimeFilter.weekly,
                  label: Text(l10n.filterWeekly),
                ),
                ButtonSegment(
                  value: TimeFilter.monthly,
                  label: Text(l10n.filterMonthly),
                ),
                ButtonSegment(
                  value: TimeFilter.yearly,
                  label: Text(l10n.filterYearly),
                ),
              ],
              selected: {timeFilter},
              onSelectionChanged: (s) => onFilterChanged(s.first),
            ),
          ],
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _NavButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: ChartColors.primary, size: 22),
        ),
      ),
    );
  }
}
