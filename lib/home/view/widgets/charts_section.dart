// lib/home/view/widgets/charts_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';
import '../../cubit/home_cubit.dart';
import '../materials_trend_page.dart';

import 'charts/chart_colors.dart';
import 'charts/chart_shared_widgets.dart';
import 'charts/section_header.dart';
import 'charts/revenue_chart.dart';
import 'charts/trend_line_chart.dart';
import 'charts/contracts_pie_chart.dart';
import 'charts/inventory_pie_chart.dart';
import 'charts/meters_progress_chart.dart';

class ChartsSection extends StatelessWidget {
  final HomeState state;
  const ChartsSection({super.key, required this.state});

  String _getPeriodLabel(BuildContext context) {
    final ref = state.referenceDate;
    final locale = Localizations.localeOf(context).languageCode;

    switch (state.timeFilter) {
      case TimeFilter.daily:
        final start = ref.subtract(const Duration(days: 6));
        return '${DateFormat('MM/dd').format(start)} – ${DateFormat('MM/dd').format(ref)}';
      case TimeFilter.weekly:
        return DateFormat('MMM yyyy', locale).format(ref);
      case TimeFilter.monthly:
        return DateFormat('yyyy', locale).format(ref);
      case TimeFilter.yearly:
        return '${ref.year - 4} – ${ref.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HomeCubit>();
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          periodLabel: _getPeriodLabel(context),
          timeFilter: state.timeFilter,
          onPrevious: cubit.navigatePrevious,
          onNext: cubit.navigateNext,
          onFilterChanged: cubit.changeTimeFilter,
        ),
        const SizedBox(height: 24),
        ChartRow(
          children: [
            Expanded(
              flex: 2,
              child: RevenueChart(
                title: l10n.chartRevenueTitle,
                description: l10n.chartRevenueDesc,
                data: state.groupedRevenue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: TrendLineChart(
                title: l10n.chartDollarTrendTitle,
                description: l10n.chartDollarTrendDesc,
                data: state.dollarTrend,
                color: Colors.green.shade600,
                icon: Icons.currency_exchange,
                peakLabel: l10n.chartDollarTrendPeak,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ChartRow(
          children: [
            Expanded(
              flex: 1,
              child: ContractsPieChart(
                title: l10n.chartContractsTypeTitle,
                description: l10n.chartContractsTypeDesc,
                data: state.contractsByType,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: TrendLineChart(
                title: l10n.chartCostTrendTitle,
                description: l10n.chartCostTrendDesc,
                data: state.costTrend,
                color: ChartColors.red,
                icon: Icons.warning_amber_rounded,
                peakLabel: l10n.chartCostTrendPeak,
                isCost: true,
                actionIcon: Icons.analytics_outlined,
                actionTooltip: l10n.chartCostTrendActionTooltip,
                onActionTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MaterialsTrendPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ChartRow(
          children: [
            Expanded(
              flex: 1,
              child: InventoryPieChart(
                data: state.inventoryStatus,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: MetersProgressChart(
                allocatedSold: state.allocatedSoldMeters,
                allocatedPaid: state.allocatedPaidMeters,
                allocatedDebt: state.allocatedDebtMeters,
                allocatedUndelivered: state.allocatedUndeliveredMeters,
                unallocatedPaid: state.unallocatedPaidMeters,
                totalAvailableArea: state.totalAvailableArea,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
