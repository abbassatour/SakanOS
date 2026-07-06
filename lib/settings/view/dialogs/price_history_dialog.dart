// lib/settings/view/dialogs/price_history_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/settings_cubit.dart';

class PriceHistoryDialog extends StatelessWidget {
  const PriceHistoryDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'سجل تغيير الأسعار',
        style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: 400,
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            if (state.priceHistory.isEmpty) {
              return const Center(child: Text('لا يوجد سجل أسعار محفوظ بعد.'));
            }

            final sortedHistory = List.of(state.priceHistory)
              ..sort((a, b) {
                return b.effectiveDate.compareTo(a.effectiveDate);
              });

            return SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    Colors.grey.shade200,
                  ),
                  columns: const [
                    DataColumn(
                      label: Text(
                        'تاريخ التسعيرة',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'حديد (كغ)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'اسمنت (كيس)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'بلوك 15',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'كوفراج وصب (م³)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'حصويات (م³)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'عامل (يوم)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'إجراء',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows: sortedHistory.map((price) {
                    final hour = price.effectiveDate.hour;
                    final minute = price.effectiveDate.minute
                        .toString()
                        .padLeft(2, '0');
                    final date =
                        "${price.effectiveDate.year}/${price.effectiveDate.month}/${price.effectiveDate.day}  ($hour:$minute)";

                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            date,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                        ),
                        DataCell(Text(price.ironPrice.toStringAsFixed(0))),
                        DataCell(Text(price.cementPrice.toStringAsFixed(0))),
                        DataCell(Text(price.block15Price.toStringAsFixed(0))),
                        DataCell(
                          Text(
                            price.formworkAndPouringWages.toStringAsFixed(0),
                          ),
                        ),
                        DataCell(
                          Text(
                            price.aggregateMaterialsPrice.toStringAsFixed(0),
                          ),
                        ),
                        DataCell(
                          Text(price.ordinaryWorkerWage.toStringAsFixed(0)),
                        ),
                        DataCell(
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            tooltip: 'حذف هذه التسعيرة',
                            onPressed: () {
                              context
                                  .read<SettingsCubit>()
                                  .deleteHistoricalPrice(price.id);
                            },
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إغلاق'),
        ),
      ],
    );
  }
}
