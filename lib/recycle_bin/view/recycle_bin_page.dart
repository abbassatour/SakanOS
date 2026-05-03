// lib/recycle_bin/view/recycle_bin_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erp_repository/erp_repository.dart';
import '../cubit/recycle_bin_cubit.dart';
import 'dialogs/verify_hard_delete_dialog.dart'; // 🌟 استدعاء الديالوج الموحد

// 🌟 استدعاء الحارس الشخصي والصلاحيات
import '../../auth/cubit/auth_cubit.dart';
import '../../core/constants/app_permissions.dart';

class RecycleBinPage extends StatelessWidget {
  const RecycleBinPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RecycleBinCubit(context.read<ErpRepository>())..loadAllDeletedData(),
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
    final bool canRestore = authState.hasPermission(AppPermissions.restoreItems);
    final bool canHardDelete = authState.hasPermission(AppPermissions.hardDeleteItems);

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('سلة المحذوفات الشاملة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.red.shade800,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs:[
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
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage ?? 'خطأ', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red));
            }
          },
          builder: (context, state) {
            if (state.status == RecycleBinStatus.loading) {
              return const Center(child: CircularProgressIndicator(color: Colors.red));
            }

            return TabBarView(
              children:[
                // 1. العملاء
                _buildList(
                  context: context, 
                  items: state.deletedClients, 
                  emptyMessage: 'العملاء',
                  icon: Icons.person_off,
                  canRestore: canRestore, // 🌟 تمرير الصلاحية
                  canHardDelete: canHardDelete, // 🌟 تمرير الصلاحية
                  getTitle: (item) => item.name, 
                  getSubtitle: (item) => 'رقم الهاتف: ${item.phone}',
                  getUpdatedAt: (item) => item.updatedAt,
                  onRestore: (item) => context.read<RecycleBinCubit>().restoreClient(item.id),
                  onHardDelete: (item) => context.read<RecycleBinCubit>().hardDeleteClient(item.id)
                ),
                // 2. المحاضر
                _buildList(
                  context: context, 
                  items: state.deletedBuildings, 
                  emptyMessage: 'المحاضر', 
                  icon: Icons.domain_disabled,
                  canRestore: canRestore,
                  canHardDelete: canHardDelete,
                  getTitle: (item) => 'محضر: ${item.name}', 
                  getSubtitle: (item) => 'الموقع: ${item.location}',
                  getUpdatedAt: (item) => item.updatedAt,
                  onRestore: (item) => context.read<RecycleBinCubit>().restoreBuilding(item.id),
                  onHardDelete: (item) => context.read<RecycleBinCubit>().hardDeleteBuilding(item.id)
                ),
                // 3. الوحدات
                _buildList(
                  context: context, 
                  items: state.deletedApartments, 
                  emptyMessage: 'الوحدات (الشقق/المحلات)', 
                  icon: Icons.do_not_disturb_alt,
                  canRestore: canRestore,
                  canHardDelete: canHardDelete,
                  getTitle: (item) => 'وحدة رقم: ${item.apartmentNumber}', 
                  getSubtitle: (item) => 'المساحة: ${item.area} م²',
                  getUpdatedAt: (item) => item.updatedAt,
                  onRestore: (item) => context.read<RecycleBinCubit>().restoreApartment(item.id),
                  onHardDelete: (item) => context.read<RecycleBinCubit>().hardDeleteApartment(item.id)
                ),
                // 4. العقود
                _buildList(
                  context: context, 
                  items: state.deletedContracts, 
                  emptyMessage: 'العقود', 
                  icon: Icons.file_copy_outlined,
                  canRestore: canRestore,
                  canHardDelete: canHardDelete,
                  getTitle: (item) => 'عقد بيع (${item.apartmentDetails})', 
                  getSubtitle: (item) => 'المساحة الإجمالية: ${item.totalArea} م²',
                  getUpdatedAt: (item) => item.updatedAt,
                  onRestore: (item) => context.read<RecycleBinCubit>().restoreContract(item.id),
                  onHardDelete: (item) => context.read<RecycleBinCubit>().hardDeleteContract(item.id)
                ),
                // 5. المدفوعات
                _buildList(
                  context: context, 
                  items: state.deletedPayments, 
                  emptyMessage: 'المدفوعات والإيصالات', 
                  icon: Icons.money_off,
                  canRestore: canRestore,
                  canHardDelete: canHardDelete,
                  getTitle: (item) => 'إيصال رقم: ${item.id.split('-').first.toUpperCase()}', 
                  getSubtitle: (item) => 'مبلغ الدفعة: ${item.amountPaid}',
                  getUpdatedAt: (item) => item.updatedAt,
                  onRestore: (item) => context.read<RecycleBinCubit>().restorePayment(item.id),
                  onHardDelete: (item) => context.read<RecycleBinCubit>().hardDeletePayment(item.id)
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // 🌟 الدالة السحرية المطورة لبناء القوائم (تدعم احتساب الأيام المتبقية وتخفي الأزرار بناءً على الصلاحيات)
  Widget _buildList<T>({
    required BuildContext context, 
    required List<T> items, 
    required String emptyMessage, 
    required IconData icon,
    required bool canRestore, // 🌟
    required bool canHardDelete, // 🌟
    required String Function(T) getTitle, 
    required String Function(T) getSubtitle, 
    required DateTime Function(T) getUpdatedAt, 
    required void Function(T) onRestore, 
    required void Function(T) onHardDelete
  }) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[
            Icon(Icons.check_circle_outline, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('سلة المحذوفات فارغة من $emptyMessage', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
            const SizedBox(height: 8),
            Text('يتم تنظيف السلة تلقائياً كل 7 أيام.', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
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

        // 🌟 حساب الأيام المتبقية
        final deletionDate = getUpdatedAt(item).toLocal();
        final daysPassed = DateTime.now().difference(deletionDate).inDays;
        final daysLeft = (7 - daysPassed).clamp(0, 7); // لضمان عدم ظهور رقم سالب

        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(backgroundColor: Colors.redAccent, child: Icon(icon, color: Colors.white)),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.lineThrough)),
            subtitle: Text('$subtitle\n⏳ باقي $daysLeft أيام على الحذف النهائي', style: const TextStyle(color: Colors.redAccent)),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children:[
                // 👻 إخفاء زر الاستعادة إذا لم يكن يملك الصلاحية
                if (canRestore)
                  IconButton(
                    icon: const Icon(Icons.restore, color: Colors.green, size: 30),
                    tooltip: 'استعادة',
                    onPressed: () {
                      onRestore(item);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت الاستعادة بنجاح.'), backgroundColor: Colors.green));
                    },
                  ),
                
                // 👻 إخفاء زر الحذف المدمر إذا لم يكن يملك الصلاحية (متاح غالباً للمدير فقط)
                if (canHardDelete)
                  IconButton(
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    tooltip: 'حذف نهائي الآن',
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
          ),
        );
      },
    );
  }
}