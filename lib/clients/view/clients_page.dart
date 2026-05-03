// lib/clients/view/clients_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erp_repository/erp_repository.dart'; 
import '../cubit/clients_cubit.dart';
import 'dialogs/add_client_dialog.dart';
import 'dialogs/edit_client_dialog.dart';

import '../../dashboard/cubit/dashboard_cubit.dart';
import '../../payments/cubit/payments_cubit.dart';
import '../../schedule/cubit/schedule_cubit.dart';
import '../../profile/cubit/client_profile_cubit.dart';
import '../../profile/view/client_profile_page.dart';

// 🌟 استدعاء الحارس الشخصي والصلاحيات
import '../../auth/cubit/auth_cubit.dart';
import '../../core/constants/app_permissions.dart';

class ClientsPage extends StatelessWidget {
  const ClientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ClientsView();
  }
}

class ClientsView extends StatefulWidget {
  const ClientsView({super.key});

  @override
  State<ClientsView> createState() => _ClientsViewState();
}

class _ClientsViewState extends State<ClientsView> {
  String _searchQuery = ''; 

  @override
  Widget build(BuildContext context) {
    // 🌟 جلب حالة الصلاحيات للمستخدم الحالي
    final authState = context.watch<AuthCubit>().state;
    
    // 🌟 استخراج الصلاحيات كمتغيرات منطقية (True / False)
    final canCreate = authState.hasPermission(AppPermissions.createClients);
    final canEdit = authState.hasPermission(AppPermissions.editClients);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      // لا يوجد AppBar أبداً
      
      // ==========================================
      // 🛡️ حماية زر إضافة عميل (استراتيجية الزر الباهت)
      // ==========================================
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        // إذا لم يكن لديه صلاحية، نعطيه null لتعطيل الضغط
        onPressed: canCreate ? () => showAddClientDialog(context) : null,
        icon: const Icon(Icons.person_add),
        label: const Text('إضافة عميل', style: TextStyle(fontWeight: FontWeight.bold)),
        // تغيير اللون وإزالة الظل بناءً على الصلاحية
        backgroundColor: canCreate ? Colors.blueAccent : Colors.grey.shade300,
        foregroundColor: canCreate ? Colors.white : Colors.grey.shade600,
        elevation: canCreate ? 6 : 0, 
        tooltip: canCreate ? 'إضافة عميل جديد' : 'لا تملك صلاحية إضافة عملاء',
      ),
      
