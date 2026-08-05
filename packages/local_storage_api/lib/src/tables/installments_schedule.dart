// packages/local_storage_api/lib/src/tables/installments_schedule.dart
import 'package:drift/drift.dart';
import '../secure_time.dart';
import 'package:uuid/uuid.dart';
import 'contracts.dart';

@TableIndex(
  name: 'idx_schedules_sync',
  columns: {#isDeleted, #updatedAt, #contractId},
)
class InstallmentsSchedule extends Table {
  TextColumn get id => text().clientDefault(() => Uuid().v7())();

  TextColumn get contractId => text().references(Contracts, #id)();
  IntColumn get installmentNumber => integer()();
  DateTimeColumn get dueDate => dateTime()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  TextColumn get notes => text().nullable()();
  RealColumn get expectedAmount => real().nullable()();
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
