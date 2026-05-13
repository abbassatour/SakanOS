// lib/legal/view/dialogs/legal_attachments_dialog.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:local_storage_api/local_storage_api.dart' show LegalAction, LegalActionAttachment;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

import '../../cubit/legal_affairs_cubit.dart';

void showLegalAttachmentsDialog(BuildContext context, LegalAction action, List<LegalActionAttachment> attachments, bool canManage) {
  final cubit = context.read<LegalAffairsCubit>();

  // ==========================================
  // 🌟 دالة لفتح الصور داخل التطبيق (In-App Viewer)
  // ==========================================
  void _openImageInApp(BuildContext ctx, String url, String fileName) {
    showDialog(
      context: ctx,
      builder: (dialogCtx) => Dialog( // 🌟 تم التعديل هنا (استخدمنا dialogCtx بدلاً من _)
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Stack(
          alignment: Alignment.center,
          children:[
            // عارض تفاعلي يسمح بالتقريب (Zoom)
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  },
                  errorBuilder: (c, e, s) => Container(
                    color: Colors.white, padding: const EdgeInsets.all(20),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [Icon(Icons.broken_image, color: Colors.red, size: 50), SizedBox(height: 10), Text('تعذر تحميل الصورة')],
                    ),
                  ),
                ),
              ),
            ),
            // زر إغلاق عائم
            Positioned(
              top: 10, right: 10,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white), 
                  onPressed: () => Navigator.pop(dialogCtx) // 🌟 وتم التعديل هنا أيضاً
                ),
              ),
            ),
            // اسم الملف في الأسفل
            Positioned(
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                child: Text(fileName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 🌟 دالة لتحميل وفتح الملفات بالبرامج الأصلية للويندوز (PDF, Word, Excel)
  // ==========================================
  Future<void> _downloadAndOpenFile(BuildContext ctx, String url, String fileName) async {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(content: Text('جاري تنزيل وفتح "$fileName"... ⏳'), backgroundColor: Colors.indigo, duration: const Duration(seconds: 2)),
    );

    try {
      // 1. تحديد مجلد الـ Temp في الويندوز
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$fileName';
      final file = File(filePath);

      // 2. تحميل الملف إذا لم يكن موجوداً مسبقاً لتوفير الإنترنت
      if (!await file.exists()) {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          await file.writeAsBytes(response.bodyBytes);
        } else {
          throw Exception('فشل التحميل من السيرفر');
        }
      }

      // 3. فتح الملف بالبرنامج الافتراضي للكمبيوتر (Acrobat, Excel, etc.)
      final result = await OpenFilex.open(file.path);
      if (result.type != ResultType.done && ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('⚠️ تعذر فتح الملف: ${result.message}'), backgroundColor: Colors.orange));
      }
    } catch (e) {
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('❌ خطأ في فتح الملف: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('supabase.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setStateDialog) {
        bool isUploading = false;
        bool isCancelling = false;
        int totalFilesToUpload = 0;
        int currentUploadIndex = 0;
        double totalSizeMB = 0.0;
        double uploadedMB = 0.0;
        String currentSpeedStr = "0.00 MB/s";
        String? errorMessage;

        // ==========================================
        // 🚀 محرك الرفع الذكي (نفسه لم يتغير لأنه مثالي)
        // ==========================================
        Future<void> _startUploadProcess() async {
          bool hasNet = await _hasInternetConnection();
          if (!hasNet) {
            if (context.mounted) setStateDialog(() => errorMessage = '❌ لا يوجد اتصال بالإنترنت! تأكد من الشبكة وحاول مجدداً.');
            return;
          }

          FilePickerResult? result = await FilePicker.platform.pickFiles(
            allowMultiple: true, type: FileType.custom,
            allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx', 'xls', 'xlsx'],
          );

          if (result == null || result.files.isEmpty) return;

          double totalBytes = result.files.fold(0, (sum, file) => sum + file.size);
          
          if (context.mounted) {
            setStateDialog(() {
              isUploading = true; isCancelling = false; errorMessage = null;
              totalFilesToUpload = result.files.length; currentUploadIndex = 0;
              totalSizeMB = totalBytes / (1024 * 1024); uploadedMB = 0.0; currentSpeedStr = "0.00 MB/s";
            });
          }

          await Future.delayed(const Duration(milliseconds: 300));
          Stopwatch stopwatch = Stopwatch()..start();

          for (int i = 0; i < result.files.length; i++) {
            if (isCancelling) {
              if (context.mounted) setStateDialog(() => errorMessage = '⚠️ تم إلغاء الرفع. تم رفع $currentUploadIndex ملفات فقط.');
              break; 
            }

            if (context.mounted) setStateDialog(() => currentUploadIndex = i + 1);
            await Future.delayed(const Duration(milliseconds: 100));

            final file = result.files[i];

            if (file.path != null) {
              try {
                await cubit.attachFileToAction(
                  actionId: action.id, filePath: file.path!,
                  extension: file.extension ?? 'unknown', originalFileName: file.name,
                );

                double currentFileMB = file.size / (1024 * 1024);
                uploadedMB += currentFileMB;
                double elapsedSec = stopwatch.elapsedMilliseconds / 1000.0;
                double speed = elapsedSec > 0 ? (uploadedMB / elapsedSec) : 0.0;

                if (context.mounted) setStateDialog(() => currentSpeedStr = "${speed.toStringAsFixed(2)} MB/s");
              } catch (e) {
                if (context.mounted) {
                  if (e is SocketException || e.toString().toLowerCase().contains('socket')) {
                    setStateDialog(() => errorMessage = '❌ انقطع الاتصال بالإنترنت أثناء الرفع!');
                  } else {
                    setStateDialog(() => errorMessage = '❌ حدث خطأ أثناء رفع الملف (${file.name}): $e');
                  }
                }
                break; 
              }
            }
          }

          stopwatch.stop();
          
          if (!isCancelling && errorMessage == null) {
            if (ctx.mounted) {
              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('تم رفع $totalFilesToUpload ملفات بنجاح! ✅'), backgroundColor: Colors.green));
              Navigator.pop(ctx); 
            }
          } else {
            if (context.mounted) setStateDialog(() => isUploading = false);
          }
        }

        return PopScope(
          canPop: !isUploading,
          onPopInvoked: (didPop) {
            if (!didPop && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ الرجاء الانتظار حتى يكتمل الرفع.'), backgroundColor: Colors.orange));
            }
          },
          child: AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:[
                const Text('معرض المرفقات', style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                if (canManage && !isUploading) 
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add_photo_alternate, size: 18),
                    label: const Text('رفع ملفات جديدة'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, elevation: 4),
                    onPressed: _startUploadProcess,
                  )
              ],
            ),
            content: SizedBox(
              width: 650, // 🌟 توسعة الشاشة لتبدو كمعرض حقيقي
              height: 450, // 🌟 تثبيت الارتفاع ليكون مريحاً على شاشات الديسكتوب
              child: isUploading
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children:[
                            const CircularProgressIndicator(color: Colors.indigo),
                            const SizedBox(height: 24),
                            Text('جاري معالجة ورفع الملف $currentUploadIndex من $totalFilesToUpload', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                            const SizedBox(height: 16),
                            LinearProgressIndicator(
                              value: totalSizeMB > 0 ? (uploadedMB / totalSizeMB) : 0,
                              backgroundColor: Colors.indigo.shade100, color: Colors.indigo, minHeight: 12, borderRadius: BorderRadius.circular(6),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children:[
                                Text('متوسط السرعة: $currentSpeedStr', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                Text('${uploadedMB.toStringAsFixed(2)} / ${totalSizeMB.toStringAsFixed(2)} MB', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 32),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                              icon: const Icon(Icons.cancel), label: Text(isCancelling ? 'جاري الإيقاف...' : 'إلغاء العملية'),
                              onPressed: isCancelling ? null : () {
                                if (context.mounted) setStateDialog(() => isCancelling = true);
                              },
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children:[
                        if (errorMessage != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.shade200)),
                            child: Row(children:[const Icon(Icons.error_outline, color: Colors.red), const SizedBox(width: 8), Expanded(child: Text(errorMessage!, style: TextStyle(color: Colors.red.shade800, fontWeight: FontWeight.bold)))]),
                          ),

                        attachments.isEmpty 
                          ? const Expanded(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.perm_media_outlined, size: 80, color: Colors.black12), SizedBox(height: 16), Text('المعرض فارغ. لا توجد مرفقات.', style: TextStyle(color: Colors.grey, fontSize: 18))]),))
                          
                          // ==========================================
                          // 🖼️ واجهة المعرض الشبكي (Grid Gallery)
                          // ==========================================
                          : Expanded(
                              child: GridView.builder(
                                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 180, // عرض الكرت المربع
                                  childAspectRatio: 0.85,  // نسبة العرض للطول
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                                itemCount: attachments.length,
                                itemBuilder: (context, index) {
                                  final att = attachments[index];
                                  final ext = att.fileType?.toLowerCase() ?? '';
                                  final isImage = ['jpg', 'jpeg', 'png'].contains(ext);
                                  final isPdf = ext == 'pdf';
                                  final isExcel = ['xls', 'xlsx'].contains(ext);
                                  
                                  // أيقونات للملفات التي ليست صوراً
                                  IconData fileIcon = Icons.insert_drive_file;
                                  Color fileColor = Colors.blueGrey;
                                  if (isPdf) { fileIcon = Icons.picture_as_pdf; fileColor = Colors.red; }
                                  else if (isExcel) { fileIcon = Icons.table_chart; fileColor = Colors.green; }
                                  else if (['doc', 'docx'].contains(ext)) { fileIcon = Icons.description; fileColor = Colors.blue.shade800; }

                                  return Card(
                                    elevation: 2, clipBehavior: Clip.antiAlias,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                                    child: Stack(
                                      children:[
                                        // محتوى الكرت (زر مخفي للضغط عليه بالكامل)
                                        InkWell(
                                          onTap: () {
                                            if (isImage) {
                                              _openImageInApp(context, att.fileUrl, att.fileName ?? 'صورة');
                                            } else {
                                              _downloadAndOpenFile(context, att.fileUrl, att.fileName ?? 'ملف.$ext');
                                            }
                                          },
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children:[
                                              // القسم العلوي (الصورة أو الأيقونة)
                                              Expanded(
                                                child: Container(
                                                  color: isImage ? Colors.black12 : Colors.grey.shade100,
                                                  child: isImage
                                                    ? Image.network(att.fileUrl, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.broken_image, color: Colors.grey))
                                                    : Icon(fileIcon, size: 60, color: fileColor),
                                                ),
                                              ),
                                              // القسم السفلي (الاسم والتاريخ)
                                              Container(
                                                padding: const EdgeInsets.all(8),
                                                color: Colors.white,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children:[
                                                    Text(att.fileName ?? 'بدون اسم', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                                    const SizedBox(height: 2),
                                                    Text(DateFormat('yyyy/MM/dd').format(att.createdAt.toLocal()), style: const TextStyle(color: Colors.grey, fontSize: 10)),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        
                                        // زر الحذف العائم (يظهر فقط للمدير)
                                        if (canManage)
                                          Positioned(
                                            top: 4, right: 4,
                                            child: CircleAvatar(
                                              radius: 14, backgroundColor: Colors.white.withOpacity(0.9),
                                              child: IconButton(
                                                padding: EdgeInsets.zero,
                                                icon: const Icon(Icons.delete_forever, color: Colors.red, size: 16),
                                                tooltip: 'حذف المرفق',
                                                onPressed: () {
                                                  cubit.deleteAttachment(att.id);
                                                  Navigator.pop(ctx);
                                                },
                                              ),
                                            ),
                                          ),
                                          
                                        // أيقونة نوع الملف أعلى اليسار للصور
                                        if (isImage)
                                          Positioned(
                                            top: 6, left: 6,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                                              child: Text(ext.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                            ),
                                          )
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
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إغلاق المعرض', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)))
            ],
          ),
        );
      }
    ),
  );
}