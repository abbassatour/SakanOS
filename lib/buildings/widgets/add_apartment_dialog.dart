// lib/buildings/widgets/add_apartment_dialog.dart
import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart' show Building;
import 'package:our_home_erp_app/buildings/cubit/buildings_cubit.dart';

void showAddApartmentDialog(
  BuildContext parentContext,
  Building building, {
  String? preSelectedFloor,
}) {
  final cubit = parentContext.read<BuildingsCubit>();

  unawaited(
    showDialog<void>(
      context: parentContext,
      builder: (dialogCtx) => BlocProvider.value(
        value: cubit,
        child: _AddApartmentDialogContent(
          building: building,
          preSelectedFloor: preSelectedFloor,
        ),
      ),
    ),
  );
}

class _AddApartmentDialogContent extends StatefulWidget {
  const _AddApartmentDialogContent({
    required this.building,
    this.preSelectedFloor,
  });

  final Building building;
  final String? preSelectedFloor;

  @override
  State<_AddApartmentDialogContent> createState() =>
      _AddApartmentDialogContentState();
}

class _AddApartmentDialogContentState
    extends State<_AddApartmentDialogContent> {
  late final TextEditingController _numCtrl;
  late final TextEditingController _slabAreaCtrl;
  late final TextEditingController _terraceAreaCtrl;
  late final TextEditingController _physicalYardAreaCtrl;
  late final TextEditingController _yardCoeffCtrl;
  late final TextEditingController _profitCoeffCtrl;

  late final Map<String, dynamic> _availableFloors;
  late final Map<String, dynamic> _generalCoeffs;

  String? _selectedFloorName;
  double _calculatedTotalArea = 0;

  final List<String> _mainDirections = ['شمالي', 'جنوبي', 'شرقي', 'غربي'];
  final Map<String, bool> _selectedDirections = {
    'شمالي': false,
    'جنوبي': false,
    'شرقي': false,
    'غربي': false,
  };

  @override
  void initState() {
    super.initState();
    _numCtrl = TextEditingController();
    _slabAreaCtrl = TextEditingController();
    _terraceAreaCtrl = TextEditingController(text: '0');
    _physicalYardAreaCtrl = TextEditingController(text: '0');
    _yardCoeffCtrl = TextEditingController(text: '0');
    _profitCoeffCtrl = TextEditingController(text: '0');

    var parsedFloors = <String, dynamic>{};
    var parsedGeneral = <String, dynamic>{};

    try {
      parsedFloors = jsonDecode(widget.building.floorCoefficients)
          as Map<String, dynamic>;
      parsedGeneral = jsonDecode(widget.building.directionCoefficients)
          as Map<String, dynamic>;
    } catch (e, stackTrace) {
      log('خطأ في فك تشفير المعاملات', error: e, stackTrace: stackTrace);
    }

    _availableFloors = parsedFloors;
    _generalCoeffs = parsedGeneral;

    _selectedFloorName = widget.preSelectedFloor ??
        (_availableFloors.keys.isNotEmpty ? _availableFloors.keys.first : null);
  }

  @override
  void dispose() {
    _numCtrl.dispose();
    _slabAreaCtrl.dispose();
    _terraceAreaCtrl.dispose();
    _physicalYardAreaCtrl.dispose();
    _yardCoeffCtrl.dispose();
    _profitCoeffCtrl.dispose();
    super.dispose();
  }

  void _updateCalculatedArea() {
    final slab = double.tryParse(_slabAreaCtrl.text) ?? 0.0;
    final terrace = double.tryParse(_terraceAreaCtrl.text) ?? 0.0;
    final yard = double.tryParse(_physicalYardAreaCtrl.text) ?? 0.0;

    setState(() {
      _calculatedTotalArea = slab + (terrace * 0.40) + (yard / 8.0);
    });
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    Color? fillColor,
    TextInputType keyboardType = TextInputType.number,
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade600),
        filled: true,
        fillColor: fillColor ?? Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.indigo.shade400, width: 2),
        ),
      ),
    );
  }

  void _handleSave() {
    if (_numCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ الرجاء إدخال رقم الشقة!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedFloorName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ الرجاء تحديد الطابق!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_slabAreaCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ الرجاء إدخال مساحة البلاطة!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _updateCalculatedArea();

    if (_calculatedTotalArea <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ المساحة المحسوبة غير صالحة!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final aptCoeffs = <String, double>{};
    final slab = double.tryParse(_slabAreaCtrl.text) ?? 0.0;
    final terrace = double.tryParse(_terraceAreaCtrl.text) ?? 0.0;
    final yard = double.tryParse(_physicalYardAreaCtrl.text) ?? 0.0;

    if (slab > 0) aptCoeffs['مساحة البلاطة (م2)'] = slab;
    if (terrace > 0) aptCoeffs['مساحة التراس (م2)'] = terrace;
    if (yard > 0) aptCoeffs['مساحة الوجيبة (م2)'] = yard;

    final floorPercentage =
        (_availableFloors[_selectedFloorName] as num).toDouble();
    if (floorPercentage != 0.0) {
      aptCoeffs['الطابق ($_selectedFloorName)'] = floorPercentage;
    }

    final chosenNames = <String>[];
    var totalDirPercentage = 0.0;
    _selectedDirections.forEach((dirName, isSelected) {
      if (isSelected) {
        chosenNames.add(dirName);
        totalDirPercentage +=
            (_generalCoeffs[dirName] as num?)?.toDouble() ?? 0.0;
      }
    });

    final finalDirectionName =
        chosenNames.isEmpty ? 'غير محدد' : chosenNames.join(' - ');
    if (totalDirPercentage != 0.0) {
      aptCoeffs['الاتجاه ($finalDirectionName)'] = totalDirPercentage;
    }

    void addVal(String key, String val) {
      final parsed = double.tryParse(val);
      if (parsed != null && parsed != 0.0) aptCoeffs[key] = parsed;
    }

    addVal('معامل التميز للوجيبة', _yardCoeffCtrl.text);
    addVal('هامش الربح', _profitCoeffCtrl.text);

    unawaited(
      context.read<BuildingsCubit>().addApartment(
            buildingId: widget.building.id,
            aptNumber: _numCtrl.text.trim(),
            area: _calculatedTotalArea,
            floorName: _selectedFloorName!,
            directionName: finalDirectionName,
            customCoeffs: aptCoeffs,
          ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding: const EdgeInsets.all(24),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.apartment,
              color: Colors.indigo.shade700,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'إضافة شقة للكتالوج',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      controller: _numCtrl,
                      label: 'رقم الشقة / الرمز',
                      icon: Icons.tag,
                      keyboardType: TextInputType.text,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedFloorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        labelText: 'اختر الطابق (يحدد النسبة آلياً)',
                        prefixIcon: Icon(
                          Icons.layers,
                          size: 20,
                          color: Colors.grey.shade600,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.indigo.shade400,
                            width: 2,
                          ),
                        ),
                      ),
                      items: _availableFloors.keys.map((floorName) {
                        final percentage = _availableFloors[floorName];
                        return DropdownMenuItem(
                          value: floorName,
                          child: Text('$floorName ($percentage%)'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() => _selectedFloorName = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.indigo.shade100, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.architecture, color: Colors.indigo.shade400),
                        const SizedBox(width: 8),
                        const Text(
                          'حساب المساحة البيعية (م²)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.indigo,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      controller: _slabAreaCtrl,
                      label: 'مساحة البلاطة (المسقوفة) م²',
                      icon: Icons.crop_square,
                      fillColor: Colors.white,
                      onChanged: (_) => _updateCalculatedArea(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            controller: _terraceAreaCtrl,
                            label: 'مساحة التراس م²',
                            icon: Icons.balcony,
                            fillColor: Colors.white,
                            onChanged: (_) => _updateCalculatedArea(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildField(
                            controller: _physicalYardAreaCtrl,
                            label: 'مساحة الوجيبة م²',
                            icon: Icons.grass,
                            fillColor: Colors.white,
                            onChanged: (_) => _updateCalculatedArea(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.indigo.shade400,
                            Colors.indigo.shade600,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.indigo.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'المساحة البيعية المعتمدة للعقد',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_calculatedTotalArea.toStringAsFixed(2)} م²',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.teal.shade200, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.explore, color: Colors.teal.shade600),
                        const SizedBox(width: 8),
                        const Text(
                          'اختيار اتجاهات الشقة',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _mainDirections.map((dir) {
                        final dirPercentage =
                            (_generalCoeffs[dir] as num?)?.toDouble() ?? 0.0;
                        return FilterChip(
                          label: Text(
                            '$dir ($dirPercentage%)',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          selected: _selectedDirections[dir]!,
                          backgroundColor: Colors.teal.shade50,
                          selectedColor: Colors.teal.shade200,
                          checkmarkColor: Colors.teal.shade900,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.teal.shade100),
                          ),
                          onSelected: (selected) {
                            setState(() {
                              _selectedDirections[dir] = selected;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.shade200, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.percent, color: Colors.green.shade600),
                        const SizedBox(width: 8),
                        const Text(
                          'المعاملات المالية الخاصة بالشقة',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            controller: _yardCoeffCtrl,
                            label: 'معامل الوجيبة  %',
                            icon: Icons.yard_outlined,
                            fillColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildField(
                            controller: _profitCoeffCtrl,
                            label: 'هامش الربح %',
                            icon: Icons.trending_up,
                            fillColor: const Color(0xFFE8F5E9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'إلغاء',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 2,
          ),
          onPressed: _handleSave,
          icon: const Icon(Icons.check_circle_outline),
          label: const Text(
            'حفظ الشقة',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}