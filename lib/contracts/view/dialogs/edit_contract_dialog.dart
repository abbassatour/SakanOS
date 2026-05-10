// lib/contracts/view/dialogs/edit_contract_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:local_storage_api/local_storage_api.dart' show Contract;
import '../../../buildings/cubit/buildings_cubit.dart';
import '../../cubit/contracts_cubit.dart';
import 'verify_pin_dialog.dart';

// 🌟 استدعاء الحارس الشخصي والصلاحيات
import '../../../auth/cubit/auth_cubit.dart';
import '../../../core/constants/app_permissions.dart';

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

  // 🌟[الإضافات الجديدة]: متحكمات الغرامة المرنة لتعديلها
  bool isPenaltyActive = contract.isPenaltyActive ?? false; // استخدمنا ?? false للحماية من الـ null
  final penaltyPctCtrl = TextEditingController(text: (contract.penaltyPercentage ?? 0).toString());
  final penaltyIntervalCtrl = TextEditingController(text: (contract.penaltyIntervalMonths ?? 1).toString());

  // جلب حالة الصلاحيات للمستخدم الحالي
  final authState = parentContext.read<AuthCubit>().state;
  final bool canEdit = authState.hasPermission(AppPermissions.createContracts); 
  final bool isSuperAdmin = authState.isSystemAdmin;

  showDialog(
    context: parentContext,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('إدارة وتعديل تفاصيل العقد', style: TextStyle(color: Colors.blue)),
            content: SizedBox(
              width: 500, 
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children:[
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.amber.shade50,
                      child: const Row(
                        children:[
                          Icon(Icons.info_outline, color: Colors.brown, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'لا يمكن تغيير العميل، العقار، أو سعر المتر بعد التوقيع. يمكنك فقط تحديث التفاصيل الإدارية أو ملف العقد.',
                              style: TextStyle(color: Colors.brown, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ==========================================
                    // 1. تاريخ التوقيع
                    // ==========================================
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:[
                          const Text('📅 تاريخ التوقيع:', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextButton.icon(
                            icon: Icon(Icons.edit_calendar, color: canEdit ? Colors.blue : Colors.grey),
                            label: Text(
                              '${selectedDate.year}/${selectedDate.month}/${selectedDate.day}', 
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: canEdit ? Colors.blue : Colors.grey)
                            ),
                            onPressed: canEdit 
                              ? () async {
                                  final pickedDate = await showDatePicker(
                                    context: dialogContext, initialDate: selectedDate, firstDate: DateTime(2000), lastDate: DateTime.now(),
                                  );
                                  if (pickedDate != null) setState(() => selectedDate = pickedDate);
                                }
                              : null, 
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // ==========================================
                    // 2. الحقول النصية
                    // ==========================================
                    TextField(
                      controller: monthlyAmountController, enabled: canEdit, 
                      decoration: const InputDecoration(labelText: 'المبلغ الشهري المتفق عليه', border: OutlineInputBorder(), prefixIcon: Icon(Icons.payments, color: Colors.green)), 
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
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

                    // ==========================================
                    // 3. قسم إدارة تسليم الشقة (خاص بالمتخصص فقط)
                    // ==========================================
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
                              children: [
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
                                    child: Text(
                                      'المتفق عليه: ${contract.agreedHandoverDate!.year}/${contract.agreedHandoverDate!.month}',
                                      style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                                    ),
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
                                        final date = await showDatePicker(
                                          context: dialogContext,
                                          initialDate: actualHandoverDate ?? DateTime.now(),
                                          firstDate: DateTime(2000), lastDate: DateTime.now().add(const Duration(days: 30)),
                                        );
                                        if (date != null) setState(() => actualHandoverDate = date);
                                      } : null,
                                      child: InputDecorator(
                                        decoration: InputDecoration(
                                          labelText: 'تاريخ التسليم الفعلي *',
                                          border: const OutlineInputBorder(), filled: true, fillColor: Colors.white,
                                          prefixIcon: const Icon(Icons.calendar_today, color: Colors.teal),
                                          errorText: actualHandoverDate == null ? 'مطلوب' : null,
                                        ),
                                        child: Text(
                                          actualHandoverDate != null ? '${actualHandoverDate!.year}/${actualHandoverDate!.month}/${actualHandoverDate!.day}' : 'حدد التاريخ',
                                          style: TextStyle(color: actualHandoverDate != null ? Colors.black : Colors.red, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: handoverNotesController, enabled: canEdit, maxLines: 2,
                                decoration: const InputDecoration(labelText: 'ملاحظات / نواقص التسليم (إن وجدت)', border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
                              ),
                              const SizedBox(height: 12),
                              
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: contract.isHandedOver ? Colors.orange : Colors.teal, 
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12)
                                  ),
                                  onPressed: canEdit ? () async {
                                    if (actualHandoverDate == null) {
                                      ScaffoldMessenger.of(parentContext).showSnackBar(const SnackBar(content: Text('يجب تحديد تاريخ التسليم الفعلي!'), backgroundColor: Colors.red));
                                      return;
                                    }
                                    
                                    bool isAuthorized = await showVerifyPinDialog(parentContext);
                                    if (!isAuthorized) return;

                                    if(parentContext.mounted) {
                                      ScaffoldMessenger.of(parentContext).showSnackBar(const SnackBar(content: Text('جاري توثيق التسليم... ⏳'), backgroundColor: Colors.teal));
                                      
                                      await parentContext.read<ContractsCubit>().markContractAsHandedOver(
                                        contractId: contract.id,
                                        actualHandoverDate: actualHandoverDate!,
                                        notes: handoverNotesController.text,
                                      );
                                      
                                      if(parentContext.mounted) {
                                        parentContext.read<BuildingsCubit>().loadData();
                                        ScaffoldMessenger.of(parentContext).showSnackBar(const SnackBar(content: Text('تم توثيق الاستلام بنجاح! ✅'), backgroundColor: Colors.green));
                                        Navigator.pop(dialogContext); 
                                      }
                                    }
                                  } : null,
                                  child: Text(contract.isHandedOver ? 'تحديث بيانات الاستلام' : 'تأكيد وحفظ الاستلام'),
                                ),
                              ),
                              
                              if (contract.isHandedOver) ...[
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red.shade700,
                                      side: BorderSide(color: Colors.red.shade300),
                                      padding: const EdgeInsets.symmetric(vertical: 12)
                                    ),
                                    icon: const Icon(Icons.cancel_presentation),
                                    label: const Text('إلغاء التسليم (تراجع عن الإجراء)'),
                                    onPressed: canEdit ? () async {
                                      bool isAuthorized = await showVerifyPinDialog(parentContext);
                                      if (!isAuthorized) return;

                                      if(parentContext.mounted) {
                                        ScaffoldMessenger.of(parentContext).showSnackBar(const SnackBar(content: Text('جاري إلغاء التسليم... ⏳'), backgroundColor: Colors.orange));
                                        
                                        await parentContext.read<ContractsCubit>().cancelContractHandover(contractId: contract.id);
                                        
                                        if(parentContext.mounted) {
                                          parentContext.read<BuildingsCubit>().loadData();
                                          ScaffoldMessenger.of(parentContext).showSnackBar(const SnackBar(content: Text('تم إلغاء التسليم بنجاح!'), backgroundColor: Colors.green));
                                          Navigator.pop(dialogContext); 
                                        }
                                      }
                                    } : null,
                                  ),
                                ),
                              ]
                            ]
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ==========================================
                      // 🌟[القسم الجديد]: تعديل أو تفعيل غرامة التأخير
                      // ==========================================
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange.shade50,
                          border: Border.all(color: Colors.deepOrange.shade200, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children:[
                            SwitchListTile(
                              title: const Text('تفعيل غرامة التأخير (ما بعد الاستلام)', style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)),
                              subtitle: const Text('لتطبيق نسبة مئوية تتراكم على الذمة المالية بعد استلام الشقة.'),
                              value: isPenaltyActive,
                              activeColor: Colors.deepOrange,
                              onChanged: canEdit ? (val) => setState(() => isPenaltyActive = val) : null,
                              contentPadding: EdgeInsets.zero,
                            ),
                            if (isPenaltyActive) ...[
                              const SizedBox(height: 12),
                              Row(
                                children:[
                                  Expanded(
                                    child: TextFormField(
                                      controller: penaltyPctCtrl, 
                                      enabled: canEdit,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      decoration: const InputDecoration(labelText: 'نسبة الغرامة', suffixText: '%', border: OutlineInputBorder(), filled: true, fillColor: Colors.white, prefixIcon: Icon(Icons.percent, color: Colors.deepOrange)),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextFormField(
                                      controller: penaltyIntervalCtrl, 
                                      enabled: canEdit,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(labelText: 'تُطبق كل', suffixText: 'أشهر', border: OutlineInputBorder(), filled: true, fillColor: Colors.white, prefixIcon: Icon(Icons.update, color: Colors.deepOrange)),
                                    ),
                                  ),
                                ],
                              ),
                            ]
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ==========================================
                    // 4. ملف العقد (الأسفل)
                    // ==========================================
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.grey.shade50, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:[
                          Row(
                            children:[
                              Icon(
                                contract.contractFileUrl != null && contract.contractFileUrl!.isNotEmpty ? Icons.check_circle : Icons.warning_amber_rounded,
                                color: contract.contractFileUrl != null && contract.contractFileUrl!.isNotEmpty ? Colors.green : Colors.orange,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                contract.contractFileUrl != null && contract.contractFileUrl!.isNotEmpty ? 'يوجد ملف مرفق' : 'لا يوجد ملف',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          TextButton.icon(
                            icon: Icon(Icons.upload_file, color: canEdit ? Colors.blue : Colors.grey),
                            label: Text(
                              contract.contractFileUrl != null && contract.contractFileUrl!.isNotEmpty ? 'استبدال الملف' : 'إرفاق ملف',
                              style: TextStyle(color: canEdit ? Colors.blue : Colors.grey)
                            ),
                            onPressed: canEdit 
                              ? () async {
                                  bool isAuthorized = await showVerifyPinDialog(parentContext);
                                  if (!isAuthorized) return; 
                                  
                                  FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions:['doc', 'docx', 'pdf']);

                                  if (result != null && result.files.single.path != null) {
                                    final filePath = result.files.single.path!;
                                    final extension = result.files.single.extension ?? 'docx';
                                    
                                    if(parentContext.mounted) {
                                      ScaffoldMessenger.of(parentContext).showSnackBar(const SnackBar(content: Text('جاري رفع الملف الجديد للسحابة... ⏳'), backgroundColor: Colors.orange));
                                      await parentContext.read<ContractsCubit>().attachContractFile(contractId: contract.id, filePath: filePath, extension: extension);
                                      if(parentContext.mounted) {
                                        ScaffoldMessenger.of(parentContext).showSnackBar(const SnackBar(content: Text('تم استبدال/إرفاق الملف بنجاح! ✅'), backgroundColor: Colors.green));
                                        Navigator.pop(dialogContext); 
                                      }
                                    }
                                  }
                                }
                              : null, 
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween, 
            actions:[
              if (isSuperAdmin)
                TextButton.icon(
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  label: const Text('إلغاء العقد نهائياً', style: TextStyle(color: Colors.red)),
                  onPressed: () async {
                    Navigator.pop(dialogContext); 
                    bool isAuthorized = await showVerifyPinDialog(parentContext); 
                    if (isAuthorized && parentContext.mounted) {
                      ScaffoldMessenger.of(parentContext).showSnackBar(SnackBar(content: const Text('جاري إلغاء العقد وتحرير الشقة... ⏳'), backgroundColor: Colors.red.shade400, duration: const Duration(seconds: 1)));
                      await parentContext.read<ContractsCubit>().deleteContract(contract.id);
                      if (parentContext.mounted) {
                        parentContext.read<BuildingsCubit>().loadData();
                        final currentState = parentContext.read<ContractsCubit>().state;
                        if (currentState.status != ContractsStatus.failure) {
                          ScaffoldMessenger.of(parentContext).showSnackBar(const SnackBar(content: Text('تم إلغاء العقد بنجاح! ✅'), backgroundColor: Colors.green));
                        }
                      }
                    }
                  },
                )
              else
                const SizedBox.shrink(), 

              // ==========================================
              // 🌟 زر حفظ التعديلات النصية (مررنا الغرامات هنا)
              // ==========================================
              Row(
                mainAxisSize: MainAxisSize.min,
                children:[
                  TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: canEdit ? Colors.blue : Colors.grey.shade300, foregroundColor: canEdit ? Colors.white : Colors.grey.shade600),
                    onPressed: canEdit 
                      ? () async {
                          if (monthsController.text.isNotEmpty && monthlyAmountController.text.isNotEmpty) {
                            
                            // 🌟 حماية خفيفة
                            if (isPenaltyActive && double.tryParse(penaltyPctCtrl.text) == null) {
                              ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('أدخل نسبة غرامة صحيحة!'), backgroundColor: Colors.red));
                              return;
                            }

                            Navigator.pop(dialogContext); 
                            bool isAuthorized = await showVerifyPinDialog(parentContext);
                            if (isAuthorized && parentContext.mounted) {
                              parentContext.read<ContractsCubit>().updateContract(
                                id: contract.id,
                                details: detailsController.text,
                                guarantorName: guarantorController.text.isEmpty ? 'بدون كفيل' : guarantorController.text,
                                installmentsCount: int.parse(monthsController.text), 
                                agreedMonthlyAmount: double.parse(monthlyAmountController.text), 
                                contractDate: selectedDate,

                                // 🌟 حقن وتمرير بيانات الغرامة
                                isPenaltyActive: isAllocated ? isPenaltyActive : false,
                                penaltyPercentage: isAllocated && isPenaltyActive ? (double.tryParse(penaltyPctCtrl.text) ?? 0.0) : 0.0,
                                penaltyIntervalMonths: isAllocated && isPenaltyActive ? (int.tryParse(penaltyIntervalCtrl.text) ?? 1) : 1,
                              );
                            }
                          }
                        }
                      : null,
                    child: const Text('حفظ التعديلات النصية'),
                  ),
                ],
              )
            ],
          );
        }
      );
    },
  );
}