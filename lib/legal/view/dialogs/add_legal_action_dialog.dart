import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../cubit/legal_affairs_cubit.dart';

void showAddLegalActionDialog(BuildContext context) {
  final cubit = context.read<LegalAffairsCubit>();
  final state = cubit.state;

  String? selectedContractId;
  String selectedActionType = 'إنذار';
  DateTime selectedDate = DateTime.now();
  final notesController = TextEditingController();

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setStateDialog) {
        return AlertDialog(
          title: const Row(
            children:[
              Icon(Icons.balance, color: Colors.brown),
              SizedBox(width: 8),
              Text('تسجيل إجراء قانوني', style: TextStyle(color: Colors.brown)),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children:[
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'اختر العقد / العميل', border: OutlineInputBorder()),
                    isExpanded: true,
                    value: selectedContractId,
                    items: state.contracts.map((contract) {
                      final client = state.clients.where((c) => c.id == contract.clientId).firstOrNull;
                      return DropdownMenuItem(
                        value: contract.id,
                        child: Text('${client?.name ?? "مجهول"} - ${contract.apartmentDetails}', overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (val) => setStateDialog(() => selectedContractId = val),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'نوع الإجراء', border: OutlineInputBorder()),
                    value: selectedActionType,
                    items: ['إنذار', 'فراغ عقاري', 'رهن', 'تسوية', 'دعوى قضائية']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) => setStateDialog(() => selectedActionType = val!),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(4)),
                    title: const Text('تاريخ الإجراء'),
                    subtitle: Text(DateFormat('yyyy-MM-dd').format(selectedDate), style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.calendar_month, color: Colors.brown),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context, initialDate: selectedDate,
                        firstDate: DateTime(2000), lastDate: DateTime(2100),
                      );
                      if (date != null) setStateDialog(() => selectedDate = date);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(labelText: 'ملاحظات وتفاصيل', border: OutlineInputBorder()),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          actions:[
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.brown, foregroundColor: Colors.white),
              onPressed: () {
                if (selectedContractId == null) {
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('الرجاء اختيار العقد أولاً')));
                  return;
                }
                cubit.addLegalAction(
                  contractId: selectedContractId!,
                  actionType: selectedActionType,
                  actionDate: selectedDate,
                  notes: notesController.text,
                );
                Navigator.pop(ctx);
              },
              child: const Text('حفظ الإجراء'),
            ),
          ],
        );
      }
    ),
  );
}