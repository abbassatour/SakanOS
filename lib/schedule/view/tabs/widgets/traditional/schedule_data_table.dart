// lib/schedule/view/tabs/widgets/traditional/schedule_data_table.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart' show Contract;
import '../../../../cubit/schedule_cubit.dart';
import '../../../../../core/utils/whatsapp_helper.dart';
import '../../../dialogs/edit_single_schedule_dialog.dart';

class ScheduleDataTable extends StatelessWidget {
  final ScheduleState state;
  final Contract currentContract;
  final bool isPostAllocation;
  final String formattedAgreedAmount;
  final double metersPerInstallment;

  const ScheduleDataTable({
    super.key,
    required this.state,
    required this.currentContract,
    required this.isPostAllocation,
    required this.formattedAgreedAmount,
    required this.metersPerInstallment,
  });

  // 🌟 دالة مساعدة سريعة لتنسيق المبلغ الخاص بالدفعة الاستثنائية
  String _formatMoney(num number) {
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return number.toInt().toString().replaceAllMapped(
      reg,
      (Match match) => '${match[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
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
            headingRowHeight: 40,
            dataRowMinHeight: 35,
            dataRowMaxHeight: 48,
            headingRowColor: WidgetStateProperty.all(Colors.indigo.shade50),
            horizontalMargin: 16,
            columnSpacing: 24,
            columns: const [
              DataColumn(
                label: Text(
                  'رقم الشهر',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              DataColumn(
                label: Text(
                  'تاريخ الاستحقاق',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              DataColumn(
                label: Text(
                  'المبلغ المطلوب',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              DataColumn(
                label: Text(
                  'الحالة',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              DataColumn(
                label: Text(
                  'الإجراءات الإدارية',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
            rows: state.scheduleList.map((schedule) {
              final isPaid = schedule.status == 'paid';
              final isMissed = schedule.status == 'missed';
              final isOverdue =
                  !isPaid &&
                  !isMissed &&
                  schedule.dueDate.isBefore(DateTime.now());

              // 🌟 التحقق: هل هذه الدفعة استثنائية (موسمية)؟
              final isCustom = schedule.expectedAmount != null;

              String statusText = 'قادم / معلق';
              Color statusColor = Colors.orange;

              if (isPaid) {
                statusText = 'مسدد ✓';
                statusColor = Colors.green;
              } else if (isMissed) {
                statusText = 'شهر ضائع ❌';
                statusColor = Colors.grey.shade800;
              } else if (isOverdue) {
                statusText = 'متأخر 🚨';
                statusColor = Colors.red;
              }

              // 🌟 تحديد لون خلفية الصف بناءً على الحالة ونوع الدفعة
              Color rowColor = Colors.transparent;
              if (isOverdue) {
                rowColor = Colors.red.shade50.withOpacity(0.5);
              } else if (isCustom && !isPaid && !isMissed) {
                rowColor = Colors.blue.shade50; // لون مميز للدفعة الاستثنائية
              }

              return DataRow(
                color: WidgetStateProperty.all(rowColor),
                cells: [
                  // 🌟 الخلية 1: رقم الشهر (يظهر بجانبه نجمة إذا كان استثنائياً)
                  DataCell(
                    Text(
                      isCustom
                          ? '🌟 #${schedule.installmentNumber}'
                          : '#${schedule.installmentNumber}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isCustom ? Colors.orange.shade800 : Colors.black,
                      ),
                    ),
                  ),

                  // الخلية 2: التاريخ والملاحظات
                  DataCell(
                    Row(
                      children: [
                        Text(
                          '${schedule.dueDate.year}/${schedule.dueDate.month}/${schedule.dueDate.day}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        if (schedule.notes != null &&
                            schedule.notes!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Tooltip(
                            message: schedule.notes!,
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              Icons.info_outline,
                              size: 16,
                              color: isCustom ? Colors.indigo : Colors.blueGrey,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // 🌟 الخلية 3: المبلغ (ذكي يفرق بين القسط العادي والدفعة الاستثنائية)
                  DataCell(
                    isPaid || isMissed
                        ? const Text(
                            'مُغلق 🔒',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : Text(
                            isCustom
                                ? '${_formatMoney(schedule.expectedAmount!)} ل.س'
                                : '$formattedAgreedAmount ل.س',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isCustom ? Colors.indigo : Colors.teal,
                              fontSize: 13,
                            ),
                          ),
                  ),

                  // الخلية 4: الحالة
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: statusColor.withOpacity(0.5)),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),

                  // الخلية 5: الإجراءات الإدارية
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isPaid || isMissed)
                          Text(
                            isPaid
                                ? 'سُددت عبر الإيصالات'
                                : 'تخلف عن الدفع (مغلق)',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                            ),
                          )
                        else ...[
                          // زر التذكير واتساب
                          SizedBox(
                            height: 28,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.chat,
                                color: Colors.green,
                                size: 20,
                              ),
                              tooltip: 'تذكير واتساب',
                              onPressed: () async {
                                final client = state.clients.firstWhere(
                                  (c) => c.id == currentContract.clientId,
                                );
                                await WhatsAppHelper.sendReminderMessage(
                                  schedule: schedule,
                                  contract: currentContract,
                                  client: client,
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          // زر تعديل التاريخ يدوياً (الآن يدعم تعديل مبلغ الدفعة الاستثنائية من الداخل إذا أردنا)
                          SizedBox(
                            height: 28,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.edit_calendar,
                                color: Colors.indigo,
                                size: 20,
                              ),
                              tooltip: 'تأجيل أو تعديل',
                              onPressed: () => showEditSingleScheduleDialog(
                                context,
                                schedule,
                              ),
                            ),
                          ),
                          Container(
                            height: 20,
                            width: 1,
                            color: Colors.grey.shade300,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                          ),

                          // 🌟 الأزرار الإدارية السريعة
                          SizedBox(
                            height: 28,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                context
                                    .read<ScheduleCubit>()
                                    .handleRollingCheckpoint(
                                      contractId: currentContract.id,
                                      scheduleId: schedule.id,
                                      actionType: 'paid',
                                      nextDueDate: DateTime(
                                        schedule.dueDate.year,
                                        schedule.dueDate.month + 1,
                                        schedule.dueDate.day,
                                      ),
                                    );
                              },
                              icon: const Icon(Icons.check, size: 14),
                              label: const Text(
                                'تسديد إداري',
                                style: TextStyle(fontSize: 11),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          SizedBox(
                            height: 28,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                context
                                    .read<ScheduleCubit>()
                                    .handleRollingCheckpoint(
                                      contractId: currentContract.id,
                                      scheduleId: schedule.id,
                                      actionType: 'missed',
                                      nextDueDate: DateTime(
                                        schedule.dueDate.year,
                                        schedule.dueDate.month + 1,
                                        schedule.dueDate.day,
                                      ),
                                    );
                              },
                              icon: const Icon(Icons.close, size: 14),
                              label: const Text(
                                'ضائع',
                                style: TextStyle(fontSize: 11),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade800,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                              ),
                            ),
                          ),
                        ],
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
