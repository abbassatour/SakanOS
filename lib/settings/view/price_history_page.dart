// lib/settings/view/price_history_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/settings_cubit.dart';

// 🌟 استدعاء ديالوج الإضافة الجديد
import 'dialogs/add_historical_price_dialog.dart';

// دالة مساعدة لتنسيق الأرقام بالفواصل
String formatWithCommas(num number) {
  RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  return number.toInt().toString().replaceAllMapped(reg, (Match match) => '${match[1]},');
}

class PriceHistoryPage extends StatelessWidget {
  const PriceHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      // 🌟 تم إزالة الـ AppBar بالكامل لتوسيع مساحة الجدول
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddHistoricalPriceDialog(context),
        icon: const Icon(Icons.add_chart),
        label: const Text('إضافة تسعيرة قديمة', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo.shade600,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            
            // 🌟 السحر هنا: الترتيب التنازلي حسب تاريخ التسعيرة (الأحدث أولاً)
            final sortedHistory = List.of(state.priceHistory)..sort((a, b) {
              return b.effectiveDate.compareTo(a.effectiveDate); 
            });

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                // 🌟 عنوان مدمج وأنيق يحتوي على (زر الرجوع المخصص)
                _buildHeader(context, sortedHistory.length),

                Expanded(
                  child: state.priceHistory.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:[
                            Icon(Icons.history_toggle_off, size: 80, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            const Text('لا يوجد سجل أسعار محفوظ بعد.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                            const SizedBox(height: 8),
                            const Text('اضغط على الزر بالأسفل لإضافة تسعيرة.', style: TextStyle(color: Colors.blueGrey)),
                          ],
                        ),
                      )
                    : ListView(
                        // 🌟 أضفنا مسافة 100 בـالأسفل لكي لا يحجب الزر العائم آخر تسعيرة
                        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0), 
                        children:[
                          Card(
                            elevation: 2,
                            margin: EdgeInsets.zero, // إزالة الهوامش المهدورة
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                            clipBehavior: Clip.antiAlias,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 32),
                                child: DataTable(
                                  headingRowColor: WidgetStateProperty.all(Colors.indigo.shade50),
                                  dataRowMinHeight: 55, // 🌟 ضغط ارتفاع الأسطر
                                  dataRowMaxHeight: 70, // 🌟 ضغط ارتفاع الأسطر
                                  columnSpacing: 30,
                                  horizontalMargin: 20,
                                  columns: const[
                                    DataColumn(label: Text('تاريخ التسعيرة', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo))),
                                    DataColumn(label: Text('حديد (كغ)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo))),
                                    DataColumn(label: Text('اسمنت (كيس)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo))),
                                    DataColumn(label: Text('بلوك 15', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo))),
                                    DataColumn(label: Text('كوفراج (م³)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo))),
                                    DataColumn(label: Text('حصويات (م³)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo))),
                                    DataColumn(label: Text('عامل (يوم)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo))),
                                    
                                    // 🌟 العامود الجديد
                                    DataColumn(label: Text('مُدخل/مُعدِّل التسعيرة', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo))),
                                    
                                    DataColumn(label: Text('إجراء', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo))),
                                  ],
                                  rows: sortedHistory.asMap().entries.map((mapEntry) {
                                    final index = mapEntry.key;
                                    final price = mapEntry.value;
                                    
                                    final hour = price.effectiveDate.hour;
                                    final minute = price.effectiveDate.minute.toString().padLeft(2, '0');
                                    final date = "${price.effectiveDate.year}/${price.effectiveDate.month}/${price.effectiveDate.day}  ($hour:$minute)";

                                    return DataRow(
                                      color: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                                        if (index.isEven) return Colors.grey.withOpacity(0.03); 
                                        return null; 
                                      }),
                                      cells:[
                                        DataCell(Text(date, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo, fontSize: 13))), 
                                        DataCell(Text(formatWithCommas(price.ironPrice), style: const TextStyle(fontWeight: FontWeight.bold))),
                                        DataCell(Text(formatWithCommas(price.cementPrice), style: const TextStyle(fontWeight: FontWeight.bold))),
                                        DataCell(Text(formatWithCommas(price.block15Price), style: const TextStyle(fontWeight: FontWeight.bold))),
                                        DataCell(Text(formatWithCommas(price.formworkAndPouringWages), style: const TextStyle(fontWeight: FontWeight.bold))),
                                        DataCell(Text(formatWithCommas(price.aggregateMaterialsPrice), style: const TextStyle(fontWeight: FontWeight.bold))),
                                        DataCell(Text(formatWithCommas(price.ordinaryWorkerWage), style: const TextStyle(fontWeight: FontWeight.bold))),
                                        
                                        // ==========================================
                                        // 🌟 الخلية الجديدة: عرض اسم المستخدم وتاريخ الإدخال
                                        // ==========================================
                                        DataCell(
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children:[
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children:[
                                                  Icon(Icons.person_outline, size: 14, color: Colors.orange.shade700),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    state.userNamesMap[price.userId] ?? 'مجهول', // جلب الاسم من القاموس
                                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.orange.shade800),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children:[
                                                  const Icon(Icons.access_time, size: 12, color: Colors.grey),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${price.createdAt.year}/${price.createdAt.month.toString().padLeft(2,'0')}/${price.createdAt.day.toString().padLeft(2,'0')} ${price.createdAt.hour}:${price.createdAt.minute.toString().padLeft(2,'0')}',
                                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                                  ),
                                                ],
                                              )
                                            ],
                                          )
                                        ),

                                        DataCell(
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                                            tooltip: 'حذف هذه التسعيرة',
                                            onPressed: () {
                                              context.read<SettingsCubit>().deleteHistoricalPrice(price.id);
                                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حذف التسعيرة بنجاح'), backgroundColor: Colors.green));
                                            },
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
                      ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // 🌟 دالة مساعدة لإنشاء العنوان المدمج (مع زر الرجوع)
  Widget _buildHeader(BuildContext context, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 24, 16),
      child: Row(
        children:[
          // 🌟 زر الرجوع المخصص
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.blueGrey, size: 24),
            tooltip: 'العودة للإعدادات',
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.history, color: Colors.indigo.shade700, size: 26),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'سجل التسعيرات التاريخية',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueGrey),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.indigo.shade100)
            ),
            child: Text(
              'الإجمالي: $count',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo.shade700, fontSize: 14),
            ),
          )
        ],
      ),
    );
  }
}