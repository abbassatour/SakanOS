// lib/payments/view/payments_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart'; 
import '../cubit/payments_cubit.dart';
import '../../core/utils/ledger_pdf_helper.dart';
import '../../core/utils/pdf_generator.dart';
import '../../core/utils/pdf_preview_page.dart';
import '../../core/utils/whatsapp_helper.dart';
import '../../core/utils/excel_export_helper.dart';
import 'dialogs/add_payment_dialog.dart'; 
import 'dialogs/edit_payment_dialog.dart'; 
import 'dialogs/delete_payment_dialog.dart'; 

import 'dart:typed_data';
import '../../core/utils/allocated_ledger_pdf.dart'; // 🌟 الاستيراد الجديد
import '../../core/utils/unallocated_ledger_pdf.dart'; // 🌟 الاستيراد الجديد
// 🌟 استدعاء الحارس الشخصي والصلاحيات
import '../../auth/cubit/auth_cubit.dart';
import '../../core/constants/app_permissions.dart';

// ==========================================
// 🌟 دالة مساعدة لتنسيق الأرقام بالفواصل
// ==========================================
String formatWithCommas(num number) {
  RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  return number.toInt().toString().replaceAllMapped(reg, (Match match) => '${match[1]},');
}

class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PaymentsView();
  }
}

class PaymentsView extends StatelessWidget {
  const PaymentsView({super.key});