      // 🌟 الشاشة تبدأ فوراً من المنطقة الآمنة
      body: SafeArea(
        child: BlocConsumer<ClientsCubit, ClientsState>(
          listener: (context, state) {
            if (state.status == ClientsStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'حدث خطأ غير متوقع', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  backgroundColor: Colors.red.shade700,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.status == ClientsStatus.loading && state.clients.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
            }

            if (state.clients.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:[
                    Icon(Icons.group_off, size: 80, color: Colors.blue.shade200),
                    const SizedBox(height: 16),
                    const Text('لا يوجد عملاء مضافين حتى الآن.', style: TextStyle(fontSize: 18, color: Colors.blueGrey)),
                  ],
                )
              );
            }

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
              children:[
                // ==========================================
                // 🌟 شريط البحث المضغوط في أعلى الشاشة (بدون مساحات مهدورة)
                // ==========================================
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12), // هوامش صغيرة جداً
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow:[BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))],
                  ),
                  child: Row(
                    children:[
                      Expanded(
                        child: SizedBox(
                          height: 48, // 🌟 ارتفاع صغير ومناسب لحقل البحث
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value; 
                              });
                            },
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            decoration: InputDecoration(
                              // دمج الأيقونة داخل الحقل لتوفير المساحة
                              prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                              hintText: 'ابحث عن اسم، هاتف، أو رقم وطني...',
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0), // إزالة الحشو الداخلي الزائد
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
                              ),
                              suffixIcon: _searchQuery.isNotEmpty 
                                ? IconButton(
                                    icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
                                    onPressed: () {
                                      setState(() => _searchQuery = '');
                                      FocusScope.of(context).unfocus();
                                    },
                                  ) 
                                : null,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 🌟 مؤشر العدد المضغوط
                      Container(
                        height: 48, // نفس ارتفاع حقل البحث ليكون الشكل متناسقاً
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50, 
                          borderRadius: BorderRadius.circular(10), 
                          border: Border.all(color: Colors.blue.shade200)
                        ),
                        child: Text('${filteredClients.length} عملاء', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700, fontSize: 14)),
                      )
                    ],
                  ),
                ),

                // ==========================================
                // 🌟 الجدول يأخذ باقي المساحة بالكامل
                // ==========================================
                Expanded(
                  child: filteredClients.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:[
                            Icon(Icons.person_search, size: 80, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text('لا يوجد نتائج مطابقة لبحثك.', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                          ],
                        )
                      )
                    : ListView(
                        // 🌟 أضفنا مسافة 100 בـالأسفل لكي لا يحجب الزر العائم آخر عميل
                        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0), 
                        children:[
                          Card(
                            elevation: 2,
                            margin: EdgeInsets.zero, // إزالة مسافة الـ Card ليأخذ مساحة أكبر
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                            clipBehavior: Clip.antiAlias,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal, 
                              child: ConstrainedBox(
                                constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 32),
                                child: DataTable(
                                  columnSpacing: 22, 
                                  horizontalMargin: 20, 
                                  headingRowColor: WidgetStateProperty.all(Colors.blue.shade50),
                                  dataRowMinHeight: 55, 
                                  dataRowMaxHeight: 70, // تصغير ارتفاع الأسطر قليلاً
                                  columns: const[
                                    DataColumn(label: Text('مُعرّف (ID)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent, fontSize: 14))),
                                    DataColumn(label: Text('الاسم / الملف التعريفي', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent, fontSize: 14))),
                                    DataColumn(label: Text('رقم الهاتف', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent, fontSize: 14))),
                                    DataColumn(label: Text('الرقم الوطني', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent, fontSize: 14))),
                                    DataColumn(label: Text('تاريخ الإضافة', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent, fontSize: 14))),
                                    DataColumn(label: Text('إجراءات', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent, fontSize: 14))), 
                                  ],
                                  rows: filteredClients.asMap().entries.map((mapEntry) {
                                    final index = mapEntry.key;
                                    final client = mapEntry.value;
                                    
                                    return DataRow(
                                      color: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                                        if (index.isEven) return Colors.grey.withOpacity(0.03); 
                                        return null; 
                                      }),
                                      cells:[
                                        DataCell(Text(client.id.split('-').first.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade600, fontSize: 13))),
                                        DataCell(
                                          ConstrainedBox(
                                            constraints: const BoxConstraints(maxWidth: 200),
                                            child: InkWell(
                                              onTap: () {
                                                final dashboardCubit = context.read<DashboardCubit>();
                                                final paymentsCubit = context.read<PaymentsCubit>();
                                                final scheduleCubit = context.read<ScheduleCubit>();

                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => MultiBlocProvider(
                                                      providers:[
                                                        BlocProvider.value(value: dashboardCubit),
                                                        BlocProvider.value(value: paymentsCubit),
                                                        BlocProvider.value(value: scheduleCubit),
                                                        BlocProvider(create: (_) => ClientProfileCubit(context.read<ErpRepository>())..fetchClientData(client)),
                                                      ],
                                                      child: ClientProfilePage(client: client),
                                                    ),
                                                  ),
                                                );
                                              },
                                              borderRadius: BorderRadius.circular(8),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: Colors.indigo.withOpacity(0.05),
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(color: Colors.indigo.withOpacity(0.2))
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children:[
                                                    const Icon(Icons.open_in_new, size: 14, color: Colors.indigo),
                                                    const SizedBox(width: 6),
                                                    Flexible(
                                                      child: Text(
                                                        client.name, 
                                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.indigo), 
                                                        maxLines: 2, 
                                                        overflow: TextOverflow.ellipsis
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                        ),
                                        DataCell(Text(client.phone, style: const TextStyle(fontSize: 14, color: Colors.black87))),
                                        DataCell(Text(client.nationalId ?? '-', style: TextStyle(fontSize: 14, color: client.nationalId != null ? Colors.black87 : Colors.grey))),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(6)),
                                            child: Text('${client.createdAt.year}/${client.createdAt.month.toString().padLeft(2,'0')}/${client.createdAt.day.toString().padLeft(2,'0')}', 
                                              style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold, fontSize: 13)
                                            ),
                                          )
                                        ),
                                        DataCell(
                                          // ==========================================
                                          // 🛡️ حماية أيقونة التعديل (الزر الباهت)
                                          // ==========================================
                                          IconButton(
                                            icon: Icon(Icons.edit_note, color: canEdit ? Colors.blue : Colors.grey.shade400, size: 22), 
                                            tooltip: canEdit ? 'تعديل بيانات العميل' : 'لا تملك صلاحية التعديل',
                                            onPressed: canEdit ? () => showEditClientDialog(context, client) : null, 
                                          ),
                                        ),
                                      ]
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ],
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