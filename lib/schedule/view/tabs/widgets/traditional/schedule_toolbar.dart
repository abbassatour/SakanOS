// lib/schedule/view/tabs/widgets/traditional/schedule_toolbar.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart' show Contract;
import 'package:our_home_erp_app/l10n/l10n.dart';
import '../../../../cubit/schedule_cubit.dart';
import '../../../dialogs/edit_schedule_dialog.dart';
import '../../../dialogs/reschedule_dialog.dart';
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
