// مسار الملف: lib/clients/widgets/edit_client_dialog.dart
// ignore_for_file: always_use_package_imports
// ignore_for_file: depend_on_referenced_packages
// ignore_for_file: simple_directive_paths

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart' show Client;

import '../../../auth/cubit/auth_cubit.dart';
import '../../../core/constants/app_permissions.dart';
import '../cubit/clients_cubit.dart';
import 'verify_pin_dialog.dart';

void showEditClientDialog(BuildContext parentContext, Client client) {
  final authState = parentContext.read<AuthCubit>().state;
  final canDelete = authState.hasPermission(AppPermissions.deleteClients);

  unawaited(
    showDialog<void>(
      context: parentContext,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: parentContext.read<ClientsCubit>(),
          child: _EditClientDialogContent(
            client: client,
            canDelete: canDelete,
            parentContext: parentContext,
          ),
        );
      },
    ),
  );
}

class _EditClientDialogContent extends StatefulWidget {
  const _EditClientDialogContent({
    required this.client,
    required this.canDelete,
    required this.parentContext,
  });

  final Client client;
  final bool canDelete;
  final BuildContext parentContext;

  @override
  State<_EditClientDialogContent> createState() =>
      _EditClientDialogContentState();
}

class _EditClientDialogContentState extends State<_EditClientDialogContent> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _nationalIdController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.client.name);
    _phoneController = TextEditingController(text: widget.client.phone);
    _nationalIdController =
        TextEditingController(text: widget.client.nationalId ?? '');
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
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blueAccent.shade400, width: 2),
        ),
      ),
    );
  }

  Future<void> _handleDelete() async {
    Navigator.pop(context);
    final isAuthorized = await showVerifyPinDialog(widget.parentContext);

    if (isAuthorized && widget.parentContext.mounted) {
      await widget.parentContext
          .read<ClientsCubit>()
          .deleteClient(widget.client.id);

      if (widget.parentContext.mounted) {
        ScaffoldMessenger.of(widget.parentContext).showSnackBar(
          const SnackBar(
            content: Text('تم نقل العميل لسلة المحذوفات'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final nationalId = _nationalIdController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ يرجى إدخال الاسم ورقم الهاتف على الأقل!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.pop(context);
    final isAuthorized = await showVerifyPinDialog(widget.parentContext);

    if (isAuthorized && widget.parentContext.mounted) {
      await widget.parentContext.read<ClientsCubit>().updateClient(
            id: widget.client.id,
            name: name,
            phone: phone,
            nationalId: nationalId.isEmpty ? null : nationalId,
          );

      if (widget.parentContext.mounted) {
        ScaffoldMessenger.of(widget.parentContext).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث بيانات العميل بنجاح ✅'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
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
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.manage_accounts,
              color: Colors.blueAccent.shade700,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'تعديل بيانات العميل',
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200, width: 1.5),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.security,
                      color: Colors.amber.shade800,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'تنبيه أمني: إجراءات التعديل أو الحذف للعملاء '
                        'تتطلب إدخال رمز الأمان الخاص بالإدارة للحفاظ '
                        'على موثوقية العقود.',
                        style: TextStyle(
                          color: Colors.amber.shade900,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildField(
                controller: _nameController,
                label: 'الاسم الثلاثي',
                icon: Icons.person,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      controller: _phoneController,
                      label: 'رقم الهاتف',
                      icon: Icons.phone_android,
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildField(
                      controller: _nationalIdController,
                      label: 'الرقم الوطني',
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (widget.canDelete)
              TextButton.icon(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  backgroundColor: Colors.red.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                label: const Text(
                  'حذف ونقل للسلة',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: _handleDelete,
              )
            else
              const SizedBox.shrink(),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
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
                    backgroundColor: Colors.blueAccent,
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
                  icon: const Icon(Icons.save),
                  label: const Text(
                    'حفظ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
