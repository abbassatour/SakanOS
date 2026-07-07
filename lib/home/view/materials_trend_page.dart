// lib/home/view/materials_trend_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:intl/intl.dart';

// 🌟 استدعاء الـ Cubit الخاص بالصفحة والفلتر الزمني
import '../cubit/home_cubit.dart'; // لغايات TimeFilter
import '../cubit/materials_trend/materials_trend_cubit.dart';

// 🌟 استيراد المخططات والمكونات
import 'widgets/charts/trend_line_chart.dart';
import 'widgets/charts/chart_colors.dart';
import 'widgets/charts/section_header.dart';

class MaterialsTrendPage extends StatelessWidget {
  const MaterialsTrendPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 🌟 حقن الكيوبت الخاص بالصفحة بمجرد فتحها لتكون مستقلة تماماً
    return BlocProvider(
      create: (context) =>
          MaterialsTrendCubit(context.read<ErpRepository>())..fetchData(),
      child: const _MaterialsTrendView(),
    );
  }
}

class _MaterialsTrendView extends StatelessWidget {
  const _MaterialsTrendView();

  // 🌟 دالة مساعدة لتوليد عنوان الفترة الزمنية بذكاء
  String _getPeriodLabel(MaterialsTrendState state) {
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
    return Scaffold(
      backgroundColor: const Color(
        0xFFF4F6FA,
      ), // خلفية رمادية مزرقة مريحة للعين
      appBar: AppBar(
        backgroundColor: ChartColors.primary,
        title: const Text(
          'غرفة التحليل المالي والتسعير',
          style: TextStyle(
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
          // 1. حالة التحميل
          if (state.status == MaterialsTrendStatus.loading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: ChartColors.primary),
                  SizedBox(height: 16),
                  Text(
                    'جاري معالجة السجلات التاريخية...',
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }

          // 2. حالة الخطأ
          if (state.status == MaterialsTrendStatus.failure) {
            return Center(
              child: Text(
                'خطأ في النظام: ${state.errorMessage}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          // 🌟 3. التحقق الاحترافي من خلو البيانات في الفترة الزمنية المحددة
          final bool isAllEmpty =
              state.ironTrend.values.every((v) => v == 0) &&
              state.cementTrend.values.every((v) => v == 0);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==========================================
                // 📝 الترويسة التعريفية
                // ==========================================
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
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'تحليل مكونات التكلفة الخام (Raw Material Analytics)',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: ChartColors.titleColor,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'تتبع التغيرات التاريخية لكل مادة بشكل مستقل. استخدم شريط الزمن أدناه لمعرفة المسبب الحقيقي لتضخم تكاليف البناء في أي فترة.',
                              style: TextStyle(
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

                // ==========================================
                // ⏱️ شريط الفلترة الزمنية التفاعلي
                // ==========================================
                SectionHeader(
                  periodLabel: _getPeriodLabel(state),
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

                // ==========================================
                // 🚫 عرض الحالة الفارغة (إن وجدت)
                // ==========================================
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
                            'لا توجد بيانات مسجلة لأسعار المواد في هذه الفترة.',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'قم بتغيير الفلتر الزمني أو العودة لفترة سابقة.',
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
                  // ==========================================
                  // 📊 شبكة المخططات التفصيلية (Grid Layout)
                  // ==========================================
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // 🌟 استجابة ذكية لحجم الشاشة (شاشات الكمبيوتر/التابلت/الهاتف)
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
                              title: 'تطور سعر الحديد (كغ)',
                              description:
                                  'يعرض التغير الزمني لمتوسط سعر الكيلوغرام الواحد من الحديد المبروم.',
                              data: state.ironTrend,
                              color: Colors.blueGrey.shade800,
                              icon: Icons.hardware,
                              peakLabel: 'أعلى سعر سُجل:',
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: TrendLineChart(
                              title: 'تطور سعر الإسمنت (كيس)',
                              description:
                                  'يعرض التغير الزمني لمتوسط سعر كيس الإسمنت البورتلاندي.',
                              data: state.cementTrend,
                              color: Colors.brown.shade600,
                              icon: Icons.foundation,
                              peakLabel: 'أعلى سعر سُجل:',
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: TrendLineChart(
                              title: 'تطور سعر البلوك 15',
                              description:
                                  'يعرض التغير الزمني لمتوسط سعر البلوكة الواحدة سماكة 15 سم.',
                              data: state.blockTrend,
                              color: Colors.teal.shade600,
                              icon: Icons.view_in_ar,
                              peakLabel: 'أعلى سعر سُجل:',
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: TrendLineChart(
                              title: 'أجور الكوفراج والصب (م³)',
                              description:
                                  'يعرض التغير الزمني لمتوسط تكلفة الكوفراج وصب المتر المكعب الواحد.',
                              data: state.formworkTrend,
                              color: Colors.indigo.shade500,
                              icon: Icons.architecture,
                              peakLabel: 'أعلى أجر سُجل:',
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: TrendLineChart(
                              title: 'سعر الحصويات (م³)',
                              description:
                                  'يعرض التغير الزمني لمتوسط سعر المتر المكعب من الرمل والبحص (المواد الحصوية).',
                              data: state.aggregatesTrend,
                              color: Colors.amber.shade700,
                              icon: Icons.landslide,
                              peakLabel: 'أعلى سعر سُجل:',
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: TrendLineChart(
                              title: 'تطور أجرة العامل (يومية)',
                              description:
                                  'يعرض التغير الزمني لمتوسط يومية العامل العادي.',
                              data: state.workerTrend,
                              color: Colors.deepOrange.shade600,
                              icon: Icons.engineering,
                              peakLabel: 'أعلى أجر سُجل:',
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
