// lib/home/view/widgets/charts/meters_progress_chart.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'chart_shared_widgets.dart';

class MetersProgressChart extends StatelessWidget {
  final double totalSold;
  final double paid;
  final double unpaid;
  final double undelivered;

  // المعاملات المفرزة الجديدة لتطبيق دلالة الفصل المحاسبي
  final double allocatedSold;
  final double allocatedPaid;
  final double allocatedDebt;
  final double allocatedUndelivered;
  final double unallocatedPaid;

  const MetersProgressChart({
    super.key,
    this.totalSold = 0,
    this.paid = 0,
    this.unpaid = 0,
    this.undelivered = 0,
    required this.allocatedSold,
    required this.allocatedPaid,
    required this.allocatedDebt,
    required this.allocatedUndelivered,
    required this.unallocatedPaid,
  });

  @override
  Widget build(BuildContext context) {
    final numberFormatter = NumberFormat.decimalPattern('ar_AR');

    // حساب النسب لمحفظة الشقق المخصصة وحمايتها من القسمة على صفر
    final double allocatedPaidPct = allocatedSold == 0
        ? 0
        : (allocatedPaid / allocatedSold).clamp(0.0, 1.0);
    final double allocatedDebtPct = allocatedSold == 0
        ? 0
        : (allocatedDebt / allocatedSold).clamp(0.0, 1.0);
    final double allocatedUndeliveredPct = allocatedSold == 0
        ? 0
        : (allocatedUndelivered / allocatedSold).clamp(0.0, 1.0);

    return ChartCard(
      title: 'ميزان حركة الأمتار المربعة والمحفظة الاستثمارية',
      description:
          'هذا المؤشر يقوم بفصل الأمتار والأسهم المباعة في الشركة إلى مجموعتين مستقلتين تماماً لتسهيل المتابعة على متخذ القرار وجدولة أعمال الكسوة الإنشائية:\n\n'
          '🏢 1. محفظة الشقق المخصصة (حقوق الشركة وأصولها على زبائنها):\n'
          '• مساحات مخصصة مسددة: المساحات الفعلية للشقق التي سدد الملاك ثمنها ودخلت أموالاً في الصندوق لتمويل صب الأسقف والتشطيبات.\n'
          '• أمتار متبقية كديون: مساحات حجزها الزبائن في شققهم المحددة ولكنهم لم يسددوا ثمنها بعد (وتعتبر ديوناً على الزبائن لصالح الشركة).\n'
          '• التزام الإنشاء المخصص: المساحات الإنشائية للشقق قيد البناء والتجهيز حالياً ولم نسلمها بعد.\n\n'
          '📊 2. محفظة الأسهم لاحقة التخصص (التزامات الشركة وديونها العينية تجاه مستثمريها):\n'
          '• أمتار الأسهم واجبة البناء والتخصيص: هي أمتار مجردة (حصص استثمارية) اشتراها مستثمرو المحافظ ودفعوا ثمنها بالكامل كاش في الصندوق، وهي غير مخصصة لعقار محدد بعد، والشركة ملتزمة ببنائها وتخصيص شقق لهم مستقبلاً (وتعتبر التزاماً عينيّاً ودائناً على عاتق الشركة للغير).',
      titleIcon: Icons.balance_rounded,
      iconColor: Colors.teal.shade800,
      chart: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==========================================
          // 🏢 القسم الأول: الشقق المخصصة
          // ==========================================
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.apartment_rounded,
                  color: Colors.amber.shade800,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '1. محفظة التخصيص العيني (الشقق والمحلات المحددة للزبائن)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.amber.shade900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _buildProgressRow(
            title: 'أمتار مخصصة مسددة (في الصندوق)',
            value: '${numberFormatter.format(allocatedPaid.toInt())} m²',
            percentage: allocatedPaidPct,
            color: Colors.teal.shade600,
            icon: Icons.monetization_on_rounded,
          ),
          const SizedBox(height: 16),
          _buildProgressRow(
            title: 'أمتار بذمة العملاء (ديون عينية جارية على الملاك)',
            value: '${numberFormatter.format(allocatedDebt.toInt())} m²',
            percentage: allocatedDebtPct,
            color: Colors.orange.shade700,
            icon: Icons.badge_outlined,
          ),
          const SizedBox(height: 16),
          _buildProgressRow(
            title: 'التزام الإنشاء العيني (لم يكتمل تسليم الشقق)',
            value: '${numberFormatter.format(allocatedUndelivered.toInt())} m²',
            percentage: allocatedUndeliveredPct,
            color: Colors.purple.shade600,
            icon: Icons.construction_rounded,
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(color: Colors.black12, height: 1),
          ),

          // ==========================================
          // 📊 القسم الثاني: لاحق التخصص
          // ==========================================
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.savings_rounded,
                  color: Colors.blue.shade800,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '2. محفظة الأسهم لاحقة التخصص (التزامات الشركة للمستثمرين)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.blue.shade900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _buildStaticPortfolioRow(
            title: 'أمتار واجبة البناء والتخصيص للمستثمرين',
            value: '${numberFormatter.format(unallocatedPaid.toInt())} m²',
            color: Colors.blue.shade700,
            icon: Icons.pie_chart_rounded,
            subtitle: 'دين إنشائي عيني والتزام تم قبض ثمنه كاش للشركة',
          ),
        ],
      ),
      footerRows: [
        FooterRow(
          icon: Icons.architecture,
          iconColor: Colors.indigo,
          label: 'إجمالي مساحات الشقق المعروضة بالمشاريع كمرجع:',
          value: '${numberFormatter.format(allocatedSold.toInt())} m²',
        ),
      ],
    );
  }

  Widget _buildProgressRow({
    required String title,
    required String value,
    required double percentage,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutCubic,
                  height: 8,
                  width: constraints.maxWidth * percentage,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStaticPortfolioRow({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      color: color.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
