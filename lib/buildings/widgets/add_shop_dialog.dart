// lib/buildings/widgets/add_shop_dialog.dart
// ignore_for_file: always_use_package_imports, depend_on_referenced_packages

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart' show Building;

import '../cubit/buildings_cubit.dart';

void showAddShopDialog(BuildContext parentContext, Building building) {
  final cubit = parentContext.read<BuildingsCubit>();

  unawaited(
    showDialog<void>(
      context: parentContext,
      builder: (dialogCtx) => BlocProvider.value(
        value: cubit,
        child: _AddShopDialogContent(building: building),
      ),
    ),
  );
}

class _AddShopDialogContent extends StatefulWidget {
  const _AddShopDialogContent({required this.building});

  final Building building;

  @override
  State<_AddShopDialogContent> createState() => _AddShopDialogContentState();
}

class _AddShopDialogContentState extends State<_AddShopDialogContent> {
  late final TextEditingController _numCtrl;
  late final TextEditingController _slabAreaCtrl;
  late final TextEditingController _terraceAreaCtrl;
  late final TextEditingController _physicalYardAreaCtrl;
  late final TextEditingController _facadeLengthCtrl;

  late final TextEditingController _locationCoeffCtrl;
  late final TextEditingController _streetCoeffCtrl;
  late final TextEditingController _facadeCoeffCtrl;
  late final TextEditingController _yardCoeffCtrl;
  late final TextEditingController _profitCoeffCtrl;

  double _calculatedTotalArea = 0.0;

  @override
  void initState() {
    super.initState();
    _numCtrl = TextEditingController();
    _slabAreaCtrl = TextEditingController();
    _terraceAreaCtrl = TextEditingController(text: '0');
    _physicalYardAreaCtrl = TextEditingController(text: '0');
    _facadeLengthCtrl = TextEditingController();

    _locationCoeffCtrl = TextEditingController(text: '0');
    _streetCoeffCtrl = TextEditingController(text: '0');
    _facadeCoeffCtrl = TextEditingController(text: '0');
    _yardCoeffCtrl = TextEditingController(text: '0');
    _profitCoeffCtrl = TextEditingController(text: '0');
  }

  @override
  void dispose() {
    _numCtrl.dispose();
    _slabAreaCtrl.dispose();
    _terraceAreaCtrl.dispose();
    _physicalYardAreaCtrl.dispose();
    _facadeLengthCtrl.dispose();

    _locationCoeffCtrl.dispose();
    _streetCoeffCtrl.dispose();
    _facadeCoeffCtrl.dispose();
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
          borderSide: BorderSide(color: Colors.orange.shade400, width: 2),
        ),
      ),
    );
  }

  void _handleSave() {
    if (_numCtrl.text.trim().isEmpty || _calculatedTotalArea <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ بيانات غير مكتملة أو مساحة غير صالحة!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final aptCoeffs = <String, double>{};

    final slab = double.tryParse(_slabAreaCtrl.text) ?? 0.0;
    final terrace = double.tryParse(_terraceAreaCtrl.text) ?? 0.0;
    final yard = double.tryParse(_physicalYardAreaCtrl.text) ?? 0.0;
    final facadeLen = double.tryParse(_facadeLengthCtrl.text) ?? 0.0;

    if (slab > 0) aptCoeffs['مساحة البلاطة (م2)'] = slab;
    if (terrace > 0) aptCoeffs['مساحة التراس (م2)'] = terrace;
    if (yard > 0) aptCoeffs['مساحة الوجيبة (م2)'] = yard;
    if (facadeLen > 0) aptCoeffs['عرض الواجهة الفعلي (متر)'] = facadeLen;

    void addVal(String key, String val) {
      final parsed = double.tryParse(val);
      if (parsed != null && parsed != 0.0) aptCoeffs[key] = parsed;
    }

    addVal('الموقع', _locationCoeffCtrl.text);
    addVal('الشارع', _streetCoeffCtrl.text);
    addVal('تميز الواجهة', _facadeCoeffCtrl.text);
    addVal('معامل التميز للوجيبة', _yardCoeffCtrl.text);
    addVal('هامش الربح', _profitCoeffCtrl.text);

    context.read<BuildingsCubit>().addApartment(
          buildingId: widget.building.id,
          unitType: 'shop',
          aptNumber: _numCtrl.text.trim(),
          area: _calculatedTotalArea,
          floorName: 'تجاري',
          directionName: 'واجهة تجارية',
          customCoeffs: aptCoeffs,
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
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.storefront,
              color: Colors.orange.shade700,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'إضافة محل تجاري',
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
              _buildField(
                controller: _numCtrl,
                label: 'رقم المحل / الرمز',
                icon: Icons.tag,
                keyboardType: TextInputType.text,
                fillColor: Colors.white,
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
                          'البيانات الهندسية (المساحات والأبعاد)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.indigo,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            controller: _slabAreaCtrl,
                            label: 'مساحة الأرضي م²',
                            icon: Icons.crop_square,
                            fillColor: Colors.white,
                            onChanged: (_) => _updateCalculatedArea(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildField(
                            controller: _facadeLengthCtrl,
                            label: 'عرض الواجهة (متر)',
                            icon: Icons.straighten,
                            fillColor: const Color(0xFFF3E5F5),
                          ),
                        ),
                      ],
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
                            Colors.orange.shade400,
                            Colors.orange.shade600,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'المساحة البيعية الإجمالية للمحل',
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
                          'المعاملات المالية المئوية ',
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
                            controller: _locationCoeffCtrl,
                            label: 'نسبة الموقع %',
                            icon: Icons.location_on_outlined,
                            fillColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildField(
                            controller: _streetCoeffCtrl,
                            label: 'نسبة الشارع %',
                            icon: Icons.add_road,
                            fillColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            controller: _facadeCoeffCtrl,
                            label: 'نسبة التميز للواجهة %',
                            icon: Icons.star_border,
                            fillColor: const Color(0xFFFFF3E0),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildField(
                            controller: _yardCoeffCtrl,
                            label: 'معامل الوجيبة %',
                            icon: Icons.yard_outlined,
                            fillColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildField(
                      controller: _profitCoeffCtrl,
                      label: 'هامش الربح %',
                      icon: Icons.trending_up,
                      fillColor: const Color(0xFFE8F5E9),
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
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
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
            backgroundColor: Colors.orange.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 2,
          ),
          onPressed: _handleSave,
          icon: const Icon(Icons.check_circle_outline),
          label: const Text(
            'حفظ المحل',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}