// packages/erp_repository/lib/src/repositories/dashboard_repository.dart
// ignore_for_file: depend_on_referenced_packages

import 'package:intl/intl.dart';
import 'package:local_storage_api/local_storage_api.dart';

// ==========================================
// 📊 النماذج (Models) الخاصة بلوحة التحكم
// ==========================================
enum ActivityType { payment, contract, client, adminAction }

enum DashboardTimeFilter { daily, weekly, monthly, yearly }

class ActivityItem {
  ActivityItem({
    required this.entityId,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.userId,
    this.userName = 'مستخدم غير معروف',
  });

  final String entityId;
  final ActivityType type;
  final String title;
  final String description;
  final DateTime timestamp;
  final String userId;
  String userName;
}

class DashboardMetrics {
  DashboardMetrics({
    required this.totalRevenue,
    required this.totalAreaSold,
    required this.totalPaidMeters,
    required this.totalOverdueDebts,
    required this.totalUndeliveredMeters,
    required this.inventoryStatus,
    required this.activeContractsCount,
    required this.latestPayments,
    required this.groupedRevenue,
    required this.dollarTrend,
    required this.costTrend,
    required this.contractsByType,
    required this.recentActivities,
  });

  final double totalRevenue;
  final double totalAreaSold;
  final double totalPaidMeters;
  final double totalOverdueDebts;
  final double totalUndeliveredMeters;
  final Map<String, int> inventoryStatus;
  final int activeContractsCount;
  final List<PaymentsLedgerData> latestPayments;
  final Map<String, double> groupedRevenue;
  final Map<String, double> dollarTrend;
  final Map<String, double> costTrend;
  final Map<String, int> contractsByType;
  final List<ActivityItem> recentActivities;
}

class DashboardRepository {
  const DashboardRepository({required LocalStorageApi localApi})
    : _localApi = localApi;

  final LocalStorageApi _localApi;

  // ==========================================
  // 🕒 سجل النشاطات (Activity Log)
  // ==========================================
  Future<List<ActivityItem>> getRecentActivities({
    int limitPerType = 20,
    int finalLimit = 30,
  }) async {
    final allActivities = <ActivityItem>[];

    final recentPayments = await _localApi.getRecentPayments(limitPerType);
    final recentContracts = await _localApi.getRecentContracts(limitPerType);
    final recentClients = await _localApi.getRecentClients(limitPerType);

    for (final p in recentPayments) {
      allActivities.add(
        ActivityItem(
          entityId: p.id,
          type: ActivityType.payment,
          title: 'حركة مالية (دفعة/تعديل)',
          description:
              'دفعة بقيمة ${p.amountPaid} '
              'للعقد ${p.contractId.substring(0, 5)}...',
          timestamp: p.updatedAt,
          userId: p.userId,
        ),
      );
    }

    for (final c in recentContracts) {
      if (c.lastActionDate != null &&
          c.lastActionDate!.difference(c.updatedAt).inMinutes.abs() < 5) {
        allActivities.add(
          ActivityItem(
            entityId: c.id,
            type: ActivityType.adminAction,
            title: 'إجراء إداري (ملاحظة)',
            description: c.lastActionNote ?? 'تم تسجيل ملاحظة على العقد',
            timestamp: c.updatedAt,
            userId: c.userId,
          ),
        );
      } else {
        allActivities.add(
          ActivityItem(
            entityId: c.id,
            type: ActivityType.contract,
            title: 'إضافة/تعديل عقد',
            description:
                'عقد جديد أو معدل للعميل '
                '${c.clientId.substring(0, 5)}...',
            timestamp: c.updatedAt,
            userId: c.userId,
          ),
        );
      }
    }

    for (final c in recentClients) {
      allActivities.add(
        ActivityItem(
          entityId: c.id,
          type: ActivityType.client,
          title: 'إضافة/تعديل عميل',
          description: 'العميل: ${c.name}',
          timestamp: c.updatedAt,
          userId: c.userId,
        ),
      );
    }

    allActivities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final trimmedActivities = allActivities.length > finalLimit
        ? allActivities.sublist(0, finalLimit)
        : allActivities;

    final allUsers = await _localApi.getAllLocalUsers();
    final userNamesMap = <String, String>{
      for (final user in allUsers) user.id: user.fullName ?? 'مدير النظام',
    };

    for (final activity in trimmedActivities) {
      if (userNamesMap.containsKey(activity.userId)) {
        activity.userName = userNamesMap[activity.userId]!;
      }
    }

    return trimmedActivities;
  }

