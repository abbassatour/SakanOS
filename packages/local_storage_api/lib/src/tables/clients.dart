// packages/local_storage_api/lib/src/tables/clients.dart
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';


@TableIndex(name: 'idx_clients_sync', columns: {#isDeleted, #updatedAt})
class Clients extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v7())();
  TextColumn get name => text().withLength(min: 2, max: 100)();
  TextColumn get phone => text()(); 
  TextColumn get nationalId => text().nullable()(); 
  TextColumn get userId => text()(); 
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now().toUtc())();
  DateTimeColumn get updatedAt => dateTime().clientDefault(() => DateTime.now().toUtc())();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}