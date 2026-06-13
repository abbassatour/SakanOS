// packages/local_storage_api/lib/src/tables/local_users.dart
import 'package:drift/drift.dart';
import '../secure_time.dart';
import 'app_roles.dart';

@TableIndex(name: 'idx_users_sync', columns: {#isDeleted, #updatedAt})
class LocalUsers extends Table {
  TextColumn get id => text()();
  TextColumn get fullName => text().nullable()();
  TextColumn get email => text()();
  TextColumn get roleId => text().nullable().references(AppRoles, #id)();

  // 🌟 [العمود الجديد]: رمز الأمان الخاص بالمستخدم (افتراضياً 0000)
  TextColumn get securityPin => text().withDefault(const Constant('0000'))();

  TextColumn get extraPermissionsJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get revokedPermissionsJson =>
      text().withDefault(const Constant('[]'))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => SecureTime.now())();
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => SecureTime.now())();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
