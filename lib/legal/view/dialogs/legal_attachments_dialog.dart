import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:local_storage_api/local_storage_api.dart' show LegalAction, LegalActionAttachment;

import '../../cubit/legal_affairs_cubit.dart';

void showLegalAttachmentsDialog(BuildContext context, LegalAction action, List<LegalActionAttachment> attachments, bool canManage) {
  final cubit = context.read<LegalAffairsCubit>();

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children:[
          const Text('المرفقات القانونية', style: TextStyle(color: Colors.indigo)),
          if (canManage)
            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file, size: 16),
              label: const Text('إضافة ملف'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
                );

                if (result != null) {
                  Navigator.pop(ctx); // إغلاق النافذة مؤقتاً أثناء الرفع
                  cubit.attachFileToAction(
                    actionId: action.id,
                    filePath: result.files.single.path!,
                    extension: result.files.single.extension ?? 'unknown',
                    originalFileName: result.files.single.name,
                  );
                }
              },
            )
        ],
      ),
      content: SizedBox(
        width: 400,
        child: attachments.isEmpty 
          ? const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text('لا توجد مرفقات لهذا الإجراء.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            )
          : ListView.separated(
              shrinkWrap: true,
              itemCount: attachments.length,
              separatorBuilder: (c, i) => const Divider(),
              itemBuilder: (c, i) {
                final att = attachments[i];
                final isPdf = att.fileType?.toLowerCase() == 'pdf';
                return ListTile(
                  leading: Icon(isPdf ? Icons.picture_as_pdf : Icons.image, color: isPdf ? Colors.red : Colors.blue, size: 32),
                  title: Text(att.fileName ?? 'ملف بدون اسم', maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(DateFormat('yyyy/MM/dd').format(att.createdAt.toLocal()), style: const TextStyle(fontSize: 10)),
                  trailing: canManage 
                    ? IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () {
                          cubit.deleteAttachment(att.id);
                          Navigator.pop(ctx);
                        },
                      ) 
                    : null,
                );
              },
            ),
      ),
      actions:[TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إغلاق'))],
    ),
  );
}