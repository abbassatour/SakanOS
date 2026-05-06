// lib/main_development.dart
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart'; 
import 'package:our_home_erp_app/app/app.dart';
import 'package:our_home_erp_app/bootstrap.dart';

void main() async {
  // 1. التأكد من تهيئة بيئة فلاتر والنافذة أولاً
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  // 2. إعدادات النافذة الافتراضية
  WindowOptions windowOptions = const WindowOptions(
    title: 'نظام بيتنا العقاري', 
    center: true,
    minimumSize: Size(800, 600), // يفضل وضع حجم أدنى لكي لا يصغر الموظف الشاشة جداً وتختفي الأزرار
  );
  
  // 3. التحكم بالنافذة قبل إظهارها للمستخدم
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    
    // 🌟 السطر السحري الجديد: تكبير النافذة لتأخذ كامل الشاشة (Maximized) تلقائياً
    await windowManager.maximize(); 
  });

  // 4. تشغيل التطبيق
  bootstrap((erpRepository) => App(erpRepository: erpRepository));
}