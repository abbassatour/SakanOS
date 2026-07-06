// packages/local_storage_api/lib/src/tables/legal_action_attachments.dart
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'legal_actions.dart';

@TableIndex(
  name: 'idx_attachments_sync',
  columns: {#isDeleted, #updatedAt, #legalActionId},
)
class LegalActionAttachments extends Table {
  TextColumn get id => text().clientDefault(() => Uuid().v7())();

  TextColumn get legalActionId => text().references(LegalActions, #id)();
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
