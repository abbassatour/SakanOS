// مسار الملف: lib/contracts/widgets/dialogs/edit_contract_sections/attachment_manager_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:erp_repository/erp_repository.dart';

import 'package:our_home_erp_app/contracts/cubit/contracts_cubit.dart';
import 'package:our_home_erp_app/contracts/widgets/dialogs/verify_pin_dialog.dart';

class AttachmentManagerSection extends StatelessWidget {
  const AttachmentManagerSection({
    super.key,
    required this.contract,
    required this.canEdit,
    required this.parentContext,
  });

  final Contract contract;
  final bool canEdit;
  final BuildContext parentContext;

  Future<void> _handleFileUpload(BuildContext context) async {
    // 1. طلب رمز الأمان
    final isAuth = await showVerifyPinDialog(parentContext);
    if (!isAuth) return;

    // 2. فتح نافذة اختيار الملف
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['doc', 'docx', 'pdf'],
    );

    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      final extension = result.files.single.extension ?? 'docx';

      if (parentContext.mounted) {
        ScaffoldMessenger.of(parentContext).showSnackBar(
          const SnackBar(
            content: Text('جاري الرفع... ⏳'),
            backgroundColor: Colors.orange,
          ),
        );

        // 3. إرسال أمر الرفع للـ Cubit
        await parentContext.read<ContractsCubit>().attachContractFile(
          contractId: contract.id,
          filePath: filePath,
          extension: extension,
        );

        if (parentContext.mounted) {
          ScaffoldMessenger.of(parentContext).showSnackBar(
            const SnackBar(
              content: Text('تم إرفاق الملف! ✅'),
              backgroundColor: Colors.green,
            ),
          );
          // 4. إغلاق النافذة المنبثقة للعودة للجدول
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasFile =
        contract.contractFileUrl != null &&
        contract.contractFileUrl!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                hasFile ? Icons.check_circle : Icons.warning_amber_rounded,
                color: hasFile ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 8),
              Text(
                hasFile ? 'يوجد ملف مرفق' : 'لا يوجد ملف',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          TextButton.icon(
            icon: Icon(
              Icons.upload_file,
              color: canEdit ? Colors.blue : Colors.grey,
            ),
            label: Text(
              hasFile ? 'استبدال الملف' : 'إرفاق ملف',
              style: TextStyle(color: canEdit ? Colors.blue : Colors.grey),
            ),
            onPressed: canEdit ? () => _handleFileUpload(context) : null,
          ),
        ],
      ),
    );
  }
}
