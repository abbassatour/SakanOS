// lib/schedule/view/tabs/widgets/traditional/schedule_toolbar.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart' show Contract;
import '../../../../cubit/schedule_cubit.dart';
import '../../../dialogs/edit_schedule_dialog.dart';
import '../../../dialogs/reschedule_dialog.dart';
// 🌟 [الاستدعاء الجديد]: استدعاء نافذة إضافة الدفعة الاستثنائية
import '../../../dialogs/add_custom_schedule_dialog.dart';

class ScheduleToolbar extends StatelessWidget {
  final ScheduleState state;
  final Contract? currentContract;
  final bool isPostAllocation;

  const ScheduleToolbar({
    super.key,
    required this.state,
    required this.currentContract,
    required this.isPostAllocation,
  });

  @override
  Widget build(BuildContext context) {
    // 🌟 متغير للتحقق مما إذا كانت القائمة فارغة
    final bool hasContracts = state.contracts.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.indigo.shade100, width: 1),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_search, color: Colors.indigo, size: 24),
          const SizedBox(width: 12),

          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // 🌟 الحل الذكي: إذا لم يكن هناك عقود، نعرض حقل معطل بشكل أنيق
                if (!hasContracts) {
                  return TextField(
                    enabled: false,
                    decoration: InputDecoration(
                      hintText: 'لا يوجد عملاء أو عقود حالياً...',
                      hintStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                      isDense: true,
                      filled: true,
                      fillColor: Colors.grey.shade200, // لون يدل على التعطيل
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  );
                }

                // 🌟 إذا كان هناك عقود، نعرض قائمة البحث الطبيعية
                return DropdownMenu<String>(
                  width: constraints.maxWidth,
                  enableSearch: true,
                  enableFilter: true,
                  hintText: '🔍 اكتب اسم العميل أو العقار...',
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  inputDecorationTheme: InputDecorationTheme(
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  initialSelection:
                      state.contracts.any(
                        (c) => c.id == state.selectedContractId,
                      )
                      ? state.selectedContractId
                      : null,
                  onSelected: (val) {
                    if (val != null)
                      context.read<ScheduleCubit>().selectContract(val);
                  },
                  dropdownMenuEntries: state.contracts.map((contract) {
                    final clientIdx = state.clients.indexWhere(
                      (c) => c.id == contract.clientId,
                    );
                    final clientName = clientIdx >= 0
                        ? state.clients[clientIdx].name
                        : 'عميل غير معروف';
                    return DropdownMenuEntry<String>(
                      value: contract.id,
                      label: '$clientName (${contract.apartmentDetails})',
                    );
                  }).toList(),
                );
              },
            ),
          ),

          if (state.selectedContractId != null && !isPostAllocation) ...[
            const SizedBox(width: 16),

            // 🌟 [الزر الجديد]: إضافة دفعة استثنائية / موسمية
            SizedBox(
              height: 36,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade600,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                icon: const Icon(Icons.star, size: 16),
                label: const Text(
                  'دفعة استثنائية',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                onPressed: () {
                  if (currentContract != null) {
                    showAddCustomScheduleDialog(context, currentContract!.id);
                  }
                },
              ),
            ),
            const SizedBox(width: 8),

            SizedBox(
              height: 36,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.indigo,
                  side: const BorderSide(color: Colors.indigo, width: 1),
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                icon: const Icon(Icons.settings, size: 16),
                label: const Text(
                  'الخصائص',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                onPressed: () {
                  if (currentContract != null)
                    showEditScheduleDialog(context, currentContract!);
                },
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 36,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                icon: const Icon(Icons.autorenew, size: 16),
                label: const Text(
                  'إعادة جدولة',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                onPressed: () {
                  if (currentContract != null)
                    showRescheduleDialog(context, currentContract!);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
