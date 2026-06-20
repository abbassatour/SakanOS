// مسار الملف: lib/clients/view/clients_view.dart
// المسؤولية: الهيكل الرئيسي للواجهة، وتجميع مكونات البحث والجدول وإدارة الصلاحيات.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/cubit/auth_cubit.dart';
import '../../../core/constants/app_permissions.dart';
import '../cubit/clients_cubit.dart';
import '../widgets/widgets.dart'; // استيراد ملف الـ Barrel لجميع المكونات

class ClientsView extends StatefulWidget {
  const ClientsView({super.key});

  @override
  State<ClientsView> createState() => _ClientsViewState();
}

class _ClientsViewState extends State<ClientsView> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // 🌟 الأداء المذهل هنا: نراقب الصلاحيات باستخدام `select` بدلاً من `watch`
    // بحيث لا يتم إعادة بناء الشاشة أبداً إلا إذا تغيرت هذه الصلاحية تحديداً.
    final canCreate = context.select(
      (AuthCubit cubit) => cubit.state.hasPermission(AppPermissions.createClients),
    );
    final canEdit = context.select(
      (AuthCubit cubit) => cubit.state.hasPermission(AppPermissions.editClients),
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      
      // ==========================================
      // 🛡️ حماية زر إضافة عميل (استراتيجية الزر الباهت)
      // ==========================================
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: canCreate ? () => showAddClientDialog(context) : null,
        icon: const Icon(Icons.person_add),
        label: const Text('إضافة عميل', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: canCreate ? Colors.blueAccent : Colors.grey.shade300,
        foregroundColor: canCreate ? Colors.white : Colors.grey.shade600,
        elevation: canCreate ? 6 : 0,
        tooltip: canCreate ? 'إضافة عميل جديد' : 'لا تملك صلاحية إضافة عملاء',
      ),
      
      body: SafeArea(
        child: BlocConsumer<ClientsCubit, ClientsState>(
          // 🌟 تجنب إعادة تشغيل الـ Listener عبثاً
          listenWhen: (previous, current) => previous.status != current.status,
          listener: (context, state) {
            if (state.status == ClientsStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.errorMessage ?? 'حدث خطأ غير متوقع',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Colors.red.shade700,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            // حالة التحميل الأولية
            if (state.status == ClientsStatus.loading && state.clients.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
            }

            // حالة عدم وجود بيانات (قائمة فارغة)
            if (state.clients.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.group_off, size: 80, color: Colors.blue.shade200),
                    const SizedBox(height: 16),
                    const Text(
                      'لا يوجد عملاء مضافين حتى الآن.',
                      style: TextStyle(fontSize: 18, color: Colors.blueGrey),
                    ),
                  ],
                ),
              );
            }

            // فلترة القائمة بناءً على نص البحث
            final filteredClients = state.clients.where((client) {
              if (_searchQuery.isEmpty) return true;

              final searchLower = _searchQuery.toLowerCase();
              final idShort = client.id.split('-').first.toLowerCase();

              return client.name.toLowerCase().contains(searchLower) ||
                  client.phone.contains(searchLower) ||
                  (client.nationalId?.contains(searchLower) ?? false) ||
                  idShort.contains(searchLower);
            }).toList();

            return Column(
              children: [
                // ==========================================
                // 🌟 استدعاء شريط البحث المعزول
                // ==========================================
                ClientSearchBar(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  filteredCount: filteredClients.length,
                ),

                // ==========================================
                // 🌟 استدعاء الجدول المعزول
                // ==========================================
                Expanded(
                  child: filteredClients.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_search, size: 80, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text(
                                'لا يوجد نتائج مطابقة لبحثك.',
                                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        )
                      : ClientTable(
                          filteredClients: filteredClients,
                          canEdit: canEdit, // تمرير الصلاحية للجدول
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}