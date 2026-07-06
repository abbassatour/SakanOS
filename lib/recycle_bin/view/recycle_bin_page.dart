// lib/recycle_bin/view/recycle_bin_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erp_repository/erp_repository.dart';
import '../cubit/recycle_bin_cubit.dart';
import 'dialogs/verify_hard_delete_dialog.dart'; // 🌟 استدعاء الديالوج الموحد

// 🌟 استدعاء الحارس الشخصي والصلاحيات
import '../../auth/cubit/auth_cubit.dart';
import '../../core/constants/app_permissions.dart';

// دالة مساعدة لتنسيق المبالغ
String formatWithCommas(num number) {
  RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  return number.toInt().toString().replaceAllMapped(
    reg,
    (Match match) => '${match[1]},',
  );
}

class RecycleBinPage extends StatelessWidget {
  const RecycleBinPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          RecycleBinCubit(context.read<ErpRepository>())..loadAllDeletedData(),
      child: const RecycleBinView(),
    );
  }
}

class RecycleBinView extends StatelessWidget {
  const RecycleBinView({super.key});

  @override
  Widget build(BuildContext context) {
    // 🌟 جلب الصلاحيات لمعرفة ما إذا كان يملك حق الاستعادة أو الحذف النهائي
    final authState = context.watch<AuthCubit>().state;
    final bool canRestore = authState.hasPermission(
      AppPermissions.restoreItems,
    );
    final bool canHardDelete = authState.hasPermission(
      AppPermissions.hardDeleteItems,
    );

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'سلة المحذوفات الشاملة',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.red.shade800,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs: [
              Tab(icon: Icon(Icons.people), text: 'العملاء'),
              Tab(icon: Icon(Icons.domain), text: 'المحاضر'),
              Tab(icon: Icon(Icons.door_front_door), text: 'الوحدات'),
              Tab(icon: Icon(Icons.description), text: 'العقود'),
              Tab(icon: Icon(Icons.receipt_long), text: 'المدفوعات'),
            ],
          ),
        ),
        body: BlocConsumer<RecycleBinCubit, RecycleBinState>(
          listener: (context, state) {
            if (state.status == RecycleBinStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.errorMessage ?? 'خطأ',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.status == RecycleBinStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.red),
              );
            }

            return TabBarView(
              children: [
                // ==========================================
                // 1. العملاء
                // ==========================================
                _buildList(
                  context: context,
                  items: state.deletedClients,
                  emptyMessage: 'العملاء',
                  icon: Icons.person_off,
                  canRestore: canRestore,
                  canHardDelete: canHardDelete,
                  getTitle: (item) => 'العميل: ${item.name}',
                  getSubtitle: (item) =>
                      'رقم الهاتف: ${item.phone} ${item.nationalId != null ? ' | الرقم الوطني: ${item.nationalId}' : ''}',
                  getDeletedBy: (item) =>
                      state.userNamesMap[item.userId] ?? 'مجهول',
                  getUpdatedAt: (item) => item.updatedAt,
                  onRestore: (item) =>
                      context.read<RecycleBinCubit>().restoreClient(item.id),
                  onHardDelete: (item) =>
                      context.read<RecycleBinCubit>().hardDeleteClient(item.id),
                ),

                // ==========================================
                // 2. المحاضر
                // ==========================================
                _buildList(
                  context: context,
                  items: state.deletedBuildings,
                  emptyMessage: 'المحاضر العقارية',
                  icon: Icons.domain_disabled,
                  canRestore: canRestore,
                  canHardDelete: canHardDelete,
                  getTitle: (item) => 'محضر: ${item.name}',
                  getSubtitle: (item) => 'الموقع: ${item.location}',
                  getDeletedBy: (item) =>
                      state.userNamesMap[item.userId] ?? 'مجهول',
                  getUpdatedAt: (item) => item.updatedAt,
                  onRestore: (item) =>
                      context.read<RecycleBinCubit>().restoreBuilding(item.id),
                  onHardDelete: (item) => context
                      .read<RecycleBinCubit>()
                      .hardDeleteBuilding(item.id),
                ),

                // ==========================================
                // 3. الوحدات (نستخدم المراجع لمعرفة اسم المحضر)
                // ==========================================
                _buildList(
                  context: context,
                  items: state.deletedApartments,
                  emptyMessage: 'الوحدات (الشقق/المحلات)',
                  icon: Icons.do_not_disturb_alt,
                  canRestore: canRestore,
                  canHardDelete: canHardDelete,
                  getTitle: (item) =>
                      '${item.unitType == 'shop' ? 'محل' : 'شقة'} رقم: ${item.apartmentNumber}',
                  getSubtitle: (item) {
                    final bldgs = state.referenceBuildings.where(
                      (b) => b.id == item.buildingId,
                    );
                    final bldgName = bldgs.isNotEmpty
                        ? bldgs.first.name
                        : 'محضر محذوف';
                    return 'محضر: $bldgName | الطابق: ${item.floorName} | المساحة: ${item.area} م²';
                  },
                  getDeletedBy: (item) =>
                      state.userNamesMap[item.userId] ?? 'مجهول',
                  getUpdatedAt: (item) => item.updatedAt,
                  onRestore: (item) =>
                      context.read<RecycleBinCubit>().restoreApartment(item.id),
                  onHardDelete: (item) => context
                      .read<RecycleBinCubit>()
                      .hardDeleteApartment(item.id),
                ),

                // ==========================================
                // 4. العقود (نستخدم المراجع لمعرفة اسم العميل)
                // ==========================================
                _buildList(
                  context: context,
                  items: state.deletedContracts,
                  emptyMessage: 'العقود',
                  icon: Icons.file_copy_outlined,
                  canRestore: canRestore,
                  canHardDelete: canHardDelete,
                  getTitle: (item) => 'عقد ${item.contractType}',
                  getSubtitle: (item) {
                    final clients = state.referenceClients.where(
                      (c) => c.id == item.clientId,
                    );
                    final clientName = clients.isNotEmpty
                        ? clients.first.name
                        : 'عميل محذوف';
                    return 'العميل: $clientName\nالتفاصيل: ${item.apartmentDetails}\nالمساحة: ${item.totalArea} م²';
                  },
                  getDeletedBy: (item) =>
                      state.userNamesMap[item.userId] ?? 'مجهول',
                  getUpdatedAt: (item) => item.updatedAt,
                  onRestore: (item) =>
                      context.read<RecycleBinCubit>().restoreContract(item.id),
                  onHardDelete: (item) => context
                      .read<RecycleBinCubit>()
                      .hardDeleteContract(item.id),
                ),

                // ==========================================
                // 5. المدفوعات (نستخدم المراجع لمعرفة العقد والعميل)
                // ==========================================
                _buildList(
                  context: context,
                  items: state.deletedPayments,
                  emptyMessage: 'المدفوعات والإيصالات',
                  icon: Icons.money_off,
                  canRestore: canRestore,
                  canHardDelete: canHardDelete,
                  getTitle: (item) =>
                      'إيصال مبلغ: ${formatWithCommas(item.amountPaid)} ل.س',
                  getSubtitle: (item) {
                    final contracts = state.referenceContracts.where(
                      (c) => c.id == item.contractId,
                    );
                    final contract = contracts.isNotEmpty
                        ? contracts.first
                        : null;
                    if (contract != null) {
                      final clients = state.referenceClients.where(
                        (c) => c.id == contract.clientId,
                      );
                      final clientName = clients.isNotEmpty
                          ? clients.first.name
                          : 'عميل محذوف';
                      return 'العميل: $clientName\nرقم العقد: ${contract.id.split('-').first.toUpperCase()} | الأمتار المحولة: ${item.convertedMeters.toStringAsFixed(2)} م²';
                    }
                    return 'عقد غير معروف';
                  },
                  getDeletedBy: (item) =>
                      state.userNamesMap[item.userId] ?? 'مجهول',
                  getUpdatedAt: (item) => item.updatedAt,
                  onRestore: (item) =>
                      context.read<RecycleBinCubit>().restorePayment(item.id),
                  onHardDelete: (item) => context
                      .read<RecycleBinCubit>()
                      .hardDeletePayment(item.id),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ==========================================
  // 🌟 الدالة السحرية المطورة لبناء البطاقات الاحترافية للمحذوفات
  // ==========================================
  Widget _buildList<T>({
    required BuildContext context,
    required List<T> items,
    required String emptyMessage,
    required IconData icon,
    required bool canRestore,
    required bool canHardDelete,
    required String Function(T) getTitle,
    required String Function(T) getSubtitle,
    required String Function(T) getDeletedBy, // 🌟 لجلب من قام بالحذف
    required DateTime Function(T) getUpdatedAt,
    required void Function(T) onRestore,
    required void Function(T) onHardDelete,
  }) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'سلة المحذوفات فارغة من $emptyMessage',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'يتم تنظيف السلة تلقائياً كل 7 أيام.',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final title = getTitle(item);
        final subtitle = getSubtitle(item);
        final deletedBy = getDeletedBy(item);

        // 🌟 حساب الأيام المتبقية
        final deletionDate = getUpdatedAt(item).toLocal();
        final daysPassed = DateTime.now().difference(deletionDate).inDays;
        final daysLeft = (7 - daysPassed).clamp(0, 7);

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.red.shade100,
              width: 1.5,
            ), // إطار أحمر خفيف يدل على الحذف
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- الصف الأول: الأيقونة + العنوان + عداد التدمير ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: Colors.red.shade700, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              decoration: TextDecoration.lineThrough,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // شارة الأيام المتبقية
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Text(
                        '⏳ باقي $daysLeft أيام',
                        style: TextStyle(
                          color: Colors.orange.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),

                const Divider(height: 24),

                // --- الصف الثاني: معلومات من حذف + أزرار الإجراءات ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // معلومات الحذف
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.delete_sweep,
                                size: 14,
                                color: Colors.red.shade400,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'حُذف بواسطة: ',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                deletedBy,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${deletionDate.year}/${deletionDate.month.toString().padLeft(2, '0')}/${deletionDate.day.toString().padLeft(2, '0')} - ${deletionDate.hour}:${deletionDate.minute.toString().padLeft(2, '0')}',
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

                    // الأزرار
                    Row(
                      children: [
                        if (canRestore)
                          TextButton.icon(
                            icon: const Icon(Icons.restore),
                            label: const Text('استعادة'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.green.shade700,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                            ),
                            onPressed: () {
                              onRestore(item);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('تمت الاستعادة بنجاح.'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                          ),
                        if (canHardDelete)
                          TextButton.icon(
                            icon: const Icon(Icons.delete_forever),
                            label: const Text('تدمير'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red.shade700,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                            ),
                            onPressed: () {
                              showVerifyHardDeleteDialog(
                                context: context,
                                itemName: title,
                                onConfirm: () => onHardDelete(item),
                              );
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
