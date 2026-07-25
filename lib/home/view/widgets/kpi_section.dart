// lib/home/view/widgets/kpi_section.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:our_home_erp_app/home/cubit/home_cubit.dart';

class KpiSection extends StatelessWidget {
  const KpiSection({required this.state, super.key});
  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final numberFormatter = NumberFormat.decimalPattern('ar_AR');

    final kpis = [
      _KpiData(
        icon: Icons.account_balance_wallet_rounded,
        mainColor: Colors.teal.shade600, // لون يعبر عن النقد
        title: 'السيولة النقدية (الصافي)',
        value: '${numberFormatter.format(state.totalRevenue.toInt())} ل.س',
        subtitle: 'إجمالي أموال الصندوق الحقيقية',
      ),
      _KpiData(
        icon: Icons.money_off_rounded,
        mainColor: Colors.red.shade600, // أحمر للمسحوبات
        title: 'الأموال المستردة (سحوبات)',
        value:
            '${numberFormatter.format(state.totalRefundedAmount.toInt())} ل.س',
        subtitle: 'إجمالي المبالغ الخارجة من الصندوق',
        infoDetails:
            'يمثل هذا الرقم إجمالي المبالغ التي تم دفعها من الصندوق (Cash Outflow) كاستردادات للعملاء المنسحبين، أو كقيود عكسية وتسويات محاسبية.',
      ),
      _KpiData(
        icon: Icons.hourglass_bottom_rounded,
        mainColor: Colors.orange.shade600, // برتقالي للديون الجارية
        title: 'ديون جارية (قيد الإنشاء)',
        value:
            '${numberFormatter.format(state.overduePreHandover.toInt())} ل.س',
        subtitle: 'أقساط متأخرة على شقق لم تُسلّم',
        infoDetails:
            'يمثل الأقساط الشهرية المتأخرة على الزبائن الذين اشتروا شققاً مخصصة، ولكن شققهم لا تزال تحت الإعمار ولم يستلموها بعد. (لا يُطبق عليها غرامات).',
      ),
      _KpiData(
        icon: Icons.warning_amber_rounded,
        mainColor: Colors.red.shade800, // أحمر داكن للذمم المستحقة الخطرة
        title: 'ذمم مستحقة (شقق مُسلّمة)',
        value:
            '${numberFormatter.format(state.overduePostHandover.toInt())} ل.س',
        subtitle: 'ديون عقارات تم تسليم مفاتيحها',
        infoDetails:
            'يمثل المبالغ المتأخرة على الزبائن الذين أتمت المكتب بناء شققهم وسلمتهم المفاتيح. يُعامل هذا الرقم بجدية ويُطبق عليه غرامات تأخير آلياً.',
      ),
      _KpiData(
        icon: Icons.vpn_key_outlined,
        mainColor: Colors.blue.shade600, // أزرق للوحدات المتاحة
        title: 'الوحدات المتاحة للبيع',
        value: numberFormatter.format(state.inventoryStatus['متاحة'] ?? 0),
        subtitle: 'شقق ومحلات جاهزة للتعاقد',
        infoDetails:
            'يعرض عدد الوحدات العقارية (شقق/محلات) المُسجلة في كتالوج المحاضر والتي لم يتم ربطها بأي عقد مبيع حتى الآن.',
      ),
      _KpiData(
        icon: Icons.description_rounded,
        mainColor: Colors.purple.shade600, // بنفسجي للعقود
        title: 'العقود الفعّالة',
        value: numberFormatter.format(state.activeContractsCount),
        subtitle: 'إجمالي العقود الجارية المبرمة',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        if (constraints.maxWidth >= 1300) {
          crossAxisCount = 6;
        } else if (constraints.maxWidth >= 900) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth >= 550) {
          crossAxisCount = 2;
        } else {
          crossAxisCount = 1;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 135,
          ),
          itemCount: kpis.length,
          itemBuilder: (context, index) => _KpiCard(data: kpis[index]),
        );
      },
    );
  }
}

// 🌟 تعديل الكلاس ليقبل لوناً رئيسياً بدلاً من التدرج
class _KpiData {
  const _KpiData({
    required this.icon,
    required this.mainColor,
    required this.title,
    required this.value,
    required this.subtitle,
    this.infoDetails,
  });
  final IconData icon;
  final Color mainColor;
  final String title;
  final String value;
  final String subtitle;
  final String? infoDetails;
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.data});
  final _KpiData data;

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.analytics_outlined,
              color: Colors.blue.shade700,
              size: 28,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'المنطق المالي لـ: ${data.title}',
                style: TextStyle(
                  color: Colors.blue.shade900,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          data.infoDetails!,
          style: const TextStyle(
            height: 1.6,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('مفهوم إداريّاً'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // 🌟 خلفية بيضاء
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.lightBlue.shade100, // 🌟 حدود زرقاء فاتحة كما طلبت
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade900.withOpacity(0.04), // ظل أزرق خفيف جداً
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          data.title,
                          style: TextStyle(
                            color: Colors
                                .blueGrey
                                .shade600, // 🌟 نص رمادي مزرق للعنوان
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (data.infoDetails != null) ...[
                        const SizedBox(width: 6),
                        Tooltip(
                          message: 'انقر لمعرفة المفهوم المالي لمتخذ القرار',
                          child: InkWell(
                            onTap: () => _showInfoDialog(context),
                            borderRadius: BorderRadius.circular(12),
                            child: Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade300,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // 🌟 الأيقونة أصبحت بخلفية شفافة بلون الدلالة (أحمر، أخضر، الخ)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: data.mainColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(data.icon, color: data.mainColor, size: 20),
                ),
              ],
            ),
            Text(
              data.value,
              style: TextStyle(
                color:
                    Colors.blue.shade900, // 🌟 الرقم بلون أزرق داكن ليبرز بوضوح
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              data.subtitle,
              style: TextStyle(
                color: Colors.grey.shade500, // 🌟 نص فاتح للوصف الفرعي
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
