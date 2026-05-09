// lib/home/view/widgets/charts/meters_progress_chart.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'chart_colors.dart';
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
    
    // نسب الإنجاز
    final double paidPct = totalSold == 0 ? 0 : (paid / totalSold).clamp(0.0, 1.0);
    final double unpaidPct = totalSold == 0 ? 0 : (unpaid / totalSold).clamp(0.0, 1.0);
    final double undeliveredPct = totalSold == 0 ? 0 : (undelivered / totalSold).clamp(0.0, 1.0);

    return ChartCard(
      title: 'مؤشر أداء الأمتار المربعة',
      description: 'هذا المؤشر هو العصب الحقيقي للشركة. \n- (الأمتار المحصلة): هي الأمتار التي دخل ثمنها للصندوق.\n- (ذمم الشركة): هي الأمتار المباعة والتي يجب سدادها من قبل العملاء.\n- (الالتزام الإنشائي): الأمتار التي تقع على عاتق الشركة ويجب بناؤها وتسليمها.',
      titleIcon: Icons.square_foot_rounded,
      iconColor: Colors.deepOrange.shade600,
      chart: Column(
        children:[
          // 1. الأمتار المحصلة مالياً
          _buildProgressRow(
            title: 'الأمتار المحصلة مالياً',
            value: '${numberFormatter.format(paid.toInt())} م²',
            percentage: paidPct,
            color: Colors.green.shade500,
            icon: Icons.monetization_on_rounded,
          ),
          const SizedBox(height: 20),
          
          // 2. ذمم الشركة (أمتار لم تدفع)
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
            title: 'الالتزام الإنشائي (أمتار غير مُسلّمة)',
            value: '${numberFormatter.format(undelivered.toInt())} م²',
            percentage: undeliveredPct,
            color: Colors.red.shade600,
            icon: Icons.engineering_rounded,
          ),
        ],
      ),
      footerRows:[
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
    required String title, required String value, required double percentage, 
    required Color color, required IconData icon
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children:[
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade800)),
              ],
            ),
            Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children:[
            Container(
              height: 10,
              width: double.infinity,
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
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
                    boxShadow:[BoxShadow(color: color.withOpacity(0.4), blurRadius: 4, offset: const Offset(0, 2))],
                  ),
                );
              }
            ),
          ],
        ),
      ],
    );
  }
}