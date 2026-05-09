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

    final kpis =[
      // 1. الأرقام القديمة (التي تعمل لديك بامتياز)
      _KpiData(
        icon: Icons.account_balance_wallet_rounded,
        gradient: const LinearGradient(colors: [Color(0xFF11998e), Color(0xFF38ef7d)]),
        title: 'إجمالي المحصّل',
        value: '${numberFormatter.format(state.totalRevenue.toInt())} ل.س',
        subtitle: 'إجمالي المدفوعات المسجلة',
        iconBg: const Color(0xFF11998e),
      ),
      _KpiData(
        icon: Icons.square_foot_rounded,
        gradient: const LinearGradient(colors: [Color(0xFF1A237E), Color(0xFF3949AB)]),
        title: 'إجمالي المباع',
        value: '${numberFormatter.format(state.totalAreaSold)} م²',
        subtitle: 'المساحة الكلية للعقود',
        iconBg: const Color(0xFF1A237E),
      ),
      
      // ==========================================
      // 🌟 [الإضافات الجديدة]: البطاقات الإدارية الخطيرة
      // ==========================================
      _KpiData(
        icon: Icons.warning_amber_rounded,
        gradient: const LinearGradient(colors:[Color(0xFFe53935), Color(0xFFe35d5b)]), // أحمر تحذيري
        title: 'الديون المتأخرة الفورية',
        value: '${numberFormatter.format(state.totalOverdueDebts.toInt())} ل.س',
        subtitle: 'أقساط تجاوزت موعد الاستحقاق',
        iconBg: const Color(0xFFe53935),
      ),
      _KpiData(
        icon: Icons.construction_rounded,
        gradient: const LinearGradient(colors:[Color(0xFFf5af19), Color(0xFFf12711)]), // برتقالي تنبيهي
        title: 'الأمتار المتبقية ',
        value: '${numberFormatter.format(state.remainingMetersInDebt)} م²',
        subtitle: 'أمتار للشركة لم ي تم قبض ثمنها',
        iconBg: const Color(0xFFf5af19),
      ),
      // ==========================================

      // عودة للأرقام القديمة
      _KpiData(
        icon: Icons.trending_up_rounded,
        gradient: const LinearGradient(colors: [Color(0xFFf7971e), Color(0xFFffd200)]),
        title: 'متوسط سعر المتر',
        value: '${numberFormatter.format(state.averageSellPrice.toInt())} ل.س',
        subtitle: 'متوسط سعر البيع للمتر المربع',
        iconBg: const Color(0xFFf7971e),
      ),
      _KpiData(
        icon: Icons.description_rounded,
        gradient: const LinearGradient(colors:[Color(0xFF7b4397), Color(0xFFdc2430)]),
        title: 'العقود الفعّالة',
        value: numberFormatter.format(state.activeContractsCount),
        subtitle: 'إجمالي العقود المبرمة',
        iconBg: const Color(0xFF7b4397),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // ✅ شبكة تكيّفية: 2 عمود للصغير، 3 للوسط، 6 للكبير جداً
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
            childAspectRatio: constraints.maxWidth >= 1200 ? 1.4 : 1.6, // تعديل بسيط ليتناسب مع الشاشات العريضة
          ),
          itemCount: kpis.length,
          itemBuilder: (context, index) => _KpiCard(data: kpis[index]),
        );
      },
    );
  }
}

// ✅ نموذج بيانات الكرت (بقي كما هو بدون أي مساس)
class _KpiData {

  const _KpiData({
    required this.icon,
    required this.gradient,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.iconBg,
  });
  final IconData icon;
  final LinearGradient gradient;
  final String title;
  final String value;
  final String subtitle;
  final Color iconBg;
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.data});
  final _KpiData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: data.gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow:[
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
          children:[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:[
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