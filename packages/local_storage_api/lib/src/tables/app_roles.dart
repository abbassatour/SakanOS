// packages/local_storage_api/lib/src/tables/app_roles.dart
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

@TableIndex(name: 'idx_roles_sync', columns: {#isDeleted, #updatedAt})
class AppRoles extends Table {
  TextColumn get id => text().clientDefault(() => Uuid().v7())();

  TextColumn get name => text()();
  TextColumn get permissionsJson => text().withDefault(const Constant('[]'))();
  BoolColumn get isSystemRole => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
