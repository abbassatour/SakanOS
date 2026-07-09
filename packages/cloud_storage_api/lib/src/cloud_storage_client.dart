//packages\cloud_storage_api\lib\src\cloud_storage_client.dart
import 'dart:io';
import 'package:http/http.dart'
    as http; // 🌟 استيراد مكتبة HTTP للتعامل مع الرفع المباشر
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
  // ⚙️ دالة مساعدة لتجاوز حد الـ 1000 سجل (Pagination)
  // ==========================================
  Future<List<Map<String, dynamic>>> _fetchAllPaginated(
    String tableName, {
    DateTime? lastSync,
  }) async {
    const int limit = 1000;
    int offset = 0;
    List<Map<String, dynamic>> allData = [];
    bool hasMore = true;

    while (hasMore) {
      var query = _supabase.from(tableName).select();

      if (lastSync != null) {
        // 🌍 التعديل الذهبي: فرض الـ UTC
        query = query.gte('updated_at', lastSync.toUtc().toIso8601String());
      }

      // سحب دفعة (Chunk) من البيانات
      final response = await query.range(offset, offset + limit - 1);
      final List<Map<String, dynamic>> chunk = List<Map<String, dynamic>>.from(
        response,
      );

      allData.addAll(chunk);

      // إذا كانت الدفعة أقل من الحد الأقصى، فهذا يعني أننا وصلنا للنهاية
      if (chunk.length < limit) {
        hasMore = false;
      } else {
        offset += limit; // الانتقال للدفعة التالية
      }
    }

    return allData;
  }

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
  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
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
        .subscribe((status, [error]) {
          if (status == RealtimeSubscribeStatus.subscribed) {
            print(
              '✅ تم الاتصال بقناة Supabase بنجاح، التطبيق الآن يستمع للأسعار الحية.',
            );
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

  // ==========================================
  // 📥 دوال سحب البيانات (PULL from Cloud) محصنة ضد الـ 1000 Limit
  // ==========================================

  Future<List<Map<String, dynamic>>> getClients({DateTime? lastSync}) =>
      _fetchAllPaginated('clients', lastSync: lastSync);

  Future<List<Map<String, dynamic>>> getAppRoles({DateTime? lastSync}) =>
      _fetchAllPaginated('app_roles', lastSync: lastSync);

  Future<List<Map<String, dynamic>>> getAppUsers({DateTime? lastSync}) =>
      _fetchAllPaginated('app_users', lastSync: lastSync);

  Future<List<Map<String, dynamic>>> getContracts({DateTime? lastSync}) =>
      _fetchAllPaginated('contracts', lastSync: lastSync);

  Future<List<Map<String, dynamic>>> getPayments({DateTime? lastSync}) =>
      _fetchAllPaginated('payments', lastSync: lastSync);

  Future<List<Map<String, dynamic>>> getSchedules({DateTime? lastSync}) =>
      _fetchAllPaginated('installments_schedule', lastSync: lastSync);

  Future<List<Map<String, dynamic>>> getMaterialPrices() =>
      _fetchAllPaginated('material_prices');

  Future<List<Map<String, dynamic>>> getBuildings() =>
      _fetchAllPaginated('buildings');

  Future<List<Map<String, dynamic>>> getApartments() =>
      _fetchAllPaginated('apartments');

  Future<List<Map<String, dynamic>>> getLegalActions({DateTime? lastSync}) =>
      _fetchAllPaginated('legal_actions', lastSync: lastSync);

  Future<List<Map<String, dynamic>>> getDollarPrices({DateTime? lastSync}) =>
      _fetchAllPaginated('dollar_prices', lastSync: lastSync);

  Future<List<Map<String, dynamic>>> getLegalActionAttachments({
    DateTime? lastSync,
  }) => _fetchAllPaginated('legal_action_attachments', lastSync: lastSync);

  Future<List<Map<String, dynamic>>> getContractAttachments({
    DateTime? lastSync,
  }) => _fetchAllPaginated('contract_attachments', lastSync: lastSync);

  Future<List<Map<String, dynamic>>> getApartmentAttachments({
    DateTime? lastSync,
  }) => _fetchAllPaginated('apartment_attachments', lastSync: lastSync);
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

  // 📤 رفع سجل مرفقات الشقق إلى السحابة
  Future<void> upsertApartmentAttachment(Map<String, dynamic> data) async =>
      await _supabase.from('apartment_attachments').upsert(data);

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

  // ==========================================
  // 📎 دوال مرفقات الإجراءات القانونية (تمت الإضافة)
  // ==========================================

  // 2. 📤 رفع سجل المرفق إلى السحابة
  Future<void> upsertLegalActionAttachment(Map<String, dynamic> data) async =>
      await _supabase.from('legal_action_attachments').upsert(data);

  // 📤 رفع سجل مرفقات العقود إلى السحابة
  Future<void> upsertContractAttachment(Map<String, dynamic> data) async =>
      await _supabase.from('contract_attachments').upsert(data);

  // 3. 📂 رفع الملف الفعلي (PDF/صورة) إلى سلة المرفقات
  Future<String> uploadLegalAttachmentFile({
    required String attachmentId,
    required File file,
    required String extension,
  }) async {
    // ⚠️ يجب إنشاء سلة (Bucket) في Supabase باسم 'legal_attachments'
    const bucketName = 'legal_attachments';
    final fileName = 'attach_$attachmentId.$extension';

    var session = _supabase.auth.currentSession;
    if (session == null) throw Exception('يجب تسجيل الدخول لرفع الملفات.');

    if (session.isExpired) {
      final response = await _supabase.auth.refreshSession();
      session = response.session;
    }

    final jwtToken = session?.accessToken;
    if (jwtToken == null) throw Exception('فشل الحصول على مفتاح الجلسة الآمن.');

    final bytes = file.readAsBytesSync();

    String contentType = 'application/octet-stream';
    if (extension == 'pdf') contentType = 'application/pdf';
    if (extension == 'png') contentType = 'image/png';
    if (extension == 'jpg' || extension == 'jpeg') contentType = 'image/jpeg';
    if (extension == 'doc' || extension == 'docx')
      contentType = 'application/msword';
    // 🌟 السطرين الجديدين لدعم الإكسل 🌟
    if (extension == 'xls') contentType = 'application/vnd.ms-excel';
    if (extension == 'xlsx')
      contentType =
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

    // استخراج رابط الـ Storage السحابي ديناميكياً
    final String storageUrl = _supabase.storage.url;
    final uploadUrl = Uri.parse(
      '$storageUrl/object/$bucketName/$fileName',
    );

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
      return fileName; // 🌟 تم التعديل: إرجاع اسم الملف فقط
    } else {
      throw Exception(
        'فشل رفع المرفق: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // 📂 رفع الملف الفعلي (مرفقات العقود الجديدة) إلى سلة المرفقات
  Future<String> uploadContractAttachmentFile({
    required String attachmentId,
    required File file,
    required String extension,
  }) async {
    const bucketName = 'contract_attachments';
    final fileName = 'attach_$attachmentId.$extension';

    var session = _supabase.auth.currentSession;
    if (session == null) throw Exception('يجب تسجيل الدخول لرفع الملفات.');

    if (session.isExpired) {
      final response = await _supabase.auth.refreshSession();
      session = response.session;
    }

    final jwtToken = session?.accessToken;
    if (jwtToken == null) throw Exception('فشل الحصول على مفتاح الجلسة الآمن.');

    final bytes = file.readAsBytesSync();

    String contentType = 'application/octet-stream';
    if (extension == 'pdf') contentType = 'application/pdf';
    if (extension == 'png') contentType = 'image/png';
    if (extension == 'jpg' || extension == 'jpeg') contentType = 'image/jpeg';
    if (extension == 'doc' || extension == 'docx')
      contentType = 'application/msword';
    if (extension == 'xls') contentType = 'application/vnd.ms-excel';
    if (extension == 'xlsx')
      contentType =
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

    // استخراج رابط الـ Storage السحابي ديناميكياً
    final String storageUrl = _supabase.storage.url;
    final uploadUrl = Uri.parse('$storageUrl/object/$bucketName/$fileName');

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
      return fileName; // إرجاع اسم الملف فقط لحفظه في الداتابيز
    } else {
      throw Exception(
        'فشل رفع مرفق العقد: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // 📂 رفع الملف الفعلي (مرفقات الشقق) إلى سلة المرفقات
  Future<String> uploadApartmentAttachmentFile({
    required String attachmentId,
    required File file,
    required String extension,
  }) async {
    const bucketName =
        'apartment_attachments'; // ⚠️ تأكد من إنشاء هذه السلة في Supabase
    final fileName = 'attach_$attachmentId.$extension';

    var session = _supabase.auth.currentSession;
    if (session == null) throw Exception('يجب تسجيل الدخول لرفع الملفات.');

    if (session.isExpired) {
      final response = await _supabase.auth.refreshSession();
      session = response.session;
    }

    final jwtToken = session?.accessToken;
    if (jwtToken == null) throw Exception('فشل الحصول على مفتاح الجلسة الآمن.');

    final bytes = file.readAsBytesSync();

    String contentType = 'application/octet-stream';
    if (extension == 'pdf') contentType = 'application/pdf';
    if (extension == 'png') contentType = 'image/png';
    if (extension == 'jpg' || extension == 'jpeg') contentType = 'image/jpeg';
    if (extension == 'doc' || extension == 'docx')
      contentType = 'application/msword';
    if (extension == 'xls') contentType = 'application/vnd.ms-excel';
    if (extension == 'xlsx')
      contentType =
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

    // استخراج رابط الـ Storage السحابي ديناميكياً
    final String storageUrl = _supabase.storage.url;
    final uploadUrl = Uri.parse('$storageUrl/object/$bucketName/$fileName');

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
      return fileName;
    } else {
      throw Exception(
        'فشل رفع مرفق الشقة: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // ==========================================
  // 🔐 توليد الروابط الآمنة المؤقتة (Signed URLs)
  // ==========================================
  Future<String> getSecureSignedUrl(
    String bucketName,
    String storedPath,
  ) async {
    String actualFileName = storedPath;

    // توافقية رجعية (Backward Compatibility):
    // إذا كان المسار المخزن هو رابط قديم (Public URL)، نستخرج اسم الملف منه.
    if (storedPath.startsWith('http')) {
      final uri = Uri.parse(storedPath);
      final segments = uri.pathSegments;
      final bucketIndex = segments.indexOf(bucketName);
      if (bucketIndex != -1 && bucketIndex < segments.length - 1) {
        actualFileName = segments.sublist(bucketIndex + 1).join('/');
      }
    }

    // توليد رابط آمن صالح لمدة 5 دقائق (300 ثانية)
    final signedUrl = await _supabase.storage
        .from(bucketName)
        .createSignedUrl(actualFileName, 300);
    return signedUrl;
  }
}
