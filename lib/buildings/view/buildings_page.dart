// lib/buildings/view/buildings_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart' show Building, Apartment;
import '../cubit/buildings_cubit.dart';
import 'dialogs/add_building_dialog.dart';
import 'dialogs/add_apartment_dialog.dart';
import 'dialogs/apartment_details_dialog.dart';
import 'dialogs/building_details_dialog.dart';
import 'dialogs/copy_floor_dialog.dart';
import 'dialogs/edit_building_dialog.dart';
import 'dialogs/edit_apartment_dialog.dart';
// 🌟 استيراد نافذة المحلات التجارية الجديدة
import 'dialogs/add_shop_dialog.dart';

// ==========================================
// 🌟 دالة فرز ذكية لترتيب الطوابق هندسياً 
// (القبو أولاً، ثم الأرضي، ثم الطوابق العليا)
// ==========================================
int _getFloorLevel(String name) {
  if (name.contains('الأرضي')) return 0;
  
  int level = 99; // قيمة افتراضية للحالات غير المعروفة
  
  if (name.contains('الثاني عشر')) level = 12;
  else if (name.contains('الحادي عشر')) level = 11;
  else if (name.contains('العاشر')) level = 10;
  else if (name.contains('التاسع')) level = 9;
  else if (name.contains('الثامن')) level = 8;
  else if (name.contains('السابع')) level = 7;
  else if (name.contains('السادس')) level = 6;
  else if (name.contains('الخامس')) level = 5;
  else if (name.contains('الرابع')) level = 4;
  else if (name.contains('الثالث')) level = 3;
  else if (name.contains('الثاني')) level = 2;
  else if (name.contains('الأول')) level = 1;
  else {
    // في حال وجود طوابق بأرقام عادية مثل "الطابق 15"
    final match = RegExp(r'\d+').firstMatch(name);
    if (match != null) {
      level = int.parse(match.group(0)!);
    }
  }

  // إذا كان قبو نجعله بالسالب لكي يظهر في الأعلى عند الفرز
  if (name.contains('القبو')) {
    return -level; 
  }
  
  return level;
}

class BuildingsPage extends StatefulWidget {
  const BuildingsPage({super.key});

  @override
  State<BuildingsPage> createState() => _BuildingsPageState();
}

class _BuildingsPageState extends State<BuildingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<BuildingsCubit>().loadData();
  }

  @override
  Widget build(BuildContext context) {
    return const BuildingsView();
  }
}

