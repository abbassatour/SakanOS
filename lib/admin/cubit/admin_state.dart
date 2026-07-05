//lib\admin\cubit\admin_state.dart
part of 'admin_cubit.dart';

enum AdminStatus { initial, loading, success, failure }

class AdminState extends Equatable {
  const AdminState({
    this.status = AdminStatus.initial,
    this.users = const [],
    this.roles = const [],
    this.errorMessage,
  });

  final AdminStatus status;
  final List<LocalUser> users;
  final List<AppRole> roles;
  final String? errorMessage;

  // 🌟 فلتر 1: الطلبات المعلقة (المستخدم ليس لديه دور، أو حسابه غير مفعل)
  List<LocalUser> get pendingUsers =>
      users.where((u) => u.roleId == null || u.roleId!.isEmpty || !u.isActive).toList();

  // 🌟 فلتر 2: الموظفون النشطون (لديهم دور وحسابهم مفعل)
  List<LocalUser> get activeUsers =>
      users.where((u) => u.roleId != null && u.roleId!.isNotEmpty && u.isActive).toList();

  AdminState copyWith({
    AdminStatus? status,
    List<LocalUser>? users,
    List<AppRole>? roles,
    String? errorMessage,
  }) {
    return AdminState(
      status: status ?? this.status,
      users: users ?? this.users,
      roles: roles ?? this.roles,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, users, roles, errorMessage];
}