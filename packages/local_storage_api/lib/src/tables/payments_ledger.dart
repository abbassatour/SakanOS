// packages/local_storage_api/lib/src/tables/payments_ledger.dart
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'contracts.dart';
import 'installments_schedule.dart';


@TableIndex(name: 'idx_payments_sync', columns: {#isDeleted, #updatedAt, #contractId})
class PaymentsLedger extends Table {
  TextColumn get id => text().clientDefault(() =>Uuid().v7())();
  TextColumn get contractId => text().references(Contracts, #id)(); 
  TextColumn get scheduleId => text().nullable().references(InstallmentsSchedule, #id)();
  DateTimeColumn get paymentDate => dateTime()(); 
  RealColumn get amountPaid => real()(); 
  RealColumn get meterPriceAtPayment => real()(); 
  RealColumn get convertedMeters => real()(); 
  TextColumn get pricesSnapshot => text().withDefault(const Constant('{}'))(); 
  RealColumn get fees => real().withDefault(const Constant(0))(); 
  BoolColumn get isWhatsAppSent => boolean().withDefault(const Constant(false))();
  TextColumn get userId => text()();
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now().toUtc())();
  DateTimeColumn get updatedAt => dateTime().clientDefault(() => DateTime.now().toUtc())();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))(); 

  @override
  Set<Column> get primaryKey => {id};
}