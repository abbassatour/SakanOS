// lib/settings/view/dollar_history_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/settings_cubit.dart';

// 🌟 ديالوج إضافة سعر دولار قديم (سنقوم بإنشائه في الخطوة القادمة)
import 'dialogs/add_historical_dollar_dialog.dart';

// دالة تنسيق الأرقام بالفواصل
String formatWithCommas(num number) {
  RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  return number.toInt().toString().replaceAllMapped(reg, (Match match) => '${match[1]},');
}

class DollarHistoryPage extends StatelessWidget {
  const DollarHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddHistoricalDollarDialog(context),
        icon: const Icon(Icons.add_chart),
        label: const Text('إضافة تسعيرة قديمة', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green.shade700, // 🌟 اللون الأخضر المميز للدولار
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            
            // ترتيب تنازلي حسب تاريخ التسعيرة (الأحدث أولاً)
            final sortedHistory = List.of(state.dollarPriceHistory)..sort((a, b) {
              return b.effectiveDate.compareTo(a.effectiveDate); 
            });

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                // 🌟 عنوان مدمج وأنيق
                _buildHeader(context, sortedHistory.length),

                Expanded(
                  child: sortedHistory.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:[
                            Icon(Icons.monetization_on_outlined, size: 80, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            const Text('لا يوجد سجل لأسعار الدولار بعد.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                            const SizedBox(height: 8),
                            const Text('اضغط على الزر بالأسفل لإضافة تسعيرة.', style: TextStyle(color: Colors.blueGrey)),
                          ],
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0), 
                        children:[
                          Card(
                            elevation: 2,
                            margin: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                            clipBehavior: Clip.antiAlias,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 32),
                                child: DataTable(
                                  headingRowColor: WidgetStateProperty.all(Colors.green.shade50), // 🌟 ترويسة خضراء
                                  dataRowMinHeight: 55, 
                                  dataRowMaxHeight: 70, 
                                  columnSpacing: 40,
                                  horizontalMargin: 24,
                                  columns: const [
                                    DataColumn(label: Text('تاريخ التسعيرة', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green))),
                                    DataColumn(label: Text('سعر الصرف (ل.س)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green))),
                                    DataColumn(label: Text('مُدخل/مُعدِّل التسعيرة', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green))),
                                    DataColumn(label: Text('إجراء', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green))),
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
                                        // 1. التاريخ
                                        DataCell(Text(date, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade800, fontSize: 14))), 
                                        
                                        // 2. سعر الصرف
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade50,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              formatWithCommas(price.exchangeRate), 
                                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade900, fontSize: 15)
                                            ),
                                          )
                                        ),
                                        
                                        // 3. اسم المدخل وتاريخ الإدخال
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
                                                    state.userNamesMap[price.userId] ?? 'مجهول', 
                                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.orange.shade800),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children:[
                                                  const Icon(Icons.cloud_upload_outlined, size: 12, color: Colors.grey),
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

                                        // 4. زر الحذف
                                        DataCell(
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                                            tooltip: 'حذف هذه التسعيرة',
                                            onPressed: () {
                                              context.read<SettingsCubit>().deleteHistoricalDollarPrice(price.id);
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

  Widget _buildHeader(BuildContext context, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 24, 16),
      child: Row(
        children:[
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.blueGrey, size: 24),
            tooltip: 'العودة للإعدادات',
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.currency_exchange, color: Colors.green.shade700, size: 26),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'سجل أسعار الدولار',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueGrey),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade100)
            ),
            child: Text(
              'الإجمالي: $count',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade800, fontSize: 14),
            ),
          )
        ],
      ),
    );
  }
}