// lib/settings/view/price_history_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:our_home_erp_app/l10n/l10n.dart';
import '../cubit/settings_cubit.dart';
import 'dialogs/add_historical_price_dialog.dart';

String formatWithCommas(num number) {
  RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  return number.toInt().toString().replaceAllMapped(
    reg,
    (Match match) => '${match[1]},',
  );
}

class PriceHistoryPage extends StatefulWidget {
  const PriceHistoryPage({super.key});

  @override
  State<PriceHistoryPage> createState() => _PriceHistoryPageState();
}

class _PriceHistoryPageState extends State<PriceHistoryPage> {
  DateTimeRange? _selectedDateRange;

  Future<void> _pickDateRange() async {
    final initialDateRange =
        _selectedDateRange ??
        DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 30)),
          end: DateTime.now(),
        );

    final newRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.indigo.shade700,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (newRange != null) {
      setState(() {
        _selectedDateRange = newRange;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddHistoricalPriceDialog(context),
        icon: const Icon(Icons.add_chart),
        label: Text(
          l10n.dollarHistoryAddBtn,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo.shade600,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            var filteredHistory = state.priceHistory;

            if (_selectedDateRange != null) {
              filteredHistory = filteredHistory.where((price) {
                final date = DateTime(
                  price.effectiveDate.year,
                  price.effectiveDate.month,
                  price.effectiveDate.day,
                );
                final start = DateTime(
                  _selectedDateRange!.start.year,
                  _selectedDateRange!.start.month,
                  _selectedDateRange!.start.day,
                );
                final end = DateTime(
                  _selectedDateRange!.end.year,
                  _selectedDateRange!.end.month,
                  _selectedDateRange!.end.day,
                );

                return date.isAfter(start.subtract(const Duration(days: 1))) &&
                    date.isBefore(end.add(const Duration(days: 1)));
              }).toList();
            }

            final sortedHistory = List.of(filteredHistory)
              ..sort((a, b) {
                return b.effectiveDate.compareTo(a.effectiveDate);
              });

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, sortedHistory.length),

                if (_selectedDateRange != null) _buildActiveFilterIndicator(),

                Expanded(
                  child: sortedHistory.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.history_toggle_off,
                                size: 80,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _selectedDateRange != null
                                    ? l10n.priceHistoryEmptyRange
                                    : l10n.priceHistoryEmpty,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (_selectedDateRange == null)
                                Text(
                                  l10n.dollarHistoryAddHint,
                                  style: const TextStyle(
                                    color: Colors.blueGrey,
                                  ),
                                ),
                            ],
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(
                            16.0,
                            8.0,
                            16.0,
                            100.0,
                          ),
                          children: [
                            Card(
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
                                    minWidth:
                                        MediaQuery.of(context).size.width - 32,
                                  ),
                                  child: DataTable(
                                    headingRowColor: WidgetStateProperty.all(
                                      Colors.indigo.shade50,
                                    ),
                                    dataRowMinHeight: 55,
                                    dataRowMaxHeight: 70,
                                    columnSpacing: 30,
                                    horizontalMargin: 20,
                                    columns: [
                                      DataColumn(
                                        label: Text(
                                          l10n.dollarHistoryColDate,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.indigo,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          l10n.settingsIronLabel,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.indigo,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          l10n.settingsCementLabel,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.indigo,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          l10n.settingsBlockLabel,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.indigo,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          l10n.settingsFormworkLabel,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.indigo,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          l10n.settingsAggregatesLabel,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.indigo,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          l10n.settingsWorkerLabel,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.indigo,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          l10n.dollarHistoryColUser,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.indigo,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          l10n.dollarHistoryColActions,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.indigo,
                                          ),
                                        ),
                                      ),
                                    ],
                                    rows: sortedHistory.asMap().entries.map((
                                      mapEntry,
                                    ) {
                                      final index = mapEntry.key;
                                      final price = mapEntry.value;

                                      final hour = price.effectiveDate.hour;
                                      final minute = price.effectiveDate.minute
                                          .toString()
                                          .padLeft(2, '0');
                                      final date =
                                          "${price.effectiveDate.year}/${price.effectiveDate.month}/${price.effectiveDate.day}  ($hour:$minute)";

                                      return DataRow(
                                        color:
                                            WidgetStateProperty.resolveWith<
                                              Color?
                                            >((Set<WidgetState> states) {
                                              if (index.isEven) {
                                                return Colors.grey.withOpacity(
                                                  0.03,
                                                );
                                              }
                                              return null;
                                            }),
                                        cells: [
                                          DataCell(
                                            Text(
                                              date,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.indigo,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              formatWithCommas(price.ironPrice),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              formatWithCommas(
                                                price.cementPrice,
                                              ),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              formatWithCommas(
                                                price.block15Price,
                                              ),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              formatWithCommas(
                                                price.formworkAndPouringWages,
                                              ),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              formatWithCommas(
                                                price.aggregateMaterialsPrice,
                                              ),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              formatWithCommas(
                                                price.ordinaryWorkerWage,
                                              ),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.person_outline,
                                                      size: 14,
                                                      color: Colors
                                                          .orange
                                                          .shade700,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      state.userNamesMap[price
                                                              .userId] ??
                                                          l10n.clientUnknownUser,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 13,
                                                        color: Colors
                                                            .orange
                                                            .shade800,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 2),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Icons.access_time,
                                                      size: 12,
                                                      color: Colors.grey,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      '${price.createdAt.year}/${price.createdAt.month.toString().padLeft(2, '0')}/${price.createdAt.day.toString().padLeft(2, '0')} ${price.createdAt.hour}:${price.createdAt.minute.toString().padLeft(2, '0')}',
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
                                          DataCell(
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                color: Colors.red,
                                              ),
                                              tooltip: l10n
                                                  .dollarHistoryDeleteTooltip,
                                              onPressed: () {
                                                context
                                                    .read<SettingsCubit>()
                                                    .deleteHistoricalPrice(
                                                      price.id,
                                                    );
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      l10n.priceHistoryDeleteSuccess,
                                                    ),
                                                    backgroundColor:
                                                        Colors.green,
                                                  ),
                                                );
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

  Widget _buildActiveFilterIndicator() {
    final l10n = context.l10n;
    final start =
        "${_selectedDateRange!.start.year}/${_selectedDateRange!.start.month}/${_selectedDateRange!.start.day}";
    final end =
        "${_selectedDateRange!.end.year}/${_selectedDateRange!.end.month}/${_selectedDateRange!.end.day}";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.indigo.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.indigo.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.filter_alt, color: Colors.indigo.shade700, size: 20),
            const SizedBox(width: 8),
            Text(
              l10n.dollarHistoryFilterRange(start, end),
              style: TextStyle(
                color: Colors.indigo.shade900,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                setState(() => _selectedDateRange = null);
              },
              icon: const Icon(Icons.clear, size: 16, color: Colors.red),
              label: Text(
                l10n.dollarHistoryClearFilter,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int count) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 24, 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.blueGrey,
              size: 24,
            ),
            tooltip: l10n.dollarHistoryBackTooltip,
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.history, color: Colors.indigo.shade700, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.priceHistoryTitle,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          IconButton(
            onPressed: _pickDateRange,
            icon: Icon(
              Icons.date_range,
              color: Colors.indigo.shade700,
              size: 28,
            ),
            tooltip: l10n.dollarHistoryFilterTooltip,
          ),
          const SizedBox(width: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.indigo.shade100),
            ),
            child: Text(
              l10n.dollarHistoryTotalCount(count),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.indigo.shade700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
