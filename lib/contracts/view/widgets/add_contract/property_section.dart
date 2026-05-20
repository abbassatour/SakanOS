//lib\contracts\view\widgets\add_contract\property_section.dart
import 'package:flutter/material.dart';

class PropertySection extends StatelessWidget {
  final bool isAllocated;
  final List<dynamic> buildings;
  final List<dynamic> availableApartments;
  final String? selectedBuildingId;
  final String? selectedApartmentId;
  final ValueChanged<String?> onBuildingChanged;
  final ValueChanged<String?> onApartmentChanged;

  const PropertySection({
    super.key,
    required this.isAllocated,
    required this.buildings,
    required this.availableApartments,
    required this.selectedBuildingId,
    required this.selectedApartmentId,
    required this.onBuildingChanged,
    required this.onApartmentChanged,
  });

  @override
  Widget build(BuildContext context) {
    // إذا كان لاحق التخصص، نعرض رسالة فقط ولا نطلب أي بيانات عقارية
    if (!isAllocated) {
      return Card(
        elevation: 2, color: Colors.blue.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.blue.shade200)),
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children:[
              Icon(Icons.info_outline, color: Colors.blue, size: 24),
              SizedBox(width: 8),
              Expanded(
                child: Text('عقد محفظة (لاحق التخصص): سيتم تخصيص العقار لاحقاً بناءً على الرصيد المتراكم.', 
                style: TextStyle(color: Colors.blueGrey, fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }

    // إذا كان متخصص، نعرض اختيار المحضر والشقة
    return Card(
      elevation: 2, color: Colors.amber.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.amber.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            const Text('🏠 اختيار العقار من الكتالوج', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey, fontSize: 16)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedBuildingId,
              decoration: const InputDecoration(labelText: 'اختر المحضر', border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
              items: buildings.map((b) => DropdownMenuItem<String>(value: b.id, child: Text('${b.name} (${b.location ?? ''})'))).toList(),
              onChanged: onBuildingChanged,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedApartmentId,
              decoration: const InputDecoration(labelText: 'اختر الشقة المتاحة', border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
              items: availableApartments.map((apt) => DropdownMenuItem<String>(value: apt.id, child: Text('شقة: ${apt.apartmentNumber} | طابق: ${apt.floorName}'))).toList(),
              onChanged: onBuildingChanged == null ? null : onApartmentChanged,
              disabledHint: Text(selectedBuildingId == null ? 'يرجى اختيار المحضر أولاً' : 'لا يوجد شقق متاحة!'),
            ),
          ],
        ),
      ),
    );
  }
}