// lib/legal/view/dialogs/legal_attachments_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:local_storage_api/local_storage_api.dart' show LegalAction, LegalActionAttachment;
import 'package:url_launcher/url_launcher.dart'; // 🌟 المكتبة المسؤولة عن فتح الروابط

import '../../cubit/legal_affairs_cubit.dart';

void showLegalAttachmentsDialog(BuildContext context, LegalAction action, List<LegalActionAttachment> attachments, bool canManage) {
  final cubit = context.read<LegalAffairsCubit>();

  // 🌟 دالة فتح الرابط في المتصفح الافتراضي للنظام
  Future<void> _launchFileUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      // LaunchMode.externalApplication يجبر النظام على فتح المتصفح (Edge/Chrome)
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('عذراً، تعذر فتح هذا الرابط!'), backgroundColor: Colors.red),
        );
      }
    }
  }

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
        width: 450, // 🌟 قمنا بزيادة العرض قليلاً لتتسع الأزرار الجديدة
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
                final isImage = ['jpg', 'jpeg', 'png'].contains(att.fileType?.toLowerCase());
                
                // تحديد الأيقونة المناسبة
                IconData leadingIcon = Icons.insert_drive_file;
                Color leadingColor = Colors.grey;
                if (isPdf) { leadingIcon = Icons.picture_as_pdf; leadingColor = Colors.red; }
                else if (isImage) { leadingIcon = Icons.image; leadingColor = Colors.blue; }
                else { leadingIcon = Icons.description; leadingColor = Colors.blue.shade900; }

                return ListTile(
                  // 🌟 جعل السطر بأكمله قابلاً للضغط لفتح الملف
                  onTap: () => _launchFileUrl(att.fileUrl),
                  hoverColor: Colors.indigo.shade50,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  
                  leading: Icon(leadingIcon, color: leadingColor, size: 32),
                  title: Text(att.fileName ?? 'ملف بدون اسم', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(DateFormat('yyyy/MM/dd').format(att.createdAt.toLocal()), style: const TextStyle(fontSize: 10)),
                  
                  // 🌟 إضافة الأزرار في نهاية السطر
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children:[
                      // زر العرض / التحميل (متاح للجميع)
                      Tooltip(
                        message: isImage || isPdf ? 'معاينة الملف' : 'تحميل الملف',
                        child: IconButton(
                          icon: Icon(isImage || isPdf ? Icons.visibility : Icons.download, color: Colors.indigo),
                          onPressed: () => _launchFileUrl(att.fileUrl),
                        ),
                      ),
                      
                      // زر الحذف (متاح لأصحاب الصلاحيات فقط)
                      if (canManage) ...[
                        const SizedBox(width: 8),
                        Tooltip(
                          message: 'حذف المرفق',
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () {
                              cubit.deleteAttachment(att.id);
                              Navigator.pop(ctx);
                            },
                          ),
                        ),
                      ]
                    ],
                  ),
                );
              },
            ),
      ),
      actions:[
        TextButton(
          onPressed: () => Navigator.pop(ctx), 
          child: const Text('إغلاق', style: TextStyle(fontWeight: FontWeight.bold))
        )
      ],
    ),
  );
}