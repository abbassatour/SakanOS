// lib/home/view/widgets/recent_activities_section.dart
import 'package:flutter/material.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';

class RecentActivitiesSection extends StatelessWidget {
  final List<ActivityItem> activities;

  const RecentActivitiesSection({super.key, required this.activities});

  String _getTimeAgo(BuildContext context, DateTime dateTime) {
    final l10n = context.l10n;
    final difference = SecureTime.now().difference(dateTime);

    if (difference.inMinutes < 1) return l10n.timeJustNow;
    if (difference.inMinutes < 60) {
      return l10n.timeMinutesAgo(difference.inMinutes);
    }
    if (difference.inHours < 24) {
      return l10n.timeHoursAgo(difference.inHours);
    }
    if (difference.inDays == 1) return l10n.timeYesterday;
    if (difference.inDays < 7) {
      return l10n.timeDaysAgo(difference.inDays);
    }
    return '${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')}';
  }

  String _getActivityTitle(BuildContext context, ActivityType type) {
    final l10n = context.l10n;
    switch (type) {
      case ActivityType.payment:
        return l10n.activityPaymentTitle;
      case ActivityType.contract:
        return l10n.activityContractTitle;
      case ActivityType.client:
        return l10n.activityClientTitle;
      case ActivityType.adminAction:
        return l10n.activityAdminActionTitle;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) return const SizedBox.shrink();
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.history_toggle_off,
                  color: Colors.orange.shade700,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.recentActivitiesTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...activities.asMap().entries.map((entry) {
            final index = entry.key;
            final activity = entry.value;
            final isLast = index == activities.length - 1;

            Color iconColor;
            IconData iconData;

            switch (activity.type) {
              case ActivityType.payment:
                iconColor = Colors.green.shade600;
                iconData = Icons.payments_outlined;
              case ActivityType.contract:
                iconColor = Colors.teal.shade600;
                iconData = Icons.real_estate_agent_outlined;
              case ActivityType.client:
                iconColor = Colors.indigo.shade600;
                iconData = Icons.person_add_alt_1_outlined;
              case ActivityType.adminAction:
                iconColor = Colors.orange.shade600;
                iconData = Icons.admin_panel_settings_outlined;
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: iconColor.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(iconData, color: iconColor, size: 18),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 50,
                        color: Colors.grey.shade200,
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _getActivityTitle(context, activity.type),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              _getTimeAgo(context, activity.timestamp),
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          activity.description,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                activity.userName,
                                style: TextStyle(
                                  color: Colors.grey.shade800,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
