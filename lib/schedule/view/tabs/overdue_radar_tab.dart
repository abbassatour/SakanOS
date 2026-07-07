// lib/schedule/view/tabs/overdue_radar_tab.dart
import 'package:flutter/material.dart';
import '../../cubit/schedule_cubit.dart';
import '../../../core/utils/whatsapp_helper.dart';

class OverdueRadarTab extends StatelessWidget {
  final ScheduleState state;

  const OverdueRadarTab({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.overdueAlerts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 60,
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            Text(
              'الوضع ممتاز! لا يوجد أي عميل متأخر حالياً.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.green.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: state.overdueAlerts.length,
      itemBuilder: (context, index) {
        final alert = state.overdueAlerts[index];

        Color borderColor;
        Color bgColor;
        IconData icon;
        String warningTitle;

        if (alert.severity == 'critical') {
          borderColor = Colors.redAccent;
          bgColor = Colors.red.shade50;
          icon = Icons.cancel;
          warningTitle = 'حرج';
        } else if (alert.severity == 'warning') {
          borderColor = Colors.orange;
          bgColor = Colors.orange.shade50;
          icon = Icons.warning_amber;
          warningTitle = 'إنذار';
        } else {
          borderColor = Colors.amber.shade700;
          bgColor = Colors.amber.shade50;
          icon = Icons.notifications_active;
          warningTitle = 'سماح';
        }

        final oldestSchedule = alert.overdueSchedules.first;

        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 8),
          color: bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: borderColor.withOpacity(0.5), width: 1),
          ),

          child: LayoutBuilder(
            builder: (context, constraints) {
              final double cardWidth = constraints.maxWidth > 850
                  ? constraints.maxWidth
                  : 850;

              // 🌟 الحل هنا: تم حذف Scrollbar بالكامل، وأبقينا SingleChildScrollView فقط!
              // هذا يضمن السحب المخفي، ويمنع ظهور الخطأ الأحمر في الكونسول نهائياً.
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: cardWidth,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 250,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      alert.client.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: borderColor,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          icon,
                                          size: 12,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$warningTitle (${alert.maxDaysOverdue} يوم)',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${alert.contract.apartmentDetails} | 📱 ${alert.client.phone}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 16),
                        Container(
                          height: 30,
                          width: 1,
                          color: borderColor.withOpacity(0.3),
                        ),
                        const SizedBox(width: 16),

                        Expanded(
                          flex: 4,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.receipt_long,
                                    size: 14,
                                    color: Colors.indigo,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'الديون المتراكمة: ',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                  Text(
                                    '${alert.overdueSchedules.length} أقساط',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.indigo,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.event_busy,
                                    size: 14,
                                    color: borderColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      'أقدم قسط: رقم (${oldestSchedule.installmentNumber}) مستحق في ${oldestSchedule.dueDate.year}/${oldestSchedule.dueDate.month}/${oldestSchedule.dueDate.day}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: borderColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 16),

                        SizedBox(
                          width: 130,
                          height: 36,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            icon: const Icon(Icons.chat, size: 14),
                            label: const Text(
                              'مطالبة',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () async {
                              final success =
                                  await WhatsAppHelper.sendReminderMessage(
                                    schedule: oldestSchedule,
                                    contract: alert.contract,
                                    client: alert.client,
                                  );
                              if (context.mounted) {
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'تم فتح الواتساب للمطالبة!',
                                      ),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('فشل فتح تطبيق الواتساب.'),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
