// lib/home/view/materials_trend_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart' show MaterialPricesHistoryData;

// استيراد المخططات التي بنيناها سابقاً
import 'widgets/charts/trend_line_chart.dart';
import 'widgets/charts/chart_colors.dart';

class MaterialsTrendPage extends StatefulWidget {
  const MaterialsTrendPage({super.key});

  @override
  State<MaterialsTrendPage> createState() => _MaterialsTrendPageState();
}

class _MaterialsTrendPageState extends State<MaterialsTrendPage> {
  bool _isLoading = true;
  List<MaterialPricesHistoryData> _prices =[];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // 🌟 سحب البيانات التاريخية من المستودع مباشرة
  Future<void> _fetchData() async {
    try {
      final repo = context.read<ErpRepository>();
      final data = await repo.getAllMaterialPricesHistory();
      
      // ترتيب زمني تصاعدي (من الأقدم للأحدث) لكي يرسم المخطط بشكل صحيح
      final activeData = data.where((p) => p.isDeleted == false).toList();
      activeData.sort((a, b) => a.effectiveDate.compareTo(b.effectiveDate));
      
      setState(() {
        _prices = activeData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فشل جلب البيانات'), backgroundColor: Colors.red));
      }
    }
  }

  // 🌟 خوارزمية ذكية لتجميع الأسعار حسب (السنة-الشهر) وأخذ المتوسط
  Map<String, double> _buildTrendData(double Function(MaterialPricesHistoryData) selector) {
    if (_prices.isEmpty) return {};

    Map<String, List<double>> grouped = {};
    for (var p in _prices) {
      // تنسيق المفتاح (مثال: 2026-05)
      String key = "${p.effectiveDate.year}-${p.effectiveDate.month.toString().padLeft(2, '0')}";
      if (!grouped.containsKey(key)) grouped[key] = [];
      grouped[key]!.add(selector(p));
    }

    Map<String, double> result = {};
    grouped.forEach((key, list) {
      // حساب المتوسط لذلك الشهر
      result[key] = list.fold(0.0, (a, b) => a + b) / list.length; 
    });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: ChartColors.primary,
        title: const Text('التحليل التفصيلي لأسعار المواد', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: ChartColors.primary))
        : _prices.isEmpty 
            ? _buildEmptyState() 
            : _buildDashboard(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children:[
          Icon(Icons.query_stats, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('لا يوجد سجل تاريخي لأسعار المواد بعد.', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    // 🌟 استخراج الخرائط (Trends) لكل مادة على حدة
    final ironData = _buildTrendData((p) => p.ironPrice);
    final cementData = _buildTrendData((p) => p.cementPrice);
    final blockData = _buildTrendData((p) => p.block15Price);
    final formworkData = _buildTrendData((p) => p.formworkAndPouringWages);
    final aggregatesData = _buildTrendData((p) => p.aggregateMaterialsPrice);
    final workerData = _buildTrendData((p) => p.ordinaryWorkerWage);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
          const Text(
            'تحليل مكونات التكلفة الخام',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: ChartColors.titleColor),
          ),
          const SizedBox(height: 8),
          const Text(
            'تتبع التغيرات التاريخية لكل مادة بشكل مستقل لمعرفة المسبب الحقيقي لتضخم تكاليف البناء.',
            style: TextStyle(fontSize: 14, color: ChartColors.axisLabel),
          ),
          const SizedBox(height: 24),

          // ==========================================
          // 📊 شبكة المخططات التفصيلية
          // ==========================================
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
              final double width = constraints.maxWidth;
              // تعديل العرض بناءً على عدد الأعمدة
              final itemWidth = (width - (16 * (crossAxisCount - 1))) / crossAxisCount;

              return Wrap(
                spacing: 16,
                runSpacing: 24,
                children:[
                  SizedBox(
                    width: itemWidth,
                    child: TrendLineChart(
                      title: 'تطور سعر الحديد (كغ)',
                      description: 'يعرض التغير الشهري لمتوسط سعر الكيلوغرام الواحد من الحديد المبروم.',
                      data: ironData,
                      color: Colors.blueGrey.shade800,
                      icon: Icons.hardware,
                      peakLabel: 'أعلى سعر سُجل:',
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: TrendLineChart(
                      title: 'تطور سعر الإسمنت (كيس)',
                      description: 'يعرض التغير الشهري لمتوسط سعر كيس الإسمنت البورتلاندي.',
                      data: cementData,
                      color: Colors.brown.shade600,
                      icon: Icons.foundation,
                      peakLabel: 'أعلى سعر سُجل:',
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: TrendLineChart(
                      title: 'تطور سعر البلوك 15',
                      description: 'يعرض التغير الشهري لمتوسط سعر البلوكة الواحدة سماكة 15 سم.',
                      data: blockData,
                      color: Colors.teal.shade600,
                      icon: Icons.view_in_ar,
                      peakLabel: 'أعلى سعر سُجل:',
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: TrendLineChart(
                      title: 'أجور الكوفراج والصب (م³)',
                      description: 'يعرض التغير الشهري لمتوسط تكلفة الكوفراج وصب المتر المكعب الواحد.',
                      data: formworkData,
                      color: Colors.indigo.shade500,
                      icon: Icons.architecture,
                      peakLabel: 'أعلى أجر سُجل:',
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: TrendLineChart(
                      title: 'سعر الحصويات (م³)',
                      description: 'يعرض التغير الشهري لمتوسط سعر المتر المكعب من الرمل والبحص (المواد الحصوية).',
                      data: aggregatesData,
                      color: Colors.amber.shade700,
                      icon: Icons.landslide,
                      peakLabel: 'أعلى سعر سُجل:',
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: TrendLineChart(
                      title: 'تطور أجرة العامل (يومية)',
                      description: 'يعرض التغير الشهري لمتوسط يومية العامل العادي.',
                      data: workerData,
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
  }
}