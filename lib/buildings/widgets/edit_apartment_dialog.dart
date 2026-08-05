// lib/buildings/widgets/edit_apartment_dialog.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart' show Apartment;
import 'package:our_home_erp_app/l10n/l10n.dart';

import '../cubit/buildings_cubit.dart';

void showEditApartmentDialog(BuildContext parentContext, Apartment apt) {
  final cubit = parentContext.read<BuildingsCubit>();

  unawaited(
    showDialog<void>(
      context: parentContext,
      builder: (dialogCtx) => BlocProvider.value(
        value: cubit,
        child: _EditApartmentDialogContent(apt: apt),
      ),
    ),
  );
}

class _EditApartmentDialogContent extends StatefulWidget {
  const _EditApartmentDialogContent({required this.apt});

  final Apartment apt;

  @override
  State<_EditApartmentDialogContent> createState() =>
      _EditApartmentDialogContentState();
}

class _EditApartmentDialogContentState
    extends State<_EditApartmentDialogContent> {
  late final TextEditingController _numberController;

  @override
  void initState() {
    super.initState();
    _numberController = TextEditingController(text: widget.apt.apartmentNumber);
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.grey.shade500),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
              const Icon(Icons.warning_amber_rounded, color: Colors.red),
              const SizedBox(width: 8),
              Text(l10n.aptDeleteConfirmTitle),
            ],
          ),
          content: Text(
            l10n.aptDeleteConfirmMessage,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(confirmCtx),
              child: Text(l10n.btnCancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                unawaited(
                  context.read<BuildingsCubit>().deleteApartment(widget.apt.id),
                );

                Navigator.pop(confirmCtx);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.aptSuccessDeleted),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: Text(
                l10n.aptBtnConfirmDelete,
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

    if (_numberController.text.trim().isNotEmpty) {
      unawaited(
        context.read<BuildingsCubit>().updateApartment(
          id: widget.apt.id,
          apartmentNumber: _numberController.text.trim(),
          area: widget.apt.area,
          directionName: widget.apt.directionName,
        ),
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.aptSuccessUpdated),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.aptValidationEmptyNumber),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final isAvailable = widget.apt.status == 'available';
    final isDelivered = widget.apt.status == 'delivered';

    Color boxColor;
    Color borderColor;
    Color iconTextColor;
    IconData alertIcon;
    String alertText;

    if (isAvailable) {
      boxColor = Colors.amber.shade50;
      borderColor = Colors.amber.shade200;
      iconTextColor = Colors.brown.shade800;
      alertIcon = Icons.info_outline;
      alertText = l10n.aptEditBannerAvailable;
    } else if (isDelivered) {
      boxColor = Colors.teal.shade50;
      borderColor = Colors.teal.shade200;
      iconTextColor = Colors.teal.shade900;
      alertIcon = Icons.verified_user;
      alertText = l10n.aptEditBannerDelivered;
    } else {
      boxColor = Colors.red.shade50;
      borderColor = Colors.red.shade200;
      iconTextColor = Colors.red.shade900;
      alertIcon = Icons.gavel;
      alertText = l10n.aptEditBannerSold;
    }

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
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isAvailable ? Icons.edit_note : Icons.lock,
                  color: isAvailable
                      ? Colors.orange.shade700
                      : (isDelivered
                            ? Colors.teal.shade700
                            : Colors.red.shade700),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                l10n.aptEditDialogTitle(widget.apt.apartmentNumber),
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          if (isAvailable)
            IconButton(
              icon: const Icon(
                Icons.delete_forever,
                color: Colors.red,
                size: 28,
              ),
              tooltip: l10n.aptBtnConfirmDelete,
              onPressed: _confirmDelete,
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDelivered ? Colors.teal.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDelivered
                      ? Colors.teal.shade200
                      : Colors.red.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isDelivered ? Icons.check_circle : Icons.lock,
                    color: isDelivered
                        ? Colors.teal.shade700
                        : Colors.red.shade700,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isDelivered
                        ? l10n.aptTagLockedDelivered
                        : l10n.aptTagLockedSold,
                    style: TextStyle(
                      color: isDelivered
                          ? Colors.teal.shade700
                          : Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: boxColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Icon(alertIcon, color: iconTextColor, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        alertText,
                        style: TextStyle(
                          color: iconTextColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _numberController,
                enabled: isAvailable,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  labelText: l10n.aptLabelNumber,
                  prefixIcon: Icon(
                    Icons.tag,
                    color: isAvailable ? Colors.orange.shade600 : Colors.grey,
                  ),
                  filled: true,
                  fillColor: isAvailable ? Colors.white : Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.orange.shade400,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildReadOnlyField(
                      l10n.aptLabelApprovedArea,
                      '${widget.apt.area} m²',
                      Icons.architecture,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildReadOnlyField(
                      l10n.aptLabelDirection,
                      widget.apt.directionName,
                      Icons.explore,
                    ),
                  ),
                ],
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
            isAvailable ? l10n.btnCancel : l10n.btnClose,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        if (isAvailable)
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _handleSave,
            icon: const Icon(Icons.save),
            label: Text(
              l10n.aptBtnSaveEdit,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }
}
