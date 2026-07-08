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

// 🌟 الاستيرادات الجديدة المطلوبة للزر والصلاحيات
import 'package:our_home_erp_app/auth/cubit/auth_cubit.dart';
import 'package:our_home_erp_app/core/constants/app_permissions.dart';
import 'package:our_home_erp_app/contracts/widgets/dialogs/edit_contract_dialog.dart';

class ContractsDataTable extends StatelessWidget {
  const ContractsDataTable({
    required this.contracts,
    required this.clients,
    required this.userNamesMap,
    super.key,
  });

  final List<Contract> contracts;
  final List<Client> clients;
  final Map<String, String> userNamesMap;

  void _openFile(String urlString) {
    unawaited(
      () async {
        final url = Uri.parse(urlString);
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        }
      }(),
    );
  }

  Widget _buildFileAction(BuildContext context, Contract contract) {
    final hasFile =
        contract.contractFileUrl != null &&
        contract.contractFileUrl!.isNotEmpty;

    return TextButton.icon(
      icon: Icon(
        hasFile ? Icons.download : Icons.upload_file,
        color: hasFile ? Colors.green : Colors.orange,
        size: 18,
      ),
      label: Text(
        hasFile ? 'فتح' : 'إرفاق',
        style: TextStyle(
          color: hasFile ? Colors.green : Colors.orange,
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: () async {
        if (hasFile) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('جاري إنشاء رابط وصول آمن... ⏳')),
          );

          final secureUrl = await context
              .read<ContractsCubit>()
              .getSecureContractUrl(contract.contractFileUrl!);

          if (secureUrl != null) {
            if (secureUrl.startsWith('http')) {
              // فتح الملف السحابي في المتصفح
              final url = Uri.parse(secureUrl);
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              }
            } else {
              // فتح الملف المحلي (الذي لم يُرفع بعد)
              await OpenFilex.open(secureUrl);
            }
          }
        } else {
          // إرشاد الموظف إلى المكان الصحيح للإرفاق
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'لإرفاق ملف، اضغط على أيقونة (تعديل العقد 📝) بجوار العقد، ثم أرفقه من هناك.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      },
    );
  }

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
                  'ملف العقد',
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
                  DataCell(_buildFileAction(context, contract)),
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

                        // 🌟 الزر الجديد الذي أضفناه: أرشفة العقد
                        IconButton(
                          tooltip: isCompleted
                              ? 'إلغاء الأرشفة (إعادة فتح العقد)'
                              : 'أرشفة وإغلاق العقد نهائياً',
                          icon: Icon(
                            isCompleted ? Icons.lock_open : Icons.archive,
                            color: isCompleted
                                ? Colors.green
                                : Colors.grey.shade600,
                            size: 22,
                          ),
                          onPressed: !canEditContracts
                              ? null
                              : () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      title: Row(
                                        children: [
                                          Icon(
                                            isCompleted
                                                ? Icons.lock_open
                                                : Icons.archive,
                                            color: isCompleted
                                                ? Colors.green
                                                : Colors.grey.shade700,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            isCompleted
                                                ? 'إعادة فتح العقد'
                                                : 'أرشفة وإغلاق العقد',
                                          ),
                                        ],
                                      ),
                                      content: SizedBox(
                                        width: 400,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              isCompleted
                                                  ? 'إعادة فتح العقد سيجعله نشطاً من جديد، وسيظهر في شاشة المدفوعات ورادار المراقبة. هل أنت متأكد؟'
                                                  : 'أرشفة العقد تعني أن العلاقة المالية والإنشائية مع العميل قد اكتملت بنجاح.',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            if (!isCompleted) ...[
                                              const SizedBox(height: 12),
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  12,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: Colors.grey.shade300,
                                                  ),
                                                ),
                                                child: const Text(
                                                  'ماذا سيحدث عند الأرشفة؟\n'
                                                  '1. سيختفي العقد من شاشة إدخال المدفوعات.\n'
                                                  '2. سيتم إيقاف تنبيهات الأقساط (سيختفي من الرادار).\n'
                                                  '3. سيتم حفظ السجل المالي والقانوني كـ (أرشيف للقراءة فقط).',
                                                  style: TextStyle(
                                                    height: 1.5,
                                                    fontSize: 13,
                                                    color: Colors.blueGrey,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text(
                                            'إلغاء',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isCompleted
                                                ? Colors.green
                                                : Colors.grey.shade800,
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: () {
                                            context
                                                .read<ContractsCubit>()
                                                .toggleContractCompletion(
                                                  contractId: contract.id,
                                                  isCompleted: !isCompleted,
                                                );
                                            Navigator.pop(ctx);
                                          },
                                          icon: Icon(
                                            isCompleted
                                                ? Icons.lock_open
                                                : Icons.archive_outlined,
                                            size: 18,
                                          ),
                                          label: Text(
                                            isCompleted
                                                ? 'نعم، أعد الفتح'
                                                : 'نعم، أرشف العقد',
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
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
