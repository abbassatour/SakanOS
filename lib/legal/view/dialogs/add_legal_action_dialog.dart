import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:local_storage_api/local_storage_api.dart' show LegalAction;
import 'package:our_home_erp_app/l10n/l10n.dart';

import '../../cubit/legal_affairs_cubit.dart';

void showAddOrEditLegalActionDialog(
  BuildContext context, {
  LegalAction? actionToEdit,
}) {
  final legalCubit = context.read<LegalAffairsCubit>();

  showDialog(
    context: context,
    builder: (ctx) => BlocProvider.value(
      value: legalCubit,
      child: AddOrEditLegalActionDialog(actionToEdit: actionToEdit),
    ),
  );
}

class AddOrEditLegalActionDialog extends StatefulWidget {
  final LegalAction? actionToEdit;

  const AddOrEditLegalActionDialog({super.key, this.actionToEdit});

  @override
  State<AddOrEditLegalActionDialog> createState() =>
      _AddOrEditLegalActionDialogState();
}

class _AddOrEditLegalActionDialogState
    extends State<AddOrEditLegalActionDialog> {
  String? selectedContractId;
  String selectedActionType = 'إنذار';
  DateTime selectedDate = DateTime.now();
  late TextEditingController notesController;

  bool get isEditing => widget.actionToEdit != null;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<LegalAffairsCubit>();

    if (isEditing) {
      final action = widget.actionToEdit!;
      bool contractExists = cubit.state.contracts.any(
        (c) => c.id == action.contractId,
      );
      selectedContractId = contractExists ? action.contractId : null;

      selectedActionType = action.actionType;
      selectedDate = action.actionDate.toLocal();
      notesController = TextEditingController(text: action.notes ?? '');
    } else {
      notesController = TextEditingController();
    }
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LegalAffairsCubit>();
    final state = cubit.state;
    final l10n = context.l10n;

    final actionTypes = [
      l10n.legalTypeWarning,
      l10n.legalTypeTransfer,
      l10n.legalTypeMortgage,
      l10n.legalTypeSettlement,
      l10n.legalTypeLawsuit,
    ];

    if (!actionTypes.contains(selectedActionType)) {
      selectedActionType = actionTypes.first;
    }

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            isEditing ? Icons.edit_document : Icons.balance,
            color: Colors.brown,
          ),
          const SizedBox(width: 8),
          Text(
            isEditing ? l10n.legalDialogEditTitle : l10n.legalDialogAddTitle,
            style: const TextStyle(color: Colors.brown),
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: l10n.legalDialogSelectContractLabel,
                  border: const OutlineInputBorder(),
                ),
                isExpanded: true,
                value: selectedContractId,
                items: state.contracts.map((contract) {
                  final client = state.clients
                      .where((c) => c.id == contract.clientId)
                      .firstOrNull;
                  return DropdownMenuItem(
                    value: contract.id,
                    child: Text(
                      '${client?.name ?? l10n.clientUnknownUser} - ${contract.apartmentDetails}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => selectedContractId = val),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: l10n.legalDialogActionTypeLabel,
                  border: const OutlineInputBorder(),
                ),
                value: selectedActionType,
                items: actionTypes
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => selectedActionType = val!),
              ),
              const SizedBox(height: 16),
              ListTile(
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4),
                ),
                title: Text(l10n.legalDialogActionDateLabel),
                subtitle: Text(
                  DateFormat('yyyy-MM-dd').format(selectedDate),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.calendar_month, color: Colors.brown),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) setState(() => selectedDate = date);
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: InputDecoration(
                  labelText: l10n.legalDialogNotesLabel,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.btnCancel),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.brown,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            if (selectedContractId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.legalDialogSelectContractWarning)),
              );
              return;
            }

            if (isEditing) {
              cubit.updateLegalAction(
                actionId: widget.actionToEdit!.id,
                contractId: selectedContractId!,
                actionType: selectedActionType,
                actionDate: selectedDate,
                notes: notesController.text,
              );
            } else {
              cubit.addLegalAction(
                contractId: selectedContractId!,
                actionType: selectedActionType,
                actionDate: selectedDate,
                notes: notesController.text,
              );
            }
            Navigator.pop(context);
          },
          child: Text(
            isEditing
                ? l10n.legalDialogSaveEditBtn
                : l10n.legalDialogSaveActionBtn,
          ),
        ),
      ],
    );
  }
}
