//lib\admin\cubit\admin_cubit.dart
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart'; // لجلب أنواع LocalUser و AppRole

part 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  AdminCubit(this._erpRepository) : super(const AdminState());

  final ErpRepository _erpRepository;

  // 🌟 جلب كل المستخدمين والأدوار من الداتابيز
  Future<void> loadAdminData() async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      final users = await _erpRepository.getAllUsers();
      final roles = await _erpRepository.getAllRoles();
      emit(state.copyWith(status: AdminStatus.success, users: users, roles: roles));
    } catch (e) {
      emit(state.copyWith(status: AdminStatus.failure, errorMessage: e.toString()));
    }
  }

  // 🌟 إنشاء قالب دور جديد
  Future<void> createNewRole(String roleName, List<String> selectedPermissions) async {
    try {
      final jsonPerms = jsonEncode(selectedPermissions);
      await _erpRepository.createRole(name: roleName, permissionsJson: jsonPerms);
      await loadAdminData(); // تحديث القائمة بعد الإضافة
    } catch (e) {
      emit(state.copyWith(status: AdminStatus.failure, errorMessage: e.toString()));
    }
  }

  // 🌟 تحديث صلاحيات قالب موجود
  Future<void> updateRole(String roleId, List<String> selectedPermissions) async {
    try {
      final jsonPerms = jsonEncode(selectedPermissions);
      await _erpRepository.updateRolePermissions(roleId: roleId, permissionsJson: jsonPerms);
      await loadAdminData();
    } catch (e) {
      emit(state.copyWith(status: AdminStatus.failure, errorMessage: e.toString()));
    }
  }

  // 🌟 تعيين دور للمستخدم أو إيقاف حسابه
  Future<void> updateUser(String userId, String? roleId, bool isActive) async {
    try {
      await _erpRepository.updateUserRoleAndPermissions(
        userId: userId, 
        roleId: roleId ?? '', 
        isActive: isActive,
      );
      await loadAdminData();
    } catch (e) {
      emit(state.copyWith(status: AdminStatus.failure, errorMessage: e.toString()));
    }
  }
}