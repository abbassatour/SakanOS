// test/home/home_cubit_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:our_home_erp_app/home/cubit/home_cubit.dart';
import 'package:erp_repository/erp_repository.dart';

import '../helpers/mocks.dart';

// تسجيل قيم افتراضية لكي يتمكن Mocktail من استخدام any() مع الـ Enums
class FakeDateTime extends Fake implements DateTime {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeDateTime());
    registerFallbackValue(DashboardTimeFilter.monthly);
  });

  group('HomeCubit - CEO Dashboard & Analytics Engine', () {
    late MockErpRepository mockErpRepository;

    // تجهيز مؤشرات وهمية قادمة من الداتابيز
    final dummyMetrics = DashboardMetrics(
      totalRevenue: 50000000.0, // 50 مليون ل.س محصلة
      totalAreaSold: 1200.5, // 1200.5 متر تم بيعها
      totalPaidMeters: 600.0, // 600 متر تم دفع ثمنها بالكامل
      totalOverdueDebts: 150000.0,
      totalUndeliveredMeters: 400.0,
      inventoryStatus: const {'متاحة': 10, 'مباعة': 5, 'مُسلّمة': 2},
      activeContractsCount: 15,
      latestPayments: const [],
      groupedRevenue: const {'2026-07': 50000000.0},
      dollarTrend: const {'2026-07': 15000.0},
      costTrend: const {'2026-07': 1090000.0},
      contractsByType: const {'متخصص': 10, 'لاحق التخصص': 5},
      recentActivities: const [],
    );

    setUp(() {
      mockErpRepository = MockErpRepository();
    });

    // =========================================================
    // 📊 اختبار جلب المؤشرات الحيوية للشركة (KPIs)
    // =========================================================
    blocTest<HomeCubit, HomeState>(
      'emits [loading, success] and securely calculates derived metrics for the CEO dashboard',
      build: () {
        when(
          () => mockErpRepository.getDashboardMetrics(
            timeFilter: any(named: 'timeFilter'),
            refDate: any(named: 'refDate'),
          ),
        ).thenAnswer((_) async => dummyMetrics);

        return HomeCubit(mockErpRepository);
      },
      act: (cubit) => cubit.fetchDashboardData(),
      expect: () => [
        isA<HomeState>().having((s) => s.status, 'status', HomeStatus.loading),
        isA<HomeState>()
            .having((s) => s.status, 'status', HomeStatus.success)
            .having((s) => s.totalRevenue, 'totalRevenue', 50000000.0)
            .having((s) => s.totalAreaSold, 'totalAreaSold', 1200.5)
            // 🎯 التحقق الأهم: الخاصية المشتقة (المساحة المباعة - المساحة المسددة)
            // 1200.5 - 600.0 = 600.5 متر متبقي ديون في السوق!
            .having(
              (s) => s.remainingMetersInDebt,
              'remainingMetersInDebt',
              600.5,
            )
            .having(
              (s) => s.inventoryStatus['متاحة'],
              'available inventory',
              10,
            ),
      ],
      verify: (_) {
        verify(
          () => mockErpRepository.getDashboardMetrics(
            timeFilter: any(named: 'timeFilter'),
            refDate: any(named: 'refDate'),
          ),
        ).called(1);
      },
    );

    // =========================================================
    // ⏱️ اختبار تغيير الفلتر الزمني (Time Filter)
    // =========================================================
    blocTest<HomeCubit, HomeState>(
      'updates time filter, resets reference date, and fetches new data',
      build: () {
        when(
          () => mockErpRepository.getDashboardMetrics(
            timeFilter: any(named: 'timeFilter'),
            refDate: any(named: 'refDate'),
          ),
        ).thenAnswer((_) async => dummyMetrics);

        return HomeCubit(mockErpRepository);
      },
      seed: () => HomeState(
        referenceDate: DateTime(2020),
        timeFilter: TimeFilter.monthly,
      ),
      act: (cubit) => cubit.changeTimeFilter(TimeFilter.yearly),
      expect: () => [
        // يغير الفلتر والتاريخ أولاً
        isA<HomeState>()
            .having((s) => s.timeFilter, 'timeFilter', TimeFilter.yearly)
            .having(
              (s) => s.referenceDate.year,
              'year',
              DateTime.now().year,
            ), // التاريخ يعود للوقت الحالي
        // ثم يصدر حالة التحميل أثناء الجلب
        isA<HomeState>().having((s) => s.status, 'status', HomeStatus.loading),
        // ثم يعيد النجاح
        isA<HomeState>().having((s) => s.status, 'status', HomeStatus.success),
      ],
    );
  });
}