  // ==========================================
  // 📊 محرك الإحصائيات (Metrics Engine)
  // ==========================================
  int _monthsBetween(DateTime from, DateTime to) {
    final years = to.year - from.year;
    final months = to.month - from.month;
    var totalMonths = (years * 12) + months;
    if (to.day < from.day) totalMonths--;
    return totalMonths > 0 ? totalMonths : 0;
  }

  Future<DashboardMetrics> getDashboardMetrics({
    required DashboardTimeFilter timeFilter,
    required DateTime refDate,
  }) async {
    final contracts = await _localApi.getAllContracts();
    final payments = await _localApi.getAllPayments();
    final prices = await _localApi.getAllMaterialPricesHistory();
    final activities = await getRecentActivities(
      limitPerType: 10,
      finalLimit: 20,
    );
    final apartments = await _localApi.getAllApartments();
    final dollarPrices = await _localApi.getAllDollarPricesHistory();

    var totalRevenue = 0.0;
    var totalAreaSold = 0.0;
    var totalPaidMeters = 0.0;
    var totalOverdueDebts = 0.0;
    var totalUndeliveredMeters = 0.0;

    final inventoryStatus = {'متاحة': 0, 'مباعة': 0, 'مُسلّمة': 0};
    final tempGroupedRev = <String, double>{};
    final tempDollarTrend = <String, List<double>>{};
    final tempCostTrend = <String, List<double>>{};

    final now = DateTime.now().toUtc();

    // 🌟 [الإضافة الجديدة]: حفظ تواريخ الفلتر اليومي الدقيقة (مع السنة)
    final validDailyDates = <DateTime>[];

    // تهيئة الخرائط الزمنية
    if (timeFilter == DashboardTimeFilter.daily) {
      for (var i = 6; i >= 0; i--) {
        final d = refDate.subtract(Duration(days: i));
        // حفظ التاريخ بدون وقت للمطابقة الدقيقة
        validDailyDates.add(DateTime(d.year, d.month, d.day));

        final key = DateFormat('MM-dd').format(d);
        tempGroupedRev[key] = 0.0;
        tempDollarTrend[key] = [];
        tempCostTrend[key] = [];
      }
    } else if (timeFilter == DashboardTimeFilter.weekly) {
      for (var i = 1; i <= 4; i++) {
        tempGroupedRev['الأسبوع $i'] = 0.0;
        tempDollarTrend['الأسبوع $i'] = [];
        tempCostTrend['الأسبوع $i'] = [];
      }
    } else if (timeFilter == DashboardTimeFilter.monthly) {
      for (var i = 1; i <= 12; i++) {
        final key = '${refDate.year}-${i.toString().padLeft(2, '0')}';
        tempGroupedRev[key] = 0.0;
        tempDollarTrend[key] = [];
        tempCostTrend[key] = [];
      }
    } else if (timeFilter == DashboardTimeFilter.yearly) {
      for (var i = 4; i >= 0; i--) {
        final key = '${refDate.year - i}';
        tempGroupedRev[key] = 0.0;
        tempDollarTrend[key] = [];
        tempCostTrend[key] = [];
      }
    }

    // 1. حساب المدفوعات الإجمالية والأمتار المحصلة
    for (final p in payments) {
      totalRevenue += p.amountPaid;
      totalPaidMeters += p.convertedMeters;

      if (timeFilter == DashboardTimeFilter.daily) {
        // 🌟 [التحقق الصارم]: هل الدفعة حدثت فعلاً في أحد هذه الأيام الـ 7؟
        final pDate = DateTime(
          p.paymentDate.year,
          p.paymentDate.month,
          p.paymentDate.day,
        );
        if (validDailyDates.contains(pDate)) {
          final key = DateFormat('MM-dd').format(pDate);
          tempGroupedRev[key] = tempGroupedRev[key]! + p.amountPaid;
        }
      } else if (timeFilter == DashboardTimeFilter.weekly &&
          p.paymentDate.year == refDate.year &&
          p.paymentDate.month == refDate.month) {
        var weekNum = ((p.paymentDate.day - 1) / 7).floor() + 1;
        if (weekNum > 4) weekNum = 4;
        tempGroupedRev['الأسبوع $weekNum'] =
            tempGroupedRev['الأسبوع $weekNum']! + p.amountPaid;
      } else if (timeFilter == DashboardTimeFilter.monthly &&
          p.paymentDate.year == refDate.year) {
        final key =
            '${p.paymentDate.year}-'
            '${p.paymentDate.month.toString().padLeft(2, '0')}';
        if (tempGroupedRev.containsKey(key)) {
          tempGroupedRev[key] = tempGroupedRev[key]! + p.amountPaid;
        }
      } else if (timeFilter == DashboardTimeFilter.yearly) {
        final key = '${p.paymentDate.year}';
        if (tempGroupedRev.containsKey(key)) {
          tempGroupedRev[key] = tempGroupedRev[key]! + p.amountPaid;
        }
      }
    }

    final byType = <String, int>{};

    // 2. تحليل العقود
    for (final c in contracts) {
      if (c.isDeleted) continue;

      totalAreaSold += c.totalArea;
      byType[c.contractType] = (byType[c.contractType] ?? 0) + 1;

      if (!c.isHandedOver) totalUndeliveredMeters += c.totalArea;

      // 🌟 الكود الذي أصلحناه في الخطوة السابقة لحساب الأقساط الاستثنائية
      if (!c.isCompleted) {
        var monthsPassed = _monthsBetween(c.contractDate, now);
        if (monthsPassed > c.installmentsCount) {
          monthsPassed = c.installmentsCount;
        }

        var expectedPayment = c.downPayment;
        if (c.agreedMonthlyAmount > 0) {
          expectedPayment += (monthsPassed * c.agreedMonthlyAmount);
        }

        final contractSchedules = await _localApi.getContractSchedule(c.id);
        for (final s in contractSchedules) {
          if (s.expectedAmount != null && s.dueDate.isBefore(now)) {
            expectedPayment += s.expectedAmount!;
          }
        }

        var actualPaidForThisContract = 0.0;
        for (final p in payments.where(
          (p) => p.contractId == c.id && !p.isDeleted,
        )) {
          actualPaidForThisContract += p.amountPaid;
        }

        var overdue = expectedPayment - actualPaidForThisContract;

        if (overdue > 0 &&
            c.isHandedOver &&
            c.isPenaltyActive &&
            c.actualHandoverDate != null) {
          final handoverMonthsPassed = _monthsBetween(
            c.actualHandoverDate!,
            now,
          );

          if (handoverMonthsPassed > 0 && c.penaltyIntervalMonths > 0) {
            final penaltyApplications =
                (handoverMonthsPassed / c.penaltyIntervalMonths).floor();
            if (penaltyApplications > 0) {
              final penaltyAmount =
                  overdue * (c.penaltyPercentage / 100) * penaltyApplications;
              overdue += penaltyAmount;
            }
          }
        }

        if (overdue > 0) {
          totalOverdueDebts += overdue;
        }
      }
    }

    // 3. توزيع أسعار الدولار
    for (final d in dollarPrices) {
      if (d.isDeleted) continue;

      if (timeFilter == DashboardTimeFilter.daily) {
        // 🌟 الحماية نفسها للدولار
        final dDate = DateTime(
          d.effectiveDate.year,
          d.effectiveDate.month,
          d.effectiveDate.day,
        );
        if (validDailyDates.contains(dDate)) {
          final key = DateFormat('MM-dd').format(dDate);
          tempDollarTrend[key]!.add(d.exchangeRate);
        }
      } else if (timeFilter == DashboardTimeFilter.weekly &&
          d.effectiveDate.year == refDate.year &&
          d.effectiveDate.month == refDate.month) {
        var weekNum = ((d.effectiveDate.day - 1) / 7).floor() + 1;
        if (weekNum > 4) weekNum = 4;
        tempDollarTrend['الأسبوع $weekNum']!.add(d.exchangeRate);
      } else if (timeFilter == DashboardTimeFilter.monthly &&
          d.effectiveDate.year == refDate.year) {
        final key =
            '${d.effectiveDate.year}-'
            '${d.effectiveDate.month.toString().padLeft(2, '0')}';
        if (tempDollarTrend.containsKey(key)) {
          tempDollarTrend[key]!.add(d.exchangeRate);
        }
      } else if (timeFilter == DashboardTimeFilter.yearly) {
        final key = '${d.effectiveDate.year}';
        if (tempDollarTrend.containsKey(key)) {
          tempDollarTrend[key]!.add(d.exchangeRate);
        }
      }
    }

    // 4. تحليل جرد الشقق
    for (final apt in apartments) {
      if (apt.status == 'available') {
        inventoryStatus['متاحة'] = inventoryStatus['متاحة']! + 1;
      } else if (apt.status == 'delivered') {
        inventoryStatus['مُسلّمة'] = inventoryStatus['مُسلّمة']! + 1;
      } else {
        inventoryStatus['مباعة'] = inventoryStatus['مباعة']! + 1;
      }
    }

    // 5. تريند التكاليف
    for (final price in prices) {
      final baseCost =
          (price.ironPrice * 30.0) +
          (price.cementPrice * 4.0) +
          (price.block15Price * 50.0) +
          (price.formworkAndPouringWages * 1.0) +
          (price.aggregateMaterialsPrice * 2.0) +
          (price.ordinaryWorkerWage * 1.0);

      if (timeFilter == DashboardTimeFilter.daily) {
        // 🌟 الحماية نفسها لتكاليف المواد
        final pDate = DateTime(
          price.effectiveDate.year,
          price.effectiveDate.month,
          price.effectiveDate.day,
        );
        if (validDailyDates.contains(pDate)) {
          final key = DateFormat('MM-dd').format(pDate);
          tempCostTrend[key]!.add(baseCost);
        }
      } else if (timeFilter == DashboardTimeFilter.weekly &&
          price.effectiveDate.year == refDate.year &&
          price.effectiveDate.month == refDate.month) {
        var weekNum = ((price.effectiveDate.day - 1) / 7).floor() + 1;
        if (weekNum > 4) weekNum = 4;
        tempCostTrend['الأسبوع $weekNum']!.add(baseCost);
      } else if (timeFilter == DashboardTimeFilter.monthly &&
          price.effectiveDate.year == refDate.year) {
        final key =
            '${price.effectiveDate.year}-'
            '${price.effectiveDate.month.toString().padLeft(2, '0')}';
        if (tempCostTrend.containsKey(key)) {
          tempCostTrend[key]!.add(baseCost);
        }
      } else if (timeFilter == DashboardTimeFilter.yearly) {
        final key = '${price.effectiveDate.year}';
        if (tempCostTrend.containsKey(key)) {
          tempCostTrend[key]!.add(baseCost);
        }
      }
    }

    final finalDollarTrend = <String, double>{};
    tempDollarTrend.forEach((key, rates) {
      finalDollarTrend[key] = rates.isEmpty
          ? 0.0
          : rates.fold(0.0, (a, b) => a + b) / rates.length;
    });

    final finalCostTrend = <String, double>{};
    tempCostTrend.forEach((key, costs) {
      finalCostTrend[key] = costs.isEmpty
          ? 0.0
          : costs.fold(0.0, (a, b) => a + b) / costs.length;
    });

    void applyForwardFill(Map<String, double> trendData) {
      var lastKnownValue = 0.0;
      for (final value in trendData.values) {
        if (value > 0) {
          lastKnownValue = value;
          break;
        }
      }
      for (final key in trendData.keys) {
        if (trendData[key] == 0.0) {
          trendData[key] = lastKnownValue;
        } else {
          lastKnownValue = trendData[key]!;
        }
      }
    }

    applyForwardFill(finalDollarTrend);
    applyForwardFill(finalCostTrend);

    final sortedPayments = List<PaymentsLedgerData>.from(payments)
      ..sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
    final latestFive = sortedPayments.take(5).toList();

    return DashboardMetrics(
      totalRevenue: totalRevenue,
      totalAreaSold: totalAreaSold,
      totalPaidMeters: totalPaidMeters,
      totalOverdueDebts: totalOverdueDebts,
      totalUndeliveredMeters: totalUndeliveredMeters,
      inventoryStatus: inventoryStatus,
      activeContractsCount: contracts
          .where((c) => !c.isDeleted && !c.isCompleted)
          .length,
      latestPayments: latestFive,
      groupedRevenue: tempGroupedRev,
      dollarTrend: finalDollarTrend,
      costTrend: finalCostTrend,
      contractsByType: byType,
      recentActivities: activities,
    );
  }
}
