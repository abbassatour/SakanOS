//lib\schedule\view\tabs\widgets\traditional\schedule_stats_ribbon.dart
import 'package:flutter/material.dart';

class ScheduleStatsRibbon extends StatelessWidget {
  final int totalInstallments;
  final int paidInstallments;
  final int pendingInstallments;
  final int overdueInstallments;
  final bool
  isPostAllocation; // لم نعد نحتاجها كشرط، لكن سنبقيها كي لا ينكسر الكود القديم
  final String formattedAgreedAmount;
  final double metersPerInstallment;

  const ScheduleStatsRibbon({
    super.key,
    required this.totalInstallments,
    required this.paidInstallments,
    required this.pendingInstallments,
    required this.overdueInstallments,
    required this.isPostAllocation,
    required this.formattedAgreedAmount,
    required this.metersPerInstallment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 24,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // 🌟 توحيد المصطلحات لتناسب المدة المفتوحة
                _buildDesktopStatItem(
                  'الأشهر المُسجلة',
                  totalInstallments.toString(),
                  Colors.indigo,
                ),
                _buildDesktopStatItem(
                  'تم السداد',
                  paidInstallments.toString(),
                  Colors.green,
                ),
                _buildDesktopStatItem(
                  'الاستحقاق القادم',
                  pendingInstallments.toString(),
                  Colors.orange,
                ),
                _buildDesktopStatItem(
                  'أشهر متأخرة',
                  overdueInstallments.toString(),
                  Colors.red,
                  isAlert: overdueInstallments > 0,
                ),
                // 🌟 عرض المبلغ الشهري لجميع العقود
                _buildDesktopStatItem(
                  'المطلوب شهرياً',
                  '$formattedAgreedAmount ل.س',
                  Colors.teal,
                ),
              ],
            ),
          ),
          Container(
            height: 20,
            width: 1,
            color: Colors.grey.shade300,
            margin: const EdgeInsets.symmetric(horizontal: 12),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLegendItem(Colors.green, 'مُسدد'),
              const SizedBox(width: 12),
              _buildLegendItem(Colors.orange, 'معلق'),
              const SizedBox(width: 12),
              _buildLegendItem(Colors.red, 'متأخر'),
              const SizedBox(width: 12),
              _buildLegendItem(Colors.grey.shade800, 'ضائع'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopStatItem(
    String title,
    String value,
    Color color, {
    bool isAlert = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$title: ',
          style: const TextStyle(
            color: Colors.blueGrey,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: isAlert
                ? Border.all(color: Colors.red.withOpacity(0.5))
                : null,
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