class BuildingsView extends StatelessWidget {
  const BuildingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      // 🌟 تم إزالة الـ AppBar بالكامل لتوسيع مساحة العمل
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        backgroundColor: Colors.indigo.shade600,
        onPressed: () => showAddBuildingDialog(context),
        icon: const Icon(Icons.domain_add, color: Colors.white),
        label: const Text('إضافة محضر جديد', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
      ),
      body: SafeArea(
        child: BlocConsumer<BuildingsCubit, BuildingsState>(
          listener: (context, state) {
            if (state.status == BuildingsStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'حدث خطأ', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  backgroundColor: Colors.red.shade700,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.status == BuildingsStatus.loading && state.buildings.isEmpty) {
              return Center(child: CircularProgressIndicator(color: Colors.indigo.shade600));
            }
            if (state.buildings.isEmpty) {
              return Column(
                children:[
                  _buildHeader(0),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:[
                          Icon(Icons.domain_disabled, size: 80, color: Colors.indigo.shade100),
                          const SizedBox(height: 16),
                          Text('لا توجد محاضر عقارية حتى الآن.', style: TextStyle(fontSize: 18, color: Colors.blueGrey.shade400)),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                // 🌟 عنوان مدمج وأنيق أعلى الشاشة
                _buildHeader(state.buildings.length),

                // 🌟 القائمة التي تحتوي على المحاضر
                Expanded(
                  child: ListView.builder(
                    // 🌟 إضافة Bottom Padding بقيمة 100 لتجنب حجب الزر العائم للمحتوى في النهاية
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                    itemCount: state.buildings.length,
                    itemBuilder: (context, index) {
                      final building = state.buildings[index];
                      
                      // 🌟 فلترة الوحدات العقارية إلى شقق ومحلات
                      final allUnits = state.apartments.where((a) => a.buildingId == building.id).toList();
                      final bldApartments = allUnits.where((a) => a.unitType == 'apartment').toList();
                      final bldShops = allUnits.where((a) => a.unitType == 'shop').toList();

                      Map<String, dynamic> availableFloors = {};
                      try {
                        availableFloors = jsonDecode(building.floorCoefficients);
                      } catch (e) {
                        // تجاهل الأخطاء الصامتة في تحويل الـ JSON
                      }

                      // 🌟 استخراج قائمة الطوابق وترتيبها بالدالة الذكية (قبو -> أرضي -> طوابق عليا)
                      final sortedFloorNames = availableFloors.keys.toList()
                        ..sort((a, b) => _getFloorLevel(a).compareTo(_getFloorLevel(b)));

                      // 🌟 بطاقة المحضر
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.indigo.shade50, width: 2)),
                        clipBehavior: Clip.antiAlias,
                        child: Theme(
                          // إزالة خطوط الـ ExpansionTile الافتراضية المزعجة
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            initiallyExpanded: index == 0, // فتح أول محضر تلقائياً
                            backgroundColor: Colors.white,
                            collapsedBackgroundColor: Colors.white,
                            tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            
                            title: Row(
                              children:[
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(10)),
                                  child: Icon(Icons.business, color: Colors.indigo.shade600, size: 26),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children:[
                                      Text(
                                        building.name, 
                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo.shade900),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '📍 ${building.location ?? 'بدون عنوان'}  |  🚪 ${bldApartments.length} شقق  |  🏪 ${bldShops.length} محلات',
                                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 6),
                                      // ==========================================
                                      // 🌟 الإضافة 1: اسم وتاريخ التعديل للمحضر نفسه
                                      // ==========================================
                                      Row(
                                        children:[
                                          Icon(Icons.edit_calendar, size: 12, color: Colors.orange.shade700),
                                          const SizedBox(width: 4),
                                          Text(
                                            'آخر تعديل بواسطة: ',
                                            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                          ),
                                          Text(
                                            state.userNamesMap[building.userId] ?? 'مجهول',
                                            style: TextStyle(fontSize: 11, color: Colors.orange.shade800, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '(${building.updatedAt.year}/${building.updatedAt.month}/${building.updatedAt.day})',
                                            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children:[
                                IconButton(
                                  icon: const Icon(Icons.edit_note, color: Colors.orange),
                                  tooltip: 'تعديل بيانات المحضر',
                                  onPressed: () => showEditBuildingDialog(context, building), 
                                ),
                                IconButton(
                                  icon: const Icon(Icons.info_outline, color: Colors.teal),
                                  tooltip: 'عرض التفاصيل والنسب',
                                  onPressed: () => showBuildingDetailsDialog(context, building),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                              ],
                            ),
                            
                            children:[
                              Container(
                                color: Colors.grey.shade50,
                                padding: const EdgeInsets.only(top: 16, bottom: 24),
                                child: Column(
                                  children:[
                                    // ==========================================
                                    // 🚪 1. قسم الشقق السكنية (يُعرض حسب الطوابق مرتبة)
                                    // ==========================================
                                    if (sortedFloorNames.isEmpty)
                                      Padding(
                                        padding: const EdgeInsets.all(24.0), 
                                        child: Text('لم يتم إعداد الطوابق لهذا المحضر. يرجى تعديل المحضر أولاً.', style: TextStyle(color: Colors.grey.shade600)),
                                      ),
                                    
                                    // 🌟 استخدام القائمة المرتبة بدلاً من المبعثرة
                                    ...sortedFloorNames.map((floorName) {
                                      final floorApts = bldApartments.where((a) => a.floorName == floorName).toList();
                                      
                                      return Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(color: Colors.indigo.shade100, width: 1.5),
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow:[BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2))],
                                        ),
                                        child: Theme(
                                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                          child: ExpansionTile(
                                            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                            title: Row(
                                              children:[
                                                Icon(Icons.layers, color: Colors.indigo.shade300, size: 22),
                                                const SizedBox(width: 12),
                                                Text(
                                                  '$floorName ( ${floorApts.length} شقق )', 
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.indigo),
                                                ),
                                              ],
                                            ),
                                            children:[
                                              if (floorApts.isEmpty)
                                                Padding(
                                                  padding: const EdgeInsets.all(16.0), 
                                                  child: Text('لا توجد شقق مضافة في هذا الطابق بعد.', style: TextStyle(color: Colors.grey.shade500)),
                                                ),
                                              
                                              if (floorApts.isNotEmpty)
                                                SingleChildScrollView(
                                                  scrollDirection: Axis.horizontal,
                                                  physics: const BouncingScrollPhysics(),
                                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                                  child: Container(
                                                    decoration: _tableDecoration(Colors.indigo.shade50),
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(10),
                                                      child: DataTable(
                                                        headingRowHeight: 50, 
                                                        dataRowMinHeight: 55, 
                                                        dataRowMaxHeight: 65, // 🌟 قمت بتكبيرها قليلاً لتستوعب سطرين
                                                        horizontalMargin: 24, columnSpacing: 30, dividerThickness: 0.5,
                                                        headingRowColor: WidgetStateProperty.all(Colors.indigo.shade50.withOpacity(0.5)),
                                                        columns: const[
                                                          DataColumn(label: Text('رقم الشقة', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo))),
                                                          DataColumn(label: Text('المساحة', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo))),
                                                          DataColumn(label: Text('الاتجاه', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo))),
                                                          DataColumn(label: Text('الحالة', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo))),
                                                          
                                                          // 🌟 العامود الجديد
                                                          DataColumn(label: Text('آخر تعديل بواسطة', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo))),
                                                          
                                                          DataColumn(label: Text('إجراءات', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo))),
                                                        ],
                                                        rows: floorApts.map((apt) => _buildDataRow(context, apt, isShop: false, userNamesMap: state.userNamesMap)).toList(),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              
                                              // أزرار الطابق السفلية
                                              Container(
                                                padding: const EdgeInsets.all(12.0),
                                                decoration: BoxDecoration(color: Colors.indigo.shade50.withOpacity(0.3), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12))),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children:[
                                                    TextButton.icon(
                                                      icon: const Icon(Icons.add_home, size: 20),
                                                      label: const Text('إضافة شقة هنا', style: TextStyle(fontWeight: FontWeight.bold)),
                                                      style: TextButton.styleFrom(foregroundColor: Colors.indigo.shade600),
                                                      onPressed: () => showAddApartmentDialog(context, building, preSelectedFloor: floorName),
                                                    ),
                                                    if (floorApts.isNotEmpty)
                                                      TextButton.icon(
                                                        icon: const Icon(Icons.copy_all, size: 20),
                                                        label: const Text('نسخ نموذج الطابق', style: TextStyle(fontWeight: FontWeight.bold)),
                                                        style: TextButton.styleFrom(foregroundColor: Colors.orange.shade700),
                                                        onPressed: () => showCopyFloorDialog(context, building, floorName, floorApts, availableFloors.keys.toList()),
                                                      ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),

                                    // ==========================================
                                    // 🏪 2. قسم المحلات التجارية (الآن يظهر دائماً)
                                    // ==========================================
                                    Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(color: Colors.orange.shade200, width: 1.5),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow:[BoxShadow(color: Colors.orange.shade900.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4))],
                                      ),
                                      child: Theme(
                                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                        child: ExpansionTile(
                                          initiallyExpanded: bldShops.isNotEmpty, // يفتح تلقائياً إذا كان هناك محلات
                                          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                          title: Row(
                                            children:[
                                              Icon(Icons.storefront, color: Colors.orange.shade700, size: 22),
                                              const SizedBox(width: 12),
                                              Text(
                                                'المحلات التجارية ( ${bldShops.length} محلات )', 
                                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange.shade800),
                                              ),
                                            ],
                                          ),
                                          children:[
                                            // رسالة توضيحية إذا لم تكن هناك محلات
                                            if (bldShops.isEmpty)
                                              Padding(
                                                padding: const EdgeInsets.all(16.0), 
                                                child: Text('لا توجد محلات تجارية مضافة في هذا المحضر بعد.', style: TextStyle(color: Colors.grey.shade500)),
                                              ),

                                            // الجدول إذا كان هناك محلات
                                            if (bldShops.isNotEmpty)
                                              SingleChildScrollView(
                                                scrollDirection: Axis.horizontal,
                                                physics: const BouncingScrollPhysics(),
                                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                                child: Container(
                                                  decoration: _tableDecoration(Colors.orange.shade100),
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(10),
                                                    child: DataTable(
                                                      headingRowHeight: 50, 
                                                      dataRowMinHeight: 55, 
                                                      dataRowMaxHeight: 65, // 🌟 التكبير للسطرين
                                                      horizontalMargin: 24, columnSpacing: 30, dividerThickness: 0.5,
                                                      headingRowColor: WidgetStateProperty.all(Colors.orange.shade50),
                                                      columns: const[
                                                        DataColumn(label: Text('رقم/رمز المحل', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange))),
                                                        DataColumn(label: Text('المساحة', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange))),
                                                        DataColumn(label: Text('الواجهة', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange))),
                                                        DataColumn(label: Text('الحالة', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange))),
                                                        
                                                        // 🌟 العامود الجديد للمحلات أيضاً
                                                        DataColumn(label: Text('آخر تعديل بواسطة', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange))),
                                                        
                                                        DataColumn(label: Text('إجراءات', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange))),
                                                      ],
                                                      rows: bldShops.map((shop) => _buildDataRow(context, shop, isShop: true, userNamesMap: state.userNamesMap)).toList(),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                            // 🌟 زر الإضافة تم نقله للداخل أسفل الجدول
                                            Container(
                                              padding: const EdgeInsets.all(12.0),
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: Colors.orange.shade50.withOpacity(0.5), 
                                                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12))
                                              ),
                                              child: Center(
                                                child: TextButton.icon(
                                                  icon: const Icon(Icons.add_business, size: 20),
                                                  label: const Text('إضافة محل تجاري هنا', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                                  style: TextButton.styleFrom(foregroundColor: Colors.orange.shade800),
                                                  onPressed: () => showAddShopDialog(context, building),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // 🌟 دالة مساعدة لإنشاء العنوان المدمج
  Widget _buildHeader(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        children:[
          const Icon(Icons.domain, color: Colors.indigo, size: 30),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'كتالوج المشاريع والوحدات',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blueGrey),
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

  // دالة مساعدة لتصميم إطار الجداول
  BoxDecoration _tableDecoration(Color borderColor) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: borderColor, width: 1.5),
    );
  }

  // ==========================================
  // 🌟 الإضافة 2: تعديل دالة رسم الصف لتستقبل القاموس وترسم الخلية
  // ==========================================
  DataRow _buildDataRow(BuildContext context, Apartment apt, {required bool isShop, required Map<String, String> userNamesMap}) {
    final isAvailable = apt.status == 'available';
    final mainColor = isShop ? Colors.orange : Colors.indigo;
    
    return DataRow(
      cells:[
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children:[
              Icon(isShop ? Icons.store : Icons.door_front_door_outlined, size: 18, color: mainColor.shade300),
              const SizedBox(width: 8),
              Text(
                apt.apartmentNumber, 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: mainColor.shade700),
              ),
            ],
          ),
        ),
        DataCell(Text('${apt.area} م²', style: const TextStyle(fontWeight: FontWeight.w600))),
        DataCell(Text(apt.directionName ?? '-', style: TextStyle(color: Colors.grey.shade700))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isAvailable ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: isAvailable ? Colors.green.shade200 : Colors.red.shade200, width: 1),
            ),
            child: Text(
              isAvailable ? 'متاحة' : 'مباعة', 
              style: TextStyle(
                color: isAvailable ? Colors.green.shade700 : Colors.red.shade700, 
                fontWeight: FontWeight.bold, fontSize: 12,
              ),
            ),
          ),
        ),

        // ==========================================
        // 🌟 الخلية الجديدة: آخر تعديل بواسطة (مدمجة هنا)
        // ==========================================
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              Row(
                mainAxisSize: MainAxisSize.min,
                children:[
                  Icon(Icons.person_outline, size: 13, color: mainColor.shade400),
                  const SizedBox(width: 4),
                  Text(
                    userNamesMap[apt.userId] ?? 'مجهول',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: mainColor.shade700),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children:[
                  const Icon(Icons.access_time, size: 11, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${apt.updatedAt.year}/${apt.updatedAt.month.toString().padLeft(2,'0')}/${apt.updatedAt.day.toString().padLeft(2,'0')} ${apt.updatedAt.hour}:${apt.updatedAt.minute.toString().padLeft(2,'0')}',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              )
            ],
          )
        ),

        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children:[
              IconButton(
                icon: const Icon(Icons.edit_note, size: 22, color: Colors.orange),
                tooltip: 'تعديل الوحدة',
                onPressed: () => showEditApartmentDialog(context, apt), 
              ),
              IconButton(
                icon: const Icon(Icons.visibility, size: 22, color: Colors.indigo),
                tooltip: 'عرض التفاصيل',
                onPressed: () => showApartmentDetailsDialog(context, apt),
              ),
            ],
          ),
        ),
      ],
    );
  }
}