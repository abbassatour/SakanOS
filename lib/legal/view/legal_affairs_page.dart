// lib/legal/view/legal_affairs_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

import '../cubit/legal_affairs_cubit.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../core/constants/app_permissions.dart';
import 'package:local_storage_api/local_storage_api.dart' show LegalAction, Contract, Client, LegalActionAttachment;

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
    // 🌟 جلب الصلاحيات لمعرفة هل المستخدم يحق له الإدارة أم فقط العرض
    final authState = context.watch<AuthCubit>().state;
    final canManage = authState.hasPermission(AppPermissions.manageLegalAffairs);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      
      // ==========================================
      // 🛡️ حماية الزر العائم (إضافة إجراء جديد)
      // ==========================================
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_legal_action_fab',
        onPressed: canManage ? () => _showAddActionDialog(context) : null,
        icon: const Icon(Icons.gavel),
        label: const Text('إضافة إجراء قانوني', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: canManage ? Colors.brown.shade600 : Colors.grey.shade300,
        foregroundColor: canManage ? Colors.white : Colors.grey.shade600,
        elevation: canManage ? 6 : 0, 
        tooltip: canManage ? 'تسجيل إجراء قانوني جديد' : 'لا تملك صلاحية الإدارة القانونية',
      ),
      
      body: SafeArea(
        child: BlocConsumer<LegalAffairsCubit, LegalAffairsState>(
          listener: (context, state) {
            if (state.status == LegalAffairsStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'حدث خطأ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  backgroundColor: Colors.red.shade700,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.status == LegalAffairsStatus.loading && state.actions.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: Colors.brown));
            }

            if (state.actions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:[
                    Icon(Icons.folder_off_outlined, size: 80, color: Colors.brown.shade200),
                    const SizedBox(height: 16),
                    const Text('الأرشيف القانوني فارغ. لا توجد إجراءات مسجلة.', style: TextStyle(fontSize: 18, color: Colors.blueGrey)),
                  ],
                )
              );
            }

            // ==========================================
            // 🔍 محرك البحث الذكي (يبحث بالاسم، نوع الإجراء، والملاحظات)
            // ==========================================
            final filteredActions = state.actions.where((action) {
              if (_searchQuery.isEmpty) return true;
              
              final searchLower = _searchQuery.toLowerCase();
              
              // جلب العميل المرتبط بهذا الإجراء للبحث باسمه
              final contract = state.contracts.where((c) => c.id == action.contractId).firstOrNull;
              final client = contract != null ? state.clients.where((c) => c.id == contract.clientId).firstOrNull : null;
              
              final clientName = client?.name.toLowerCase() ?? '';
              final actionType = action.actionType.toLowerCase();
              final notes = action.notes?.toLowerCase() ?? '';

              return clientName.contains(searchLower) || 
                     actionType.contains(searchLower) ||
                     notes.contains(searchLower);
            }).toList();

            return Column(
              children:[
                // 🌟 شريط البحث العلوي المضغوط
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow:[BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))],
                  ),
                  child: Row(
                    children:[
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: TextField(
                            onChanged: (value) => setState(() => _searchQuery = value),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search, color: Colors.brown),
                              hintText: 'ابحث باسم العميل، نوع الإجراء، أو الملاحظات...',
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.brown.shade400, width: 2)),
                              suffixIcon: _searchQuery.isNotEmpty 
                                ? IconButton(
                                    icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
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
                        decoration: BoxDecoration(color: Colors.brown.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.brown.shade200)),
                        child: Text('${filteredActions.length} إجراء', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown.shade700, fontSize: 14)),
                      )
                    ],
                  ),
                ),

                // ==========================================
                // 📊 جدول الإجراءات القانونية
                // ==========================================
                Expanded(
                  child: filteredActions.isEmpty
                    ? Center(child: Text('لا توجد نتائج مطابقة لبحثك.', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)))
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0),
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
                                  columnSpacing: 22,
                                  horizontalMargin: 20,
                                  headingRowColor: WidgetStateProperty.all(Colors.brown.shade50),
                                  dataRowMinHeight: 60,
                                  dataRowMaxHeight: 80,
                                  columns: const[
                                    DataColumn(label: Text('نوع الإجراء', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown, fontSize: 14))),
                                    DataColumn(label: Text('العميل / العقار', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown, fontSize: 14))),
                                    DataColumn(label: Text('التاريخ الفعلي', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown, fontSize: 14))),
                                    DataColumn(label: Text('المرفقات', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown, fontSize: 14))),
                                    DataColumn(label: Text('بواسطة', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown, fontSize: 14))),
                                    DataColumn(label: Text('إدارة', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown, fontSize: 14))),
                                  ],
                                  rows: filteredActions.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final action = entry.value;
                                    
                                    // جلب بيانات العقد والعميل المرتبطة
                                    final contract = state.contracts.where((c) => c.id == action.contractId).firstOrNull;
                                    final client = contract != null ? state.clients.where((c) => c.id == contract.clientId).firstOrNull : null;
                                    
                                    // جلب المرفقات
                                    final attachments = state.attachmentsMap[action.id] ??[];

                                    return DataRow(
                                      color: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) => index.isEven ? Colors.grey.withOpacity(0.03) : null),
                                      cells:[
                                        DataCell(_buildActionTypeChip(action.actionType)),
                                        DataCell(
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children:[
                                              Text(client?.name ?? 'عميل محذوف', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                              Text(contract?.apartmentDetails ?? 'غير محدد', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                            ],
                                          )
                                        ),
                                        DataCell(Text(DateFormat('yyyy/MM/dd').format(action.actionDate.toLocal()), style: const TextStyle(fontWeight: FontWeight.bold))),
                                        
                                        // 📎 زر المرفقات
                                        DataCell(
                                          InkWell(
                                            onTap: () => _showAttachmentsDialog(context, action, attachments, canManage),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: attachments.isNotEmpty ? Colors.blue.shade50 : Colors.grey.shade100,
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(color: attachments.isNotEmpty ? Colors.blue.shade200 : Colors.grey.shade300)
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children:[
                                                  Icon(Icons.attach_file, size: 16, color: attachments.isNotEmpty ? Colors.blue.shade700 : Colors.grey),
                                                  const SizedBox(width: 4),
                                                  Text('${attachments.length}', style: TextStyle(fontWeight: FontWeight.bold, color: attachments.isNotEmpty ? Colors.blue.shade700 : Colors.grey)),
                                                ],
                                              ),
                                            ),
                                          )
                                        ),
                                        
                                        // الموظف الذي أضاف الإجراء
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
                                                  Text(state.userNamesMap[action.userId] ?? 'مجهول', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.orange.shade800)),
                                                ],
                                              ),
                                              Text(DateFormat('yyyy/MM/dd').format(action.createdAt.toLocal()), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                            ],
                                          )
                                        ),

                                        // إجراءات الحذف
                                        DataCell(
                                          IconButton(
                                            icon: Icon(Icons.delete_outline, color: canManage ? Colors.red : Colors.grey.shade400),
                                            tooltip: canManage ? 'حذف الإجراء' : 'غير مصرح',
                                            onPressed: canManage ? () => _confirmDeleteAction(context, action) : null,
                                          ),
                                        ),
                                      ]
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
  // 🎨 تصميم الـ Chip حسب نوع الإجراء
  // ==========================================
  Widget _buildActionTypeChip(String type) {
    Color bgColor;
    Color textColor;

    switch (type) {
      case 'إنذار': bgColor = Colors.orange.shade100; textColor = Colors.orange.shade900; break;
      case 'فراغ عقاري': bgColor = Colors.green.shade100; textColor = Colors.green.shade900; break;
      case 'رهن': bgColor = Colors.purple.shade100; textColor = Colors.purple.shade900; break;
      case 'دعوى قضائية': bgColor = Colors.red.shade100; textColor = Colors.red.shade900; break;
      default: bgColor = Colors.blue.shade100; textColor = Colors.blue.shade900;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6)),
      child: Text(type, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  // ==========================================
  // ➕ نافذة إضافة إجراء جديد (شاملة)
  // ==========================================
  void _showAddActionDialog(BuildContext context) {
    final cubit = context.read<LegalAffairsCubit>();
    final state = cubit.state;

    // بما أننا في لوحة عامة، يجب أن نختار العقد أولاً
    String? selectedContractId;
    String selectedActionType = 'إنذار';
    DateTime selectedDate = DateTime.now();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Row(
              children:[
                Icon(Icons.balance, color: Colors.brown),
                SizedBox(width: 8),
                Text('تسجيل إجراء قانوني', style: TextStyle(color: Colors.brown)),
              ],
            ),
            content: SizedBox(
              width: 400,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children:[
                    // 1. اختيار العقد/العميل (Dropdown)
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'اختر العقد / العميل', border: OutlineInputBorder()),
                      isExpanded: true,
                      value: selectedContractId,
                      items: state.contracts.map((contract) {
                        final client = state.clients.where((c) => c.id == contract.clientId).firstOrNull;
                        return DropdownMenuItem(
                          value: contract.id,
                          child: Text('${client?.name ?? "مجهول"} - ${contract.apartmentDetails}', overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (val) => setStateDialog(() => selectedContractId = val),
                    ),
                    const SizedBox(height: 16),

                    // 2. نوع الإجراء
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'نوع الإجراء', border: OutlineInputBorder()),
                      value: selectedActionType,
                      items: ['إنذار', 'فراغ عقاري', 'رهن', 'تسوية', 'دعوى قضائية']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (val) => setStateDialog(() => selectedActionType = val!),
                    ),
                    const SizedBox(height: 16),

                    // 3. التاريخ
                    ListTile(
                      shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(4)),
                      title: const Text('تاريخ الإجراء'),
                      subtitle: Text(DateFormat('yyyy-MM-dd').format(selectedDate), style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: const Icon(Icons.calendar_month, color: Colors.brown),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context, initialDate: selectedDate,
                          firstDate: DateTime(2000), lastDate: DateTime(2100),
                        );
                        if (date != null) setStateDialog(() => selectedDate = date);
                      },
                    ),
                    const SizedBox(height: 16),

                    // 4. الملاحظات
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(labelText: 'ملاحظات وتفاصيل', border: OutlineInputBorder()),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            actions:[
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.brown, foregroundColor: Colors.white),
                onPressed: () {
                  if (selectedContractId == null) {
                    ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('الرجاء اختيار العقد أولاً')));
                    return;
                  }
                  cubit.addLegalAction(
                    contractId: selectedContractId!,
                    actionType: selectedActionType,
                    actionDate: selectedDate,
                    notes: notesController.text,
                  );
                  Navigator.pop(ctx);
                },
                child: const Text('حفظ الإجراء'),
              ),
            ],
          );
        }
      ),
    );
  }

  // ==========================================
  // 📎 نافذة إدارة المرفقات
  // ==========================================
  void _showAttachmentsDialog(BuildContext context, LegalAction action, List<LegalActionAttachment> attachments, bool canManage) {
    final cubit = context.read<LegalAffairsCubit>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:[
            const Text('المرفقات القانونية', style: TextStyle(color: Colors.indigo)),
            if (canManage)
              ElevatedButton.icon(
                icon: const Icon(Icons.upload_file, size: 16),
                label: const Text('إضافة ملف'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                onPressed: () async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
                  );

                  if (result != null) {
                    Navigator.pop(ctx); // إغلاق النافذة مؤقتاً أثناء الرفع
                    cubit.attachFileToAction(
                      actionId: action.id,
                      filePath: result.files.single.path!,
                      extension: result.files.single.extension ?? 'unknown',
                      originalFileName: result.files.single.name,
                    );
                  }
                },
              )
          ],
        ),
        content: SizedBox(
          width: 400,
          child: attachments.isEmpty 
            ? const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text('لا توجد مرفقات لهذا الإجراء.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              )
            : ListView.separated(
                shrinkWrap: true,
                itemCount: attachments.length,
                separatorBuilder: (c, i) => const Divider(),
                itemBuilder: (c, i) {
                  final att = attachments[i];
                  final isPdf = att.fileType?.toLowerCase() == 'pdf';
                  return ListTile(
                    leading: Icon(isPdf ? Icons.picture_as_pdf : Icons.image, color: isPdf ? Colors.red : Colors.blue, size: 32),
                    title: Text(att.fileName ?? 'ملف بدون اسم', maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(DateFormat('yyyy/MM/dd').format(att.createdAt.toLocal()), style: const TextStyle(fontSize: 10)),
                    trailing: canManage 
                      ? IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () {
                            cubit.deleteAttachment(att.id);
                            Navigator.pop(ctx);
                          },
                        ) 
                      : null,
                  );
                },
              ),
        ),
        actions:[TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إغلاق'))],
      ),
    );
  }

  // ==========================================
  // 🗑️ تأكيد الحذف
  // ==========================================
  void _confirmDeleteAction(BuildContext context, LegalAction action) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف', style: TextStyle(color: Colors.red)),
        content: const Text('هل أنت متأكد من حذف هذا الإجراء القانوني؟'),
        actions:[
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
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