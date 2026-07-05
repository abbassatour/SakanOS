// lib/buildings/widgets/add_building_dialog.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:our_home_erp_app/buildings/cubit/buildings_cubit.dart';

String _getArabicFloorName(int floorNumber) {
  if (floorNumber == 0) return 'الطابق الأرضي';

  if (floorNumber > 0) {
    const names = [
      'الأول',
      'الثاني',
      'الثالث',
      'الرابع',
      'الخامس',
      'السادس',
      'السابع',
      'الثامن',
      'التاسع',
      'العاشر',
      'الحادي عشر',
      'الثاني عشر',
      'الثالث عشر',
      'الرابع عشر',
      'الخامس عشر'
    ];
    if (floorNumber <= names.length) {
      return 'الطابق ${names[floorNumber - 1]}';
    }
    return 'الطابق $floorNumber';
  } else {
    const names = ['الأول', 'الثاني', 'الثالث', 'الرابع', 'الخامس'];
    final absFloor = floorNumber.abs();

    if (absFloor <= names.length) {
      return 'القبو ${names[absFloor - 1]}';
    }
    return 'القبو $absFloor';
  }
}

void showAddBuildingDialog(BuildContext parentContext) {
  final cubit = parentContext.read<BuildingsCubit>();

  unawaited(
    showDialog<void>(
      context: parentContext,
      builder: (dialogCtx) => BlocProvider.value(
        value: cubit,
        child: const _AddBuildingDialogContent(),
      ),
    ),
  );
}

class _AddBuildingDialogContent extends StatefulWidget {
  const _AddBuildingDialogContent();

  @override
  State<_AddBuildingDialogContent> createState() =>
      _AddBuildingDialogContentState();
}

