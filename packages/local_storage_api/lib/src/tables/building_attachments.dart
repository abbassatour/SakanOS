// packages/local_storage_api/lib/src/tables/building_attachments.dart
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'buildings.dart';

@TableIndex(
  name: 'idx_building_attachments_sync',
  columns: {#isDeleted, #updatedAt, #buildingId},
)
class BuildingAttachments extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v7())();

  TextColumn get buildingId => text().references(Buildings, #id)();
  TextColumn get fileUrl => text()();
  TextColumn get fileName => text().nullable()();
  TextColumn get fileType => text().nullable()();
  TextColumn get userId => text()();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateTime.now().toUtc())();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
