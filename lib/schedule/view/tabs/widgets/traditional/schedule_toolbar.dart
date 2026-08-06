// lib/schedule/view/tabs/widgets/traditional/schedule_toolbar.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart' show Contract;
import 'package:our_home_erp_app/l10n/l10n.dart';
import '../../../../cubit/schedule_cubit.dart';
import '../../../dialogs/edit_schedule_dialog.dart';
import '../../../dialogs/reschedule_dialog.dart';
import '../../../dialogs/add_custom_schedule_dialog.dart';

String formatApartmentDetails(BuildContext context, String rawDetails) {
  final l10n = context.l10n;
  if (rawDetails == 'أسهم/غير مخصص' ||
      rawDetails == 'أسهم استثمارية غير مخصصة' ||
      rawDetails == 'محفظة استثمارية (عقد لاحق التخصص)' ||
      (rawDetails.contains('غير مخصص') && !rawDetails.contains('شقة')) ||
      (rawDetails.contains('استثمارية') && !rawDetails.contains('شقة'))) {
    if (rawDetails.contains('عقود متفاوتة الدفع') ||
        rawDetails.contains('منفاوتة')) {
      return l10n.localeName == 'en'
          ? 'Investment Shares (Flexible Payments)'
          : 'أسهم استثمارية غير مخصصة (عقود متفاوتة الدفع)';
    }
    return l10n.contractAutoDetailsUnallocated;
  }

  var formatted = rawDetails;
  if (l10n.localeName == 'en') {
    formatted = formatted
        .replaceAll('مشروع السلموني', 'Al-Salamoni Project')
        .replaceAll('مشروع', 'Project:')
        .replaceAll('عقار 1593', 'Property 1593')
        .replaceAll('عقار', 'Property:')
        .replaceAll('محضر:', 'Building:')
        .replaceAll('شقة:', 'Apt:')
        .replaceAll('شقة', 'Apt')
        .replaceAll('طابق:', 'Floor:')
        .replaceAll('الطابق الأرضي', 'Ground Floor')
        .replaceAll('الطابق الأول', '1st Floor')
        .replaceAll('الطابق الثاني', '2nd Floor')
        .replaceAll('الطابق الثالث', '3rd Floor')
        .replaceAll('الطابق الرابع', '4th Floor')
        .replaceAll('الطابق الخامس', '5th Floor')
        .replaceAll('الطابق السادس', '6th Floor')
        .replaceAll('الطابق السابع', '7th Floor')
        .replaceAll('الطابق الثامن', '8th Floor')
        .replaceAll('الطابق التاسع', '9th Floor')
        .replaceAll('الطابق العاشر', '10th Floor')
        .replaceAll('الطابق الحادي عشر', '11th Floor')
        .replaceAll('الطابق الثاني عشر', '12th Floor')
        .replaceAll('الطابق 1', '1st Floor')
        .replaceAll('الطابق 2', '2nd Floor')
        .replaceAll('الطابق 3', '3rd Floor')
        .replaceAll('الطابق 4', '4th Floor')
        .replaceAll('الطابق 5', '5th Floor')
        .replaceAll('القبو الأول', '1st Basement')
        .replaceAll('القبو الثاني', '2nd Basement')
        .replaceAll('القبو الثالث', '3rd Basement');
  }
  return formatted;
}

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
    final l10n = context.l10n;
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
                if (!hasContracts) {
                  return TextField(
                    enabled: false,
                    decoration: InputDecoration(
                      hintText: l10n.scheduleToolbarNoClients,
                      hintStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                      isDense: true,
                      filled: true,
                      fillColor: Colors.grey.shade200,
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

                return DropdownMenu<String>(
                  width: constraints.maxWidth,
                  enableSearch: true,
                  enableFilter: true,
                  hintText: l10n.scheduleToolbarSearchHint,
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
                        : l10n.scheduleToolbarUnknownClient;
                    final details = formatApartmentDetails(
                      context,
                      contract.apartmentDetails,
                    );
                    return DropdownMenuEntry<String>(
                      value: contract.id,
                      label: '$clientName ($details)',
                    );
                  }).toList(),
                );
              },
            ),
          ),

          if (state.selectedContractId != null && !isPostAllocation) ...[
            const SizedBox(width: 16),

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
                label: Text(
                  l10n.scheduleToolbarCustomBtn,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
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
                label: Text(
                  l10n.scheduleToolbarPropsBtn,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
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
                label: Text(
                  l10n.scheduleToolbarRescheduleBtn,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
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
