// lib/profile/view/contract_details_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart' show Contract, Client;
import 'package:url_launcher/url_launcher.dart'; 

import '../../dashboard/cubit/dashboard_cubit.dart';
import '../cubit/client_profile_cubit.dart';
import '../../payments/cubit/payments_cubit.dart';
import '../../schedule/cubit/schedule_cubit.dart';


String formatWithCommas(num number) {
  RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  return number.toInt().toString().replaceAllMapped(reg, (Match match) => '${match[1]},');
}

// دالة مساعدة لتنسيق التواريخ بشكل أنيق وحماية من القيم الفارغة
String _formatDateSafely(DateTime? date) {
  if (date == null) return 'غير محدد';
  return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
}

class ContractDetailsPage extends StatelessWidget {
  final Contract contract;
  final Client client;
  final ContractProfileSummary? summary;

  const ContractDetailsPage({
    super.key,
    required this.contract,
    required this.client,
    this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAllocated = contract.contractType == 'متخصص';
    final Color mainColor = isAllocated ? Colors.amber.shade700 : Colors.blue.shade700;
    final Color bgColor = isAllocated ? Colors.amber.shade50 : Colors.blue.shade50;

    // فك تشفير المعاملات بأمان
    Map<String, dynamic> coefficientsMap = {};
    if (contract.coefficients.isNotEmpty && contract.coefficients != '{}') {
      try {
        coefficientsMap = jsonDecode(contract.coefficients);
      } catch (_) {}
    }

    // 🌟 استخراج بيانات الغرامة بأمان
    final bool isPenaltyActive = contract.isPenaltyActive ?? false;
    final double penaltyPct = contract.penaltyPercentage ?? 0.0;
    final int penaltyInterval = contract.penaltyIntervalMonths ?? 1;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: 700, 
            child: CustomScrollView(
              slivers:[
                // ==========================================
                // 🌟 1. قسم الهيدر والبطاقة الطافية
                // ==========================================
                SliverToBoxAdapter(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children:[
                      // الخلفية العلوية الملونة حسب نوع العقد
                      Container(
                        height: 220,
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors:[mainColor, isAllocated ? Colors.amber.shade900 : Colors.blue.shade900],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:[
                            // شريط الرجوع والعنوان
                            Row(
                              children:[
                                IconButton(
                                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                const Expanded(
                                  child: Text('تفاصيل العقد والمحفظة', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
                                ),
                                // شارة نوع العقد
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                                  child: Row(
                                    children:[
                                      Icon(isAllocated ? Icons.apartment : Icons.savings, color: Colors.white, size: 16),
                                      const SizedBox(width: 6),
                                      Text(contract.contractType, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // اسم العميل ومعرف العقد
                            Row(
                              children:[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                                  child: const Icon(Icons.description, color: Colors.white, size: 32),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children:[
                                      Text('عقد العميل: ${client.name}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                                      const SizedBox(height: 4),
                                      Text('رقم العقد: ${contract.id.split('-').first.toUpperCase()}', style: const TextStyle(color: Colors.white70, fontSize: 14, letterSpacing: 1)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // البطاقة المحاسبية الطافية (Overlapping Card)
                      Positioned(
                        top: 160, 
                        left: 20,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow:[BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: Row(
                            children:[
                              _buildTopStat('المطلوب شهرياً', '${formatWithCommas(contract.agreedMonthlyAmount)}', 'ل.س', Icons.payments, Colors.deepOrange),
                              Container(height: 40, width: 1, color: Colors.grey.shade200),
                              if (isAllocated) ...[
                                _buildTopStat('سعر المتر عند التوقيع', '${formatWithCommas(contract.baseMeterPriceAtSigning)}', 'ل.س', Icons.price_change, Colors.teal),
                                Container(height: 40, width: 1, color: Colors.grey.shade200),
                                _buildTopStat('المساحة الإجمالية', '${contract.totalArea.toStringAsFixed(2)}', 'م²', Icons.architecture, Colors.indigo),
                              ] else ...[
                                _buildTopStat('سعر المتر', 'حسب السوق', 'يوم الدفع', Icons.trending_up, Colors.blue),
                                Container(height: 40, width: 1, color: Colors.grey.shade200),
                                _buildTopStat('المساحة', 'أسهم', 'غير مخصصة', Icons.pie_chart, Colors.indigo),
                              ]
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 80)),

                // ==========================================
                // 🚀 2. أزرار الإجراءات السريعة
                // ==========================================
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:[
                        const Text('الإجراءات التشغيلية', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                        const SizedBox(height: 12),
                        Row(
                          children:[
                            Expanded(
                              child: _buildActionButton(
                                icon: Icons.account_balance_wallet,
                                label: 'صفحة الأقساط',
                                color: Colors.deepOrange.shade600,
                                onTap: () {
                                  context.read<PaymentsCubit>().selectContract(contract.id);
                                  context.read<DashboardCubit>().changeTab(4);
                                  Navigator.of(context).popUntil((route) => route.isFirst);
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تحويلك لالأقساط الخاص بهذا العقد!'), backgroundColor: Colors.green));
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildActionButton(
                                icon: Icons.radar,
                                label: 'جدول المراقبة والمستحقات',
                                color: Colors.indigo.shade600,
                                onTap: () {
                                  context.read<ScheduleCubit>().selectContract(contract.id);
                                  context.read<DashboardCubit>().changeTab(5);
                                  Navigator.of(context).popUntil((route) => route.isFirst);
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تحويلك لجدول المراقبة الخاص بهذا العقد!'), backgroundColor: Colors.green));
                                },
                              ),
                            ),
                          ],
                        ),
                        if (contract.contractFileUrl != null && contract.contractFileUrl!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: _buildActionButton(
                              icon: Icons.attachment,
                              label: 'عرض ملف العقد المرفق (PDF/Word)',
                              color: Colors.green.shade700,
                              onTap: () async {
                                final Uri url = Uri.parse(contract.contractFileUrl!);
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لا يمكن فتح الرابط.'), backgroundColor: Colors.red));
                                }
                              },
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),

                // ==========================================
                // 📄 3. تفاصيل العقد والوصف
                // ==========================================
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildSectionCard(
                      title: 'تفاصيل العقد والوحدة',
                      icon: Icons.info_outline,
                      color: mainColor,
                      bgColor: bgColor,
                      child: Column(
                        children:[
                          _buildInfoRow('تاريخ توقيع العقد:', _formatDateSafely(contract.contractDate), Icons.calendar_month),
                          const Divider(height: 24),
                          _buildInfoRow('المدة المسجلة:', '${contract.installmentsCount} أشهر', Icons.timer),
                          const Divider(height: 24),
                          _buildInfoRow('اسم الكفيل الضامن:', contract.guarantorName, Icons.person_pin),
                          const Divider(height: 24),
                          _buildInfoRow('الوصف العقاري:', contract.apartmentDetails, Icons.apartment, isBold: true, valueColor: Colors.black87),
                        ],
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // ==========================================
                // 🔑 4. حالة تسليم العقار + الغرامات (للمتخصص فقط)
                // ==========================================
                if (isAllocated) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildSectionCard(
                        title: 'حالة تسليم العقار (المفتاح)',
                        icon: Icons.vpn_key,
                        color: contract.isHandedOver ? Colors.teal.shade700 : Colors.orange.shade700,
                        bgColor: contract.isHandedOver ? Colors.teal.shade50 : Colors.orange.shade50,
                        child: Column(
                          children:[
                            // حالة التسليم
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: contract.isHandedOver ? Colors.teal.shade100 : Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children:[
                                  Icon(
                                    contract.isHandedOver ? Icons.check_circle : Icons.hourglass_top, 
                                    color: contract.isHandedOver ? Colors.teal.shade800 : Colors.orange.shade800
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    contract.isHandedOver ? 'تم تسليم الشقة للعميل' : 'قيد الإنشاء / لم يتم التسليم بعد',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 15, 
                                      color: contract.isHandedOver ? Colors.teal.shade900 : Colors.orange.shade900
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 24),
                            _buildInfoRow('الموعد المتفق عليه بالعقد:', _formatDateSafely(contract.agreedHandoverDate), Icons.event),
                            const Divider(height: 24),
                            _buildInfoRow('فترة السماح (للمطور):', '${contract.gracePeriodMonths} أشهر', Icons.hourglass_empty),
                            
                            // ==========================================
                            // 🌟 إعدادات الغرامة المسجلة في العقد
                            // ==========================================
                            const Divider(height: 24),
                            _buildInfoRow(
                              'نظام غرامة التأخير (بعد التسليم):', 
                              isPenaltyActive ? 'مُفعّل ($penaltyPct% كل $penaltyInterval أشهر)' : 'غير مُفعّل', 
                              Icons.local_fire_department,
                              isBold: isPenaltyActive,
                              valueColor: isPenaltyActive ? Colors.deepOrange.shade700 : Colors.grey,
                            ),

                            // التفاصيل الفعلية بعد التسليم
                            if (contract.isHandedOver) ...[
                              const Divider(height: 24),
                              _buildInfoRow(
                                'تاريخ التسليم الفعلي:', 
                                _formatDateSafely(contract.actualHandoverDate), 
                                Icons.event_available, 
                                isBold: true, valueColor: Colors.teal.shade800
                              ),
                              if (contract.handoverNotes != null && contract.handoverNotes!.isNotEmpty) ...[
                                const Divider(height: 24),
                                _buildInfoRow(
                                  'ملاحظات / نواقص التسليم:', 
                                  contract.handoverNotes!, 
                                  Icons.note_alt, 
                                  valueColor: Colors.red.shade700
                                ),
                              ],
                              
                              // ==========================================
                              // 🚨 عرض التنبيه المحاسبي إذا تم احتساب غرامة فعلياً
                              // ==========================================
                              if (summary != null && summary!.penaltyAmount > 0) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.red.shade300, width: 2)
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children:[
                                      Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 28),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children:[
                                            Text(
                                              'تنبيه محاسبي: غرامات متراكمة', 
                                              style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.bold, fontSize: 14)
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'لقد مر الزمن المحدد بعد الاستلام والعميل لا يزال مديناً. النظام أضاف آلياً غرامة بقيمة ${formatWithCommas(summary!.penaltyAmount)} ل.س إلى ديونه.',
                                              style: TextStyle(color: Colors.red.shade800, fontSize: 13, height: 1.5),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ]
                            ]
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],

                // ==========================================
                // 📊 5. التحليل المالي والمعاملات (فك تشفير JSON)
                // ==========================================
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildSectionCard(
                      title: 'التحليل المالي والمعاملات (التميز)',
                      icon: Icons.analytics,
                      color: Colors.teal.shade700,
                      bgColor: Colors.teal.shade50,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:[
                          if (isAllocated) ...[
                            if (coefficientsMap.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
                                child: const Text('لا يوجد معاملات تميز إضافية مسجلة لهذا العقد.', style: TextStyle(color: Colors.grey, fontSize: 14)),
                              )
                            else
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: coefficientsMap.entries.map((entry) {
                                  double percentage = (entry.value as num).toDouble() * 100;
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.teal.shade50.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.teal.shade100),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children:[
                                        Text(entry.key, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal.shade900, fontSize: 13)),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                                          child: Text('${percentage.toStringAsFixed(1)}%', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal.shade700)),
                                        )
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                          ] else ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue.shade100)),
                              child: Row(
                                children:[
                                  Icon(Icons.info, color: Colors.blue.shade700),
                                  const SizedBox(width: 12),
                                  const Expanded(child: Text('لا يوجد معاملات لتسعير المتر. المحفظة الاستثمارية تحسب السعر آلياً لحظة كل دفعة بناءً على أسعار المواد في يوم الدفع.', style: TextStyle(color: Colors.black87, fontSize: 13, height: 1.5))),
                                ],
                              ),
                            )
                          ]
                        ],
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // דالة مساعدة لبطاقة الإحصائيات العلوية
  Widget _buildTopStat(String label, String value, String unit, IconData icon, Color color) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children:[
          Icon(icon, color: color.withOpacity(0.8), size: 24),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children:[
              Flexible(child: Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color), maxLines: 1, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(unit, style: TextStyle(fontSize: 11, color: color.withOpacity(0.7), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  // דالة مساعدة لبناء البطاقات
  Widget _buildSectionCard({required String title, required IconData icon, required Color color, required Color bgColor, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        boxShadow:[BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: color.withOpacity(0.1))),
            ),
            child: Row(
              children:[
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 10),
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(20), child: child),
        ],
      ),
    );
  }

  // דالة مساعدة لصفوف المعلومات مع أيقونات
  Widget _buildInfoRow(String label, String value, IconData icon, {bool isBold = false, Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:[
        Icon(icon, size: 18, color: Colors.grey.shade400),
        const SizedBox(width: 8),
        Expanded(flex: 2, child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w600))),
        Expanded(flex: 3, child: Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: 15, color: valueColor ?? Colors.black87), textAlign: TextAlign.left)),
      ],
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1,
      ),
      icon: Icon(icon, size: 22),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      onPressed: onTap,
    );
  }
}