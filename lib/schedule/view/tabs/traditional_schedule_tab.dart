// lib/schedule/view/tabs/traditional_schedule_tab.dart
import 'package:flutter/material.dart';
import 'package:local_storage_api/local_storage_api.dart' show Contract;
import '../../cubit/schedule_cubit.dart';

// استدعاء القطع المفككة
import 'widgets/traditional/schedule_empty_state.dart';
import 'widgets/traditional/schedule_toolbar.dart';
import 'widgets/traditional/schedule_stats_ribbon.dart';
import 'widgets/traditional/schedule_data_table.dart';

// دالة التنسيق بقيت هنا لاستخدامها عند الحاجة
String formatNumberWithCommas(num number) {
  RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  return number.toInt().toString().replaceAllMapped(
    reg,
    (Match match) => '${match[1]},',
  );
}

class TraditionalScheduleTab extends StatelessWidget {
  final ScheduleState state;

  const TraditionalScheduleTab({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    int totalInstallments = 0;
    int paidInstallments = 0;
    int pendingInstallments = 0;
    int overdueInstallments = 0;

    Contract? currentContract;
    double metersPerInstallment = 0.0;
    bool isPostAllocation = false;

    // الحسابات الأساسية
    if (state.selectedContractId != null && state.scheduleList.isNotEmpty) {
      totalInstallments = state.scheduleList.length;
      paidInstallments = state.scheduleList
          .where((s) => s.status == 'paid')
          .length;
      pendingInstallments = state.scheduleList
          .where((s) => s.status != 'paid' && s.status != 'missed')
          .length;
      overdueInstallments = state.scheduleList
          .where(
            (s) => s.status == 'pending' && s.dueDate.isBefore(DateTime.now()),
          )
          .length;

      final idx = state.contracts.indexWhere(
        (c) => c.id == state.selectedContractId,
      );
      if (idx != -1) {
        currentContract = state.contracts[idx];
        isPostAllocation = currentContract.contractType == 'لاحق التخصص';
        if (!isPostAllocation && currentContract.installmentsCount > 0) {
          metersPerInstallment =
              currentContract.totalArea / currentContract.installmentsCount;
        }
      }
    }

    return Column(
      children: [
        // 1. شريط الأدوات والبحث
        ScheduleToolbar(
          state: state,
          currentContract: currentContract,
          isPostAllocation: isPostAllocation,
        ),

        // 2. المحتوى السفلي (إما شاشة ترحيبية أو إحصائيات + جدول)
        Expanded(
          child: state.selectedContractId == null
              ? const ScheduleEmptyState()
              : state.scheduleList.isEmpty
              ? const Center(
                  child: Text(
                    'لم يتم توليد أي جدول أقساط لهذا العقد.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    ScheduleStatsRibbon(
                      totalInstallments: totalInstallments,
                      paidInstallments: paidInstallments,
                      pendingInstallments: pendingInstallments,
                      overdueInstallments: overdueInstallments,
                      isPostAllocation: isPostAllocation,
                      metersPerInstallment: metersPerInstallment,
                      formattedAgreedAmount: currentContract != null
                          ? formatNumberWithCommas(
                              currentContract.agreedMonthlyAmount,
                            )
                          : '0',
                    ),
                    const SizedBox(height: 12),
                    ScheduleDataTable(
                      state: state,
                      currentContract: currentContract!,
                      isPostAllocation: isPostAllocation,
                      metersPerInstallment: metersPerInstallment,
                      formattedAgreedAmount: formatNumberWithCommas(
                        currentContract.agreedMonthlyAmount,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