  @override
  Widget build(BuildContext context) {
    // 🌟 جلب حالة الصلاحيات للمستخدم الحالي
    final authState = context.watch<AuthCubit>().state;
    
    // 🌟 استخراج الصلاحيات 
    final canAdd = authState.hasPermission(AppPermissions.addPayments);
    final canEdit = authState.hasPermission(AppPermissions.editPayments);
    final canDelete = authState.hasPermission(AppPermissions.deletePayments);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: BlocBuilder<PaymentsCubit, PaymentsState>(
          builder: (context, state) {
            if (state.status == PaymentsStatus.loading && state.contracts.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: Colors.deepOrange));
            }
            
            if (state.clients.isEmpty || state.contracts.isEmpty) {
              return const Center(child: Text('لا يوجد بيانات كافية. يرجى إضافة عميل وتوقيع عقد أولاً.', style: TextStyle(fontSize: 18, color: Colors.grey)));
            }

            return Column(
              children:[
                // ==========================================
                // 🌟 القسم العلوي
                // ==========================================
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow:[BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))],
                    border: Border(bottom: BorderSide(color: Colors.deepOrange.shade50, width: 2)),
                  ),
                  child: Row(
                    children:[
                      Container(
                        height: 48,
                        width: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: Colors.deepOrange.shade50, borderRadius: BorderRadius.circular(12)),
                        child: Icon(Icons.account_balance_wallet, color: Colors.deepOrange.shade600, size: 24),
                      ),
                      const SizedBox(width: 12),
                      
                      Expanded(
                        child: SizedBox(
                          height: 48, 
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return DropdownMenu<String>(
                                width: constraints.maxWidth, 
                                enableSearch: true, 
                                enableFilter: true, 
                                hintText: '🔍 ابحث واختر العقد...', 
                                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                inputDecorationTheme: InputDecorationTheme(
                                  filled: true,
                                  fillColor: Colors.grey.shade50, 
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0), 
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.deepOrange.shade400, width: 2),
                                  ),
                                ),
                                initialSelection: state.contracts.any((c) => c.id == state.selectedContractId) ? state.selectedContractId : null,
                                onSelected: (val) {
                                  if (val != null) context.read<PaymentsCubit>().selectContract(val);
                                },
                                dropdownMenuEntries: state.contracts.map((contract) {
                                  final clientIdx = state.clients.indexWhere((c) => c.id == contract.clientId);
                                  final clientName = clientIdx >= 0 ? state.clients[clientIdx].name : 'عميل غير معروف (محذوف)';
                                  return DropdownMenuEntry<String>(
                                    value: contract.id, 
                                    label: '$clientName (${contract.apartmentDetails})',
                                  );
                                }).toList(),
                              );
                            }
                          ),
                        ),
                      ),
                      
                      if (state.selectedContractId != null) ...[
                        const SizedBox(width: 12),
                        
                        SizedBox(
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              if (state.ledgerEntries.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لا يوجد حركات مالية لتصديرها!'), backgroundColor: Colors.red));
                                return;
                              }
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جاري تجهيز ملف الإكسل...')));
                              
                              final contract = state.contracts.firstWhere((c) => c.id == state.selectedContractId);
                              final client = state.clients.firstWhere((c) => c.id == contract.clientId);

                              final filePath = await ExcelExportHelper.exportLedgerToExcel(
                                ledgerEntries: state.ledgerEntries, contract: contract, client: client,
                              );

                              if (context.mounted) {
                                if (filePath != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم الحفظ بنجاح في: $filePath'), backgroundColor: Colors.green));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فشل تصدير الملف.'), backgroundColor: Colors.red));
                                }
                              }
                            },
                            icon: const Icon(Icons.table_view, size: 20),
                            label: const Text('Excel', style: TextStyle(fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600, 
                              foregroundColor: Colors.white, 
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 8),
                        
                        SizedBox(
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              if (state.ledgerEntries.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لا يوجد حركات مالية لطباعتها!'), backgroundColor: Colors.red));
                                return;
                              }
                              
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جاري تجهيز كشف الحساب (PDF)...')));
                              
                              final contract = state.contracts.firstWhere((c) => c.id == state.selectedContractId);
                              final client = state.clients.firstWhere((c) => c.id == contract.clientId);

                              Apartment? selectedApartment;
                              Building? selectedBuilding;

                              if (contract.apartmentId != null) {
                                final aptIndex = state.apartments.indexWhere((a) => a.id == contract.apartmentId);
                                if (aptIndex != -1) {
                                  selectedApartment = state.apartments[aptIndex];
                                  final bldIndex = state.buildings.indexWhere((b) => b.id == selectedApartment!.buildingId);
                                  if (bldIndex != -1) {
                                    selectedBuilding = state.buildings[bldIndex];
                                  }
                                }
                              }

                              // ==========================================
                              // 🌟 التوجيه الذكي: اختيار ملف الـ PDF المناسب
                              // ==========================================
                              final bool isAllocated = contract.contractType == 'متخصص';
                              Uint8List pdfBytes;

                              if (isAllocated) {
                                // 🛡️ حماية للتأكد من جلب بيانات الشقة والمحضر
                                if (selectedApartment == null || selectedBuilding == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('خطأ: بيانات الشقة أو المحضر غير مكتملة، لا يمكن الطباعة.'), backgroundColor: Colors.red));
                                  return;
                                }

                                pdfBytes = await AllocatedLedgerPdf.generatePdf(
                                  ledgerEntries: state.ledgerEntries, 
                                  contract: contract, 
                                  client: client,
                                  apartment: selectedApartment, 
                                  building: selectedBuilding,   
                                );
                              } else {
                                pdfBytes = await UnallocatedLedgerPdf.generatePdf(
                                  ledgerEntries: state.ledgerEntries, 
                                  contract: contract, 
                                  client: client,
                                );
                              }

                              if (context.mounted) {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (_) => PdfPreviewPage(pdfBytes: pdfBytes, title: 'كشف_حساب_${client.name}')
                                ));
                              }
                            },
                            icon: const Icon(Icons.picture_as_pdf, size: 20),
                            label: const Text('PDF', style: TextStyle(fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600, 
                              foregroundColor: Colors.white, 
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),
                        
                        Tooltip(
                          message: canAdd ? 'إضافة دفعة مالية جديدة' : 'لا تملك صلاحية إدخال دفعات',
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: canAdd ? () => showAddPaymentDialog(context, state.selectedContractId!) : null,
                              icon: const Icon(Icons.add_card, size: 20),
                              label: const Text('إدخال دفعة', style: TextStyle(fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: canAdd ? Colors.deepOrange.shade600 : Colors.grey.shade300, 
                                foregroundColor: canAdd ? Colors.white : Colors.grey.shade600, 
                                elevation: canAdd ? 2 : 0,
                                disabledBackgroundColor: Colors.grey.shade300,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // ==========================================
                // 🌟 القسم السفلي: جدول الحركات
                // ==========================================
                Expanded(
                  child: state.selectedContractId == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:[
                              Icon(Icons.receipt_long, size: 80, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text('يرجى اختيار عقد من شريط البحث بالأعلى لعرض الدفعات.', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                            ],
                          )
                        )
                      : state.ledgerEntries.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children:[
                                  Icon(Icons.money_off, size: 60, color: Colors.orange.shade200),
                                  const SizedBox(height: 16),
                                  const Text('لم يتم إدخال أي دفعة لهذا العقد حتى الآن.', style: TextStyle(fontSize: 16)),
                                ],
                              )
                            )
                          : ListView(
                              padding: const EdgeInsets.all(16.0), 
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
                                        headingRowColor: WidgetStateProperty.all(Colors.deepOrange.shade50),
                                        dataRowMaxHeight: 65,
                                        columns: const[
                                          DataColumn(label: Text('رقم الإيصال', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange))),
                                          DataColumn(label: Text('المبلغ (إيداع / سحب)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange))),
                                          DataColumn(label: Text('سعر المتر', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange))),
                                          DataColumn(label: Text('الأمتار المحولة', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange))),
                                          DataColumn(label: Text('تاريخ الدفع', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange))),
                                          DataColumn(label: Text('آخر تعديل بواسطة', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange))),
                                          DataColumn(label: Text('إجراءات', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange))),
                                        ],
                                        rows: state.ledgerEntries.asMap().entries.map((mapEntry) {
                                          final int index = mapEntry.key;
                                          final entry = mapEntry.value;
                                          final bool isLatestEntry = index == 0;
                                          
                                          // 🌟 التحقق هل هي دفعة سالبة (استرداد)
                                          final bool isRefund = entry.amountPaid < 0;

                                          return DataRow(
                                            color: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                                              if (index.isEven) return Colors.grey.withOpacity(0.03); 
                                              return null; 
                                            }),
                                            cells:[
                                            DataCell(Text(entry.id.split('-').first.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade600, fontSize: 13))),
                                            
                                            // ==========================================
                                            // 🌟 1. تمييز المبلغ (أخضر للإيداع، أحمر للاسترداد)
                                            // ==========================================
                                            DataCell(
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children:[
                                                  Icon(
                                                    isRefund ? Icons.remove_circle_outline : Icons.add_circle_outline, 
                                                    color: isRefund ? Colors.red : Colors.green, 
                                                    size: 18
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    '${formatWithCommas(entry.amountPaid.abs())} ل.س', 
                                                    style: TextStyle(color: isRefund ? Colors.red : Colors.green, fontWeight: FontWeight.bold, fontSize: 15)
                                                  ),
                                                ],
                                              )
                                            ),
                                            
                                            DataCell(Text('${formatWithCommas(entry.meterPriceAtPayment)} ل.س', style: const TextStyle(color: Colors.black87))),
                                            
                                            // ==========================================
                                            // 🌟 2. تمييز الأمتار المخصومة
                                            // ==========================================
                                            DataCell(
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: isRefund ? Colors.red.shade50 : Colors.deepOrange.shade50, 
                                                  borderRadius: BorderRadius.circular(6),
                                                  border: Border.all(color: isRefund ? Colors.red.shade100 : Colors.transparent)
                                                ),
                                                child: Text(
                                                  '${isRefund ? "-" : "+"}${entry.convertedMeters.abs().toStringAsFixed(3)} م²', 
                                                  style: TextStyle(fontWeight: FontWeight.bold, color: isRefund ? Colors.red.shade700 : Colors.deepOrange.shade700, fontSize: 15)
                                                ),
                                              )
                                            ),
                                            
                                            DataCell(Text('${entry.paymentDate.year}/${entry.paymentDate.month}/${entry.paymentDate.day}', style: const TextStyle(color: Colors.black87))),
                                            
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
                                                        state.userNamesMap[entry.userId] ?? 'مجهول', 
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
                                                        '${entry.updatedAt.year}/${entry.updatedAt.month.toString().padLeft(2,'0')}/${entry.updatedAt.day.toString().padLeft(2,'0')} ${entry.updatedAt.hour}:${entry.updatedAt.minute.toString().padLeft(2,'0')}',
                                                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              )
                                            ),

                                            DataCell(Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children:[
                                                IconButton(
                                                  icon: const Icon(Icons.print, color: Colors.blue),
                                                  tooltip: 'معاينة وطباعة الفاتورة',
                                                  onPressed: () async {
                                                    final contractIdx = state.contracts.indexWhere((c) => c.id == entry.contractId);
                                                    if(contractIdx == -1) return;
                                                    final contract = state.contracts[contractIdx];

                                                    final clientIdx = state.clients.indexWhere((c) => c.id == contract.clientId);
                                                    if(clientIdx == -1) return;
                                                    final client = state.clients[clientIdx];
                                                    
                                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جاري تجهيز الفاتورة...')));

                                                    double bonusPct = entry.fees; 
                                                    double? originalInst;
                                                    double? meterPriceBonus;

                                                    if (bonusPct > 0) {
                                                      originalInst = entry.amountPaid + (entry.amountPaid * (bonusPct / 100));
                                                      meterPriceBonus = entry.amountPaid / entry.convertedMeters;
                                                    }

                                                    final pdfBytes = await PdfGenerator.generateReceiptPdf(
                                                      entry: entry, 
                                                      contract: contract, 
                                                      client: client,
                                                      originalInstallment: originalInst,
                                                      bonusPercentage: bonusPct > 0 ? bonusPct : null,
                                                      meterPriceAfterBonus: meterPriceBonus,
                                                    );

                                                    if (context.mounted) {
                                                      Navigator.push(context, MaterialPageRoute(builder: (_) => PdfPreviewPage(pdfBytes: pdfBytes, title: 'فاتورة_${entry.id.split('-').first}_${client.name}')));
                                                    }
                                                  },
                                                ),
                                                IconButton(
                                                  icon: Icon(Icons.chat, color: entry.isWhatsAppSent ? Colors.grey : Colors.green),
                                                  tooltip: entry.isWhatsAppSent ? 'تم الإرسال (إعادة إرسال)' : 'إرسال الفاتورة عبر واتساب',
                                                  onPressed: () async {
                                                    final contractIdx = state.contracts.indexWhere((c) => c.id == entry.contractId);
                                                    if(contractIdx == -1) return;
                                                    final contract = state.contracts[contractIdx];

                                                    final clientIdx = state.clients.indexWhere((c) => c.id == contract.clientId);
                                                    if(clientIdx == -1) return;
                                                    final client = state.clients[clientIdx];
                                                    
                                                    final success = await WhatsAppHelper.sendReceiptMessage(entry: entry, contract: contract, client: client);

                                                    if (context.mounted && success) {
                                                      context.read<PaymentsCubit>().markAsSent(entry.id, contract.id);
                                                    }
                                                  },
                                                ),
                                                Container(width: 1, height: 24, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 4)), // خط فاصل
                                                
                                                IconButton(
                                                  icon: Icon(Icons.edit_note, color: canEdit ? Colors.orange : Colors.grey.shade300),
                                                  tooltip: canEdit ? 'تعديل قيمة الدفعة (للإدارة فقط)' : 'لا تملك صلاحية تعديل الدفعات',
                                                  onPressed: canEdit ? () => showEditPaymentDialog(context, entry) : null,
                                                ),
                                                
                                                if (canDelete)
                                                  IconButton(
                                                    icon: Icon(Icons.delete_forever, color: isLatestEntry ? Colors.red : Colors.grey.shade300),
                                                    tooltip: isLatestEntry ? 'إلغاء آخر دفعة' : 'لا يمكن حذف الدفعات القديمة',
                                                    onPressed: isLatestEntry ? () => showDeletePaymentDialog(context, entry) : null,
                                                  ),
                                              ],
                                            )),
                                          ]);
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
}