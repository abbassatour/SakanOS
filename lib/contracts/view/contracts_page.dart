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
  
  // 🌟 متغير الفلترة الجديد (الافتراضي: جارية)
  String _selectedFilter = 'جارية'; 

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

            // 🌟 الفلترة المزدوجة الذكية (البحث النصي + حالة العقد)
            final filteredContracts = state.contracts.where((contract) {
              // 1. الفلترة حسب الحالة (مكتمل / جاري)
              if (_selectedFilter == 'جارية' && contract.isCompleted) return false;
              if (_selectedFilter == 'مكتملة' && !contract.isCompleted) return false;

              // 2. الفلترة حسب البحث النصي
              if (_searchQuery.isEmpty) return true;
              final client = state.clients.firstWhere((c) => c.id == contract.clientId, orElse: () => state.clients.first);
              final searchLower = _searchQuery.toLowerCase();
              
              return client.name.toLowerCase().contains(searchLower) ||
                     contract.apartmentDetails.toLowerCase().contains(searchLower) ||
                     contract.id.contains(searchLower);
            }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                // شريط البحث الأساسي
                ContractsSearchBar(
                  searchQuery: _searchQuery,
                  resultCount: filteredContracts.length,
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),

                // 🌟 أزرار التصفية السريعة (Choice Chips)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  color: Colors.white,
                  width: double.infinity,
                  child: Wrap(
                    spacing: 8.0,
                    children: ['جارية', 'مكتملة', 'الكل'].map((filter) {
                      final isSelected = _selectedFilter == filter;
                      IconData? icon;
                      if (filter == 'جارية') icon = Icons.trending_up;
                      if (filter == 'مكتملة') icon = Icons.lock;
                      if (filter == 'الكل') icon = Icons.all_inclusive;

                      return ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (icon != null) ...[Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.blueGrey), const SizedBox(width: 6)],
                            Text(filter, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.blueGrey)),
                          ],
                        ),
                        selected: isSelected,
                        selectedColor: filter == 'مكتملة' ? Colors.green.shade600 : Colors.teal.shade600,
                        backgroundColor: Colors.grey.shade100,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedFilter = filter);
                        },
                      );
                    }).toList(),
                  ),
                ),
                
                // خط فاصل أنيق
                const Divider(height: 1, thickness: 1),

                Expanded(
                  child: filteredContracts.isEmpty
                      ? EmptyContractsView(
                          message: _selectedFilter == 'مكتملة' 
                            ? 'لا توجد عقود مكتملة مطابقة للبحث' 
                            : 'لا توجد نتائج للبحث', 
                          icon: Icons.search_off, 
                          iconColor: Colors.grey)
                      : ListView(
                          padding: const EdgeInsets.all(16), 
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