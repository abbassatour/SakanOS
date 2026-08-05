// lib/contracts/widgets/add_contract/property_section.dart

import 'package:flutter/material.dart';
import 'package:local_storage_api/local_storage_api.dart'
    show Apartment, Building;
import 'package:our_home_erp_app/l10n/l10n.dart';

class PropertySection extends StatelessWidget {
  const PropertySection({
    required this.isAllocated,
    required this.buildings,
    required this.availableApartments,
    required this.selectedBuildingId,
    required this.selectedApartmentId,
    required this.onBuildingChanged,
    required this.onApartmentChanged,
    super.key,
  });

  final bool isAllocated;
  final List<Building> buildings;
  final List<Apartment> availableApartments;
  final String? selectedBuildingId;
  final String? selectedApartmentId;
  final ValueChanged<String?> onBuildingChanged;
  final ValueChanged<String?> onApartmentChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (!isAllocated) {
      return Card(
        elevation: 2,
        color: Colors.blue.shade50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.blue.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.blue, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.contractPropertyUnallocatedNotice,
                  style: const TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      color: Colors.amber.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.amber.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.contractPropertyHeader,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: selectedBuildingId,
              decoration: InputDecoration(
                labelText: l10n.contractPropertySelectBuilding,
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              items: buildings
                  .map(
                    (b) => DropdownMenuItem<String>(
                      value: b.id,
                      child: Text('${b.name} (${b.location ?? ''})'),
                    ),
                  )
                  .toList(),
              onChanged: onBuildingChanged,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: selectedApartmentId,
              decoration: InputDecoration(
                labelText: l10n.contractPropertySelectApartment,
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              items: availableApartments
                  .map(
                    (apt) => DropdownMenuItem<String>(
                      value: apt.id,
                      child: Text(
                        l10n.contractPropertyAptOption(
                          apt.apartmentNumber,
                          apt.floorName,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: selectedBuildingId == null ? null : onApartmentChanged,
              disabledHint: Text(
                selectedBuildingId == null
                    ? l10n.contractPropertyNoBuildingHint
                    : l10n.contractPropertyNoApartmentsHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
