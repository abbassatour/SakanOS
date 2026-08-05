// lib/home/view/materials_trend_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:intl/intl.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';

import '../cubit/home_cubit.dart';
import '../cubit/materials_trend/materials_trend_cubit.dart';

import 'widgets/charts/trend_line_chart.dart';
import 'widgets/charts/chart_colors.dart';
import 'widgets/charts/section_header.dart';

class MaterialsTrendPage extends StatelessWidget {
  const MaterialsTrendPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MaterialsTrendCubit(context.read<ErpRepository>())..fetchData(),
      child: const _MaterialsTrendView(),
    );
  }
}

class _MaterialsTrendView extends StatelessWidget {
  const _MaterialsTrendView();

  String _getPeriodLabel(BuildContext context, MaterialsTrendState state) {
    final l10n = context.l10n;
    final ref = state.referenceDate;
    final locale = Localizations.localeOf(context).languageCode;

    switch (state.timeFilter) {
      case TimeFilter.daily:
        final start = ref.subtract(const Duration(days: 6));
        return '${DateFormat('MM/dd').format(start)} – ${DateFormat('MM/dd').format(ref)}';
      case TimeFilter.weekly:
        return l10n.materialsTrendPeriodWeeks(
          DateFormat('MMM yyyy', locale).format(ref),
        );
      case TimeFilter.monthly:
        return l10n.materialsTrendPeriodMonths(ref.year);
      case TimeFilter.yearly:
        return '${ref.year - 4} – ${ref.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: ChartColors.primary,
        title: Text(
          l10n.materialsTrendPageTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: BlocBuilder<MaterialsTrendCubit, MaterialsTrendState>(
        builder: (context, state) {
          if (state.status == MaterialsTrendStatus.loading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: ChartColors.primary),
                  const SizedBox(height: 16),
                  Text(
                    l10n.materialsTrendLoading,
                    style: const TextStyle(
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state.status == MaterialsTrendStatus.failure) {
            return Center(
              child: Text(
                l10n.materialsTrendError(
                  state.errorMessage ?? l10n.homeUnexpectedError,
                ),
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final bool isAllEmpty =
              state.ironTrend.values.every((v) => v == 0) &&
              state.cementTrend.values.every((v) => v == 0);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.indigo.shade50),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.troubleshoot,
                          color: Colors.indigo.shade700,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.materialsTrendHeaderTitle,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: ChartColors.titleColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              l10n.materialsTrendHeaderDesc,
                              style: const TextStyle(
                                fontSize: 13,
                                color: ChartColors.axisLabel,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                SectionHeader(
                  periodLabel: _getPeriodLabel(context, state),
                  timeFilter: state.timeFilter,
                  onPrevious: context
                      .read<MaterialsTrendCubit>()
                      .navigatePrevious,
                  onNext: context.read<MaterialsTrendCubit>().navigateNext,
                  onFilterChanged: context
                      .read<MaterialsTrendCubit>()
                      .changeTimeFilter,
                ),

                const SizedBox(height: 24),

                if (isAllEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 60.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.auto_graph_rounded,
                            size: 80,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.materialsTrendEmptyTitle,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.materialsTrendEmptyDesc,
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 1000
                          ? 3
                          : (constraints.maxWidth > 650 ? 2 : 1);
                      final double width = constraints.maxWidth;
                      final itemWidth =
                          (width - (16 * (crossAxisCount - 1))) /
                          crossAxisCount;

                      return Wrap(
                        spacing: 16,
                        runSpacing: 24,
                        children: [
                          SizedBox(
                            width: itemWidth,
                            child: TrendLineChart(
                              title: l10n.materialsTrendIronTitle,
                              description: l10n.materialsTrendIronDesc,
                              data: state.ironTrend,
                              color: Colors.blueGrey.shade800,
                              icon: Icons.hardware,
                              peakLabel: l10n.materialsTrendPeakPrice,
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: TrendLineChart(
                              title: l10n.materialsTrendCementTitle,
                              description: l10n.materialsTrendCementDesc,
                              data: state.cementTrend,
                              color: Colors.brown.shade600,
                              icon: Icons.foundation,
                              peakLabel: l10n.materialsTrendPeakPrice,
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: TrendLineChart(
                              title: l10n.materialsTrendBlockTitle,
                              description: l10n.materialsTrendBlockDesc,
                              data: state.blockTrend,
                              color: Colors.teal.shade600,
                              icon: Icons.view_in_ar,
                              peakLabel: l10n.materialsTrendPeakPrice,
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: TrendLineChart(
                              title: l10n.materialsTrendFormworkTitle,
                              description: l10n.materialsTrendFormworkDesc,
                              data: state.formworkTrend,
                              color: Colors.indigo.shade500,
                              icon: Icons.architecture,
                              peakLabel: l10n.materialsTrendPeakWage,
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: TrendLineChart(
                              title: l10n.materialsTrendAggregatesTitle,
                              description: l10n.materialsTrendAggregatesDesc,
                              data: state.aggregatesTrend,
                              color: Colors.amber.shade700,
                              icon: Icons.landslide,
                              peakLabel: l10n.materialsTrendPeakPrice,
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: TrendLineChart(
                              title: l10n.materialsTrendWorkerTitle,
                              description: l10n.materialsTrendWorkerDesc,
                              data: state.workerTrend,
                              color: Colors.deepOrange.shade600,
                              icon: Icons.engineering,
                              peakLabel: l10n.materialsTrendPeakWage,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
