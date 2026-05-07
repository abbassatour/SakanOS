// lib/contracts/view/widgets/contracts_data_table.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../cubit/contracts_cubit.dart';
import '../../../core/utils/formatters.dart';
import '../dialogs/edit_contract_dialog.dart';

import '../../../profile/view/contract_details_page.dart'; 
import '../../../profile/cubit/client_profile_cubit.dart'; 

import '../../../dashboard/cubit/dashboard_cubit.dart';
import '../../../payments/cubit/payments_cubit.dart';
import '../../../schedule/cubit/schedule_cubit.dart';

class ContractsDataTable extends StatelessWidget {
  final List<dynamic> contracts; 
  final List<dynamic> clients;
  final Map<String, String> userNamesMap; // 🌟 الإضافة الجديدة: استقبال قاموس الأسماء

  const ContractsDataTable({
    super.key, 
    required this.contracts, 
    required this.clients,
    required this.userNamesMap, // 🌟 الإضافة الجديدة
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero, 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 32),
          child: DataTable(
            // 🌟 [التحسين الجديد]: تضييق المسافات بين الأعمدة لتوفير المساحة للعمود الجديد (الافتراضي 56)
            columnSpacing: 28, 
            horizontalMargin: 16,
            headingRowColor: WidgetStateProperty.all(Colors.teal.shade50),
            dataRowMinHeight: 55, 
            dataRowMaxHeight: 70, 
            columns: const[
              DataColumn(label: Text('رقم العقد', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal))),
              DataColumn(label: Text('العميل', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal))),
              DataColumn(label: Text('النوع', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal))),
              DataColumn(label: Text('سعر المتر', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal))),
              DataColumn(label: Text('ملف العقد', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal))),
              
              // 🌟 [العمود الجديد]: حالة التسليم
              DataColumn(label: Text('التسليم', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal))),
              
              DataColumn(label: Text('آخر تعديل بواسطة', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal))),
              DataColumn(label: Text('إجراءات', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal))),
            ],
            rows: contracts.asMap().entries.map((entry) {
              final index = entry.key;
              final contract = entry.value;
              
              final clientIdx = clients.indexWhere((c) => c.id == contract.clientId);
              final actualClient = clientIdx >= 0 ? clients[clientIdx] : null;
              final clientName = actualClient != null ? actualClient.name : 'عميل محذوف';

              // 🌟 المنطق الخاص بحالة التسليم
              final bool isAllocated = contract.contractType == 'متخصص';
              final bool isHandedOver = contract.isHandedOver ?? false; // استخدمنا ?? false للحماية الإضافية

              return DataRow(
                color: WidgetStateProperty.resolveWith<Color?>((states) => index.isEven ? Colors.grey.withOpacity(0.03) : null),
                cells:[
                  DataCell(Text(contract.id.split('-').first.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade600, fontSize: 13))),
                  DataCell(Text(clientName, style: const TextStyle(fontWeight: FontWeight.bold))), 
                  DataCell(Text(contract.contractType)),
                  DataCell(Text('${NumberFormatters.formatWithCommas(contract.baseMeterPriceAtSigning)} ل.س', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold))),
                  DataCell(_buildFileAction(context, contract)),
                  
                  // ==========================================
                  // 🌟 [الخلية الجديدة]: عرض حالة التسليم بشارة مضغوطة
                  // ==========================================
                  DataCell(
                    !isAllocated 
                      ? const Center(child: Text('-', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)))
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isHandedOver ? Colors.teal.shade50 : Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: isHandedOver ? Colors.teal.shade200 : Colors.orange.shade200),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children:[
                              Icon(
                                isHandedOver ? Icons.check_circle : Icons.hourglass_top,
                                size: 14, 
                                color: isHandedOver ? Colors.teal.shade700 : Colors.orange.shade700
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isHandedOver ? 'مُسلّم' : 'انتظار',
                                style: TextStyle(
                                  fontSize: 12, 
                                  fontWeight: FontWeight.bold, 
                                  color: isHandedOver ? Colors.teal.shade700 : Colors.orange.shade700
                                ),
                              ),
                            ],
                          ),
                        ),
                  ),

                  // ==========================================
                  // 🌟 خلية المستخدم وتاريخ التعديل
                  // ==========================================
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
                            Text(
                              userNamesMap[contract.userId] ?? 'مجهول', // جلب الاسم من القاموس
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.orange.shade800),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children:[
                            const Icon(Icons.access_time, size: 12, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              '${contract.updatedAt.year}/${contract.updatedAt.month.toString().padLeft(2,'0')}/${contract.updatedAt.day.toString().padLeft(2,'0')} ${contract.updatedAt.hour}:${contract.updatedAt.minute.toString().padLeft(2,'0')}',
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        )
                      ],
                    )
                  ),

                 DataCell(Row(
                    mainAxisSize: MainAxisSize.min,
                    children:[
                      IconButton(
                        tooltip: 'عرض التفاصيل والقفز السريع',
                        icon: const Icon(Icons.visibility, color: Colors.indigo, size: 22),
                        onPressed: () {
                          if (actualClient != null) {
                            final dashboardCubit = context.read<DashboardCubit>();
                            final paymentsCubit = context.read<PaymentsCubit>();
                            final scheduleCubit = context.read<ScheduleCubit>();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MultiBlocProvider(
                                  providers:[
                                    BlocProvider.value(value: dashboardCubit),
                                    BlocProvider.value(value: paymentsCubit),
                                    BlocProvider.value(value: scheduleCubit),
                                  ],
                                  child: ContractDetailsPage(
                                    contract: contract,
                                    client: actualClient,
                                  ),
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('لا يمكن عرض التفاصيل لأن العميل محذوف!'), backgroundColor: Colors.red),
                            );
                          }
                        },
                      ),
                      
                      IconButton(
                        tooltip: 'تعديل بيانات العقد',
                        icon: const Icon(Icons.edit_note, color: Colors.blue, size: 22),
                        onPressed: () => showEditContractDialog(context, contract),
                      ),
                    ],
                  )),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildFileAction(BuildContext context, dynamic contract) {
    bool hasFile = contract.contractFileUrl != null && contract.contractFileUrl!.isNotEmpty;
    return TextButton.icon(
      icon: Icon(hasFile ? Icons.download : Icons.upload_file, color: hasFile ? Colors.green : Colors.orange, size: 18),
      label: Text(hasFile ? 'فتح' : 'إرفاق', style: TextStyle(color: hasFile ? Colors.green : Colors.orange, fontWeight: FontWeight.bold)),
      onPressed: () async {
        if (hasFile) {
          final url = Uri.parse(contract.contractFileUrl!);
          if (await canLaunchUrl(url)) await launchUrl(url);
        } else {
          _pickAndUploadFile(context, contract.id);
        }
      },
    );
  }

  void _pickAndUploadFile(BuildContext context, String contractId) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions:['doc', 'docx', 'pdf'],
    );

    if (result != null && result.files.single.path != null) {
      if (context.mounted) {
        context.read<ContractsCubit>().attachContractFile(
              contractId: contractId,
              filePath: result.files.single.path!,
              extension: result.files.single.extension ?? 'docx',
            );
      }
    }
  }
}