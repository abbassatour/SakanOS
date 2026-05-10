// lib/home/view/widgets/charts_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../cubit/home_cubit.dart';

// استيراد المكونات
import 'charts/chart_colors.dart';
import 'charts/chart_shared_widgets.dart';
import 'charts/section_header.dart';
import 'charts/revenue_chart.dart';
import 'charts/trend_line_chart.dart';
import 'charts/contracts_pie_chart.dart';
// 🌟 استيراد المخططات الجديدة
import 'charts/inventory_pie_chart.dart';
import 'charts/meters_progress_chart.dart';

class ChartsSection extends StatelessWidget {
  final HomeState state;
  const ChartsSection({super.key, required this.state});

  String _getPeriodLabel() {
    final ref = state.referenceDate;
    switch (state.timeFilter) {
      case TimeFilter.daily:
        final start = ref.subtract(const Duration(days: 6));
        return '${DateFormat('MM/dd').format(start)} – ${DateFormat('MM/dd').format(ref)}';
      case TimeFilter.weekly:
        return 'أسابيع: ${DateFormat('MMM yyyy', 'ar').format(ref)}';
      case TimeFilter.monthly:
        return 'أشهر عام ${ref.year}';
      case TimeFilter.yearly:
        return '${ref.year - 4} – ${ref.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HomeCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:[
        SectionHeader(
          periodLabel: _getPeriodLabel(),
          timeFilter: state.timeFilter,
          onPrevious: cubit.navigatePrevious,
          onNext: cubit.navigateNext,
          onFilterChanged: cubit.changeTimeFilter,
        ),
        const SizedBox(height: 24),

        // 🌟 الصف الأول (أموال وأسعار)
        ChartRow(children:[
          Expanded(
            flex: 2,
            child: RevenueChart(
              title: 'التدفق النقدي والتحصيل',
              description: 'يعرض إجمالي الأموال الفعلية التي دخلت الصندوق في كل فترة. يتم حسابه بناءً على (تاريخ الدفع) في إيصالات الزبائن.',
              data: state.groupedRevenue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: TrendLineChart(
              title: 'تطور متوسط سعر المبيع',
              description: 'يوضح تغير متوسط سعر بيع المتر المربع عبر الزمن.',
              data: state.priceTrend,
              color: ChartColors.orange,
              icon: Icons.trending_up_rounded,
              peakLabel: 'أعلى فترة سعراً:',
            ),
          ),
        ]),
        const SizedBox(height: 16),

        // 🌟 الصف الثاني (محافظ وتكاليف)
        ChartRow(children:[
          Expanded(
            flex: 1,
            child: ContractsPieChart(
              title: 'محفظة العقود حسب النوع',
              description: 'يعرض التوزيع العددي والنسبي لأنواع العقود الموقعة.',
              data: state.contractsByType,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: TrendLineChart(
              title: 'تطور التكلفة الخام للمواد',
              description: 'يتتبع التغير في تكلفة بناء المتر المربع باستخدام المعادلة الهندسية. يعكس التكلفة المباشرة (الخام).',
              data: state.costTrend,
              color: ChartColors.red,
              icon: Icons.warning_amber_rounded,
              peakLabel: 'أعلى فترة تكلفةً:',
              isCost: true,
              // ==========================================
              // 🌟 [الربط الجديد]: زر الانتقال لصفحة التفاصيل
              // ==========================================
              actionIcon: Icons.analytics_outlined,
              actionTooltip: 'تحليل تفصيلي لأسعار المواد الستة',
              onActionTap: () {
                // سنقوم ببرمجة الصفحة التفصيلية في الخطوة القادمة
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('قريباً: فتح صفحة التحليل التفصيلي للمواد...'), 
                    backgroundColor: Colors.indigo
              },
            ),
          ),
        ]),
        
        const SizedBox(height: 16),

        // ==========================================
        // 🌟 الصف الثالث الجديد (الموقف التشغيلي والأمتار)
        // ==========================================
        ChartRow(children:[
          Expanded(
            flex: 1,
            child: InventoryPieChart(
              data: state.inventoryStatus,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2, // أعطينا الأمتار مساحة أكبر لأنها أشرطة أفقية
            child: MetersProgressChart(
              totalSold: state.totalAreaSold,
              paid: state.totalPaidMeters,
              unpaid: state.remainingMetersInDebt,
              undelivered: state.totalUndeliveredMeters,
            ),
          ),
        ]),
      ],
    );
  }
}