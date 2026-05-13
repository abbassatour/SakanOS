// lib/legal/view/dialogs/legal_attachments_dialog.dart
import 'dart:io';
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
    barrierDismissible: false, // منع إغلاق النافذة أثناء الرفع
    builder: (ctx) => StatefulBuilder(
      builder: (context, setStateDialog) {
        // ==========================================
        // 🌟 متغيرات محرك الرفع الذكي
        // ==========================================
        bool isUploading = false;
        bool isCancelling = false; // هل طلب المستخدم الإلغاء؟
        
        int totalFilesToUpload = 0;
        int currentUploadIndex = 0;
        
        double totalSizeMB = 0.0;
        double uploadedMB = 0.0;
        String currentSpeedStr = "0.00 MB/s";
        
        String? errorMessage;

        // دالة مساعدة لعملية الرفع
        Future<void> _startUploadProcess() async {
          FilePickerResult? result = await FilePicker.platform.pickFiles(
            allowMultiple: true,
            type: FileType.custom,
            allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx', 'xls', 'xlsx'],
          );

          if (result == null || result.files.isEmpty) return;

          // 1. التهيئة الحسابية
          double totalBytes = result.files.fold(0, (sum, file) => sum + file.size);
          
          setStateDialog(() {
            isUploading = true;
            isCancelling = false;
            errorMessage = null;
            totalFilesToUpload = result.files.length;
            currentUploadIndex = 0;
            totalSizeMB = totalBytes / (1024 * 1024);
            uploadedMB = 0.0;
            currentSpeedStr = "0.00 MB/s";
          });

          // تشغيل ساعة التوقيت لحساب السرعة
          Stopwatch stopwatch = Stopwatch()..start();

          // 2. طابور الرفع (Queue)
          for (int i = 0; i < result.files.length; i++) {
            // التحقق إذا ضغط المستخدم على زر "إلغاء"
            if (isCancelling) {
              setStateDialog(() => errorMessage = '⚠️ تم إلغاء الرفع بواسطة المستخدم. تم رفع $currentUploadIndex ملفات فقط.');
              break; 
            }

            setStateDialog(() => currentUploadIndex = i + 1);
            final file = result.files[i];

            if (file.path != null) {
              try {
                // استدعاء دالة الرفع
                await cubit.attachFileToAction(
                  actionId: action.id,
                  filePath: file.path!,
                  extension: file.extension ?? 'unknown',
                  originalFileName: file.name,
                );

                // حساب التقدم والسرعة بعد نجاح رفع الملف الحالي
                double currentFileMB = file.size / (1024 * 1024);
                uploadedMB += currentFileMB;
                
                double elapsedSec = stopwatch.elapsedMilliseconds / 1000.0;
                double speed = elapsedSec > 0 ? (uploadedMB / elapsedSec) : 0.0;

                setStateDialog(() {
                  currentSpeedStr = "${speed.toStringAsFixed(2)} MB/s";
                });

              } catch (e) {
                // 3. اصطياد أخطاء الإنترنت والسيرفر بدقة
                String errorStr = e.toString().toLowerCase();
                if (errorStr.contains('socket') || errorStr.contains('network') || errorStr.contains('host lookup')) {
                  setStateDialog(() => errorMessage = '❌ انقطع الاتصال بالإنترنت! يرجى التحقق من الشبكة.');
                } else {
                  setStateDialog(() => errorMessage = '❌ حدث خطأ أثناء رفع الملف (${file.name}): $e');
                }
                break; // إيقاف الطابور عند حدوث خطأ
              }
            }
          }

          stopwatch.stop();
          
          // 4. إنهاء العملية بنجاح إذا لم يتم الإلغاء أو حدوث خطأ
          if (!isCancelling && errorMessage == null) {
            if (ctx.mounted) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(content: Text('تم رفع $totalFilesToUpload ملفات بنجاح! ✅'), backgroundColor: Colors.green),
              );
              Navigator.pop(ctx); 
            }
          } else {
            // إبقاء النافذة مفتوحة ليرى المستخدم رسالة الخطأ أو الإلغاء
            setStateDialog(() => isUploading = false);
          }
        }

        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:[
              const Text('المرفقات القانونية', style: TextStyle(color: Colors.indigo)),
              if (canManage && !isUploading) 
                ElevatedButton.icon(
                  icon: const Icon(Icons.upload_file, size: 16),
                  label: const Text('إضافة ملفات'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                  onPressed: _startUploadProcess,
                )
            ],
          ),
          content: SizedBox(
            width: 480,
            child: isUploading
                // ==========================================
                // 🚀 واجهة الرفع المتقدمة (Progress UI)
                // ==========================================
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children:[
                        // 1. لافتة التحذير
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange.shade300)),
                          child: const Row(
                            children:[
                              Icon(Icons.warning_amber_rounded, color: Colors.orange),
                              SizedBox(width: 8),
                              Expanded(child: Text('رجاءً لا تقم بإغلاق التطبيق أو فصل الإنترنت حتى تكتمل عملية الرفع لتجنب تلف الملفات.', style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold, fontSize: 12))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        const CircularProgressIndicator(color: Colors.indigo),
                        const SizedBox(height: 16),
                        
                        // 2. معلومات الرفع (الملف الحالي)
                        Text('جاري رفع الملف $currentUploadIndex من $totalFilesToUpload', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 8),
                        
                        // 3. شريط التقدم
                        LinearProgressIndicator(
                          value: totalSizeMB > 0 ? (uploadedMB / totalSizeMB) : 0,
                          backgroundColor: Colors.indigo.shade100,
                          color: Colors.indigo,
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 12),
                        
                        // 4. إحصائيات حية (السرعة والحجم)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children:[
                            Text('السرعة: $currentSpeedStr', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            Text('${uploadedMB.toStringAsFixed(2)} / ${totalSizeMB.toStringAsFixed(2)} MB', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // 5. زر الإلغاء في حالات الطوارئ
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                          icon: const Icon(Icons.cancel),
                          label: Text(isCancelling ? 'جاري إيقاف العملية...' : 'إلغاء الرفع'),
                          onPressed: isCancelling ? null : () => setStateDialog(() => isCancelling = true),
                        ),
                      ],
                    ),
                  )
                // ==========================================
                // 📂 واجهة عرض الملفات أو الأخطاء
                // ==========================================
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children:[
                      // عرض رسائل الخطأ أو الإلغاء إن وجدت
                      if (errorMessage != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.shade200)),
                          child: Text(errorMessage!, style: TextStyle(color: Colors.red.shade800, fontWeight: FontWeight.bold)),
                        ),

                      attachments.isEmpty 
                        ? const Padding(padding: EdgeInsets.all(20.0), child: Text('لا توجد مرفقات لهذا الإجراء.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)))
                        : Flexible(
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: attachments.length,
                              separatorBuilder: (c, i) => const Divider(),
                              itemBuilder: (c, i) {
                                final att = attachments[i];
                                final ext = att.fileType?.toLowerCase() ?? '';
                                final isPdf = ext == 'pdf';
                                final isImage = ['jpg', 'jpeg', 'png'].contains(ext);
                                final isExcel = ['xls', 'xlsx'].contains(ext);
                                
                                IconData leadingIcon = Icons.insert_drive_file;
                                Color leadingColor = Colors.grey;
                                if (isPdf) { leadingIcon = Icons.picture_as_pdf; leadingColor = Colors.red; }
                                else if (isImage) { leadingIcon = Icons.image; leadingColor = Colors.blue; }
                                else if (isExcel) { leadingIcon = Icons.table_chart; leadingColor = Colors.green; }
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
                                        child: IconButton(icon: Icon(isImage || isPdf ? Icons.visibility : Icons.download, color: Colors.indigo), onPressed: () => _launchFileUrl(att.fileUrl)),
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
                            ),
                          ),
                    ],
                  ),
          ),
          actions:[
            if (!isUploading) 
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إغلاق', style: TextStyle(fontWeight: FontWeight.bold)))
          ],
        );
      }
    ),
  );
}