// packages/local_storage_api/lib/src/tables/legal_actions.dart
import 'package:drift/drift.dart';
import '../secure_time.dart';
import 'package:uuid/uuid.dart';
import 'contracts.dart';

@TableIndex(
  name: 'idx_legal_actions_sync',
  columns: {#isDeleted, #updatedAt, #contractId},
)
class LegalActions extends Table {
  TextColumn get id => text().clientDefault(() => Uuid().v7())();

  TextColumn get contractId => text().references(Contracts, #id)();
  TextColumn get actionType => text()();
  DateTimeColumn get actionDate => dateTime()();
  TextColumn get notes => text().nullable()();
  TextColumn get userId => text()();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => SecureTime.now())();
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => SecureTime.now())();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
