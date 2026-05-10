// lib/profile/view/client_profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart' show Client;
import '../cubit/client_profile_cubit.dart';

import '../../dashboard/cubit/dashboard_cubit.dart';
import '../../payments/cubit/payments_cubit.dart';
import '../../schedule/cubit/schedule_cubit.dart';
import 'contract_details_page.dart'; 

String formatWithCommas(num number) {
  RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  return number.toInt().toString().replaceAllMapped(reg, (Match match) => '${match[1]},');
}

class ClientProfilePage extends StatelessWidget {
  final Client client;

  const ClientProfilePage({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: BlocBuilder<ClientProfileCubit, ClientProfileState>(
          builder: (context, state) {
            if (state.status == ClientProfileStatus.loading) {
              return const Center(child: CircularProgressIndicator(color: Colors.indigo));
            }
            if (state.status == ClientProfileStatus.failure) {
              return Center(child: Text(state.errorMessage ?? 'حدث خطأ', style: const TextStyle(color: Colors.red)));
            }

            final summaries = state.contractsSummary;

            return CustomScrollView(
              slivers:[
                // ==========================================
                // 🌟 قسم الهيدر الاحترافي (Overlapping Layout)
                // ==========================================
                SliverToBoxAdapter(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children:[
                      // 1. الخلفية الزرقاء المدمجة
                      Container(
                        height: 200, 
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors:[Colors.indigo.shade800, Colors.indigo.shade600],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                          ),
                        ),
                        child: Column(
                          children:[
                            Row(
                              children:[
                                IconButton(
                                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                const Text('الملف التعريفي للعميل', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            
                            Row(
                              children:[
                                CircleAvatar(
                                  radius: 32,
                                  backgroundColor: Colors.white.withOpacity(0.15),
                                  child: Text(
                                    client.name.isNotEmpty ? client.name.substring(0, 1) : '?',
                                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children:[
                                      Text(client.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                                      const SizedBox(height: 6),
                                      Row(
                                        children:[
                                          const Icon(Icons.phone, color: Colors.white70, size: 14),
                                          const SizedBox(width: 4),
                                          Text(client.phone, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
                                          
                                          if (client.nationalId != null && client.nationalId!.isNotEmpty) ...[
                                            const SizedBox(width: 16),
                                            const Icon(Icons.badge, color: Colors.white70, size: 14),
                                            const SizedBox(width: 4),
                                            Text(client.nationalId!, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
                                          ]
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // 2. بطاقة الإحصائيات الطافية
                      Positioned(
                        top: 150, 
                        left: 20,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow:[BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                            border: Border.all(color: Colors.indigo.shade50),
                          ),
                          child: Row(
                            children:[
                              _buildTopStat('إجمالي العقود', summaries.length.toString(), Icons.folder_shared, Colors.indigo),
                              Container(height: 30, width: 1, color: Colors.grey.shade200),
                              _buildTopStat('إجمالي المدفوعات', '${formatWithCommas(state.grandTotalPaid)} ل.س', Icons.account_balance_wallet, Colors.green),
                              Container(height: 30, width: 1, color: Colors.grey.shade200),
                              // 🌟 [التعديل 1]: تحويل إجمالي المتأخرات إلى مبلغ مالي بدلاً من عدد أقساط
                              _buildTopStat('ديون متأخرة', '${formatWithCommas(state.totalOverdueAcrossAll)} ل.س', Icons.warning_rounded, state.totalOverdueAcrossAll > 0 ? Colors.red : Colors.green),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 70)),

                // ==========================================
                // 🌟 قائمة العقود (المحفظة)
                // ==========================================
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Row(
                      children:[
                        Icon(Icons.real_estate_agent, color: Colors.blueGrey.shade400, size: 22),
                        const SizedBox(width: 8),
                        const Text('المحفظة العقارية للعميل', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                      ],
                    ),
                  ),
                ),

                if (summaries.isEmpty)
                  SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          children:[
                            Icon(Icons.folder_off, size: 60, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            const Text('هذا العميل لا يملك أي عقود حالياً.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final summary = summaries[index];
                          final contract = summary.contract;
                          final isAllocated = contract.contractType == 'متخصص';

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  final dashboardCubit = context.read<DashboardCubit>();
                                  final paymentsCubit = context.read<PaymentsCubit>();
                                  final scheduleCubit = context.read<ScheduleCubit>();

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MultiBlocProvider(
                                        providers:[
                                          BlocProvider.value(value: dashboardCubit),
                                          BlocProvider.value(value: paymentsCubit),
                                          BlocProvider.value(value: scheduleCubit),
                                        ],
                                        child: ContractDetailsPage(
                                          contract: contract, 
                                          client: client,
                                          summary: summary,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade200, width: 1.5),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children:[
                                        // الأيقونة (تقوم بتمييز نوع العقد لغوياً وبصرياً بأمان)
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: isAllocated ? Colors.amber.shade50 : Colors.blue.shade50,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(isAllocated ? Icons.apartment : Icons.savings, color: isAllocated ? Colors.amber.shade700 : Colors.blue.shade700, size: 24),
                                        ),
                                        const SizedBox(width: 16),
                                        
                                        // التفاصيل الأساسية
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children:[
                                              Text(contract.apartmentDetails, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                                              const SizedBox(height: 6),
                                              Row(
                                                children:[
                                                  Text(contract.contractType, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isAllocated ? Colors.amber.shade800 : Colors.blue.shade800)),
                                                  const SizedBox(width: 8),
                                                  Text('•  توقيع: ${contract.contractDate.year}/${contract.contractDate.month}/${contract.contractDate.day}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children:[
                                                  const Icon(Icons.price_check, size: 14, color: Colors.green),
                                                  const SizedBox(width: 4),
                                                  Text('المدفوع: ${formatWithCommas(summary.totalPaid)} ل.س', style: const TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.bold)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        
                                        // خط فاصل خفيف
                                        Container(width: 1, height: 50, color: Colors.grey.shade200, margin: const EdgeInsets.symmetric(horizontal: 12)),
                                        
                                        // ==========================================
                                        // 🌟 [التعديل 2]: حالة الديون المتأخرة والغرامات
                                        // ==========================================
                                        Expanded(
                                          flex: 2, // تم التوسيع لتستوعب الأرقام الكبيرة
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children:[
                                              if (summary.totalOverdueWithPenalty > 0) ...[
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(6)),
                                                  child: Text(
                                                    '${formatWithCommas(summary.totalOverdueWithPenalty)} متأخر', 
                                                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                // 🌟 مؤشر وجود غرامة
                                                if (summary.penaltyAmount > 0)
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 4, right: 2),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children:[
                                                        Icon(Icons.local_fire_department, size: 12, color: Colors.deepOrange.shade600),
                                                        const SizedBox(width: 2),
                                                        Text('يحتوي غرامات', style: TextStyle(color: Colors.deepOrange.shade700, fontSize: 10, fontWeight: FontWeight.bold)),
                                                      ],
                                                    ),
                                                  ),
                                              ] else ...[
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(6)),
                                                  child: const Text('منتظم مالياً ✓', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                                                ),
                                              ],
                                              const SizedBox(height: 6),
                                              Text('${summary.paidSchedulesCount} حركات مسددة', style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.chevron_left, color: Colors.grey),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: summaries.length,
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            );
          },
        ),
      ),
    );
  }

  // دالة مساعدة لبطاقة الإحصائيات بتصميم مضغوط
  Widget _buildTopStat(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children:[
          Icon(icon, color: color.withOpacity(0.8), size: 22),
          const SizedBox(height: 6),
          // 🌟 وضعنا TextOverflow و maxLines لحماية التصميم من الأرقام الكبيرة
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}