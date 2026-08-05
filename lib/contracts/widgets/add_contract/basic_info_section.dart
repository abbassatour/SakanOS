// lib/contracts/widgets/add_contract/basic_info_section.dart

import 'package:flutter/material.dart';
import 'package:local_storage_api/local_storage_api.dart' show Client;
import 'package:our_home_erp_app/l10n/l10n.dart';

class BasicInfoSection extends StatelessWidget {
  const BasicInfoSection({
    required this.clients,
    required this.selectedClientId,
    required this.onClientChanged,
    required this.guarantorController,
    required this.selectedContractType,
    required this.onTypeChanged,
    super.key,
  });

  final List<Client> clients;
  final String? selectedClientId;
  final ValueChanged<String?> onClientChanged;
  final TextEditingController guarantorController;
  final String selectedContractType;
  final ValueChanged<String?> onTypeChanged;

  String _getContractTypeLabel(BuildContext context, String type) {
    final l10n = context.l10n;
    if (type == 'متخصص') return l10n.contractTypeAllocatedName;
    if (type == 'لاحق التخصص') return l10n.contractTypeUnallocatedName;
    return type;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: selectedClientId,
              decoration: InputDecoration(
                labelText: l10n.contractBasicSelectClientLabel,
                border: const OutlineInputBorder(),
              ),
              items: clients
                  .map(
                    (client) => DropdownMenuItem(
                      value: client.id,
                      child: Text(client.name),
                    ),
                  )
                  .toList(),
              onChanged: onClientChanged,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: guarantorController,
              decoration: InputDecoration(
                labelText: l10n.contractBasicGuarantorLabel,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: selectedContractType,
              decoration: InputDecoration(
                labelText: l10n.contractBasicTypeLabel,
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              items: ['متخصص', 'لاحق التخصص']
                  .map(
                    (type) => DropdownMenuItem(
                      value: type,
                      child: Text(
                        _getContractTypeLabel(context, type),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onTypeChanged,
            ),
          ],
        ),
      ),
    );
  }
}
