// lib/contracts/view/contracts_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/contracts_cubit.dart';
import '../../../buildings/cubit/buildings_cubit.dart';
import '../../../settings/cubit/settings_cubit.dart';
import 'add_contract_page.dart';
import 'widgets/contracts_search_bar.dart';
import 'widgets/contracts_data_table.dart';
import 'widgets/empty_contracts_view.dart';

import '../../auth/cubit/auth_cubit.dart';
import '../../core/constants/app_permissions.dart';

class ContractsPage extends StatelessWidget {
  const ContractsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ContractsView();
  }
}

class ContractsView extends StatefulWidget {
  const ContractsView({super.key});

  @override
  State<ContractsView> createState() => _ContractsViewState();
}

class _ContractsViewState extends State<ContractsView> {
  String _searchQuery = '';
  
  // 🌟 متغيرات الفلترة المتعددة (الافتراضي: عقود جارية فقط)
  String _statusFilter = 'active'; // all, active, completed
  String _typeFilter = 'all';      // all, allocated, unallocated
  String _handoverFilter = 'all';  // all, delivered, pending

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final canCreate = authState.hasPermission(AppPermissions.createContracts);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      
      floatingActionButton: _buildFAB(context, canCreate),
      
      body: SafeArea(
        child: BlocConsumer<ContractsCubit, ContractsState>(
          listener: (context, state) {
            if (state.status == ContractsStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage ?? 'خطأ'), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            if (state.status == ContractsStatus.loading && state.contracts.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: Colors.teal));
            }
            if (state.clients.isEmpty) {
              return const EmptyContractsView(
                message: 'يرجى إضافة عميل أولاً من قسم العملاء.',
                icon: Icons.group_add,
                iconColor: Colors.grey,
              );
            }
            if (state.contracts.isEmpty) {
              return const EmptyContractsView(
                message: 'لم يتم توقيع أي عقود بعد.',
                icon: Icons.real_estate_agent,
                iconColor: Colors.teal,
              );
            }

            // 🌟 الفلترة المركبة الذكية
            final filteredContracts = state.contracts.where((contract) {
              // 1. فلتر الحالة (مكتمل / جاري)
              bool passStatus = _statusFilter == 'all' ||
                               (_statusFilter == 'active' && !contract.isCompleted) ||
                               (_statusFilter == 'completed' && contract.isCompleted);

              // 2. فلتر النوع (متخصص / لاحق التخصص)
              bool passType = _typeFilter == 'all' ||
                             (_typeFilter == 'allocated' && contract.contractType == 'متخصص') ||
                             (_typeFilter == 'unallocated' && contract.contractType == 'لاحق التخصص');

              // 3. فلتر التسليم
              bool passHandover = _handoverFilter == 'all' ||
                                 (_handoverFilter == 'delivered' && contract.isHandedOver) ||
                                 (_handoverFilter == 'pending' && !contract.isHandedOver);

              // 4. فلتر البحث النصي
              bool passSearch = true;
              if (_searchQuery.isNotEmpty) {
                final client = state.clients.firstWhere((c) => c.id == contract.clientId, orElse: () => state.clients.first);
                final searchLower = _searchQuery.toLowerCase();
                passSearch = client.name.toLowerCase().contains(searchLower) ||
                             contract.apartmentDetails.toLowerCase().contains(searchLower) ||
                             contract.id.contains(searchLower);
              }

              return passStatus && passType && passHandover && passSearch;
            }).toList();

            final bool hasActiveFilters = _statusFilter != 'all' || _typeFilter != 'all' || _handoverFilter != 'all';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                // شريط البحث الأساسي
                ContractsSearchBar(
                  searchQuery: _searchQuery,
                  resultCount: filteredContracts.length,
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),

                // 🌟 شريط الفلاتر النشطة وزر الفتح (تصميم مستوحى من الرادار)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    border: Border.all(color: Colors.teal.shade200),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow:[BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                  ),
                  child: Row(
                    children:[
                      const Icon(Icons.tune, color: Colors.teal, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:[
                            Text(hasActiveFilters ? 'الفلاتر النشطة حالياً:' : 'عرض جميع العقود (بدون فلترة)', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            if (hasActiveFilters)
                              Text(
                                '${_getStatusName(_statusFilter)} | ${_getTypeName(_typeFilter)} | ${_getHandoverName(_handoverFilter)}',
                                style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 13),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _showFilterBottomSheet,
                        icon: const Icon(Icons.filter_alt, size: 18),
                        label: const Text('تصفية', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),

                      if (hasActiveFilters) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.clear, color: Colors.red),
                          tooltip: 'إلغاء الفلاتر',
                          style: IconButton.styleFrom(backgroundColor: Colors.red.shade50),
                          onPressed: () {
                            setState(() {
                              _statusFilter = 'all';
                              _typeFilter = 'all';
                              _handoverFilter = 'all';
                            });
                          },
                        )
                      ]
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                Expanded(
                  child: filteredContracts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:[
                              Icon(Icons.search_off, size: 60, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              const Text('لا يوجد عقود تطابق الفلاتر المحددة', style: TextStyle(color: Colors.grey, fontSize: 16)),
                            ],
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 80), 
                          children:[
                            ContractsDataTable(
                              contracts: filteredContracts, 
                              clients: state.clients,
                              userNamesMap: state.userNamesMap, 
                            )
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
  // 🎛️ النافذة السفلية للفلترة (BottomSheet)
  // ==========================================
  void _showFilterBottomSheet() {
    String tempStatus = _statusFilter;
    String tempType = _typeFilter;
    String tempHandover = _handoverFilter;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children:[
                      Icon(Icons.filter_alt, color: Colors.teal, size: 28),
                      SizedBox(width: 8),
                      Text('فرز وتصفية العقود', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // 1. حالة العقد
                  const Text('1. حالة العقد (أرشفة):', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children:[
                      _buildChipRadio('all', '🌐 الكل', tempStatus, Colors.blueGrey, (v) => setModalState(() => tempStatus = v)),
                      _buildChipRadio('active', '📈 عقود جارية', tempStatus, Colors.teal, (v) => setModalState(() => tempStatus = v)),
                      _buildChipRadio('completed', '🔒 عقود مكتملة (مؤرشفة)', tempStatus, Colors.green, (v) => setModalState(() => tempStatus = v)),
                    ],
                  ),
                  
                  const Divider(height: 32, thickness: 1.5),

                  // 2. نوع العقد
                  const Text('2. نوع العقد:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children:[
                      _buildChipRadio('all', '🌐 الكل', tempType, Colors.blueGrey, (v) => setModalState(() => tempType = v)),
                      _buildChipRadio('allocated', '🏢 متخصص (شقة محددة)', tempType, Colors.indigo, (v) => setModalState(() => tempType = v)),
                      _buildChipRadio('unallocated', '📊 لاحق التخصص (أسهم)', tempType, Colors.deepOrange, (v) => setModalState(() => tempType = v)),
                    ],
                  ),

                  const Divider(height: 32, thickness: 1.5),

                  // 3. حالة التسليم
                  const Text('3. حالة التسليم الفعلي للشقة:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children:[
                      _buildChipRadio('all', '🌐 الكل', tempHandover, Colors.blueGrey, (v) => setModalState(() => tempHandover = v)),
                      _buildChipRadio('delivered', '🔑 تم تسليم الشقة', tempHandover, Colors.green, (v) => setModalState(() => tempHandover = v)),
                      _buildChipRadio('pending', '⏳ قيد الإنشاء / لم تسلم', tempHandover, Colors.orange, (v) => setModalState(() => tempHandover = v)),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // زر التطبيق
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                      icon: const Icon(Icons.check_circle),
                      label: const Text('تطبيق الفرز', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        setState(() {
                          _statusFilter = tempStatus;
                          _typeFilter = tempType;
                          _handoverFilter = tempHandover;
                        });
                        Navigator.pop(ctx);
                      },
                    ),
                  )
                ],
              ),
            );
          }
        );
      }
    );
  }

  // ==========================================
  // تصميم الأزرار (راديو)
  // ==========================================
  Widget _buildChipRadio(String value, String title, String groupValue, Color color, Function(String) onChanged) {
    final isSelected = groupValue == value;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          border: Border.all(color: isSelected ? color : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // ==========================================
  // دوال مساعدة لترجمة الفلاتر للعرض في الشريط
  // ==========================================
  String _getStatusName(String f) {
    if (f == 'active') return 'عقود جارية';
    if (f == 'completed') return 'عقود مكتملة';
    return 'جميع الحالات';
  }

  String _getTypeName(String f) {
    if (f == 'allocated') return 'متخصص';
    if (f == 'unallocated') return 'لاحق التخصص';
    return 'جميع الأنواع';
  }

  String _getHandoverName(String f) {
    if (f == 'delivered') return 'مُسلّمة';
    if (f == 'pending') return 'بانتظار التسليم';
    return 'الكل';
  }

  // ==========================================
  // 🛡️ حماية الزر العائم
  // ==========================================
  FloatingActionButton _buildFAB(BuildContext context, bool canCreate) {
    return FloatingActionButton.extended(
      onPressed: canCreate 
        ? () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MultiBlocProvider(
                providers:[
                  BlocProvider.value(value: context.read<ContractsCubit>()),
                  BlocProvider.value(value: context.read<BuildingsCubit>()),
                  BlocProvider.value(value: context.read<SettingsCubit>()),
                ],
                child: const AddContractPage(),
              ),
            ),
          )
        : null, 
      icon: const Icon(Icons.add_home_work),
      label: const Text('عقد جديد', style: TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: canCreate ? Colors.teal.shade600 : Colors.grey.shade300,
      foregroundColor: canCreate ? Colors.white : Colors.grey.shade600,
      elevation: canCreate ? 6 : 0, 
      tooltip: canCreate ? 'إنشاء عقد جديد' : 'لا تملك صلاحية إنشاء عقود',
    );
  }
}