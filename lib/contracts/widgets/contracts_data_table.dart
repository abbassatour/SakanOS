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
import 'package:our_home_erp_app/contracts/cubit/contracts_cubit.dart';
import 'package:our_home_erp_app/contracts/view/contract_attachments_page.dart';

import 'package:our_home_erp_app/auth/cubit/auth_cubit.dart';
import 'package:our_home_erp_app/core/constants/app_permissions.dart';
import 'package:our_home_erp_app/contracts/widgets/dialogs/edit_contract_dialog.dart';
import 'package:our_home_erp_app/profile/cubit/client_profile_cubit.dart';

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

  // ==========================================
  // 🌟 الدالة السحرية للتوجيه الذكي الآمن
  // ==========================================
  Future<void> _navigateToContractDetails(
    BuildContext context,
    Contract contract,
    Client actualClient,
  ) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('جاري جلب تفاصيل المحفظة والسجل القانوني... ⏳'),
        backgroundColor: Colors.teal,
        duration: Duration(seconds: 2),
      ),
    );

    final clientProfileCubit = ClientProfileCubit(
      context.read<ErpRepository>(),
    );
    await clientProfileCubit.fetchClientData(actualClient);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ContractProfileSummary? summary;
    try {
      summary = clientProfileCubit.state.contractsSummary.firstWhere(
        (s) => s.contract.id == contract.id,
      );
    } catch (_) {}

    unawaited(
      Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: context.read<DashboardCubit>()),
              BlocProvider.value(value: context.read<PaymentsCubit>()),
              BlocProvider.value(value: context.read<ScheduleCubit>()),
              BlocProvider(create: (_) => clientProfileCubit),
            ],
            child: ContractDetailsPage(
              contract: contract,
              client: actualClient,
              summary: summary,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  'المرفقات',
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
                  // ==========================================
                  // 🌟 رقم العقد (تفاعلي)
                  // ==========================================
                  DataCell(
                    _InteractiveContractIdChip(
                      contractId: contract.id,
                      onTap: () {
                        if (actualClient != null) {
                          _navigateToContractDetails(
                            context,
                            contract,
                            actualClient,
                          );
                        }
                      },
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
                      '${NumberFormatters.formatWithCommas(contract.baseMeterPriceAtSigning)} ل.س',
                      style: const TextStyle(
                        color: Colors.teal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // ==========================================
                  // 🌟 المرفقات (تفاعلي وجديد)
                  // ==========================================
                  DataCell(
                    _InteractiveAttachmentChip(
                      attachmentCount: attachmentsMap[contract.id]?.length ?? 0,
                      onTap: () {
                        Navigator.push(
                          context,
                          ContractAttachmentsPage.route(
                            contract,
                            canEditContracts,
                            context.read<ContractsCubit>(),
                          ),
                        );
                      },
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
                              '${contract.updatedAt.year}/${contract.updatedAt.month.toString().padLeft(2, '0')}/${contract.updatedAt.day.toString().padLeft(2, '0')} ${contract.updatedAt.hour}:${contract.updatedAt.minute.toString().padLeft(2, '0')}',
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
                  // 🌟 زر التعديل فقط
                  // ==========================================
                  DataCell(
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

// ==========================================
// 🌟 الويدجت التفاعلي لرقم العقد
// ==========================================
class _InteractiveContractIdChip extends StatefulWidget {
  final String contractId;
  final VoidCallback onTap;

  const _InteractiveContractIdChip({
    required this.contractId,
    required this.onTap,
  });

  @override
  State<_InteractiveContractIdChip> createState() =>
      _InteractiveContractIdChipState();
}

class _InteractiveContractIdChipState
    extends State<_InteractiveContractIdChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      onHover: (val) => setState(() => _isHovered = val),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _isHovered ? Colors.blue.shade600 : Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _isHovered ? Colors.blue.shade800 : Colors.blue.shade200,
            width: _isHovered ? 1.5 : 1.0,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.open_in_new,
              size: 16,
              color: _isHovered ? Colors.white : Colors.blue.shade700,
            ),
            const SizedBox(width: 6),
            Text(
              widget.contractId.split('-').first.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _isHovered ? Colors.white : Colors.blue.shade900,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 🌟 الويدجت التفاعلي الجديد (للمرفقات)
// ==========================================
class _InteractiveAttachmentChip extends StatefulWidget {
  final int attachmentCount;
  final VoidCallback onTap;

  const _InteractiveAttachmentChip({
    required this.attachmentCount,
    required this.onTap,
  });

  @override
  State<_InteractiveAttachmentChip> createState() =>
      _InteractiveAttachmentChipState();
}

class _InteractiveAttachmentChipState
    extends State<_InteractiveAttachmentChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final hasAttachments = widget.attachmentCount > 0;

    Color bgColor;
    Color borderColor;
    Color textColor;
    List<BoxShadow> boxShadow = [];

    if (_isHovered) {
      bgColor = hasAttachments
          ? Colors.teal.shade600
          : Colors.blueGrey.shade500;
      borderColor = hasAttachments
          ? Colors.teal.shade800
          : Colors.blueGrey.shade700;
      textColor = Colors.white;
      boxShadow = [
        BoxShadow(
          color: (hasAttachments ? Colors.teal : Colors.blueGrey).withOpacity(
            0.3,
          ),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ];
    } else {
      bgColor = hasAttachments ? Colors.teal.shade50 : Colors.grey.shade100;
      borderColor = hasAttachments
          ? Colors.teal.shade300
          : Colors.grey.shade300;
      textColor = hasAttachments ? Colors.teal.shade700 : Colors.grey.shade600;
    }

    return InkWell(
      onTap: widget.onTap,
      onHover: (val) => setState(() => _isHovered = val),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor,
            width: _isHovered ? 1.5 : 1.0,
          ),
          boxShadow: boxShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.attach_file,
              size: 16,
              color: textColor,
            ),
            const SizedBox(width: 4),
            Text(
              '${widget.attachmentCount}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
