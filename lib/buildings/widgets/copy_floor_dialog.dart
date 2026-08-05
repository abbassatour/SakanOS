// lib/buildings/widgets/copy_floor_dialog.dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart'
    show Apartment, Building;
import 'package:our_home_erp_app/l10n/l10n.dart';

import '../cubit/buildings_cubit.dart';

void showCopyFloorDialog(
  BuildContext parentContext,
  Building building,
  String sourceFloorName,
  List<Apartment> sourceApartments,
  List<String> allFloors,
) {
  final l10n = parentContext.l10n;
  final targetFloors = allFloors.where((f) => f != sourceFloorName).toList();
  if (targetFloors.isEmpty) {
    ScaffoldMessenger.of(parentContext).showSnackBar(
      SnackBar(content: Text(l10n.copyFloorNoTargetWarning)),
    );
    return;
  }

  final cubit = parentContext.read<BuildingsCubit>();

  unawaited(
    showDialog<void>(
      context: parentContext,
      builder: (dialogCtx) => BlocProvider.value(
        value: cubit,
        child: _CopyFloorDialogContent(
          building: building,
          sourceFloorName: sourceFloorName,
          sourceApartments: sourceApartments,
          targetFloors: targetFloors,
        ),
      ),
    ),
  );
}

class _CopyFloorDialogContent extends StatefulWidget {
  const _CopyFloorDialogContent({
    required this.building,
    required this.sourceFloorName,
    required this.sourceApartments,
    required this.targetFloors,
  });

  final Building building;
  final String sourceFloorName;
  final List<Apartment> sourceApartments;
  final List<String> targetFloors;

  @override
  State<_CopyFloorDialogContent> createState() =>
      _CopyFloorDialogContentState();
}

class _CopyFloorDialogContentState extends State<_CopyFloorDialogContent> {
  String? _selectedTargetFloor;
  final Map<String, TextEditingController> _newNumberControllers = {};

  @override
  void initState() {
    super.initState();
    _selectedTargetFloor = widget.targetFloors.first;
    for (final apt in widget.sourceApartments) {
      _newNumberControllers[apt.id] = TextEditingController(
        text: '${apt.apartmentNumber}*',
      );
    }
  }

  @override
  void dispose() {
    for (final ctrl in _newNumberControllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _handleSave() {
    final l10n = context.l10n;
    final hasEmpty = _newNumberControllers.values.any(
      (c) => c.text.trim().isEmpty,
    );
    if (hasEmpty || _selectedTargetFloor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.copyFloorEmptyNumbersWarning),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final availableFloors =
        jsonDecode(widget.building.floorCoefficients) as Map<String, dynamic>;
    final targetFloorPercentage =
        (availableFloors[_selectedTargetFloor] as num?)?.toDouble() ?? 0.0;

    final cubit = context.read<BuildingsCubit>();

    for (final apt in widget.sourceApartments) {
      final copiedCoeffs =
          jsonDecode(apt.customCoefficients) as Map<String, dynamic>
            ..removeWhere(
              (key, value) =>
                  key.startsWith('الطابق') ||
                  key.toLowerCase().contains('floor'),
            );

      if (targetFloorPercentage != 0.0) {
        copiedCoeffs['الطابق ($_selectedTargetFloor)'] = targetFloorPercentage;
      }

      final finalCoeffs = <String, double>{};
      copiedCoeffs.forEach((k, v) => finalCoeffs[k] = (v as num).toDouble());

      unawaited(
        cubit.addApartment(
          buildingId: widget.building.id,
          aptNumber: _newNumberControllers[apt.id]!.text.trim(),
          area: apt.area,
          floorName: _selectedTargetFloor!,
          directionName: apt.directionName,
          customCoeffs: finalCoeffs,
        ),
      );
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.copyFloorSuccess(_selectedTargetFloor!)),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

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
              Icons.copy_all,
              color: Colors.orange.shade700,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              l10n.copyFloorDialogTitle(widget.sourceFloorName),
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100, width: 1.5),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade700,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.copyFloorInfoBanner,
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
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
                  border: Border.all(color: Colors.orange.shade200, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withValues(alpha: 0.03),
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
                        Icon(
                          Icons.arrow_downward,
                          color: Colors.orange.shade600,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.copyFloorTargetHeader,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedTargetFloor,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        labelText: l10n.copyFloorSelectTargetLabel,
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
                            color: Colors.orange.shade400,
                            width: 2,
                          ),
                        ),
                      ),
                      items: widget.targetFloors
                          .map(
                            (f) => DropdownMenuItem(
                              value: f,
                              child: Text(f),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        setState(() => _selectedTargetFloor = val);
                      },
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
                        Icon(
                          Icons.edit_document,
                          color: Colors.indigo.shade400,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.copyFloorNewNumbersHeader,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.indigo,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...widget.sourceApartments.map((apt) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade50.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.indigo.shade100),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.door_front_door,
                                    color: Colors.indigo.shade300,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.copyFloorCopyOf(
                                            apt.apartmentNumber,
                                          ),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          l10n.copyFloorAreaLabel(apt.area),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Colors.indigo.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: _newNumberControllers[apt.id],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: InputDecoration(
                                  labelText: l10n.copyFloorNewNumberLabel,
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.indigo.shade200,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.indigo.shade200,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.indigo.shade500,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
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
          child: Text(
            l10n.btnCancel,
            style: const TextStyle(
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
          label: Text(
            l10n.btnConfirmCopy,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
