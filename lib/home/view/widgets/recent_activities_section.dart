// lib/home/view/widgets/recent_activities_section.dart
import 'package:flutter/material.dart';
import 'package:erp_repository/erp_repository.dart'; 

class RecentActivitiesSection extends StatelessWidget {
  final List<ActivityItem> activities;

  const RecentActivitiesSection({super.key, required this.activities});

  // 🌟 دالة مساعدة لتحويل الوقت إلى صيغة (منذ 5 دقائق)
  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().toUtc().difference(dateTime);
    if (difference.inMinutes < 1) return 'الآن';
    if (difference.inMinutes < 60) return 'منذ ${difference.inMinutes} دقيقة';
    if (difference.inHours < 24) return 'منذ ${difference.inHours} ساعة';
    if (difference.inDays == 1) return 'أمس';
    if (difference.inDays < 7) return 'منذ ${difference.inDays} أيام';
    return '${dateTime.year}/${dateTime.month.toString().padLeft(2,'0')}/${dateTime.day.toString().padLeft(2,'0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow:[
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
          // 🌟 ترويسة القسم
          Row(
            children:[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.history_toggle_off, color: Colors.orange.shade700, size: 22),
              ),
              const SizedBox(width: 12),
              const Text(
                'سجل النشاطات الحديثة',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 🌟 شريط التتبع (Timeline)
          ...activities.asMap().entries.map((entry) {
            final index = entry.key;
            final activity = entry.value;
            final isLast = index == activities.length - 1;

            // تحديد اللون والأيقونة بناءً على نوع النشاط
            Color iconColor;
            IconData iconData;

            switch (activity.type) {
              case ActivityType.payment:
                iconColor = Colors.green.shade600;
                iconData = Icons.payments_outlined;
                break;
              case ActivityType.contract:
                iconColor = Colors.teal.shade600;
                iconData = Icons.real_estate_agent_outlined;
                break;
              case ActivityType.client:
                iconColor = Colors.indigo.shade600;
                iconData = Icons.person_add_alt_1_outlined;
                break;
              case ActivityType.adminAction:
                iconColor = Colors.orange.shade600;
                iconData = Icons.admin_panel_settings_outlined;
                break;
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                // 📍 خط الزمن والأيقونة
                Column(
                  children:[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: iconColor.withOpacity(0.3), width: 1.5),
                      ),
                      child: Icon(iconData, color: iconColor, size: 18),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 50, // طول الخط الفاصل
                        color: Colors.grey.shade200,
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                
                // 📝 المحتوى النصي للنشاط
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0), // إبعاد العناصر عن بعضها
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children:[
                            Text(
                              activity.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              _getTimeAgo(activity.timestamp),
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          activity.description,
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        
                        // 👤 اسم المستخدم الملون
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children:[
                              Icon(Icons.person_outline, size: 14, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Text(
                                activity.userName,
                                style: TextStyle(color: Colors.grey.shade800, fontSize: 12, fontWeight: FontWeight.bold),
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
          }).toList(),
        ],
      ),
    );
  }
}