// lib/admin/cubit/admin_cubit.dart
// ignore_for_file: depend_on_referenced_packages

import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart'
    show AppRole, LocalUser;

part 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  AdminCubit(this._erpRepository) : super(const AdminState());

  final ErpRepository _erpRepository;

  Future<void> loadAdminData() async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      final users = await _erpRepository.getAllUsers();
      final roles = await _erpRepository.getAllRoles();

      emit(
        state.copyWith(
          status: AdminStatus.success,
          users: users,
          roles: roles,
        ),
      );
    } catch (e, stackTrace) {
      log('خطأ في جلب بيانات الإدارة', error: e, stackTrace: stackTrace);
      emit(
        state.copyWith(
          status: AdminStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> createNewRole(
    String roleName,
    List<String> selectedPermissions,
  ) async {
    try {
      await _erpRepository.createRole(
        name: roleName,
        permissions: selectedPermissions,
      );
      await loadAdminData();
    } catch (e, stackTrace) {
      log('خطأ في إنشاء دور جديد', error: e, stackTrace: stackTrace);
      emit(
        state.copyWith(
          status: AdminStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> updateRole(
    String roleId,
    List<String> selectedPermissions,
  ) async {
    try {
      await _erpRepository.updateRolePermissions(
        roleId: roleId,
        permissions: selectedPermissions,
      );
      await loadAdminData();
    } catch (e, stackTrace) {
      log('خطأ في تحديث الصلاحيات', error: e, stackTrace: stackTrace);
      emit(
        state.copyWith(
          status: AdminStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> updateUser(String userId, String? roleId, bool isActive) async {
    try {
      await _erpRepository.updateUserRoleAndPermissions(
        userId: userId,
        roleId: roleId ?? '',
        isActive: isActive,
      );
      await loadAdminData();
    } catch (e, stackTrace) {
      log('خطأ في تحديث بيانات المستخدم', error: e, stackTrace: stackTrace);
      emit(
        state.copyWith(
          status: AdminStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
