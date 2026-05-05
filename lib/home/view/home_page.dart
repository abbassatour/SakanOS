// lib/home/view/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/home_cubit.dart';
import 'widgets/kpi_section.dart';
import 'widgets/charts_section.dart';
import 'widgets/recent_activities_section.dart'; // 🌟 الاستدعاء الجديد

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // ✅ جلب البيانات فور فتح الصفحة
    context.read<HomeCubit>().fetchDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      // 🌟 الشاشة تبدأ فوراً من المنطقة الآمنة بدون أي AppBar
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state.status == HomeStatus.loading) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children:[
                    CircularProgressIndicator(color: Color(0xFF1A237E)),
                    SizedBox(height: 16),
                    Text('جارٍ تحميل البيانات...', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            }

            if (state.status == HomeStatus.failure) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children:[
                    const Icon(Icons.error_outline_rounded, size: 64, color: Colors.redAccent),
                    const SizedBox(height: 16),
                    Text(
                      state.errorMessage ?? 'حدث خطأ غير متوقع',
                      style: const TextStyle(color: Colors.grey, fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => context.read<HomeCubit>().fetchDashboardData(),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('إعادة المحاولة'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF1A237E),
                        minimumSize: const Size(160, 48),
                      ),
                    ),
                  ],
                ),
              );
            }

            // 🌟 استخدام RefreshIndicator لتعويض زر التحديث بدون هدر أي مساحة (سحب للأسفل للتحديث)
            return RefreshIndicator(
              color: const Color(0xFF1A237E),
              onRefresh: () async {
                await context.read<HomeCubit>().fetchDashboardData();
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(), // 👈 ضروري لعمل السحب للتحديث
                slivers:[
                  SliverPadding(
                    // 🌟 تبدأ المؤشرات والمخططات فوراً من أعلى الشاشة
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        KpiSection(state: state),
                        
                        const SizedBox(height: 20), 
                        
                        ChartsSection(state: state),

                        const SizedBox(height: 24), 
                        
                        // ==========================================
                        // 🌟 القسم الجديد: سجل النشاطات الحديثة
                        // ==========================================
                        RecentActivitiesSection(activities: state.recentActivities),
                      ]),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}