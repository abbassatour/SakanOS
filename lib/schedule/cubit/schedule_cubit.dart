// lib/schedule/cubit/schedule_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
// استدعاء الكلاسات الضرورية
import 'package:drift/drift.dart' show Value;
import 'package:local_storage_api/local_storage_api.dart' show Contract, Client, InstallmentsScheduleData, InstallmentsScheduleCompanion;


part 'schedule_state.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  ScheduleCubit(this._erpRepository) : super(const ScheduleState());

  final ErpRepository _erpRepository;
  final double targetAllocationMeters = 50.0; // 🌟 هدف التخصص (يمكنك تغييره إلى 40 أو أي رقم)

  // ==========================================
  // 🎯 التحكم في التبويبات الداخلية لصفحة المراقبة
  // ==========================================
  void changeTab(int index) {
    emit(state.copyWith(activeTabIndex: index));
  }

  Future<void> fetchInitialData() async {
    if (state.status == ScheduleStatus.initial) emit(state.copyWith(status: ScheduleStatus.loading));
    try {
      final clients = await _erpRepository.getClients();
      final contracts = await _erpRepository.getAllContracts();
      
      // 🌟 1. تشغيل محرك رادار التخصص بصمت
      final allocationAlerts = await _generateAllocationRadar(contracts, clients);

      // 🌟 2. تشغيل محرك المتعثرين (الديون المتراكمة) بصمت
      final overdueAlerts = await _generateOverdueRadar(contracts, clients);

      emit(state.copyWith(
        status: ScheduleStatus.success,
        clients: clients,
        contracts: contracts,
        allocationAlerts: allocationAlerts, // 🌟 حفظ تنبيهات التخصص
        overdueAlerts: overdueAlerts,       // 🌟 حفظ تنبيهات المتعثرين
      ));
    } catch (e) {
      emit(state.copyWith(status: ScheduleStatus.failure, errorMessage: e.toString()));
    }
  }

  // ==========================================
  // 🚨 محرك المتعثرين والمتأخرين (Overdue Radar Engine)
  // ==========================================
  Future<List<OverdueContractAlert>> _generateOverdueRadar(List<Contract> allContracts, List<Client> allClients) async {
    // 1. جلب جميع الأقساط المعلقة المتأخرة عن موعدها من المستودع
    final allOverdueSchedules = await _erpRepository.getAllOverdueSchedules();
    
    // 2. تجميع الأقساط لكل عقد على حدة
    Map<String, List<InstallmentsScheduleData>> grouped = {};
    for (var s in allOverdueSchedules) {
       grouped.putIfAbsent(s.contractId, () =>[]).add(s);
    }

    List<OverdueContractAlert> alerts =[];
    final now = DateTime.now().toUtc();

    grouped.forEach((contractId, schedules) {
       final contractIdx = allContracts.indexWhere((c) => c.id == contractId);
       if (contractIdx == -1) return;
       final contract = allContracts[contractIdx];

       final clientIdx = allClients.indexWhere((c) => c.id == contract.clientId);
       if (clientIdx == -1) return;
       final client = allClients[clientIdx];

       // أقدم قسط متأخر (القائمة تأتي مرتبة، فالأول هو الأقدم)
       final oldestSchedule = schedules.first;
       final maxDaysOverdue = now.difference(oldestSchedule.dueDate).inDays;

       // تصنيف الخطورة
       String severity = 'notice'; // 🟡 أيام قليلة
       if (maxDaysOverdue >= 60) {
         severity = 'critical'; // 🔴 أكثر من شهرين
       } else if (maxDaysOverdue >= 30) {
         severity = 'warning'; // 🟠 أكثر من شهر
       }

       alerts.add(OverdueContractAlert(
          contract: contract,
          client: client,
          overdueSchedules: schedules,
          maxDaysOverdue: maxDaysOverdue,
          severity: severity,
       ));
    });

    // 3. الترتيب بحيث يظهر الأسوأ والأكثر تأخراً في أعلى القائمة
    alerts.sort((a, b) => b.maxDaysOverdue.compareTo(a.maxDaysOverdue));
    
    return alerts;
  }

  // ==========================================
  // 🧠 محرك التنبؤ الذكي للتخصص (مع ذاكرة الإجراءات)
  // ==========================================
  Future<List<AllocationAlertData>> _generateAllocationRadar(List<Contract> allContracts, List<Client> allClients) async {
    List<AllocationAlertData> radarList =[];

    final unallocatedContracts = allContracts.where((c) => c.contractType == 'لاحق التخصص' && !c.isCompleted).toList();

    for (var contract in unallocatedContracts) {
      final clientIdx = allClients.indexWhere((c) => c.id == contract.clientId);
      if (clientIdx == -1) continue; 
      final client = allClients[clientIdx];

      final ledger = await _erpRepository.getContractLedger(contract.id);
      double accumulatedMeters = ledger.fold(0, (sum, item) => sum + item.convertedMeters);

      final DateTime startDate = contract.contractDate;
      int monthsPassed = DateTime.now().difference(startDate).inDays ~/ 30;
      if (monthsPassed < 1) monthsPassed = 1; 

      double averageMetersPerMonth = accumulatedMeters / monthsPassed;

      int estimatedMonthsLeft = 999; 
      if (averageMetersPerMonth > 0) {
        double metersLeft = targetAllocationMeters - accumulatedMeters;
        if (metersLeft < 0) metersLeft = 0;
        estimatedMonthsLeft = (metersLeft / averageMetersPerMonth).ceil();
      }

      // 🌟 فحص ذاكرة الإجراءات (هل تم اتخاذ إجراء في آخر 30 يوماً؟)
      bool hasRecentAction = false;
      if (contract.lastActionDate != null) {
        final daysSinceAction = DateTime.now().difference(contract.lastActionDate!).inDays;
        if (daysSinceAction < 30) {
          hasRecentAction = true;
        }
      }

      // 🌟 تحديد الخطورة (إذا كان هناك إجراء قريب، نجعله action_taken لنسكته)
      String urgency = 'low';
      if (hasRecentAction) {
        urgency = 'action_taken'; // حالة جديدة للمسكتين
      } else if (accumulatedMeters >= targetAllocationMeters || estimatedMonthsLeft <= 2) {
        urgency = 'high'; 
      } else if (estimatedMonthsLeft <= 6) {
        urgency = 'medium'; 
      }

      radarList.add(
        AllocationAlertData(
          contract: contract,
          client: client,
          accumulatedMeters: accumulatedMeters,
          averageMetersPerMonth: averageMetersPerMonth,
          estimatedMonthsLeft: estimatedMonthsLeft,
          urgencyLevel: urgency,
          lastActionDate: contract.lastActionDate, // 🌟
          lastActionNote: contract.lastActionNote, // 🌟
        )
      );
    }

    // 🌟 الترتيب الذكي: نرمي العقود "المسكتة" إلى أسفل القائمة دائماً، ونرتب الباقي حسب الخطر!
    radarList.sort((a, b) {
      if (a.urgencyLevel == 'action_taken' && b.urgencyLevel != 'action_taken') return 1;
      if (b.urgencyLevel == 'action_taken' && a.urgencyLevel != 'action_taken') return -1;
      return a.estimatedMonthsLeft.compareTo(b.estimatedMonthsLeft);
    });

    return radarList;
  }

  // ==========================================
  // 🎯 دالة اتخاذ الإجراء الإداري
  // ==========================================
  Future<void> markContractActionTaken(String contractId, String note) async {
    try {
      await _erpRepository.markContractActionTaken(contractId: contractId, note: note);
      await fetchInitialData(); // إعادة تشغيل الرادار ليرميه في الأسفل!
    } catch (e) {
      emit(state.copyWith(status: ScheduleStatus.failure, errorMessage: 'فشل حفظ الإجراء: $e'));
    }
  }

  Future<void> selectContract(String contractId) async {
    emit(state.copyWith(selectedContractId: contractId));
    try {
      final scheduleList = await _erpRepository.getContractSchedule(contractId);
      emit(state.copyWith(status: ScheduleStatus.success, scheduleList: scheduleList));
    } catch (e) {
      emit(state.copyWith(status: ScheduleStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> markAsPaid(String scheduleId, String contractId) async {
    try {
      await _erpRepository.updateScheduleStatus(scheduleId, 'paid');
      await selectContract(contractId);
    } catch (e) {
      emit(state.copyWith(status: ScheduleStatus.failure, errorMessage: e.toString()));
    }
  }

  // ==========================================
  // ⚙️ دالة تعديل تاريخ توقيع العقد فقط
  // ==========================================
  Future<void> updateContractDateOnly({
    required String id,
    required DateTime contractDate,
  }) async {
    try {
      // نرسل التاريخ فقط ليتم تحديثه في المستودع
      await _erpRepository.updateContractDateOnly(id: id, contractDate: contractDate);
      await fetchInitialData();
      await selectContract(id);
    } catch (e) {
      emit(state.copyWith(status: ScheduleStatus.failure, errorMessage: 'فشل تعديل التاريخ: $e'));
    }
  }

  // ==========================================
  // 🔄 دالة إعادة الجدولة الذكية (Smart Restructuring)
  // ==========================================
  Future<void> restructureSchedule({
    required String contractId,
    required int newRemainingMonths,
    required DateTime newStartDate,
  }) async {
    try {
      // 1. استدعاء العملية الجراحية من المستودع
      await _erpRepository.restructureContractSchedule(
        contractId: contractId,
        newRemainingMonths: newRemainingMonths,
        newStartDate: newStartDate,
      );

      // 2. تحديث الإحصائيات والرادارات لأن مدة العقد الإجمالية تغيرت
      await fetchInitialData();

      // 3. تحديث جدول الأقساط المعروض حالياً لتظهر الأقساط الجديدة فوراً
      await selectContract(contractId);

    } catch (e) {
      emit(state.copyWith(status: ScheduleStatus.failure, errorMessage: 'فشل إعادة الجدولة: $e'));
    }
  }

  // ==========================================
  // ✏️ تعديل تاريخ قسط فردي وإضافة ملاحظة أو تعديل مبلغ موسمي
  // ==========================================
  Future<void> updateIndividualSchedule({
    required String scheduleId,
    required String contractId,
    required DateTime newDueDate,
    String? notes,
    double? expectedAmount, // 🌟 [السطر الجديد]: استقبال المبلغ
  }) async {
    try {
      await _erpRepository.updateIndividualSchedule(
        scheduleId: scheduleId,
        newDueDate: newDueDate,
        notes: notes,
        expectedAmount: expectedAmount, // 🌟 تمريره للمستودع
      );
      
      // تحديث الجدول وإعادة حساب الرادارات 
      await fetchInitialData();
      await selectContract(contractId);

    } catch (e) {
      emit(state.copyWith(status: ScheduleStatus.failure, errorMessage: 'فشل تعديل القسط: $e'));
    }
  }

  // ==========================================
  // 🌟 إضافة دفعة موسمية / مخصصة (Seasonal Payment)
  // ==========================================
  Future<void> addCustomSeasonalSchedule({
    required String contractId,
    required DateTime dueDate,
    required String notes,
    required double expectedAmount,
  }) async {
    emit(state.copyWith(status: ScheduleStatus.loading));
    try {
      // 1. جلب الأقساط الحالية لمعرفة أعلى رقم قسط موجود
      final currentSchedules = await _erpRepository.getContractSchedule(contractId);
      int maxNumber = 0;
      for (var s in currentSchedules) {
        if (s.installmentNumber > maxNumber) {
          maxNumber = s.installmentNumber;
        }
      }

      // 2. تجهيز كائن الدفعة الجديدة
      // نعطيها رقماً أعلى من البقية (لكي لا تتضارب محاسبياً)، 
      // لكن في الواجهة سنرتب العرض حسب التاريخ (dueDate) فتظهر في مكانها الصحيح!
      final companion = InstallmentsScheduleCompanion.insert(
        contractId: contractId,
        installmentNumber: maxNumber + 1,
        dueDate: dueDate.toUtc(),
        status: const Value('pending'),
        notes: Value(notes),
        expectedAmount: Value(expectedAmount), // 🌟 هنا يتم حفظ المبلغ المميز
      );

      // 3. إرسال أمر الحفظ للمستودع
      await _erpRepository.addCustomSchedule(companion);

      // 4. تحديث الواجهة والبيانات
      await fetchInitialData();
      await selectContract(contractId);

    } catch (e) {
      emit(state.copyWith(status: ScheduleStatus.failure, errorMessage: 'فشل إضافة الدفعة الموسمية: $e'));
    }
  }

  // ==========================================
  // 🌟 محرك النقاط المتدحرجة (عقود لاحق التخصص)
  // ==========================================
  Future<void> handleRollingCheckpoint({
    required String contractId,
    required String scheduleId,
    required String actionType,
    required DateTime nextDueDate,
  }) async {
    try {
      await _erpRepository.handleRollingCheckpoint(
        contractId: contractId,
        scheduleId: scheduleId,
        actionType: actionType,
        nextDueDate: nextDueDate,
      );
      
      // تحديث واجهات المراقبة (الرادار والجدول)
      await fetchInitialData();
      await selectContract(contractId);
      
    } catch (e) {
      emit(state.copyWith(status: ScheduleStatus.failure, errorMessage: 'فشل العملية: $e'));
    }
  }
}