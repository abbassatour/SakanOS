// lib/contracts/widgets/contracts_data_table.dart

import 'dart:async';

import 'package:erp_repository/erp_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:our_home_erp_app/core/utils/formatters.dart';
import 'package:our_home_erp_app/dashboard/cubit/dashboard_cubit.dart';
import 'package:our_home_erp_app/payments/cubit/payments_cubit.dart';
import 'package:our_home_erp_app/profile/view/contract_details_page.dart';
import 'package:our_home_erp_app/schedule/cubit/schedule_cubit.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:our_home_erp_app/contracts/cubit/contracts_cubit.dart';
import 'package:open_filex/open_filex.dart';
import 'package:our_home_erp_app/contracts/view/contract_attachments_page.dart';
// 🌟 الاستيرادات الجديدة المطلوبة للزر والصلاحيات
import 'package:our_home_erp_app/auth/cubit/auth_cubit.dart';
import 'package:our_home_erp_app/core/constants/app_permissions.dart';
import 'package:our_home_erp_app/contracts/widgets/dialogs/edit_contract_dialog.dart';

class ContractsDataTable extends StatelessWidget {
  const ContractsDataTable({
    required this.contracts,
    required this.clients,
    required this.userNamesMap,
    required this.attachmentsMap,
    super.key,
  });

  final List<Contract> contracts;
  final List<Client> clients;
  final Map<String, String> userNamesMap;
  final Map<String, List<ContractAttachment>> attachmentsMap;

  @override
  Widget build(BuildContext context) {
    // 🌟 جلب الصلاحيات لمعرفة ما إذا كان يحق للمستخدم تعديل العقود
    final authState = context.watch<AuthCubit>().state;
    final canEditContracts = authState.hasPermission(
      AppPermissions.createContracts,
    );

    return Card(
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
            columnSpacing: 28,
            horizontalMargin: 16,
            headingRowColor: WidgetStateProperty.all(Colors.teal.shade50),
            dataRowMinHeight: 55,
            dataRowMaxHeight: 70,
            columns: const [
              DataColumn(
                label: Text(
                  'رقم العقد',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'العميل',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'النوع',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'سعر المتر',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'المرفقات', // 🌟 كان "ملف العقد"
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'التسليم',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'آخر تعديل',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'إجراءات',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ),
            ],
            rows: contracts.asMap().entries.map((entry) {
              final index = entry.key;
              final contract = entry.value;

              final clientIdx = clients.indexWhere(
                (c) => c.id == contract.clientId,
              );
              final actualClient = clientIdx >= 0 ? clients[clientIdx] : null;
              final clientName = actualClient != null
                  ? actualClient.name
                  : 'عميل محذوف';

              final isAllocated = contract.contractType == 'متخصص';
              final isHandedOver = contract.isHandedOver;
              final isCompleted = contract.isCompleted;

              return DataRow(
                color: WidgetStateProperty.resolveWith<Color?>(
                  (states) =>
                      index.isEven ? Colors.grey.withValues(alpha: 0.03) : null,
                ),
                cells: [
                  DataCell(
                    Text(
                      contract.id.split('-').first.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      clientName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataCell(Text(contract.contractType)),
                  DataCell(
                    Text(
                      '${NumberFormatters.formatWithCommas(
                        contract.baseMeterPriceAtSigning,
                      )} ل.س',
                      style: const TextStyle(
                        color: Colors.teal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // 🌟 شارة المرفقات (Badge) وتمرير الصلاحية للمعرض
                  DataCell(
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          ContractAttachmentsPage.route(
                            contract,
                            canEditContracts, // 👈 التعديل هنا: تمرير الصلاحية المخصصة للرفع والحذف
                            context.read<ContractsCubit>(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (attachmentsMap[contract.id]?.isNotEmpty ?? false)
                              ? Colors.teal.shade50
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                (attachmentsMap[contract.id]?.isNotEmpty ??
                                    false)
                                ? Colors.teal.shade300
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.attach_file,
                              size: 16,
                              color:
                                  (attachmentsMap[contract.id]?.isNotEmpty ??
                                      false)
                                  ? Colors.teal.shade700
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${attachmentsMap[contract.id]?.length ?? 0}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    (attachmentsMap[contract.id]?.isNotEmpty ??
                                        false)
                                    ? Colors.teal.shade700
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    !isAllocated
                        ? const Center(
                            child: Text(
                              '-',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isHandedOver
                                  ? Colors.teal.shade50
                                  : Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isHandedOver
                                    ? Colors.teal.shade200
                                    : Colors.orange.shade200,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isHandedOver
                                      ? Icons.check_circle
                                      : Icons.hourglass_top,
                                  size: 14,
                                  color: isHandedOver
                                      ? Colors.teal.shade700
                                      : Colors.orange.shade700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isHandedOver ? 'مُسلّم' : 'انتظار',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isHandedOver
                                        ? Colors.teal.shade700
                                        : Colors.orange.shade700,
                                  ),
                                ),
                              ],
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
                              userNamesMap[contract.userId] ?? 'مجهول',
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
                              '${contract.updatedAt.year}/'
                              '${contract.updatedAt.month.toString().padLeft(
                                2,
                                '0',
                              )}/'
                              '${contract.updatedAt.day.toString().padLeft(
                                2,
                                '0',
                              )} '
                              '${contract.updatedAt.hour}:'
                              '${contract.updatedAt.minute.toString().padLeft(
                                2,
                                '0',
                              )}',
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

                  // ==========================================
                  // 🌟 هنا تم إضافة الزر المفقود: أزرار الإجراءات
                  // ==========================================
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 🌟 الزر الجديد (تعديل العقد)
                        IconButton(
                          tooltip: (!canEditContracts || isCompleted)
                              ? 'غير مصرح أو العقد مغلق'
                              : 'تعديل بيانات العقد',
                          icon: Icon(
                            Icons.edit_document,
                            color: (!canEditContracts || isCompleted)
                                ? Colors.grey.shade300
                                : Colors.orange,
                            size: 22,
                          ),
                          onPressed: (!canEditContracts || isCompleted)
                              ? null
                              : () => showEditContractDialog(context, contract),
                        ),

                        // زر عرض التفاصيل (القديم)
                        IconButton(
                          tooltip: 'عرض تفاصيل الملف والمحفظة',
                          icon: const Icon(
                            Icons.visibility,
                            color: Colors.indigo,
                            size: 22,
                          ),
                          onPressed: () {
                            if (actualClient != null) {
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
                                      ],
                                      child: ContractDetailsPage(
                                        contract: contract,
                                        client: actualClient,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
