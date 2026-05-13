// lib/legal/view/dialogs/legal_attachments_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:local_storage_api/local_storage_api.dart' show LegalAction, LegalActionAttachment;
import 'package:url_launcher/url_launcher.dart';

import '../../cubit/legal_affairs_cubit.dart';

void showLegalAttachmentsDialog(BuildContext context, LegalAction action, List<LegalActionAttachment> attachments, bool canManage) {
  final cubit = context.read<LegalAffairsCubit>();

  Future<void> _launchFileUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
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
    barrierDismissible: false, // 🌟 منع إغلاق النافذة بالخطأ أثناء الرفع
    builder: (ctx) => StatefulBuilder(
      builder: (context, setStateDialog) {
        // 🌟 متغيرات تتبع حالة الرفع
        bool isUploading = false;
        int totalFilesToUpload = 0;
        int currentUploadIndex = 0;

        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:[
              const Text('المرفقات القانونية', style: TextStyle(color: Colors.indigo)),
              if (canManage && !isUploading) // إخفاء زر الإضافة أثناء الرفع
                ElevatedButton.icon(
                  icon: const Icon(Icons.upload_file, size: 16),
                  label: const Text('إضافة ملفات'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles(
                      allowMultiple: true, // 🌟 السماح باختيار عدة ملفات
                      type: FileType.custom,
                      // 🌟 إضافة صيغ الإكسل
                      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx', 'xls', 'xlsx'], 
                    );

                    if (result != null && result.files.isNotEmpty) {
                      // 1. تفعيل واجهة التحميل
                      setStateDialog(() {
                        isUploading = true;
                        totalFilesToUpload = result.files.length;
                        currentUploadIndex = 0;
                      });

                      // 2. رفع الملفات واحداً تلو الآخر لتجنب الضغط على الشبكة
                      for (int i = 0; i < result.files.length; i++) {
                        setStateDialog(() => currentUploadIndex = i + 1);
                        
                        final file = result.files[i];
                        if (file.path != null) {
                          await cubit.attachFileToAction(
                            actionId: action.id,
                            filePath: file.path!,
                            extension: file.extension ?? 'unknown',
                            originalFileName: file.name,
                          );
                        }
                      }

                      // 3. إنهاء حالة التحميل بعد اكتمال الرفع
                      setStateDialog(() => isUploading = false);
                      
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(content: Text('تم رفع $totalFilesToUpload ملفات بنجاح! ✅'), backgroundColor: Colors.green),
                        );
                        Navigator.pop(ctx); // إغلاق النافذة لتحديث البيانات
                      }
                    }
                  },
                )
            ],
          ),
          content: SizedBox(
            width: 450,
            // 🌟 واجهة متغيرة: إما إظهار المرفقات أو إظهار شريط التحميل
            child: isUploading
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children:[
                        const CircularProgressIndicator(color: Colors.indigo),
                        const SizedBox(height: 24),
                        const Text('جاري معالجة ورفع الملفات...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.indigo)),
                        const SizedBox(height: 8),
                        Text('ملف $currentUploadIndex من $totalFilesToUpload', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: currentUploadIndex / totalFilesToUpload,
                          backgroundColor: Colors.indigo.shade100,
                          color: Colors.indigo,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  )
                : (attachments.isEmpty 
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
                          final ext = att.fileType?.toLowerCase() ?? '';
                          final isPdf = ext == 'pdf';
                          final isImage = ['jpg', 'jpeg', 'png'].contains(ext);
                          final isExcel = ['xls', 'xlsx'].contains(ext); // 🌟 تمييز الإكسل
                          
                          // تحديد الأيقونة واللون
                          IconData leadingIcon = Icons.insert_drive_file;
                          Color leadingColor = Colors.grey;
                          if (isPdf) { leadingIcon = Icons.picture_as_pdf; leadingColor = Colors.red; }
                          else if (isImage) { leadingIcon = Icons.image; leadingColor = Colors.blue; }
                          else if (isExcel) { leadingIcon = Icons.table_chart; leadingColor = Colors.green; } // 🌟 لون أخضر للإكسل
                          else { leadingIcon = Icons.description; leadingColor = Colors.blue.shade900; }

                          return ListTile(
                            onTap: () => _launchFileUrl(att.fileUrl),
                            hoverColor: Colors.indigo.shade50,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            
                            leading: Icon(leadingIcon, color: leadingColor, size: 32),
                            title: Text(att.fileName ?? 'ملف بدون اسم', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(DateFormat('yyyy/MM/dd').format(att.createdAt.toLocal()), style: const TextStyle(fontSize: 10)),
                            
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children:[
                                Tooltip(
                                  message: isImage || isPdf ? 'معاينة الملف' : 'تحميل الملف',
                                  child: IconButton(
                                    icon: Icon(isImage || isPdf ? Icons.visibility : Icons.download, color: Colors.indigo),
                                    onPressed: () => _launchFileUrl(att.fileUrl),
                                  ),
                                ),
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
                      )
                  ),
          ),
          actions:[
            if (!isUploading) // إخفاء زر الإغلاق أثناء الرفع لمنع المقاطعة
              TextButton(
                onPressed: () => Navigator.pop(ctx), 
                child: const Text('إغلاق', style: TextStyle(fontWeight: FontWeight.bold))
              )
          ],
        );
      }
    ),
  );
}