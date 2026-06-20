// مسار الملف: lib/clients/widgets/client_table.dart
// المسؤولية: رسم جدول عرض بيانات العملاء وإدارة التفاعل معه (تعديل، والانتقال للملف الشخصي).

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart' show Client;

// الاستيرادات المشتركة للملفات الخارجية 
import '../../dashboard/cubit/dashboard_cubit.dart';
import '../../payments/cubit/payments_cubit.dart';
import '../../profile/cubit/client_profile_cubit.dart';
import '../../profile/view/client_profile_page.dart';
import '../../schedule/cubit/schedule_cubit.dart';

// استيرادات الـ Feature الحالية
import '../cubit/clients_cubit.dart';
import 'widgets.dart'; // Barrel file

class ClientTable extends StatelessWidget {
  const ClientTable({
    required this.filteredClients,
    required this.canEdit,
    super.key,
  });

  final List<Client> filteredClients;
  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    // 🌟 الأداء المذهل هنا: نراقب فقط قائمة الأسماء من الحالة (State) بدلاً من الشاشة بأكملها
    final userNamesMap = context.select((ClientsCubit cubit) => cubit.state.userNamesMap);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        Card(
          elevation: 2,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width - 32,
              ),
              child: DataTable(
                columnSpacing: 22,
                horizontalMargin: 20,
                headingRowColor: WidgetStateProperty.all(Colors.blue.shade50),
                dataRowMinHeight: 55,
                dataRowMaxHeight: 70,
                columns: const [
                  DataColumn(label: Text('مُعرّف (ID)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent, fontSize: 14))),
                  DataColumn(label: Text('الاسم / الملف التعريفي', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent, fontSize: 14))),
                  DataColumn(label: Text('رقم الهاتف', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent, fontSize: 14))),
                  DataColumn(label: Text('الرقم الوطني', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent, fontSize: 14))),
                  DataColumn(label: Text('تاريخ الإضافة', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent, fontSize: 14))),
                  DataColumn(label: Text('آخر تعديل بواسطة', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent, fontSize: 14))),
                  DataColumn(label: Text('إجراءات', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent, fontSize: 14))),
                ],
                rows: filteredClients.asMap().entries.map((mapEntry) {
                  final index = mapEntry.key;
                  final client = mapEntry.value;

                  return DataRow(
                    color: WidgetStateProperty.resolveWith<Color?>((states) {
                      return index.isEven ? Colors.grey.withOpacity(0.03) : null;
                    }),
                    cells: [
                      DataCell(Text(client.id.split('-').first.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade600, fontSize: 13))),
                      DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 200),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MultiBlocProvider(
                                    providers: [
                                      BlocProvider.value(value: context.read<DashboardCubit>()),
                                      BlocProvider.value(value: context.read<PaymentsCubit>()),
                                      BlocProvider.value(value: context.read<ScheduleCubit>()),
                                      BlocProvider(
                                        create: (_) => ClientProfileCubit(
                                          context.read<ErpRepository>(),
                                        )..fetchClientData(client),
                                      ),
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
                                border: Border.all(color: Colors.indigo.withOpacity(0.2)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.open_in_new, size: 14, color: Colors.indigo),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      client.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.indigo),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      DataCell(Text(client.phone, style: const TextStyle(fontSize: 14, color: Colors.black87))),
                      DataCell(Text(client.nationalId ?? '-', style: TextStyle(fontSize: 14, color: client.nationalId != null ? Colors.black87 : Colors.grey))),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(6)),
                          child: Text(
                            '${client.createdAt.year}/${client.createdAt.month.toString().padLeft(2, '0')}/${client.createdAt.day.toString().padLeft(2, '0')}',
                            style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ),
                      DataCell(
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.person_outline, size: 14, color: Colors.orange.shade700),
                                const SizedBox(width: 4),
                                Text(
                                  userNamesMap[client.userId] ?? 'مجهول',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.orange.shade800),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.access_time, size: 12, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  '${client.updatedAt.year}/${client.updatedAt.month.toString().padLeft(2, '0')}/${client.updatedAt.day.toString().padLeft(2, '0')} ${client.updatedAt.hour}:${client.updatedAt.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      DataCell(
                        IconButton(
                          icon: Icon(Icons.edit_note, color: canEdit ? Colors.blue : Colors.grey.shade400, size: 22),
                          tooltip: canEdit ? 'تعديل بيانات العميل' : 'لا تملك صلاحية التعديل',
                          onPressed: canEdit ? () => showEditClientDialog(context, client) : null,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}