class _AddBuildingDialogContentState extends State<_AddBuildingDialogContent> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _locCtrl;

  late final TextEditingController _locationCoeffCtrl;
  late final TextEditingController _streetCoeffCtrl;
  late final TextEditingController _elevatorCoeffCtrl;

  late final TextEditingController _northCtrl;
  late final TextEditingController _southCtrl;
  late final TextEditingController _eastCtrl;
  late final TextEditingController _westCtrl;

  int _basementsCount = 0;
  int _floorsCount = 1;
  final Map<int, TextEditingController> _floorControllers = {};

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _locCtrl = TextEditingController();
    _locationCoeffCtrl = TextEditingController(text: '0');
    _streetCoeffCtrl = TextEditingController(text: '0');
    _elevatorCoeffCtrl = TextEditingController(text: '0');
    _northCtrl = TextEditingController(text: '0');
    _southCtrl = TextEditingController(text: '0');
    _eastCtrl = TextEditingController(text: '0');
    _westCtrl = TextEditingController(text: '0');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locCtrl.dispose();
    _locationCoeffCtrl.dispose();
    _streetCoeffCtrl.dispose();
    _elevatorCoeffCtrl.dispose();
    _northCtrl.dispose();
    _southCtrl.dispose();
    _eastCtrl.dispose();
    _westCtrl.dispose();

    for (final ctrl in _floorControllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    Color? fillColor,
    TextInputType keyboardType = TextInputType.number,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null
            ? Icon(icon, size: 20, color: Colors.grey.shade600)
            : null,
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

  List<Widget> _buildFloorInputs() {
    final widgets = <Widget>[];
    for (var i = -_basementsCount; i <= _floorsCount; i++) {
      _floorControllers.putIfAbsent(
        i,
        () => TextEditingController(text: '0'),
      );

      final isBasement = i < 0;
      final isGround = i == 0;

      final bgColor = isBasement
          ? Colors.brown.shade50
          : (isGround ? Colors.green.shade50 : Colors.indigo.shade50);

      final borderColor = isBasement
          ? Colors.brown.shade200
          : (isGround ? Colors.green.shade200 : Colors.indigo.shade200);

      final textColor = isBasement
          ? Colors.brown.shade800
          : (isGround ? Colors.green.shade800 : Colors.indigo.shade800);

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 140,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderColor),
                ),
                child: Text(
                  _getArabicFloorName(i),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildField(
                  controller: _floorControllers[i]!,
                  label: 'نسبة التمييز المالي %',
                  icon: Icons.percent,
                  fillColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return widgets;
  }

  void _handleSave() {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ الرجاء إدخال اسم المحضر!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final finalFloorCoeffs = <String, double>{};
    _floorControllers.forEach((floorNum, ctrl) {
      final val = double.tryParse(ctrl.text);
      if (val != null) {
        finalFloorCoeffs[_getArabicFloorName(floorNum)] = val;
      }
    });

    final finalDirCoeffs = <String, double>{};
    void addGeneralVal(String key, String val) {
      final parsed = double.tryParse(val);
      if (parsed != null && parsed != 0.0) finalDirCoeffs[key] = parsed;
    }

    addGeneralVal('الموقع', _locationCoeffCtrl.text);
    addGeneralVal('الشارع', _streetCoeffCtrl.text);
    addGeneralVal('المصعد', _elevatorCoeffCtrl.text);
    addGeneralVal('شمالي', _northCtrl.text);
    addGeneralVal('جنوبي', _southCtrl.text);
    addGeneralVal('شرقي', _eastCtrl.text);
    addGeneralVal('غربي', _westCtrl.text);

    unawaited(
      context.read<BuildingsCubit>().addBuilding(
            name: _nameCtrl.text.trim(),
            location: _locCtrl.text.trim(),
            floorCoeffs: finalFloorCoeffs,
            dirCoeffs: finalDirCoeffs,
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
              Icons.domain_add,
              color: Colors.indigo.shade700,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'إضافة محضر جديد (إعداد الهيكل)',
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
                    flex: 3,
                    child: _buildField(
                      controller: _nameCtrl,
                      label: 'اسم المحضر / المشروع',
                      icon: Icons.business,
                      keyboardType: TextInputType.text,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: _buildField(
                      controller: _locCtrl,
                      label: 'الموقع',
                      icon: Icons.location_on,
                      keyboardType: TextInputType.text,
                      fillColor: Colors.white,
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
                        Icon(Icons.tune, color: Colors.green.shade600),
                        const SizedBox(width: 8),
                        const Text(
                          'معاملات المحضر العامة (%)',
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
                            label: 'الموقع %',
                            icon: Icons.map,
                            fillColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildField(
                            controller: _streetCoeffCtrl,
                            label: 'الشارع %',
                            icon: Icons.add_road,
                            fillColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildField(
                            controller: _elevatorCoeffCtrl,
                            label: 'المصعد %',
                            icon: Icons.elevator,
                            fillColor: Colors.white,
                          ),
                        ),
                      ],
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
                          'معاملات الجهات الجغرافية للمحضر (%)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            controller: _northCtrl,
                            label: 'شمالي %',
                            icon: Icons.north,
                            fillColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildField(
                            controller: _southCtrl,
                            label: 'جنوبي %',
                            icon: Icons.south,
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
                            controller: _eastCtrl,
                            label: 'شرقي %',
                            icon: Icons.east,
                            fillColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildField(
                            controller: _westCtrl,
                            label: 'غربي %',
                            icon: Icons.west,
                            fillColor: Colors.white,
                          ),
                        ),
                      ],
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
                  border: Border.all(color: Colors.indigo.shade200, width: 1.5),
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
                        Icon(Icons.layers, color: Colors.indigo.shade600),
                        const SizedBox(width: 8),
                        const Text(
                          'هيكل الطوابق ونسب التمييز لكل طابق',
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
                          child: DropdownButtonFormField<int>(
                            initialValue: _basementsCount,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                            decoration: InputDecoration(
                              labelText: 'عدد الأقبية (تحت الأرض)',
                              prefixIcon: Icon(
                                Icons.arrow_downward,
                                color: Colors.brown.shade400,
                              ),
                              filled: true,
                              fillColor: Colors.brown.shade50,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.brown.shade200,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.brown.shade200,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.indigo.shade400,
                                  width: 2,
                                ),
                              ),
                            ),
                            items: [0, 1, 2, 3]
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text('$e قبو'),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _basementsCount = val);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            initialValue: _floorsCount,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                            decoration: InputDecoration(
                              labelText: 'عدد الطوابق (فوق الأرضي)',
                              prefixIcon: Icon(
                                Icons.arrow_upward,
                                color: Colors.indigo.shade400,
                              ),
                              filled: true,
                              fillColor: Colors.indigo.shade50,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.indigo.shade200,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.indigo.shade200,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.indigo.shade400,
                                  width: 2,
                                ),
                              ),
                            ),
                            items: [0, 1, 2, 3, 4, 5, 6, 7]
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text('$e طابق'),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _floorsCount = val);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ..._buildFloorInputs(),
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
            backgroundColor: Colors.indigo.shade600,
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
            'اعتماد وحفظ المحضر',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}