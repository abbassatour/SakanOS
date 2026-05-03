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

// 🌟 استدعاء الحارس الشخصي والصلاحيات
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

  @override
  Widget build(BuildContext context) {
    // 🌟 جلب حالة الصلاحيات للمستخدم الحالي
    final authState = context.watch<AuthCubit>().state;
    
    // 🌟 التحقق من صلاحية إنشاء العقود
    final canCreate = authState.hasPermission(AppPermissions.createContracts);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      // لا يوجد AppBar
      
      // 🌟 تمرير الصلاحية لدالة بناء الزر العائم
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
              return const Center(child: CircularProgressIndicator());
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

            final filteredContracts = state.contracts.where((contract) {
              final client = state.clients.firstWhere((c) => c.id == contract.clientId, orElse: () => state.clients.first);
              final searchLower = _searchQuery.toLowerCase();
              return client.name.toLowerCase().contains(searchLower) ||
                     contract.apartmentDetails.toLowerCase().contains(searchLower) ||
                     contract.id.contains(searchLower);
            }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                // 🌟 يبدأ فوراً بشريط البحث (لا عناوين نهائياً)
                ContractsSearchBar(
                  searchQuery: _searchQuery,
                  resultCount: filteredContracts.length,
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),

                Expanded(
                  child: filteredContracts.isEmpty
                      ? const EmptyContractsView(message: 'لا توجد نتائج للبحث', icon: Icons.search_off, iconColor: Colors.grey)
                      : ListView(
                          padding: const EdgeInsets.all(16), 
                          children:[ContractsDataTable(contracts: filteredContracts, clients: state.clients)],
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
  // 🛡️ حماية الزر العائم (الزر الباهت)
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
        : null, // تعطيل الضغط
      icon: const Icon(Icons.add_home_work),
      label: const Text('عقد جديد', style: TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: canCreate ? Colors.teal.shade600 : Colors.grey.shade300,
      foregroundColor: canCreate ? Colors.white : Colors.grey.shade600,
      elevation: canCreate ? 6 : 0, // إزالة الظل لجعله يبدو مطفأً
      tooltip: canCreate ? 'إنشاء عقد جديد' : 'لا تملك صلاحية إنشاء عقود',
    );
  }
}