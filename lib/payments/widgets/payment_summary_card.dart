// lib/payments/widgets/payment_summary_card.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:our_home_erp_app/core/utils/calculator_helper.dart';
import 'package:our_home_erp_app/core/utils/formatters.dart';
import 'package:our_home_erp_app/payments/cubit/payments_cubit.dart';
import 'package:our_home_erp_app/settings/cubit/settings_cubit.dart';

class PaymentSummaryCard extends StatelessWidget {
  const PaymentSummaryCard({super.key, required this.state});

  final PaymentsState state;

  @override
  Widget build(BuildContext context) {
    if (state.selectedContractId == null || state.contracts.isEmpty) {
      return const SizedBox.shrink();
    }

    final contractIdx = state.contracts.indexWhere(
      (c) => c.id == state.selectedContractId,
    );
    if (contractIdx == -1) return const SizedBox.shrink();

    final contract = state.contracts[contractIdx];
    final isAllocated = contract.contractType == 'متخصص';

    // 🌟 جلب الأسعار الحية من إعدادات النظام
    final settingsState = context.watch<SettingsCubit>().state;
    final currentPrices = settingsState.currentPrices;

    // حساب المجاميع من دفتر المدفوعات
    double totalPaid = 0;
    double totalMeters = 0;

    for (final entry in state.ledgerEntries) {
      totalPaid += entry.amountPaid;
      totalMeters += entry.convertedMeters;
    }

    // حساب النسب والأمتار المتبقية (للعقود المتخصصة فقط)
    double percentage = 0.0;
    double remainingMeters = 0.0;

    if (isAllocated && contract.totalArea > 0) {
      percentage = (totalMeters / contract.totalArea) * 100;
      if (percentage > 100) percentage = 100.0; // حماية بصرية
      if (percentage < 0) percentage = 0.0;

      remainingMeters = contract.totalArea - totalMeters;
      if (remainingMeters < 0) remainingMeters = 0.0;
    }

    // ==========================================
    // 🌟 الحساب الذكي للقيمة الحالية بناءً على أسعار اليوم
    // ==========================================
    double currentMeterPrice = 0.0;

    if (currentPrices != null) {
      try {
        final coeffsMap =
            jsonDecode(contract.coefficients) as Map<String, dynamic>;
        final parsedCoeffs = coeffsMap.map(
          (k, dynamic v) => MapEntry(k, (v as num).toDouble()),
        );

        final safeArea = (isAllocated && contract.totalArea > 0)
            ? contract.totalArea
            : 1.0;

        final calculations = CalculatorHelper.calculateContractValues(
          area: safeArea,
          currentPrices: currentPrices,
          coefficients: parsedCoeffs,
        );

        // نأخذ السعر الخام الدقيق للمتر
        currentMeterPrice =
            calculations['pricePerSqmRaw'] ??
            calculations['pricePerSqm'] ??
            0.0;
      } catch (_) {
        // تجاهل بصمت في حال فشل قراءة المعاملات
      }
    }

    // القيمة المالية الإجمالية للأمتار التي يملكها العميل بأسعار اليوم!
    final double currentValueBalance = totalMeters * currentMeterPrice;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.teal.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ==========================================
          // 📊 القسم الأيمن: المؤشر الدائري
          // ==========================================
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: isAllocated ? (percentage / 100) : 1.0,
                  backgroundColor: Colors.grey.shade200,
                  color: isAllocated
                      ? Colors.teal.shade600
                      : Colors.blue.shade600,
                  strokeWidth: 10,
                  strokeCap: StrokeCap.round,
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isAllocated
                            ? '%${percentage.toStringAsFixed(1)}'
                            : 'أسهم',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isAllocated ? 20 : 16,
                          color: isAllocated
                              ? Colors.teal.shade800
                              : Colors.blue.shade800,
                        ),
                      ),
                      if (isAllocated)
                        const Text(
                          'ملكية العميل',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Container(width: 1, height: 90, color: Colors.grey.shade200),
          const SizedBox(width: 24),

          // ==========================================
          // 📝 القسم الأيسر: الإحصائيات والأرقام (بإستخدام Wrap للاستجابة)
          // ==========================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isAllocated ? Icons.apartment : Icons.pie_chart,
                      color: isAllocated ? Colors.teal : Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'الرصيد التراكمي للمحفظة (${isAllocated ? "تخصيص عيني" : "لاحق التخصص"})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 32,
                  runSpacing: 16,
                  children: [
                    _buildStatItem(
                      title: 'إجمالي ما تم دفعه',
                      value:
                          '${NumberFormatters.formatWithCommas(totalPaid)} ل.س',
                      color: Colors
                          .grey
                          .shade700, // لون رمادي دلالة على التكلفة السابقة
                      icon: Icons.history,
                    ),
                    _buildStatItem(
                      title: 'الأمتار المكتسبة',
                      value: '${totalMeters.toStringAsFixed(3)} م²',
                      color: Colors.blue.shade700,
                      icon: Icons.square_foot,
                    ),
                    // 🌟 المقياس الجديد الذهبي!
                    _buildStatItem(
                      title: 'القيمة الحالية (بأسعار اليوم)',
                      value: currentPrices != null
                          ? '${NumberFormatters.formatWithCommas(currentValueBalance)} ل.س'
                          : 'جاري التحميل...',
                      color: Colors
                          .orange
                          .shade800, // لون ذهبي/برتقالي يعطي شعوراً بالقيمة
                      icon: Icons.trending_up,
                      isHighlighted: true, // تضخيم الخط
                    ),
                    if (isAllocated)
                      _buildStatItem(
                        title: 'المتبقي للشركة',
                        value: '${remainingMeters.toStringAsFixed(3)} م²',
                        color: remainingMeters > 0
                            ? Colors.red.shade600
                            : Colors.green.shade600,
                        icon: Icons.business,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
    bool isHighlighted = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isHighlighted ? color : Colors.grey.shade500,
            ),
            const SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isHighlighted ? color : Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          padding: isHighlighted
              ? const EdgeInsets.symmetric(horizontal: 8, vertical: 2)
              : null,
          decoration: isHighlighted
              ? BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: color.withOpacity(0.3)),
                )
              : null,
          child: Text(
            value,
            style: TextStyle(
              fontSize: isHighlighted ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
