// lib/schedule/view/tabs/overdue_radar_tab.dart
import 'package:flutter/material.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';
import '../../cubit/schedule_cubit.dart';
import '../../../core/utils/whatsapp_helper.dart';

String formatApartmentDetails(BuildContext context, String rawDetails) {
  final l10n = context.l10n;
  if (rawDetails == 'أسهم/غير مخصص' ||
      rawDetails == 'أسهم استثمارية غير مخصصة' ||
      rawDetails == 'محفظة استثمارية (عقد لاحق التخصص)' ||
      (rawDetails.contains('غير مخصص') && !rawDetails.contains('شقة')) ||
      (rawDetails.contains('استثمارية') && !rawDetails.contains('شقة'))) {
    if (rawDetails.contains('عقود متفاوتة الدفع') ||
        rawDetails.contains('منفاوتة')) {
      return l10n.localeName == 'en'
          ? 'Investment Shares (Flexible Payments)'
          : 'أسهم استثمارية غير مخصصة (عقود متفاوتة الدفع)';
    }
    return l10n.contractAutoDetailsUnallocated;
  }

  var formatted = rawDetails;
  if (l10n.localeName == 'en') {
    formatted = formatted
        .replaceAll('مشروع السلموني', 'Al-Salamoni Project')
        .replaceAll('مشروع', 'Project:')
        .replaceAll('عقار 1593', 'Property 1593')
        .replaceAll('عقار', 'Property:')
        .replaceAll('محضر:', 'Building:')
        .replaceAll('شقة:', 'Apt:')
        .replaceAll('شقة', 'Apt')
        .replaceAll('طابق:', 'Floor:')
        .replaceAll('الطابق الأرضي', 'Ground Floor')
        .replaceAll('الطابق الأول', '1st Floor')
        .replaceAll('الطابق الثاني', '2nd Floor')
        .replaceAll('الطابق الثالث', '3rd Floor')
        .replaceAll('الطابق الرابع', '4th Floor')
        .replaceAll('الطابق الخامس', '5th Floor')
        .replaceAll('الطابق السادس', '6th Floor')
        .replaceAll('الطابق السابع', '7th Floor')
        .replaceAll('الطابق الثامن', '8th Floor')
        .replaceAll('الطابق التاسع', '9th Floor')
        .replaceAll('الطابق العاشر', '10th Floor')
        .replaceAll('الطابق الحادي عشر', '11th Floor')
        .replaceAll('الطابق الثاني عشر', '12th Floor')
        .replaceAll('الطابق 1', '1st Floor')
        .replaceAll('الطابق 2', '2nd Floor')
        .replaceAll('الطابق 3', '3rd Floor')
        .replaceAll('الطابق 4', '4th Floor')
        .replaceAll('الطابق 5', '5th Floor')
        .replaceAll('القبو الأول', '1st Basement')
        .replaceAll('القبو الثاني', '2nd Basement')
        .replaceAll('القبو الثالث', '3rd Basement');
  }
  return formatted;
}

class OverdueRadarTab extends StatelessWidget {
  final ScheduleState state;

  const OverdueRadarTab({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

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
              l10n.overdueRadarAllClear,
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
          warningTitle = l10n.severityCritical;
        } else if (alert.severity == 'warning') {
          borderColor = Colors.orange;
          bgColor = Colors.orange.shade50;
          icon = Icons.warning_amber;
          warningTitle = l10n.severityWarning;
        } else {
          borderColor = Colors.amber.shade700;
          bgColor = Colors.amber.shade50;
          icon = Icons.notifications_active;
          warningTitle = l10n.severityNotice;
        }

        final oldestSchedule = alert.overdueSchedules.first;
        final details = formatApartmentDetails(
          context,
          alert.contract.apartmentDetails,
        );

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
                                          '$warningTitle (${l10n.overdueDays(alert.maxDaysOverdue)})',
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
                                '$details | 📱 ${alert.client.phone}',
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
                                  Text(
                                    l10n.overdueAccumulatedDebt,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                  Text(
                                    l10n.overdueInstallmentsCount(
                                      alert.overdueSchedules.length,
                                    ),
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
                                      l10n.overdueOldestInstallment(
                                        oldestSchedule.installmentNumber
                                            .toString(),
                                        oldestSchedule.dueDate.year.toString(),
                                        oldestSchedule.dueDate.month.toString(),
                                        oldestSchedule.dueDate.day.toString(),
                                      ),
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
                            label: Text(
                              l10n.actionClaim,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () async {
                              final success =
                                  await WhatsAppHelper.sendReminderMessage(
                                    l10n: l10n,
                                    schedule: oldestSchedule,
                                    contract: alert.contract,
                                    client: alert.client,
                                  );
                              if (context.mounted) {
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(l10n.whatsappOpenedSuccess),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(l10n.whatsappOpenedError),
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
