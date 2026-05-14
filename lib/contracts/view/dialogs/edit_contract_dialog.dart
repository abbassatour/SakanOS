// lib/contracts/view/dialogs/edit_contract_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:local_storage_api/local_storage_api.dart' show Contract;
import '../../../buildings/cubit/buildings_cubit.dart';
import '../../cubit/contracts_cubit.dart';
import 'verify_pin_dialog.dart';

import '../../../auth/cubit/auth_cubit.dart';
import '../../../core/constants/app_permissions.dart';

import '../../../core/utils/handover_pledge_pdf_helper.dart';
import '../../../core/utils/pdf_preview_page.dart';

void showEditContractDialog(BuildContext parentContext, Contract contract) {
  final detailsController = TextEditingController(text: contract.apartmentDetails);
  final guarantorController = TextEditingController(text: contract.guarantorName);
  final monthsController = TextEditingController(text: contract.installmentsCount.toString());
  final monthlyAmountController = TextEditingController(text: contract.agreedMonthlyAmount.toString());
  
  DateTime selectedDate = contract.contractDate.toLocal();

  // متحكمات قسم الاستلام (Handover)
  final handoverNotesController = TextEditingController(text: contract.handoverNotes ?? '');
  DateTime? actualHandoverDate = contract.actualHandoverDate?.toLocal();
  bool isHandoverFormVisible = contract.isHandedOver; 
  bool isAllocated = contract.contractType == 'متخصص';

  // 🌟 (تم إزالة متحكمات براءة الذمة الأولية من هنا)

  // متحكمات الغرامة المرنة
  bool isPenaltyActive = contract.isPenaltyActive ?? false; 
  final penaltyPctCtrl = TextEditingController(text: (contract.penaltyPercentage ?? 0).toString());
  final penaltyIntervalCtrl = TextEditingController(text: (contract.penaltyIntervalMonths ?? 1).toString());

  final bool isCompleted = contract.isCompleted;

  final authState = parentContext.read<AuthCubit>().state;
  final bool isSuperAdmin = authState.isSystemAdmin;
  final bool canEdit = authState.hasPermission(AppPermissions.createContracts) && !isCompleted; 

  showDialog(
    context: parentContext,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:[
                const Text('إدارة وتعديل تفاصيل العقد', style: TextStyle(color: Colors.blue)),
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.shade400)),
                    child: Row(
                      children:[
                        Icon(Icons.lock, size: 16, color: Colors.green.shade800),
                        const SizedBox(width: 4),
                        Text('مكتمل ومغلق', style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  )
              ],
            ),
            content: SizedBox(
              width: 500, 
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children:[
                    if (isCompleted)
                      Container(
                        padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green.shade200)),
                        child: Row(children:[
                          Icon(Icons.verified_user, color: Colors.green.shade700),
                          const SizedBox(width: 12),
                          Expanded(child: Text('هذا العقد مكتمل وتم أرشفته. جميع البيانات أصبحت للقراءة فقط لحماية السجلات المالية.', style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.w600))),
                        ]),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(8), color: Colors.amber.shade50,
                        child: const Row(children:[
                          Icon(Icons.info_outline, color: Colors.brown, size: 20),
                          SizedBox(width: 8),
                          Expanded(child: Text('لا يمكن تغيير العميل، العقار، أو سعر المتر بعد التوقيع. يمكنك فقط تحديث التفاصيل الإدارية أو ملف العقد.', style: TextStyle(color: Colors.brown, fontSize: 13))),
                        ]),
                      ),
                    
                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:[
                          const Text('📅 تاريخ التوقيع:', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextButton.icon(
                            icon: Icon(Icons.edit_calendar, color: canEdit ? Colors.blue : Colors.grey),
                            label: Text('${selectedDate.year}/${selectedDate.month}/${selectedDate.day}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: canEdit ? Colors.blue : Colors.grey)),
                            onPressed: canEdit ? () async {
                              final pickedDate = await showDatePicker(context: dialogContext, initialDate: selectedDate, firstDate: DateTime(2000), lastDate: DateTime.now());
                              if (pickedDate != null) setState(() => selectedDate = pickedDate);
                            } : null, 
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(controller: monthlyAmountController, enabled: canEdit, decoration: const InputDecoration(labelText: 'المبلغ الشهري المتفق عليه', border: OutlineInputBorder(), prefixIcon: Icon(Icons.payments, color: Colors.green)), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                    const SizedBox(height: 16),
                    TextField(controller: detailsController, enabled: canEdit, decoration: const InputDecoration(labelText: 'وصف العقد / التفاصيل (الشروط الإضافية)', border: OutlineInputBorder()), maxLines: 2),
                    const SizedBox(height: 16),
                    Row(
                      children:[
                        Expanded(flex: 2, child: TextField(controller: guarantorController, enabled: canEdit, decoration: const InputDecoration(labelText: 'اسم الكفيل', border: OutlineInputBorder()))),
                        const SizedBox(width: 12),
                        Expanded(flex: 1, child: TextField(controller: monthsController, enabled: canEdit, decoration: const InputDecoration(labelText: 'المدة (أشهر)', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (isAllocated) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: contract.isHandedOver ? Colors.teal.shade50 : Colors.blueGrey.shade50,
                          border: Border.all(color: contract.isHandedOver ? Colors.teal.shade300 : Colors.blueGrey.shade200, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children:[
                                Row(
                                  children:[
                                    Icon(Icons.vpn_key, color: contract.isHandedOver ? Colors.teal : Colors.blueGrey.shade700),
                                    const SizedBox(width: 8),
                                    Text(
                                      contract.isHandedOver ? '✅ الشقة مُسلّمة للعميل' : 'إدارة تسليم العقار',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: contract.isHandedOver ? Colors.teal.shade800 : Colors.blueGrey.shade800),
                                    ),
                                  ],
                                ),
                                if (contract.agreedHandoverDate != null)
                                  Tooltip(
                                    message: 'الموعد المتفق عليه في العقد الأساسي',
                                    child: Text('المتفق عليه: ${contract.agreedHandoverDate!.year}/${contract.agreedHandoverDate!.month}', style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                                  ),
                              ],
                            ),
                            
                            if (!isHandoverFormVisible) ...[
                              const SizedBox(height: 12),
                              Center(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                                  icon: const Icon(Icons.handshake),
                                  label: const Text('تسليم الشقة الآن'),
                                  onPressed: canEdit ? () => setState(() => isHandoverFormVisible = true) : null,
                                ),
                              ),
                            ] else ...[
                              const Divider(height: 24),
                              Row(
                                children:[
                                  Expanded(
                                    child: InkWell(
                                      onTap: canEdit ? () async {
                                        final date = await showDatePicker(context: dialogContext, initialDate: actualHandoverDate ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime.now().add(const Duration(days: 30)));
                                        if (date != null) setState(() => actualHandoverDate = date);
                                      } : null,
                                      child: InputDecorator(
                                        decoration: InputDecoration(
                                          labelText: 'تاريخ التسليم الفعلي *', border: const OutlineInputBorder(), filled: true, fillColor: canEdit ? Colors.white : Colors.grey.shade100,
                                          prefixIcon: Icon(Icons.calendar_today, color: canEdit ? Colors.teal : Colors.grey), errorText: actualHandoverDate == null ? 'مطلوب' : null,
                                        ),
                                        child: Text(actualHandoverDate != null ? '${actualHandoverDate!.year}/${actualHandoverDate!.month}/${actualHandoverDate!.day}' : 'حدد التاريخ', style: TextStyle(color: actualHandoverDate != null ? (canEdit ? Colors.black : Colors.grey) : Colors.red, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              
                              // 🌟 (تم إزالة ويدجت التشيك بوكس من هنا)

                              TextField(controller: handoverNotesController, enabled: canEdit, maxLines: 2, decoration: const InputDecoration(labelText: 'ملاحظات / نواقص التسليم (إن وجدت)', border: OutlineInputBorder(), filled: true, fillColor: Colors.white)),
                              
                              const SizedBox(height: 12),
                              
                              if (canEdit) 
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: contract.isHandedOver ? Colors.orange : Colors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                                    onPressed: () async {
                                      if (actualHandoverDate == null) {
                                        ScaffoldMessenger.of(parentContext).showSnackBar(const SnackBar(content: Text('يجب تحديد تاريخ التسليم الفعلي!'), backgroundColor: Colors.red));
                                        return;
                                      }
                                      
                                      bool isAuthorized = await showVerifyPinDialog(parentContext);
                                      if (!isAuthorized) return;

                                      if(parentContext.mounted) {
                                        ScaffoldMessenger.of(parentContext).showSnackBar(const SnackBar(content: Text('جاري توثيق التسليم... ⏳'), backgroundColor: Colors.teal));
                                        
                                        await parentContext.read<ContractsCubit>().markContractAsHandedOver(
                                          contractId: contract.id, actualHandoverDate: actualHandoverDate!, notes: handoverNotesController.text,
                                        );
                                        
                                        // 🌟 (تم إزالة استدعاء signInitialClearance من هنا)
                                        
                                        if(parentContext.mounted) {
                                          parentContext.read<BuildingsCubit>().loadData();
                                          ScaffoldMessenger.of(parentContext).showSnackBar(const SnackBar(content: Text('تم توثيق الاستلام بنجاح! ✅'), backgroundColor: Colors.green));
                                          Navigator.pop(dialogContext); 
                                        }
                                      }
                                    },
                                    child: Text(contract.isHandedOver ? 'تحديث بيانات الاستلام' : 'تأكيد وحفظ الاستلام'),
                                  ),
                                ),
                              
                              if (contract.isHandedOver && canEdit) ...[
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red.shade700, side: BorderSide(color: Colors.red.shade300), padding: const EdgeInsets.symmetric(vertical: 12)),
                                    icon: const Icon(Icons.cancel_presentation),
                                    label: const Text('إلغاء التسليم (تراجع عن الإجراء)'),
                                    onPressed: () async {
                                      bool isAuthorized = await showVerifyPinDialog(parentContext);
                                      if (!isAuthorized) return;
                                      if(parentContext.mounted) {
                                        ScaffoldMessenger.of(parentContext).showSnackBar(const SnackBar(content: Text('جاري إلغاء التسليم... ⏳'), backgroundColor: Colors.orange));
                                        await parentContext.read<ContractsCubit>().cancelContractHandover(contractId: contract.id);
                                        
                                        // 🌟 (تم إزالة استدعاء التراجع عن signInitialClearance من هنا)

                                        if(parentContext.mounted) {
                                          parentContext.read<BuildingsCubit>().loadData();
                                          ScaffoldMessenger.of(parentContext).showSnackBar(const SnackBar(content: Text('تم إلغاء التسليم بنجاح!'), backgroundColor: Colors.green));
                                          Navigator.pop(dialogContext); 
                                        }
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(foregroundColor: Colors.teal.shade700, side: BorderSide(color: Colors.teal.shade300), padding: const EdgeInsets.symmetric(vertical: 12)),
                                    icon: const Icon(Icons.print),
                                    label: const Text('طباعة محضر الاستلام والتعهد (PDF)'),
                                    onPressed: () async {
                                      ScaffoldMessenger.of(parentContext).showSnackBar(const SnackBar(content: Text('جاري إنشاء المستند... ⏳'), backgroundColor: Colors.teal));
                                      final client = parentContext.read<ContractsCubit>().state.clients.firstWhere((c) => c.id == contract.clientId);
                                      final buildingsState = parentContext.read<BuildingsCubit>().state;
                                      final apartment = buildingsState.apartments.firstWhere((a) => a.id == contract.apartmentId);
                                      final building = buildingsState.buildings.firstWhere((b) => b.id == apartment.buildingId);

                                      final pdfBytes = await HandoverPledgePdfHelper.generatePdf(
                                        contract: contract, client: client, apartment: apartment, building: building,
                                      );

                                      if (parentContext.mounted) {
                                        Navigator.push(parentContext, MaterialPageRoute(
                                          builder: (_) => PdfPreviewPage(pdfBytes: pdfBytes, title: 'محضر_استلام_${client.name}')
                                        ));
                                      }
                                    },
                                  ),
                                ),
                              ]
                            ]
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // تعديل أو تفعيل غرامة التأخير
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.deepOrange.shade50, border: Border.all(color: Colors.deepOrange.shade200, width: 2), borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          children:[
                            SwitchListTile(
                              title: const Text('تفعيل غرامة التأخير (ما بعد الاستلام)', style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)),
                              subtitle: const Text('لتطبيق نسبة مئوية تتراكم على الذمة المالية بعد استلام الشقة.'),
                              value: isPenaltyActive, activeColor: Colors.deepOrange,
                              onChanged: canEdit ? (val) => setState(() => isPenaltyActive = val) : null, contentPadding: EdgeInsets.zero,
                            ),
                            if (isPenaltyActive) ...[
                              const SizedBox(height: 12),
                              Row(
                                children:[
                                  Expanded(child: TextFormField(controller: penaltyPctCtrl, enabled: canEdit, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: 'نسبة الغرامة', suffixText: '%', border: const OutlineInputBorder(), filled: true, fillColor: canEdit ? Colors.white : Colors.grey.shade100, prefixIcon: const Icon(Icons.percent, color: Colors.deepOrange)))),
                                  const SizedBox(width: 16),
                                  Expanded(child: TextFormField(controller: penaltyIntervalCtrl, enabled: canEdit, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'تُطبق كل', suffixText: 'أشهر', border: const OutlineInputBorder(), filled: true, fillColor: canEdit ? Colors.white : Colors.grey.shade100, prefixIcon: const Icon(Icons.update, color: Colors.deepOrange)))),
                                ],
                              ),
                            ]
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ملف العقد والإغلاق النهائي
                    Container(
                      padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey.shade50, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:[
                          Row(children:[
                            Icon(contract.contractFileUrl != null && contract.contractFileUrl!.isNotEmpty ? Icons.check_circle : Icons.warning_amber_rounded, color: contract.contractFileUrl != null && contract.contractFileUrl!.isNotEmpty ? Colors.green : Colors.orange),
                            const SizedBox(width: 8),
                            Text(contract.contractFileUrl != null && contract.contractFileUrl!.isNotEmpty ? 'يوجد ملف مرفق' : 'لا يوجد ملف', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ]),
                          TextButton.icon(
                            icon: Icon(Icons.upload_file, color: canEdit ? Colors.blue : Colors.grey),
                            label: Text(contract.contractFileUrl != null && contract.contractFileUrl!.isNotEmpty ? 'استبدال الملف' : 'إرفاق ملف', style: TextStyle(color: canEdit ? Colors.blue : Colors.grey)),
                            onPressed: canEdit ? () async {
                              bool isAuth = await showVerifyPinDialog(parentContext);
                              if (!isAuth) return; 
                              FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions:['doc', 'docx', 'pdf']);
                              if (result != null && result.files.single.path != null) {
                                final filePath = result.files.single.path!;
                                final extension = result.files.single.extension ?? 'docx';
                                if(parentContext.mounted) {
                                  ScaffoldMessenger.of(parentContext).showSnackBar(const SnackBar(content: Text('جاري رفع الملف... ⏳'), backgroundColor: Colors.orange));
                                  await parentContext.read<ContractsCubit>().attachContractFile(contractId: contract.id, filePath: filePath, extension: extension);
                                  if(parentContext.mounted) {
                                    ScaffoldMessenger.of(parentContext).showSnackBar(const SnackBar(content: Text('تم استبدال الملف بنجاح! ✅'), backgroundColor: Colors.green));
                                    Navigator.pop(dialogContext); 
                                  }
                                }
                              }
                            } : null, 
                          ),
                        ],
                      ),
                    ),

                    if (isSuperAdmin) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: isCompleted ? Colors.grey.shade700 : Colors.green.shade700, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                          icon: Icon(isCompleted ? Icons.lock_open : Icons.lock),
                          label: Text(isCompleted ? 'إعادة فتح العقد (إلغاء الأرشفة)' : 'أرشفة وإغلاق العقد (براءة ذمة مالية)'),
                          onPressed: () async {
                            bool isAuth = await showVerifyPinDialog(parentContext);
                            if (!isAuth) return;
                            if (parentContext.mounted) {
                              ScaffoldMessenger.of(parentContext).showSnackBar(SnackBar(content: Text(isCompleted ? 'جاري فتح العقد...' : 'جاري إغلاق وأرشفة العقد...')));
                              await parentContext.read<ContractsCubit>().toggleContractCompletion(contractId: contract.id, isCompleted: !isCompleted);
                              if (parentContext.mounted) {
                                ScaffoldMessenger.of(parentContext).showSnackBar(SnackBar(content: const Text('تم تغيير حالة العقد بنجاح!'), backgroundColor: Colors.green.shade700));
                                Navigator.pop(dialogContext);
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween, 
            actions:[
              if (isSuperAdmin && !isCompleted) 
                TextButton.icon(
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  label: const Text('إلغاء العقد نهائياً', style: TextStyle(color: Colors.red)),
                  onPressed: () async {
                    Navigator.pop(dialogContext); 
                    bool isAuth = await showVerifyPinDialog(parentContext); 
                    if (isAuth && parentContext.mounted) {
                      ScaffoldMessenger.of(parentContext).showSnackBar(SnackBar(content: const Text('جاري إلغاء العقد وتحرير الشقة... ⏳'), backgroundColor: Colors.red.shade400));
                      await parentContext.read<ContractsCubit>().deleteContract(contract.id);
                      if (parentContext.mounted) {
                        parentContext.read<BuildingsCubit>().loadData();
                        ScaffoldMessenger.of(parentContext).showSnackBar(const SnackBar(content: Text('تم إلغاء العقد بنجاح! ✅'), backgroundColor: Colors.green));
                      }
                    }
                  },
                )
              else
                const SizedBox.shrink(), 

              if (canEdit)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children:[
                    TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                      onPressed: () async {
                        if (monthsController.text.isNotEmpty && monthlyAmountController.text.isNotEmpty) {
                          if (isPenaltyActive && double.tryParse(penaltyPctCtrl.text) == null) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('أدخل نسبة غرامة صحيحة!'), backgroundColor: Colors.red));
                            return;
                          }
                          Navigator.pop(dialogContext); 
                          bool isAuth = await showVerifyPinDialog(parentContext);
                          if (isAuth && parentContext.mounted) {
                            parentContext.read<ContractsCubit>().updateContract(
                              id: contract.id, details: detailsController.text,
                              guarantorName: guarantorController.text.isEmpty ? 'بدون كفيل' : guarantorController.text,
                              installmentsCount: int.parse(monthsController.text), agreedMonthlyAmount: double.parse(monthlyAmountController.text), 
                              contractDate: selectedDate, isPenaltyActive: isAllocated ? isPenaltyActive : false,
                              penaltyPercentage: isAllocated && isPenaltyActive ? (double.tryParse(penaltyPctCtrl.text) ?? 0.0) : 0.0,
                              penaltyIntervalMonths: isAllocated && isPenaltyActive ? (int.tryParse(penaltyIntervalCtrl.text) ?? 1) : 1,
                            );
                          }
                        }
                      },
                      child: const Text('حفظ التعديلات النصية'),
                    ),
                  ],
                )
              else
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إغلاق')),
            ],
          );
        }
      );
    },
  );
}