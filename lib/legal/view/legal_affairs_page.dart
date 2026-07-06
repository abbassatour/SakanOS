// lib/legal/view/legal_affairs_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'legal_attachments_page.dart';
import '../cubit/legal_affairs_cubit.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../core/constants/app_permissions.dart';
import 'package:local_storage_api/local_storage_api.dart' show LegalAction;

// استيراد النوافذ المستقلة
import 'dialogs/add_legal_action_dialog.dart';

class LegalAffairsPage extends StatelessWidget {
  const LegalAffairsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalAffairsView();
  }
}

class LegalAffairsView extends StatefulWidget {
  const LegalAffairsView({super.key});

  @override
  State<LegalAffairsView> createState() => _LegalAffairsViewState();
}

class _LegalAffairsViewState extends State<LegalAffairsView> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;

    final canAddAction = authState.hasPermission(AppPermissions.addLegalAction);
    final canEditAction = authState.hasPermission(
      AppPermissions.editLegalAction,
    );
    final canDeleteAction = authState.hasPermission(
      AppPermissions.deleteLegalAction,
    );
    final canManageAttachments = authState.hasPermission(
      AppPermissions.manageLegalAttachments,
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      // 🌟 تطبيق صلاحية "الإضافة"
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_legal_action_fab',
        onPressed: canAddAction
            ? () => showAddOrEditLegalActionDialog(context)
            : null,
        icon: const Icon(Icons.gavel),
        label: const Text(
          'إضافة إجراء قانوني',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: canAddAction
            ? Colors.brown.shade600
            : Colors.grey.shade300,
        foregroundColor: canAddAction ? Colors.white : Colors.grey.shade600,
        elevation: canAddAction ? 6 : 0,
        tooltip: canAddAction
            ? 'تسجيل إجراء قانوني جديد'
            : 'لا تملك صلاحية الإضافة',
      ),

      body: SafeArea(
        child: BlocConsumer<LegalAffairsCubit, LegalAffairsState>(
          listener: (context, state) {
            if (state.status == LegalAffairsStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.errorMessage ?? 'حدث خطأ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Colors.red.shade700,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.status == LegalAffairsStatus.loading &&
                state.actions.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.brown),
              );
            }
            if (state.actions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.folder_off_outlined,
                      size: 80,
                      color: Colors.brown.shade200,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'الأرشيف القانوني فارغ. لا توجد إجراءات مسجلة.',
                      style: TextStyle(fontSize: 18, color: Colors.blueGrey),
                    ),
                  ],
                ),
              );
            }

            final filteredActions = state.actions.where((action) {
              if (_searchQuery.isEmpty) return true;
              final searchLower = _searchQuery.toLowerCase();
              final contract = state.contracts
                  .where((c) => c.id == action.contractId)
                  .firstOrNull;
              final client = contract != null
                  ? state.clients
                        .where((c) => c.id == contract.clientId)
                        .firstOrNull
                  : null;
              return (client?.name.toLowerCase() ?? '').contains(searchLower) ||
                  action.actionType.toLowerCase().contains(searchLower) ||
                  (action.notes?.toLowerCase() ?? '').contains(searchLower);
            }).toList();

            return Column(
              children: [
                _buildSearchBar(filteredActions.length),
                Expanded(
                  child: filteredActions.isEmpty
                      ? Center(
                          child: Text(
                            'لا توجد نتائج مطابقة لبحثك.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(
                            16.0,
                            16.0,
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
                                    columnSpacing: 22,
                                    horizontalMargin: 20,
                                    headingRowColor: WidgetStateProperty.all(
                                      Colors.brown.shade50,
                                    ),
                                    dataRowMinHeight: 60,
                                    dataRowMaxHeight: 80,
                                    columns: const [
                                      DataColumn(
                                        label: Text(
                                          'نوع الإجراء',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.brown,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'العميل / العقار',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.brown,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'التاريخ الفعلي',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.brown,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'المرفقات',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.brown,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'بواسطة',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.brown,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'إدارة',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.brown,
                                          ),
                                        ),
                                      ),
                                    ],
                                    rows: filteredActions.asMap().entries.map((
                                      entry,
                                    ) {
                                      final action = entry.value;
                                      final contract = state.contracts
                                          .where(
                                            (c) => c.id == action.contractId,
                                          )
                                          .firstOrNull;
                                      final client = contract != null
                                          ? state.clients
                                                .where(
                                                  (c) =>
                                                      c.id == contract.clientId,
                                                )
                                                .firstOrNull
                                          : null;
                                      // نجلب المرفقات هنا فقط لمعرفة "العدد" وعرضه في الشارة
                                      final attachments =
                                          state.attachmentsMap[action.id] ?? [];

                                      return DataRow(
                                        color:
                                            WidgetStateProperty.resolveWith<
                                              Color?
                                            >(
                                              (Set<WidgetState> s) =>
                                                  entry.key.isEven
                                                  ? Colors.grey.withOpacity(
                                                      0.03,
                                                    )
                                                  : null,
                                            ),
                                        cells: [
                                          DataCell(
                                            _buildActionTypeChip(
                                              action.actionType,
                                            ),
                                          ),
                                          DataCell(
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  client?.name ?? 'عميل محذوف',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Text(
                                                  contract?.apartmentDetails ??
                                                      'غير محدد',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              DateFormat('yyyy/MM/dd').format(
                                                action.actionDate.toLocal(),
                                              ),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),

                                          // 🌟 استدعاء صفحة المرفقات وتمرير صلاحية "إدارة المرفقات"
                                          DataCell(
                                            InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  LegalAttachmentsPage.route(
                                                    action,
                                                    canManageAttachments, // 👈 التعديل هنا: تمرير الصلاحية المخصصة
                                                    context
                                                        .read<
                                                          LegalAffairsCubit
                                                        >(),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: attachments.isNotEmpty
                                                      ? Colors.blue.shade50
                                                      : Colors.grey.shade100,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  border: Border.all(
                                                    color:
                                                        attachments.isNotEmpty
                                                        ? Colors.blue.shade200
                                                        : Colors.grey.shade300,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.attach_file,
                                                      size: 16,
                                                      color:
                                                          attachments.isNotEmpty
                                                          ? Colors.blue.shade700
                                                          : Colors.grey,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      '${attachments.length}',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            attachments
                                                                .isNotEmpty
                                                            ? Colors
                                                                  .blue
                                                                  .shade700
                                                            : Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
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
                                                      state.userNamesMap[action
                                                              .userId] ??
                                                          'مجهول',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12,
                                                        color: Colors
                                                            .orange
                                                            .shade800,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  DateFormat(
                                                    'yyyy/MM/dd',
                                                  ).format(
                                                    action.createdAt.toLocal(),
                                                  ),
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // 🌟 تطبيق صلاحية التعديل والحذف
                                          DataCell(
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                // زر التعديل
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.edit,
                                                    color: canEditAction
                                                        ? Colors.blue
                                                        : Colors.grey.shade300,
                                                  ),
                                                  tooltip: canEditAction
                                                      ? 'تعديل الإجراء'
                                                      : 'لا تملك صلاحية التعديل',
                                                  onPressed: canEditAction
                                                      ? () =>
                                                            showAddOrEditLegalActionDialog(
                                                              context,
                                                              actionToEdit:
                                                                  action,
                                                            )
                                                      : null,
                                                ),
                                                // زر الحذف
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.delete_outline,
                                                    color: canDeleteAction
                                                        ? Colors.red
                                                        : Colors.grey.shade300,
                                                  ),
                                                  tooltip: canDeleteAction
                                                      ? 'حذف الإجراء'
                                                      : 'لا تملك صلاحية الحذف',
                                                  onPressed: canDeleteAction
                                                      ? () =>
                                                            _confirmDeleteAction(
                                                              context,
                                                              action,
                                                            )
                                                      : null,
                                                ),
                                              ],
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

  // ==========================================
  // دوال مساعدة للواجهة
  // ==========================================
  Widget _buildSearchBar(int count) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: Colors.brown),
                  hintText: 'ابحث باسم العميل، نوع الإجراء، أو الملاحظات...',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 0,
                  ),
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
                    borderSide: BorderSide(
                      color: Colors.brown.shade400,
                      width: 2,
                    ),
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: Colors.grey,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() => _searchQuery = '');
                            FocusScope.of(context).unfocus();
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 48,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.brown.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.brown.shade200),
            ),
            child: Text(
              '$count إجراء',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.brown.shade700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTypeChip(String type) {
    Color bgColor;
    Color textColor;
    switch (type) {
      case 'إنذار':
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange.shade900;
        break;
      case 'فراغ عقاري':
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade900;
        break;
      case 'رهن':
        bgColor = Colors.purple.shade100;
        textColor = Colors.purple.shade900;
        break;
      case 'دعوى قضائية':
        bgColor = Colors.red.shade100;
        textColor = Colors.red.shade900;
        break;
      default:
        bgColor = Colors.blue.shade100;
        textColor = Colors.blue.shade900;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        type,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  void _confirmDeleteAction(BuildContext context, LegalAction action) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف', style: TextStyle(color: Colors.red)),
        content: const Text('هل أنت متأكد من حذف هذا الإجراء القانوني؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              context.read<LegalAffairsCubit>().deleteLegalAction(action.id);
              Navigator.pop(ctx);
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
