import 'package:drift/drift.dart';

/// Execution statistics and logs for batches.
class BatchLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get batchId => text()();
  TextColumn get level => text()(); // info, warn, error
  TextColumn get message => text()();
  TextColumn get details => text().nullable()();
  IntColumn get totalInputTokens =>
      integer().withDefault(const Constant(0))();
  IntColumn get totalOutputTokens =>
      integer().withDefault(const Constant(0))();
  RealColumn get totalCost =>
      real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}
