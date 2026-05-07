// lib/buildings/view/dialogs/edit_apartment_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart' show Apartment;
import '../../cubit/buildings_cubit.dart';

void showEditApartmentDialog(BuildContext parentContext, Apartment apt) {
  final numberController = TextEditingController(text: apt.apartmentNumber);
  
  // 🌟 حماية الواجهة: تحديد حالة الوحدة بدقة
  final bool isAvailable = apt.status == 'available';
  final bool isDelivered = apt.status == 'delivered';
  // إذا لم تكن متاحة ولم تكن مسلمة، فهي حتماً "مباعة" (sold)

  showDialog(
    context: parentContext,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          
          // 🌟 دالة مساعدة لحقول القراءة فقط (Read-Only)
          Widget buildReadOnlyField(String label, String value, IconData icon) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children:[
                  Icon(icon, size: 24, color: Colors.grey.shade500),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:[
                      Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black54)),
                    ],
                  )
                ],
              ),
            );
          }

          // 🌟 تجهيز ألوان ونصوص رسالة التنبيه بناءً على الحالات الثلاث
          Color boxColor;
          Color borderColor;
          Color iconTextColor;
          IconData alertIcon;
          String alertText;

          if (isAvailable) {
            boxColor = Colors.amber.shade50;
            borderColor = Colors.amber.shade200;
            iconTextColor = Colors.brown.shade800;
            alertIcon = Icons.info_outline;
            alertText = 'للحفاظ على سلامة الحسابات والمعاملات المالية، يُسمح لك بتعديل "الرقم/الرمز" فقط. لتغيير المساحة أو الاتجاه، يرجى حذف الوحدة وإضافتها من جديد.';
          } else if (isDelivered) {
            boxColor = Colors.teal.shade50;
            borderColor = Colors.teal.shade200;
            iconTextColor = Colors.teal.shade900;
            alertIcon = Icons.verified_user;
            alertText = 'هذه الوحدة تم تسليمها للعميل نهائياً وانتهت دورتها. يُمنع منعاً باتاً تعديل بياناتها أو حذفها للحفاظ على استقرار العقود والبيانات المالية.';
          } else {
            // حالة المباعة (Sold)
            boxColor = Colors.red.shade50;
            borderColor = Colors.red.shade200;
            iconTextColor = Colors.red.shade900;
            alertIcon = Icons.gavel;
            alertText = 'هذه الوحدة مباعة أو محجوزة بعقد نشط. يُمنع منعاً باتاً تعديل بياناتها أو حذفها للحفاظ على استقرار العقود المالية.';
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            contentPadding: const EdgeInsets.all(24),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:[
                Row(
                  children:[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12)),
                      child: Icon(isAvailable ? Icons.edit_note : Icons.lock, color: isAvailable ? Colors.orange.shade700 : (isDelivered ? Colors.teal.shade700 : Colors.red.shade700), size: 28),
                    ),
                    const SizedBox(width: 16),
                    Text('تعديل الوحدة ( ${apt.apartmentNumber} )', style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 22)),
                  ],
                ),
                
                // 🌟 عرض زر الحذف فقط إذا كانت الوحدة متاحة
                if (isAvailable)
                  IconButton(
                    icon: const Icon(Icons.delete_forever, color: Colors.red, size: 28),
                    tooltip: 'حذف الوحدة',
                    onPressed: () {
                      showDialog(
                        context: dialogContext,
                        builder: (confirmCtx) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          title: const Row(
                            children:[
                              Icon(Icons.warning_amber_rounded, color: Colors.red),
                              SizedBox(width: 8),
                              Text('تأكيد الحذف'),
                            ],
                          ),
                          content: const Text('هل أنت متأكد من رغبتك في حذف هذه الوحدة ونقلها إلى سلة المحذوفات؟', style: TextStyle(fontSize: 16)),
                          actions:[
                            TextButton(onPressed: () => Navigator.pop(confirmCtx), child: const Text('إلغاء')),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                              onPressed: () {
                                parentContext.read<BuildingsCubit>().deleteApartment(apt.id);
                                Navigator.pop(confirmCtx); // إغلاق التأكيد
                                Navigator.pop(dialogContext); // إغلاق نافذة التعديل
                                ScaffoldMessenger.of(parentContext).showSnackBar(const SnackBar(content: Text('تم نقل الوحدة لسلة المحذوفات'), backgroundColor: Colors.green));
                              },
                              child: const Text('نعم، احذف', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                else
                  // 🌟 شارة القفل الذكية (حمراء للمباعة، وخضراء للمسلمة)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDelivered ? Colors.teal.shade50 : Colors.red.shade50, 
                      borderRadius: BorderRadius.circular(20), 
                      border: Border.all(color: isDelivered ? Colors.teal.shade200 : Colors.red.shade200)
                    ),
                    child: Row(
                      children:[
                        Icon(isDelivered ? Icons.check_circle : Icons.lock, color: isDelivered ? Colors.teal.shade700 : Colors.red.shade700, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          isDelivered ? 'مقفلة (مُسلّمة)' : 'مقفلة (مباعة)', 
                          style: TextStyle(color: isDelivered ? Colors.teal.shade700 : Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 13)
                        ),
                      ],
                    ),
                  )
              ],
            ),
            content: SizedBox(
              width: 600, // 🌟 عرض احترافي يناسب الأنظمة
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children:[
                    // 🌟 1. رسالة الحماية والتنبيه الذكية
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: boxColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children:[
                          Icon(alertIcon, color: iconTextColor, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              alertText,
                              style: TextStyle(color: iconTextColor, fontWeight: FontWeight.w600, fontSize: 13, height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 🌟 2. حقل التعديل (يُفعل فقط إذا كانت متاحة)
                    TextField(
                      controller: numberController, 
                      enabled: isAvailable, // قفل الحقل إذا كانت مباعة أو مسلمة
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      decoration: InputDecoration(
                        labelText: 'رقم الوحدة / الرمز', 
                        prefixIcon: Icon(Icons.tag, color: isAvailable ? Colors.orange.shade600 : Colors.grey),
                        filled: true,
                        fillColor: isAvailable ? Colors.white : Colors.grey.shade100,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.orange.shade400, width: 2)),
                      )
                    ),

                    const SizedBox(height: 16),

                    // 🌟 3. عرض المساحة والاتجاه (للقراءة فقط دائماً)
                    Row(
                      children:[
                        Expanded(
                          child: buildReadOnlyField('المساحة المعتمدة', '${apt.area} م²', Icons.architecture),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: buildReadOnlyField('الاتجاه / الواجهة', apt.directionName ?? 'غير محدد', Icons.explore),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            actions:[
              TextButton(
                onPressed: () => Navigator.pop(dialogContext), 
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                child: Text(isAvailable ? 'إلغاء' : 'إغلاق', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey))
              ),
              if (isAvailable) // إخفاء زر الحفظ إذا كانت مباعة أو مسلمة
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade600, 
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    if (numberController.text.trim().isNotEmpty) {
                      // 🌟 نُرسل المساحة والاتجاه القديمين كما هما، ونُحدّث الرقم فقط
                      parentContext.read<BuildingsCubit>().updateApartment(
                        id: apt.id,
                        apartmentNumber: numberController.text.trim(),
                        area: apt.area, 
                        directionName: apt.directionName ?? 'غير محدد',
                      );
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(parentContext).showSnackBar(const SnackBar(content: Text('تم تحديث رقم الوحدة بنجاح'), backgroundColor: Colors.green));
                    } else {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('الرقم لا يمكن أن يكون فارغاً!'), backgroundColor: Colors.red));
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('حفظ التعديل', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
            ],
          );
        }
      );
    },
  );
}