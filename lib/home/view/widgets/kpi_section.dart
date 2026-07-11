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
        gradient: const LinearGradient(
          colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
        ),
        title: 'السيولة النقدية (الصافي)',
        value: '${numberFormatter.format(state.totalRevenue.toInt())} ل.س',
        subtitle: 'إجمالي أموال الصندوق الحقيقية',
        iconBg: const Color(0xFF11998e),
      ),
      _KpiData(
        icon: Icons.money_off_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFFcb2d3e), Color(0xFFef473a)],
        ),
        title: 'الأموال المستردة (سحوبات)',
        value:
            '${numberFormatter.format(state.totalRefundedAmount.toInt())} ل.س',
        subtitle: 'إجمالي المبالغ الخارجة من الصندوق',
        iconBg: const Color(0xFFcb2d3e),
        infoDetails:
            'يمثل هذا الرقم إجمالي المبالغ التي تم دفعها من الصندوق (Cash Outflow) كاستردادات للعملاء المنسحبين، أو كقيود عكسية وتسويات محاسبية.',
      ),
      _KpiData(
        icon: Icons.hourglass_bottom_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFFf5af19), Color(0xFFf12711)],
        ),
        title: 'ديون جارية (قيد الإنشاء)',
        value:
            '${numberFormatter.format(state.overduePreHandover.toInt())} ل.س',
        subtitle: 'أقساط متأخرة على شقق لم تُسلّم',
        iconBg: const Color(0xFFf5af19),
        infoDetails:
            'يمثل الأقساط الشهرية المتأخرة على الزبائن الذين اشتروا شققاً مخصصة، ولكن شققهم لا تزال تحت الإعمار ولم يستلموها بعد. (لا يُطبق عليها غرامات).',
      ),
      _KpiData(
        icon: Icons.warning_amber_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFFe53935), Color(0xFFe35d5b)],
        ),
        title: 'ذمم مستحقة (شقق مُسلّمة)',
        value:
            '${numberFormatter.format(state.overduePostHandover.toInt())} ل.س',
        subtitle: 'ديون عقارات تم تسليم مفاتيحها',
        iconBg: const Color(0xFFe53935),
        infoDetails:
            'يمثل المبالغ المتأخرة على الزبائن الذين أتمت الشركة بناء شققهم وسلمتهم المفاتيح. يُعامل هذا الرقم بجدية ويُطبق عليه غرامات تأخير آلياً.',
      ),
      _KpiData(
        icon: Icons.vpn_key_outlined,
        gradient: const LinearGradient(
          colors: [Color(0xFF00695C), Color(0xFF00897B)],
        ),
        title: 'الوحدات المتاحة للبيع',
        value: numberFormatter.format(state.inventoryStatus['متاحة'] ?? 0),
        subtitle: 'شقق ومحلات جاهزة للتعاقد',
        iconBg: const Color(0xFF00695C),
        infoDetails:
            'يعرض عدد الوحدات العقارية (شقق/محلات) المُسجلة في كتالوج المحاضر والتي لم يتم ربطها بأي عقد مبيع حتى الآن.',
      ),
      _KpiData(
        icon: Icons.description_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFF7b4397), Color(0xFFdc2430)],
        ),
        title: 'العقود الفعّالة',
        value: numberFormatter.format(state.activeContractsCount),
        subtitle: 'إجمالي العقود الجارية المبرمة',
        iconBg: const Color(0xFF7b4397),
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        var crossAxisCount = 2;
        if (constraints.maxWidth >= 1200) {
          crossAxisCount = 6;
        } else if (constraints.maxWidth >= 800) {
          crossAxisCount = 3;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: constraints.maxWidth >= 1200 ? 1.4 : 1.6,
          ),
          itemCount: kpis.length,
          itemBuilder: (context, index) => _KpiCard(data: kpis[index]),
        );
      },
    );
  }
}

class _KpiData {
  const _KpiData({
    required this.icon,
    required this.gradient,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.iconBg,
    this.infoDetails,
  });
  final IconData icon;
  final LinearGradient gradient;
  final String title;
  final String value;
  final String subtitle;
  final Color iconBg;
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
            const Icon(
              Icons.analytics_outlined,
              color: Colors.indigo,
              size: 28,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'المنطق المالي لـ: ${data.title}',
                style: const TextStyle(
                  color: Colors.indigo,
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
              backgroundColor: Colors.indigo,
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
        gradient: data.gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: data.iconBg.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
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
                            child: const Icon(
                              Icons.info_outline,
                              color: Colors.white70,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(data.icon, color: Colors.white, size: 20),
                ),
              ],
            ),
            Text(
              data.value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              data.subtitle,
              style: const TextStyle(
                color: Colors.white60,
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
