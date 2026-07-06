// lib/schedule/view/tabs/widgets/traditional/schedule_empty_state.dart
import 'package:flutter/material.dart';

class ScheduleEmptyState extends StatelessWidget {
  const ScheduleEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.query_stats, size: 80, color: Colors.indigo.shade100),
          const SizedBox(width: 24),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'الجدولة والمتابعة',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'استخدم محرك البحث بالأعلى لاختيار عميل.\nيمكنك مراقبة الدفعات، وتحديد نقاط التفاعل للمستثمرين.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
