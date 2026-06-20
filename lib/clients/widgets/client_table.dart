// مسار الملف: lib/clients/widgets/client_table.dart
// ignore_for_file: always_use_package_imports

import 'dart:async';

import 'package:erp_repository/erp_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../dashboard/cubit/dashboard_cubit.dart';
import '../../payments/cubit/payments_cubit.dart';
import '../../profile/cubit/client_profile_cubit.dart';
import '../../profile/view/client_profile_page.dart';
import '../../schedule/cubit/schedule_cubit.dart';
import '../cubit/clients_cubit.dart';
import 'widgets.dart';

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
    final userNamesMap = context.select<ClientsCubit, Map<String, String>>(
      (cubit) => cubit.state.userNamesMap,
    );

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
                  DataColumn(
                    label: Text(
                      'مُعرّف (ID)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'الاسم / الملف التعريفي',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'رقم الهاتف',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'الرقم الوطني',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'تاريخ الإضافة',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'آخر تعديل بواسطة',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'إجراءات',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
                rows: filteredClients.asMap().entries.map((mapEntry) {
                  final index = mapEntry.key;
                  final client = mapEntry.value;

                  final cAt = client.createdAt;
                  final uAt = client.updatedAt;

                  final dateAdded = '${cAt.year}/'
                      '${cAt.month.toString().padLeft(2, '0')}/'
                      '${cAt.day.toString().padLeft(2, '0')}';

                  final dateUpdated = '${uAt.year}/'
                      '${uAt.month.toString().padLeft(2, '0')}/'
                      '${uAt.day.toString().padLeft(2, '0')} '
                      '${uAt.hour}:${uAt.minute.toString().padLeft(2, '0')}';

                  return DataRow(
                    color: WidgetStateProperty.resolveWith<Color?>((states) {
                      return index.isEven
                          ? Colors.grey.withValues(alpha: 0.03)
                          : null;
                    }),
                    cells: [
                      DataCell(
                        Text(
                          client.id.split('-').first.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 200),
                          child: InkWell(
                            onTap: () {
                              unawaited(
                                Navigator.push<void>(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (_) => MultiBlocProvider(
                                      providers: [
                                        BlocProvider.value(
                                          value: context.read<DashboardCubit>(),
                                        ),
                                        BlocProvider.value(
                                          value: context.read<PaymentsCubit>(),
                                        ),
                                        BlocProvider.value(
                                          value: context.read<ScheduleCubit>(),
                                        ),
                                        BlocProvider(
                                          create: (ctx) {
                                            final cubit = ClientProfileCubit(
                                              ctx.read<ErpRepository>(),
                                            );
                                            unawaited(
                                              cubit.fetchClientData(client),
                                            );
                                            return cubit;
                                          },
                                        ),
                                      ],
                                      child: ClientProfilePage(client: client),
                                    ),
                                  ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.indigo.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.indigo.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.open_in_new,
                                    size: 14,
                                    color: Colors.indigo,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      client.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.indigo,
                                      ),
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
                      DataCell(
                        Text(
                          client.phone,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          client.nationalId ?? '-',
                          style: TextStyle(
                            fontSize: 14,
                            color: client.nationalId != null
                                ? Colors.black87
                                : Colors.grey,
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            dateAdded,
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
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
                                Icon(
                                  Icons.person_outline,
                                  size: 14,
                                  color: Colors.orange.shade700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  userNamesMap[client.userId] ?? 'مجهول',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Colors.orange.shade800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 12,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  dateUpdated,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      DataCell(
                        IconButton(
                          icon: Icon(
                            Icons.edit_note,
                            color: canEdit ? Colors.blue : Colors.grey.shade400,
                            size: 22,
                          ),
                          tooltip:
                              canEdit ? 'تعديل بيانات' : 'لا تملك الصلاحية',
                          onPressed: canEdit
                              ? () => showEditClientDialog(context, client)
                              : null,
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

