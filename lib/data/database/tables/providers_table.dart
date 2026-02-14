import 'package:drift/drift.dart';

/// API provider configurations with encrypted API keys.
class Providers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()(); // openai, anthropic, google, openrouter, ollama, lmstudio
  TextColumn get baseUrl => text()();
  BlobColumn get encryptedApiKey => blob().nullable()();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
