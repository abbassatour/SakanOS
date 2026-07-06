// packages/erp_repository/lib/src/repositories/schedules_repository.dart
// ignore_for_file: depend_on_referenced_packages

import 'package:drift/drift.dart' as drift;
import 'package:local_storage_api/local_storage_api.dart';

import 'sync_repository.dart';

class SchedulesRepository {
  const SchedulesRepository({
    required LocalStorageApi localApi,
    required SyncRepository syncRepo,
    required String? Function() getCurrentUserId,
  }) : _localApi = localApi,
       _syncRepo = syncRepo,
       _getCurrentUserId = getCurrentUserId;

  final LocalStorageApi _localApi;
  final SyncRepository _syncRepo;
  final String? Function() _getCurrentUserId;

  Future<List<InstallmentsScheduleData>> getContractSchedule(
    String contractId,
  ) => _localApi.getContractSchedule(contractId);

  Future<List<InstallmentsScheduleData>> getAllOverdueSchedules() =>
      _localApi.getAllOverdueSchedules();

  Future<void> handleRollingCheckpoint({
    required String contractId,
    required String scheduleId,
    required String actionType,
    required DateTime nextDueDate,
  }) async {
    final userId = _getCurrentUserId();
    if (userId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    await _localApi.handleRollingCheckpoint(
      contractId,
      scheduleId,
      actionType,
      nextDueDate,
      userId,
    );
    await _syncRepo.syncPendingData();
  }

  Future<void> updateIndividualSchedule({
    required String scheduleId,
    required DateTime newDueDate,
    String? notes,
    double? expectedAmount,
  }) async {
    final userId = _getCurrentUserId();
    if (userId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    await _localApi.updateIndividualSchedule(
      id: scheduleId,
      newDueDate: newDueDate,
      notes: notes,
      expectedAmount: expectedAmount,
      userId: userId,
    );
    await _syncRepo.syncPendingData();
  }

  Future<void> updateScheduleStatus(String scheduleId, String status) async {
    final userId = _getCurrentUserId();
    if (userId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    await _localApi.updateScheduleStatus(scheduleId, status, userId);
    await _syncRepo.syncPendingData();
  }

  // 🌟 هنا السحر: الواجهة ترسل بيانات عادية، والمستودع يصنع הـ Companion
  Future<void> addCustomSchedule({
    required String contractId,
    required DateTime dueDate,
    required String notes,
    required double expectedAmount,
  }) async {
    final userId = _getCurrentUserId();
    if (userId == null) throw Exception('يجب تسجيل الدخول أولاً.');

    // 1. جلب الأقساط لمعرفة أعلى رقم قسط
    final currentSchedules = await _localApi.getContractSchedule(contractId);
    int maxNumber = 0;
    for (final s in currentSchedules) {
      if (s.installmentNumber > maxNumber) {
        maxNumber = s.installmentNumber;
      }
    }

    // 2. بناء הـ Companion
    final companion = InstallmentsScheduleCompanion.insert(
      contractId: contractId,
      installmentNumber: maxNumber + 1,
      dueDate: dueDate.toUtc(),
      status: const drift.Value('pending'),
      notes: drift.Value(notes),
      expectedAmount: drift.Value(expectedAmount),
      userId: userId, // 🌟 لا حاجة لكلمة 'temp' بعد الآن!
    );

    await _localApi.addCustomSchedule(companion);
    await _syncRepo.syncPendingData();
  }
}
