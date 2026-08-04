// lib/buildings/widgets/edit_building_dialog.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart' show Building;
import 'package:our_home_erp_app/l10n/l10n.dart';

import '../cubit/buildings_cubit.dart';

void showEditBuildingDialog(BuildContext parentContext, Building building) {
  final cubit = parentContext.read<BuildingsCubit>();

  unawaited(
    showDialog<void>(
      context: parentContext,
      builder: (dialogCtx) => BlocProvider.value(
        value: cubit,
        child: _EditBuildingDialogContent(building: building),
      ),
    ),
  );
}

class _EditBuildingDialogContent extends StatefulWidget {
  const _EditBuildingDialogContent({required this.building});

  final Building building;

  @override
  State<_EditBuildingDialogContent> createState() =>
      _EditBuildingDialogContentState();
}

class _EditBuildingDialogContentState
    extends State<_EditBuildingDialogContent> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _locCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.building.name);
    _locCtrl = TextEditingController(text: widget.building.location ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locCtrl.dispose();
    super.dispose();
  }

  void _confirmDelete() {
    final l10n = context.l10n;

    unawaited(
      showDialog<void>(
        context: context,
        builder: (confirmCtx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.bldDeleteConfirmTitle,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            l10n.bldDeleteConfirmMessage,
            style: const TextStyle(fontSize: 15, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(confirmCtx),
              child: Text(
                l10n.btnCancel,
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                unawaited(
                  context.read<BuildingsCubit>().deleteBuilding(
                    widget.building.id,
                  ),
                );

                Navigator.pop(confirmCtx);
                if (mounted) {
                  Navigator.pop(context);
                }
              },
              child: Text(
                l10n.bldBtnConfirmDelete,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSave() {
    final l10n = context.l10n;

    if (_nameCtrl.text.trim().isNotEmpty) {
      unawaited(
        context.read<BuildingsCubit>().updateBuilding(
          id: widget.building.id,
          name: _nameCtrl.text.trim(),
          location: _locCtrl.text.trim(),
        ),
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.bldSuccessUpdate),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.bldValidationFillName),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding: const EdgeInsets.all(24),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.edit_location_alt,
                  color: Colors.indigo.shade700,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                l10n.bldEditDialogTitle,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_forever,
              color: Colors.red,
              size: 28,
            ),
            tooltip: l10n.bldEditTooltip,
            onPressed: _confirmDelete,
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
                        l10n.bldEditInfoBanner,
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
              TextField(
                controller: _nameCtrl,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  labelText: l10n.bldLabelName,
                  prefixIcon: const Icon(Icons.business, color: Colors.indigo),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.indigo.shade400,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _locCtrl,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  labelText: l10n.bldLabelLocation,
                  prefixIcon: const Icon(
                    Icons.location_on,
                    color: Colors.indigo,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.indigo.shade400,
                      width: 2,
                    ),
                  ),
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
            backgroundColor: Colors.indigo.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 2,
          ),
          onPressed: _handleSave,
          icon: const Icon(Icons.save),
          label: Text(
            l10n.bldBtnSaveEdits,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
