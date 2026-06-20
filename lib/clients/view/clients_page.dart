// مسار الملف: lib/clients/view/clients_page.dart
// المسؤولية: نقطة الدخول الرئيسية لصفحة العملاء من نظام التوجيه (Router).

import 'package:flutter/material.dart';

import 'clients_view.dart';

class ClientsPage extends StatelessWidget {
  const ClientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // إذا كنت تحتاج مستقبلاً إلى توفير BlocProvider جديد خاص بهذه الشاشة، 
    // فهذا هو المكان الأنسب له. حالياً نعرض الـ View مباشرة.
    return const ClientsView();
  }
}
