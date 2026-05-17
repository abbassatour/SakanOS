//packages\cloud_storage_api\lib\src\cloud_storage_client.dart
import 'dart:io';
import 'package:http/http.dart' as http; // 🌟 استيراد مكتبة HTTP للتعامل مع الرفع المباشر
import 'package:supabase_flutter/supabase_flutter.dart';

/// كلاس [CloudStorageClient] هو المسؤول الحصري عن التخاطب المباشر مع قاعدة بيانات Supabase.
/// لا يجب أن يحتوي هذا الكلاس على أي منطق أعمال (Business Logic)، 
/// وظيفته فقط إرسال واستقبال البيانات بأمان، والتأكد من استخدام التوقيت العالمي (UTC).
class CloudStorageClient {
  CloudStorageClient({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  // 🌟 قناة الاستماع للأسعار الحية (Realtime Channel)
  // تم تعريفها على مستوى الكلاس لكي نتمكن من إغلاقها عند تسجيل الخروج
  RealtimeChannel? _pricesChannel;
  
  // ==========================================
  // 🔐 المصادقة (Authentication)
  // ==========================================
  
  /// جلب معرّف المستخدم الحالي (ID)
  String? get currentUserId => _supabase.auth.currentUser?.id;

  /// تسجيل الدخول باستخدام البريد الإلكتروني وكلمة المرور
  Future<void> signIn({required String email, required String password}) async {
    await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  // 🌟 الدالة الجديدة التي تمت إضافتها
  /// تسجيل موظف جديد (SignUp)
  Future<void> signUp({required String fullName, required String email, required String password}) async {
    await _supabase.auth.signUp(
      email: email,
      password: password,
      // 🌟 السحر هنا: نرسل الاسم داخل الـ metadata لكي يلتقطه الـ Trigger في قاعدة البيانات
      data: {'full_name': fullName}, 
    );
  }

  /// تسجيل الخروج الآمن
  /// بالإضافة إلى إنهاء الجلسة، يقوم بإيقاف محرك الاستماع الحي لمنع تسريب الذاكرة (Memory Leak)
  Future<void> signOut() async {
    await _supabase.auth.signOut();
    _pricesChannel?.unsubscribe();
  }

  // ==========================================
  // 📡 محرك الاستماع السحابي الحي (Realtime Sync)
  // ==========================================
  
  /// بدء الاستماع لأي تغيير يطرأ على جدول أسعار المواد في السحابة
  /// بمجرد حدوث تغيير (إضافة/تعديل/حذف) من أي جهاز آخر، سيتم استدعاء الدالة[onDataChanged]
  void startListeningToCloudChanges({required Function() onDataChanged}) {
    print('🎧 جاري بدء الاستماع لقناة Supabase Realtime...');
    
    // إغلاق أي اتصال سابق لمنع تكرار الاستماع
    _pricesChannel?.unsubscribe();

    _pricesChannel = _supabase
        .channel('public:material_prices')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'material_prices',
          callback: (payload) {
            print('🔥 السحابة تتحدث! نوع التغيير: ${payload.eventType}');
            print('📦 البيانات: ${payload.newRecord}');
            
            // إبلاغ الطبقة الأعلى (Repository) بحدوث تغيير لتقوم بجلب البيانات الجديدة
            onDataChanged(); 
          },
        )
        .subscribe((status,[error]) {
           if (status == 'SUBSCRIBED') {
             print('✅ تم الاتصال بقناة Supabase بنجاح، التطبيق الآن يستمع للأسعار الحية.');
           } else {
             print('⚠️ حالة قناة Supabase: $status | خطأ: $error');
           }
        });
  }



  // ==========================================
  // 📥 دوال سحب البيانات (PULL from Cloud)
  // ==========================================
  // ملاحظة مهمة جداً (UTC): في جميع الاستعلامات التي تعتمد على `lastSync`، 
  // نقوم قسرياً باستخدام `.toUtc()` قبل `.toIso8601String()` لضمان أننا نسأل السحابة 
  // بناءً على التوقيت العالمي، لأن السحابة تخزن التواريخ بصيغة UTC.
  
  
  
  // 📥 جلب العملاء (تزايدي - Incremental Sync)
  Future<List<Map<String, dynamic>>> getClients({DateTime? lastSync}) async {
    var query = _supabase.from('clients').select();
    if (lastSync != null) {
      // 🌍 التعديل الذهبي: فرض الـ UTC لضمان المزامنة الصحيحة عبر المناطق الزمنية
      query = query.gte('updated_at', lastSync.toUtc().toIso8601String()); 
    }
    return await query;
  }

  // 📥 جلب الأدوار/القوالب (تزايدي)
  Future<List<Map<String, dynamic>>> getAppRoles({DateTime? lastSync}) async {
    var query = _supabase.from('app_roles').select();
    if (lastSync != null) {
      query = query.gte('updated_at', lastSync.toUtc().toIso8601String());
    }
    return await query;
  }

  // 📥 جلب المستخدمين وصلاحياتهم (تزايدي)
  Future<List<Map<String, dynamic>>> getAppUsers({DateTime? lastSync}) async {
    var query = _supabase.from('app_users').select();
    if (lastSync != null) {
      query = query.gte('updated_at', lastSync.toUtc().toIso8601String());
    }
    return await query;
  }
  
  // 📥 جلب العقود (تزايدي)
  Future<List<Map<String, dynamic>>> getContracts({DateTime? lastSync}) async {
    var query = _supabase.from('contracts').select();
    if (lastSync != null) {
      // 🌍 فرض الـ UTC
      query = query.gte('updated_at', lastSync.toUtc().toIso8601String());
    }
    return await query;
  }

  // 📥 جلب الدفعات (تزايدي)
  Future<List<Map<String, dynamic>>> getPayments({DateTime? lastSync}) async {
    var query = _supabase.from('payments').select(); 
    if (lastSync != null) {
      // 🌍 فرض الـ UTC
      query = query.gte('updated_at', lastSync.toUtc().toIso8601String()); 
    }
    return await query;
  }

  // 📥 جلب جدول الاستحقاقات (تزايدي)
  Future<List<Map<String, dynamic>>> getSchedules({DateTime? lastSync}) async {
    var query = _supabase.from('installments_schedule').select();
    if (lastSync != null) {
      // 🌍 فرض الـ UTC
      query = query.gte('updated_at', lastSync.toUtc().toIso8601String()); 
    }
    return await query;
  }

  // 🌟 جلب سجل أسعار المواد (غالباً لا نحتاج lastSync هنا إن كنا نجلب السجل كاملاً للإحصائيات)
  Future<List<Map<String, dynamic>>> getMaterialPrices() async => 
      await _supabase.from('material_prices').select();

  // 📥 جلب المحاضر (Buildings)
  Future<List<Map<String, dynamic>>> getBuildings() async => 
      await _supabase.from('buildings').select();
      
  // 📥 جلب الشقق (Apartments)
  Future<List<Map<String, dynamic>>> getApartments() async => 
      await _supabase.from('apartments').select();


  // 📥 جلب الإجراءات القانونية
  Future<List<Map<String, dynamic>>> getLegalActions({DateTime? lastSync}) async {
    var query = _supabase.from('legal_actions').select();
    if (lastSync != null) {
      query = query.gte('updated_at', lastSync.toUtc().toIso8601String());
    }
    return await query;
  }

  // 📥 جلب أسعار الدولار (Pull)
  Future<List<Map<String, dynamic>>> getDollarPrices({DateTime? lastSync}) async {
    var query = _supabase.from('dollar_prices').select();
    if (lastSync != null) {
      query = query.gte('updated_at', lastSync.toUtc().toIso8601String());
    }
    return await query;
  }

  // ==========================================
  // 📤 دوال رفع البيانات (PUSH to Cloud) - (UPSERT)
  // ==========================================
  // 🌍 تنبيه هندسي (UTC Warning): 
  // بما أن هذه الدوال تستقبل `Map<String, dynamic>`، فهذا يعني أن الكائنات (Objects) 
  // تم تحويلها إلى خرائط (JSON Maps) في مكان آخر (في الـ Repository أو الـ Models).
  // **يجب** أن نضمن في ذلك المكان أن أي حقل يحتوي على وقت (مثل createdAt أو updatedAt)
  // قد تم تحويله إلى نص باستخدام `dateTime.toUtc().toIso8601String()`.
  
  // 📤 رفع العملاء
  Future<void> upsertClient(Map<String, dynamic> clientData) async => 
      await _supabase.from('clients').upsert(clientData);
      

      // 📤 رفع الأدوار (القوالب)
  Future<void> upsertAppRole(Map<String, dynamic> roleData) async => 
      await _supabase.from('app_roles').upsert(roleData);

  // 📤 رفع تعديلات المستخدمين (مثل تعيين دور لمستخدم)
  Future<void> upsertAppUser(Map<String, dynamic> userData) async => 
      await _supabase.from('app_users').upsert(userData);

      
  // 📤 رفع العقود
  Future<void> upsertContract(Map<String, dynamic> contractData) async => 
      await _supabase.from('contracts').upsert(contractData);
      
  // 📤 رفع الدفعات
  Future<void> upsertPayment(Map<String, dynamic> paymentData) async => 
    await _supabase.from('payments').upsert(paymentData);

  // 📤 رفع جدول الاستحقاقات (يمكنه رفع قائمة كاملة كـ Batch Insert)
  Future<void> upsertSchedule(List<Map<String, dynamic>> scheduleData) async =>  
      await _supabase.from('installments_schedule').upsert(scheduleData);

  // 📤 رفع أسعار المواد
  Future<void> upsertMaterialPrices(Map<String, dynamic> pricesData) async => 
      await _supabase.from('material_prices').upsert(pricesData);

  // 📤 رفع المحاضر (Buildings)
  Future<void> upsertBuilding(Map<String, dynamic> buildingData) async => 
      await _supabase.from('buildings').upsert(buildingData);
      
  // 📤 رفع الشقق (Apartments)
  Future<void> upsertApartment(Map<String, dynamic> apartmentData) async => 
      await _supabase.from('apartments').upsert(apartmentData);

  // 📤 رفع الإجراءات القانونية
  Future<void> upsertLegalAction(Map<String, dynamic> data) async => 
      await _supabase.from('legal_actions').upsert(data);

  // 📤 رفع أسعار الدولار (Push / Upsert)
  Future<void> upsertDollarPrice(Map<String, dynamic> data) async => 
      await _supabase.from('dollar_prices').upsert(data);

  // ==========================================
  // 📂 رفع الملفات إلى Supabase Storage (طريقة التجاوز المباشر HTTP)
  // ==========================================
  /// تقوم هذه الدالة برفع ملف العقد (PDF/Doc) إلى سلة تخزين Supabase.
  /// تم استخدام مكتبة HTTP مباشرة لتجاوز بعض المشاكل المتعلقة بمكتبة Storage الأصلية،
  /// مما يعطينا تحكماً كاملاً بالـ Headers والـ Auth Token.
  Future<String> uploadContractFile({
    required String contractId, 
    required File file, 
    required String extension
  }) async {
    const bucketName = 'erp_contracts'; // اسم السلة (Bucket) في Supabase
    final fileName = 'contract_$contractId.$extension';

    // 1. جلب مفتاح الجلسة الحالي (JWT) للمصادقة للسماح بالرفع
    final session = _supabase.auth.currentSession;
    if (session == null) throw Exception('يجب تسجيل الدخول لرفع الملفات.');
    final jwtToken = session.accessToken;

    // 2. قراءة الملف كبيانات خام (Bytes)
    final bytes = file.readAsBytesSync();

    // 3. تحديد نوع الملف (MIME Type) لتتعرف عليه السحابة
    String contentType = 'application/octet-stream'; // الافتراضي
    if (extension == 'pdf') contentType = 'application/pdf';
    if (extension == 'doc' || extension == 'docx') contentType = 'application/msword';

    // 4. 🌟 الرابط المباشر لـ Supabase API
    const projectId = 'krdfrdzyfdcqjmnuzads';
    final uploadUrl = Uri.parse('https://$projectId.supabase.co/storage/v1/object/$bucketName/$fileName');

    // 5. إطلاق صاروخ الـ HTTP مباشرة للسيرفر (Post Request)
    final response = await http.post(
      uploadUrl,
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': contentType,
        'x-upsert': 'true', // هذه القيمة تسمح باستبدال الملف لو تم رفعه مسبقاً بنفس الاسم
      },
      body: bytes,
    );

    // 6. التحقق من الرد (Status Code 200 يعني نجاح العملية) وإرجاع الرابط العام
    if (response.statusCode == 200) {
      final publicUrl = 'https://$projectId.supabase.co/storage/v1/object/public/$bucketName/$fileName';
      return publicUrl;
    } else {
      throw Exception('فشل الرفع من السيرفر: ${response.statusCode} - ${response.body}');
    }
  }


  // ==========================================
  // 📎 دوال مرفقات الإجراءات القانونية (تمت الإضافة)
  // ==========================================

  // 1. 📥 جلب سجلات المرفقات من السحابة (تزايدي)
  Future<List<Map<String, dynamic>>> getLegalActionAttachments({DateTime? lastSync}) async {
    var query = _supabase.from('legal_action_attachments').select();
    if (lastSync != null) {
      query = query.gte('updated_at', lastSync.toUtc().toIso8601String());
    }
    return await query;
  }

  // 2. 📤 رفع سجل المرفق إلى السحابة
  Future<void> upsertLegalActionAttachment(Map<String, dynamic> data) async => 
      await _supabase.from('legal_action_attachments').upsert(data);

  // 3. 📂 رفع الملف الفعلي (PDF/صورة) إلى سلة المرفقات
  Future<String> uploadLegalAttachmentFile({
    required String attachmentId, 
    required File file, 
    required String extension
  }) async {
    // ⚠️ يجب إنشاء سلة (Bucket) في Supabase باسم 'legal_attachments'
    const bucketName = 'legal_attachments'; 
    final fileName = 'attach_$attachmentId.$extension';

    final session = _supabase.auth.currentSession;
    if (session == null) throw Exception('يجب تسجيل الدخول لرفع الملفات.');
    final jwtToken = session.accessToken;

    final bytes = file.readAsBytesSync();

    String contentType = 'application/octet-stream';
    if (extension == 'pdf') contentType = 'application/pdf';
    if (extension == 'png') contentType = 'image/png';
    if (extension == 'jpg' || extension == 'jpeg') contentType = 'image/jpeg';
    if (extension == 'doc' || extension == 'docx') contentType = 'application/msword';
    // 🌟 السطرين الجديدين لدعم الإكسل 🌟
    if (extension == 'xls') contentType = 'application/vnd.ms-excel';
    if (extension == 'xlsx') contentType = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    

    const projectId = 'krdfrdzyfdcqjmnuzads'; // نفس البروجيكت آي دي الخاص بك
    final uploadUrl = Uri.parse('https://$projectId.supabase.co/storage/v1/object/$bucketName/$fileName');

    final response = await http.post(
      uploadUrl,
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': contentType,
        'x-upsert': 'true', 
      },
      body: bytes,
    );

    if (response.statusCode == 200) {
      return 'https://$projectId.supabase.co/storage/v1/object/public/$bucketName/$fileName';
    } else {
      throw Exception('فشل رفع المرفق: ${response.statusCode} - ${response.body}');
    }
  }
  
}