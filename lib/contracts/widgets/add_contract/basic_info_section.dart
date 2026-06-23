// contracts/widgets/add_contract/basic_info_section.dart

import 'package:flutter/material.dart';

// ignore: depend_on_referenced_packages, reason: Needed for client model
import 'package:local_storage_api/local_storage_api.dart' show Client;

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

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: selectedClientId,
              decoration: const InputDecoration(
                labelText: 'اختر العميل (الفريق الثاني)',
                border: OutlineInputBorder(),
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
              decoration: const InputDecoration(
                labelText: 'اسم الكفيل الثلاثي',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: selectedContractType,
              decoration: const InputDecoration(
                labelText: 'نوع العقد',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              items: ['متخصص', 'لاحق التخصص']
                  .map(
                    (type) => DropdownMenuItem(
                      value: type,
                      child: Text(
                        type,
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
