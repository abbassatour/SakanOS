// lib/legal/view/legal_affairs_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart' show Contract;
import '../cubit/legal_affairs_cubit.dart';

// استدعاء نافذة التعديل لكي يضغط عليها المحامي
import '../../contracts/view/dialogs/edit_contract_dialog.dart';
// استدعاء نافذة التفاصيل
import '../../profile/view/contract_details_page.dart';
// كيوبتات ضرورية لفتح التفاصيل
import '../../dashboard/cubit/dashboard_cubit.dart';
import '../../payments/cubit/payments_cubit.dart';
import '../../schedule/cubit/schedule_cubit.dart';

class LegalAffairsPage extends StatefulWidget {
  const LegalAffairsPage({super.key});

  @override
  State<LegalAffairsPage> createState() => _LegalAffairsPageState();
}

class _LegalAffairsPageState extends State<LegalAffairsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade900,
        title: const Text('الشؤون القانونية والأرشيف', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amber,
          indicatorWeight: 4,
          labelColor: Colors.amber,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          tabs: const[
            Tab(icon: Icon(Icons.gavel), text: 'مهام الفراغ القانوني'),
            Tab(icon: Icon(Icons.account_balance), text: 'أرشيف مالي مبكر'),
            Tab(icon: Icon(Icons.inventory_2), text: 'الإغلاق والتسليم التام'),
          ],
        ),
      ),
      body: BlocBuilder<LegalAffairsCubit, LegalAffairsState>(
        builder: (context, state) {
          if (state.status == LegalAffairsStatus.loading) {
            return const Center(child: CircularProgressIndicator(color: Colors.blueGrey));
          }

          return TabBarView(
            controller: _tabController,
            children:[
              _buildContractsList(
                state.pendingLegalTransfer, state, 
                Colors.purple, Icons.warning_amber_rounded, 'شقق مُسلّمة بانتظار الفراغ ونقل الملكية.',
              ),
              _buildContractsList(
                state.financialArchive, state, 
                Colors.blue, Icons.monetization_on, 'عقود مسددة بالكامل لكن الشقة قيد الإنشاء.',
              ),
              _buildContractsList(
                state.ultimateArchive, state, 
                Colors.green, Icons.verified, 'ملفات منتهية للأبد (مسددة ومفرغة).',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContractsList(List<Contract> contracts, LegalAffairsState state, Color color, IconData emptyIcon, String emptyMessage) {
    if (contracts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[
            Icon(emptyIcon, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('القائمة فارغة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            Text(emptyMessage, style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: contracts.length,
      itemBuilder: (context, index) {
        final contract = contracts[index];
        final client = state.clients.firstWhere((c) => c.id == contract.clientId);
        
        String buildingName = 'محفظة (أسهم)';
        String aptDetails = contract.apartmentDetails;
        
        if (contract.apartmentId != null) {
          final aptIndex = state.apartments.indexWhere((a) => a.id == contract.apartmentId);
          if (aptIndex != -1) {
            final apt = state.apartments[aptIndex];
            final bldIndex = state.buildings.indexWhere((b) => b.id == apt.buildingId);
            if (bldIndex != -1) buildingName = state.buildings[bldIndex].name;
            aptDetails = 'شقة ${apt.apartmentNumber} | ${apt.floorName}';
          }
        }

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: color.withOpacity(0.3), width: 1.5)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children:[
                // 1. الأيقونة اليسرى
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(Icons.description, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                
                // 2. تفاصيل العميل والعقار
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:[
                      Text('العميل: ${client.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
                      const SizedBox(height: 4),
                      Text('$buildingName - $aptDetails', style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children:[
                          Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text('توقيع العقد: ${contract.contractDate.year}/${contract.contractDate.month}/${contract.contractDate.day}', style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                          
                          if (contract.isHandedOver) ...[
                            const SizedBox(width: 12),
                            Icon(Icons.vpn_key, size: 12, color: Colors.teal.shade500),
                            const SizedBox(width: 4),
                            Text('التسليم: ${contract.actualHandoverDate?.year}/${contract.actualHandoverDate?.month}/${contract.actualHandoverDate?.day}', style: TextStyle(color: Colors.teal.shade600, fontSize: 11, fontWeight: FontWeight.bold)),
                          ]
                        ],
                      ),
                    ],
                  ),
                ),
                
                // 3. الأزرار (فتح التفاصيل / تحديث الطابو)
                Column(
                  children:[
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16)),
                      icon: const Icon(Icons.gavel, size: 18),
                      label: Text(contract.isTitleDeedTransferred ? 'تعديل الفراغ' : 'نقل الملكية والطابو'),
                      onPressed: () async {
                        // 🌟 فتح نافذة تعديل العقد مباشرة لكي يقوم المحامي بعمله!
                        showEditContractDialog(context, contract);
                        // بعد إغلاق النافذة تحديث الشاشة
                        await Future.delayed(const Duration(milliseconds: 500));
                        if(context.mounted) context.read<LegalAffairsCubit>().fetchData();
                      },
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.visibility, size: 18),
                      label: const Text('عرض كامل التفاصيل'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MultiBlocProvider(
                              providers:[
                                BlocProvider.value(value: context.read<DashboardCubit>()),
                                BlocProvider.value(value: context.read<PaymentsCubit>()),
                                BlocProvider.value(value: context.read<ScheduleCubit>()),
                              ],
                              child: ContractDetailsPage(contract: contract, client: client),
                            ),
                          ),
                        );
                      },
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