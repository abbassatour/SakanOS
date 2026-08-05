// lib/clients/widgets/add_client_dialog.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:our_home_erp_app/clients/cubit/clients_cubit.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';

void showAddClientDialog(BuildContext parentContext) {
  final clientsCubit = parentContext.read<ClientsCubit>();

  unawaited(
    showDialog<void>(
      context: parentContext,
      barrierDismissible: false,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: clientsCubit,
          child: _AddClientDialogContent(parentContext: parentContext),
        );
      },
    ),
  );
}

class _AddClientDialogContent extends StatefulWidget {
  const _AddClientDialogContent({required this.parentContext});

  final BuildContext parentContext;

  @override
  State<_AddClientDialogContent> createState() => _AddClientDialogState();
}

class _AddClientDialogState extends State<_AddClientDialogContent> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _nationalIdController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _nationalIdController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _nationalIdController.dispose();
    super.dispose();
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          size: 22,
          color: Colors.blueAccent.shade400,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
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
          borderSide: BorderSide(color: Colors.blueAccent.shade400, width: 2),
        ),
      ),
    );
  }

  Future<void> _saveClient() async {
    final l10n = context.l10n;
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final nationalId = _nationalIdController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.clientValidationFillNamePhone),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await context.read<ClientsCubit>().addClient(
        name: name,
        phone: phone,
        nationalId: nationalId.isEmpty ? null : nationalId,
      );

      if (mounted && widget.parentContext.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(widget.parentContext).showSnackBar(
          SnackBar(
            content: Text(l10n.clientSuccessAdd),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted && widget.parentContext.mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(widget.parentContext).showSnackBar(
          SnackBar(
            content: Text(l10n.clientErrorSave(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
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
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.person_add_alt_1,
              color: Colors.blueAccent.shade700,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            l10n.clientAddDialogTitle,
            style: const TextStyle(
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
              Text(
                l10n.clientAddDialogSubtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),
              _buildField(
                controller: _nameController,
                label: l10n.clientLabelFullName,
                icon: Icons.person,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      controller: _phoneController,
                      label: l10n.clientLabelPhone,
                      icon: Icons.phone_android,
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildField(
                      controller: _nationalIdController,
                      label: l10n.clientLabelNationalId,
                      icon: Icons.badge,
                      keyboardType: TextInputType.number,
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
          onPressed: _isSaving ? null : () => Navigator.pop(context),
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
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 2,
          ),
          onPressed: _isSaving ? null : _saveClient,
          icon: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.check_circle_outline),
          label: Text(
            _isSaving ? l10n.btnSaving : l10n.btnSaveClient,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
