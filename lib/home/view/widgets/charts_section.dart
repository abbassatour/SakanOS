// lib/home/view/widgets/charts_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../cubit/home_cubit.dart';

// استيراد المكونات المقسمة
import 'charts/chart_colors.dart';
import 'charts/chart_shared_widgets.dart';
import 'charts/section_header.dart';
import 'charts/revenue_chart.dart';
import 'charts/trend_line_chart.dart';
import 'charts/contracts_pie_chart.dart';

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

        ChartRow(children:[
          Expanded(
            flex: 2,
            child: RevenueChart(
              title: 'التدفق النقدي والتحصيل',
              // 🌟 مررنا الشرح هنا
              description: 'يعرض إجمالي الأموال الفعلية التي دخلت الصندوق في كل فترة. يتم حسابه بناءً على (تاريخ الدفع) في إيصالات الزبائن، ولا يعتمد على تاريخ العقد. يساعد في معرفة السيولة المتاحة.',
              data: state.groupedRevenue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: TrendLineChart(
              title: 'تطور متوسط سعر المبيع',
              // 🌟 مررنا الشرح هنا
              description: 'يوضح تغير متوسط سعر بيع المتر المربع عبر الزمن. يتم حسابه بجمع أسعار المتر الموقعة مقسوماً على عدد العقود. يعكس حركة المبيعات وتأثرها بالسوق.',
              data: state.priceTrend,
              color: ChartColors.orange,
              icon: Icons.trending_up_rounded,
              peakLabel: 'أعلى فترة سعراً:',
            ),
          ),
        ]),
        const SizedBox(height: 16),

        ChartRow(children:[
          Expanded(
            flex: 1,
            child: ContractsPieChart(
              title: 'محفظة العقود حسب النوع',
              // 🌟 مررنا الشرح هنا
              description: 'يعرض التوزيع العددي والنسبي لأنواع العقود الموقعة. يساعد الإدارة في معرفة أكثر المنتجات العقارية مبيعاً وتوجهات العملاء.',
              data: state.contractsByType,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: TrendLineChart(
              title: 'تطور سعر المتر لاحق التخصص',
              // 🌟 مررنا الشرح هنا
              description: 'يتتبع التغير في تكلفة بناء  المتر المربع اللحاق التخصص باستخدام المعادلة الهندسية (أسمنت، حديد، بلوك...). يعكس التكلفة المباشرة (الخام) ولا يشمل ربح الشركة أو معاملات التميز.',
              data: state.costTrend,
              color: ChartColors.red,
              icon: Icons.warning_amber_rounded,
              peakLabel: 'أعلى فترة تكلفةً:',
              isCost: true,
            ),
          ),
        ]),
      ],
    );
  }
}