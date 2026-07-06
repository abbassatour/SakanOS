//packages\cloud_storage_api\lib\src
/// حزمة إدارة التخزين السحابي (Supabase API)
library cloud_storage_api;

// تصدير مكتبة Supabase لكي نتمكن من تهيئتها (Initialize) في ملف bootstrap.dart لاحقاً
export 'package:supabase_flutter/supabase_flutter.dart'
    show Supabase, SupabaseClient;

// تصدير العميل الذي كتبناه
export 'src/cloud_storage_client.dart';
