import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http; // 🌟 المكتبة السحرية للتجاوز المباشر

class StorageTestPage extends StatefulWidget {
  const StorageTestPage({super.key});

  @override
  State<StorageTestPage> createState() => _StorageTestPageState();
}

class _StorageTestPageState extends State<StorageTestPage> {
  String _logText = "اضغط على الزر لبدء الاختبار...";
  bool _isLoading = false;

  void _addLog(String message) {
    print(message);
    setState(() {
      _logText += "\n$message";
    });
  }

  Future<void> runStorageTest() async {
    setState(() {
      _logText = "--- 🚀 بدء الرفع المباشر (تجاوز مكتبة Supabase) ---";
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;
      const bucketName = 'erp_contracts';

      // 1. التحقق من الاتصال وجلب الـ Token
      _addLog("⏳ [1] جلب الـ JWT Token...");
      final session = supabase.auth.currentSession;
      if (session == null) {
        _addLog("❌ خطأ: لا يوجد مستخدم مسجل الدخول!");
        setState(() => _isLoading = false);
        return;
      }
      final String jwtToken = session.accessToken;
      _addLog("✅ تم جلب مفتاح الجلسة بنجاح.");

      // 2. اختيار الملف
      _addLog("⏳ [2] يرجى اختيار ملف العقد...");
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result == null || result.files.single.path == null) {
        _addLog("⚠️ تم إلغاء الاختيار.");
        setState(() => _isLoading = false);
        return;
      }

      final file = File(result.files.single.path!);
      final extension = result.files.single.extension ?? 'docx';

      // 🌟 تنظيف اسم الملف تماماً لتجنب أي مشاكل في الروابط (أرقام فقط)
      final fileName =
          'contract_${DateTime.now().millisecondsSinceEpoch}.$extension';

      _addLog("✅ الملف جاهز: $fileName");
      _addLog("⏳ [3] جاري قراءة البيانات...");
      final bytes = file.readAsBytesSync();

      // تحديد نوع الملف (MIME)
      String contentType = 'application/octet-stream';
      if (extension == 'pdf') contentType = 'application/pdf';
      if (extension == 'doc' || extension == 'docx')
        contentType = 'application/msword';

      _addLog("⏳ [4] جاري إطلاق صاروخ الـ HTTP المباشر للسيرفر...");

      // 🌟 الرابط المباشر للرفع (نستخرج الـ Project ID من رابط الـ Supabase الأساسي)
      // مشروعك هو: krdfrdzyfdcqjmnuzads
      final projectId = 'krdfrdzyfdcqjmnuzads';
      final directUrl = Uri.parse(
        'https://$projectId.supabase.co/storage/v1/object/$bucketName/$fileName',
      );

      // 🌟 بناء الطلب يدوياً لتجاوز خطأ 404 الخاص بـ supabase_flutter
      final response = await http.post(
        directUrl,
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': contentType,
          'x-upsert': 'true', // استبدال الملف لو كان موجوداً
        },
        body: bytes,
      );

      // 5. فحص رد السيرفر الحقيقي
      if (response.statusCode == 200) {
        final publicUrl =
            'https://$projectId.supabase.co/storage/v1/object/public/$bucketName/$fileName';
        _addLog("🎉🎉 نجاح ساحق! تم رفع العقد بنجاح تام.");
        _addLog("🔗 الرابط: $publicUrl");
      } else {
        _addLog("❌ السيرفر رفض الطلب!");
        _addLog("الكود: ${response.statusCode}");
        _addLog("الرد: ${response.body}");
      }
    } catch (e, stacktrace) {
      _addLog("❌❌ خطأ برمجي عام:");
      _addLog(e.toString());
      print(stacktrace);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('أداة الفحص والتجاوز (Direct HTTP)')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(20),
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: _isLoading ? null : runStorageTest,
              icon: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Icon(Icons.rocket_launch, size: 30),
              label: const Text(
                'إطلاق الرفع المباشر',
                style: TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'سجل العمليات (Logs):',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const Divider(),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.black87,
                child: SingleChildScrollView(
                  child: Text(
                    _logText,
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontFamily: 'Consolas',
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
