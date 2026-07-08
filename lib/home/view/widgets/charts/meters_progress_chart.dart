// lib/home/view/widgets/charts/meters_progress_chart.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'chart_shared_widgets.dart';

class MetersProgressChart extends StatelessWidget {
  final double totalSold;
  final double paid;
  final double unpaid;
  final double undelivered;

  const MetersProgressChart({
    super.key,
    required this.totalSold,
    required this.paid,
    required this.unpaid,
    required this.undelivered,
  });

  @override
  Widget build(BuildContext context) {
    final numberFormatter = NumberFormat.decimalPattern('ar_AR');

    // حساب النسب وحمايتها من قسمة الصفر
    final double paidPct = totalSold == 0
        ? 0
        : (paid / totalSold).clamp(0.0, 1.0);
    final double unpaidPct = totalSold == 0
        ? 0
        : (unpaid / totalSold).clamp(0.0, 1.0);
    final double undeliveredPct = totalSold == 0
        ? 0
        : (undelivered / totalSold).clamp(0.0, 1.0);

    return ChartCard(
      title: 'مؤشر أداء الأمتار المربعة',
      // 🌟 التعديل هنا: النص الجديد المفصل والواضح للإدارة
      description:
          'هذا المؤشر يمثل العصب المالي والتشغيلي للشركة، حيث يراقب حركة الأمتار بدقة:\n\n'
          '🟢 الأمتار المحصلة (في الصندوق):\n'
          'إجمالي الأمتار التي دخل ثمنها الفعلي إلى الصندوق من جميع الإيصالات، وتشمل (الشقق المخصصة) و(المحافظ الاستثمارية).\n\n'
          '🟠 ذمة العملاء (الديون):\n'
          'هي الأمتار المباعة بعقود (مخصصة) ولم يُسدد ثمنها بعد.\n'
          '*ملاحظة محاسبية: عقود "المحافظ الاستثمارية" لا تُولّد ديوناً في هذا المؤشر، لأن العميل يمتلك فقط الأسهم التي دفع ثمنها، لذا فهي تتعادل آلياً.\n\n'
          '🔴 الالتزام الإنشائي:\n'
          'إجمالي مساحات الشقق التي تم التعاقد عليها (مُباعة) وما زالت قيد الإنشاء ولم تُسلّم للعملاء حتى الآن.',
      titleIcon: Icons.square_foot_rounded,
      iconColor: Colors.deepOrange.shade600,
      chart: Column(
        children: [
          // 1. الأمتار المحصلة
          _buildProgressRow(
            title: 'الأمتار المحصلة مالياً (في الصندوق)',
            value: '${numberFormatter.format(paid.toInt())} م²',
            percentage: paidPct,
            color: Colors.green.shade500,
            icon: Icons.monetization_on_rounded,
          ),
          const SizedBox(height: 20),

          // 2. ذمم الشركة
          _buildProgressRow(
            title: 'الأمتار في ذمة العملاء (ديون)',
            value: '${numberFormatter.format(unpaid.toInt())} م²',
            percentage: unpaidPct,
            color: Colors.orange.shade600,
            icon: Icons.money_off_csred_rounded,
          ),
          const SizedBox(height: 20),

          // 3. الأمتار غير المسلمة
          _buildProgressRow(
            title: 'الالتزام الإنشائي (أمتار لم تُسلّم)',
            value: '${numberFormatter.format(undelivered.toInt())} م²',
            percentage: undeliveredPct,
            color: Colors.red.shade600,
            icon: Icons.engineering_rounded,
          ),
        ],
      ),
      footerRows: [
        FooterRow(
          icon: Icons.architecture,
          iconColor: Colors.indigo,
          label: 'إجمالي الأمتار المباعة كمرجع:',
          value: '${numberFormatter.format(totalSold.toInt())} م²',
        ),
      ],
    );
  }

  // 🌟 دالة رسم شريط التقدم الأنيق
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
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade800,
                  ),
                ),
              ],
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 10,
              width: double.infinity,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutCubic,
                  height: 10,
                  width: constraints.maxWidth * percentage,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
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
}
