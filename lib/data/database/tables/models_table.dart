import 'package:drift/drift.dart';

/// User overrides for registry models.
class Models extends Table {
  TextColumn get modelId => text()();
  TextColumn get overrideJson => text()(); // JSON string with override fields
  BoolColumn get isUserAdded =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {modelId};
}
