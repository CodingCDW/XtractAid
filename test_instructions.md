# Testanweisung für Junior Developer

> **Projekt:** XtractAid Flutter
> **Ziel:** ~56 neue Unit-Tests in 7 Schritten
> **Reihenfolge:** aufsteigende Schwierigkeit – starte mit Schritt 1

---

## Vorbereitung

Bevor du loslegst:

```bash
# Alle bestehenden Tests müssen grün sein
flutter test

# Mach dich mit dem Teststil vertraut – lies diese Dateien:
#   test/services/encryption_service_test.dart    (einfaches Muster: setUp + group + test)
#   test/services/llm_api_service_test.dart       (Dio-Interceptor-Muster für HTTP-Tests)
#   test/test_helpers/test_harness.dart            (createTestDatabase, buildTestApp)
```

**Konventionen im Projekt:**
- Keine externen Mock-Libraries – eigene Interceptoren / In-Memory-DB
- `group()` für Klasse/Methode, `test()` für einzelnen Fall
- `setUp()` / `addTearDown()` für Lifecycle
- Testdateien spiegeln `lib/`-Struktur: `lib/services/foo.dart` → `test/services/foo_test.dart`

---

## Schritt 1: LLM API Service Tests erweitern (leicht)

**Datei:** `test/services/llm_api_service_test.dart` (bestehend – erweitern)
**Quellcode:** `lib/services/llm_api_service.dart`

Die Datei hat bereits den `_OllamaPathInterceptor`. Füge am Ende von `main()` diese neuen Gruppen hinzu:

### 1a. Gruppe `Ollama URL normalization`

Ziel: `_normalizeOllamaBaseUrl()` wird beim `callLlm`-Aufruf intern aufgerufen. Wir testen indirekt, indem wir verschiedene URLs übergeben und prüfen, welche Pfade der Interceptor sieht.

```dart
group('Ollama URL normalization', () {
  // Für jeden Testfall: erstelle einen _OllamaPathInterceptor mit chatStatusCode: 200,
  // rufe callLlm() mit der jeweiligen baseUrl auf,
  // und prüfe dass interceptor.paths[0] den normalisierten Pfad enthält.

  test('strips /api/chat suffix', () async {
    final interceptor = _OllamaPathInterceptor(chatStatusCode: 200);
    final dio = Dio()..interceptors.add(interceptor);
    final service = LlmApiService(dio: dio);

    await service.callLlm(
      providerType: 'ollama',
      baseUrl: 'http://myhost:11434/api/chat',
      modelId: 'llama3',
      messages: [const ChatMessage(role: 'user', content: 'hi')],
    );

    // Nach Normalisierung sollte der Pfad http://myhost:11434/api/chat sein
    // (d.h. der Suffix wurde entfernt und /api/chat neu angehängt)
    expect(interceptor.paths.first, contains('http://myhost:11434/api/chat'));
  });

  // Weitere Testfälle:
  // - baseUrl: 'http://host:11434/api/generate' → normalisiert auf host:11434
  // - baseUrl: 'http://host:11434/api' → normalisiert auf host:11434
  // - baseUrl: 'http://host:11434/v1/api/chat' → normalisiert auf host:11434
  // - baseUrl: 'http://host:11434///' → trailing slashes entfernt
  // - baseUrl: '' → Fallback auf http://localhost:11434
  // - baseUrl: 'http://host:11434' → bleibt unverändert
});
```

### 1b. Gruppe `Ollama missing model error patterns`

Ziel: Verschiedene Fehlertexte testen, die Ollama bei fehlenden Modellen zurückgibt.

```dart
group('Ollama missing model error patterns', () {
  // Pro Testfall: _OllamaPathInterceptor mit chatStatusCode: 404 und
  // verschiedenen chatErrorPayload-Werten erstellen.
  // Erwartung: Exception wird geworfen mit dem Modellnamen in der Message.

  test('detects model with double quotes', () async {
    final interceptor = _OllamaPathInterceptor(
      chatStatusCode: 404,
      chatErrorPayload: {'error': 'model "llama3:latest" not found'},
    );
    // ... callLlm → expectLater throwsA contains 'llama3:latest'
  });

  test('detects model with single quotes', () async {
    // chatErrorPayload: {'error': "model 'mistral' not found"}
  });

  test('detects model without quotes', () async {
    // chatErrorPayload: {'error': 'model gemma2 not found'}
  });

  test('falls back to generate when error has no model-not-found pattern', () async {
    // chatErrorPayload: {'error': 'connection refused'}
    // → Kein Modell-Match → Fallback auf /api/generate → Erfolg
  });
});
```

### 1c. Gruppe `Ollama chat/generate fallback (extended)`

```dart
group('Ollama chat/generate fallback (extended)', () {
  test('uses chat endpoint directly when it returns 200', () async {
    final interceptor = _OllamaPathInterceptor(chatStatusCode: 200);
    final dio = Dio()..interceptors.add(interceptor);
    final service = LlmApiService(dio: dio);

    final response = await service.callLlm(
      providerType: 'ollama',
      baseUrl: 'http://fake:11434',
      modelId: 'llama3',
      messages: [const ChatMessage(role: 'user', content: 'hi')],
    );

    expect(response.content, 'chat ok');
    // Nur /api/chat sollte aufgerufen worden sein, NICHT /api/generate
    expect(interceptor.paths.length, 1);
    expect(interceptor.paths.first, contains('/api/chat'));
  });

  test('does NOT fall back on 500 error (only 404 triggers fallback)', () async {
    // chatStatusCode: 500 → DioException wird geworfen, kein Fallback
    // expectLater → throwsA
  });
});
```

**Verifikation:**
```bash
flutter test test/services/llm_api_service_test.dart
```

---

## Schritt 2: WorkerMessageCodec Tests (leicht)

**Datei:** `test/workers/worker_messages_test.dart` (neu erstellen)
**Quellcode:** `lib/workers/worker_messages.dart`

Reine Serialisierungstests ohne externe Dependencies.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:xtractaid/data/models/batch_config.dart';
import 'package:xtractaid/data/models/batch_stats.dart';
import 'package:xtractaid/data/models/item.dart';
import 'package:xtractaid/data/models/log_entry.dart';
import 'package:xtractaid/workers/worker_messages.dart';

void main() {
  group('WorkerMessageCodec', () {
    group('ProgressEvent', () {
      test('encode includes stats when provided', () {
        final event = ProgressEvent(
          const BatchProgress(callCounter: 5, progressPercent: 0.5),
          stats: const BatchStats(totalApiCalls: 10, completedApiCalls: 5),
        );
        final json = WorkerMessageCodec.encodeEvent(event);

        expect(json['type'], 'progress');
        expect(json.containsKey('stats'), true);
        expect(json['stats']['totalApiCalls'], 10);
      });

      test('encode omits stats when null', () {
        final event = ProgressEvent(
          const BatchProgress(callCounter: 1),
        );
        final json = WorkerMessageCodec.encodeEvent(event);

        expect(json['type'], 'progress');
        expect(json.containsKey('stats'), false);
      });

      test('decode with stats populates stats field', () {
        final json = {
          'type': 'progress',
          'progress': const BatchProgress(callCounter: 3).toJson(),
          'stats': const BatchStats(totalApiCalls: 6, completedApiCalls: 3).toJson(),
        };
        final event = WorkerMessageCodec.decodeEvent(json);

        expect(event, isA<ProgressEvent>());
        final progress = event as ProgressEvent;
        expect(progress.stats, isNotNull);
        expect(progress.stats!.totalApiCalls, 6);
      });

      test('decode without stats returns null stats', () {
        final json = {
          'type': 'progress',
          'progress': const BatchProgress(callCounter: 1).toJson(),
        };
        final event = WorkerMessageCodec.decodeEvent(json) as ProgressEvent;

        expect(event.stats, isNull);
      });

      test('roundtrip preserves all fields', () {
        final original = ProgressEvent(
          const BatchProgress(
            callCounter: 7,
            progressPercent: 0.7,
            currentModelId: 'gpt-4o',
          ),
          stats: BatchStats(
            totalApiCalls: 10,
            completedApiCalls: 7,
            totalInputTokens: 500,
            totalOutputTokens: 200,
            totalCost: 0.05,
            startedAt: DateTime(2025, 1, 1),
          ),
        );

        final json = WorkerMessageCodec.encodeEvent(original);
        final decoded = WorkerMessageCodec.decodeEvent(json) as ProgressEvent;

        expect(decoded.progress.callCounter, 7);
        expect(decoded.progress.currentModelId, 'gpt-4o');
        expect(decoded.stats!.totalApiCalls, 10);
        expect(decoded.stats!.totalCost, 0.05);
      });
    });

    group('BatchCompletedEvent', () {
      test('roundtrip with stats and results', () {
        final original = BatchCompletedEvent(
          stats: const BatchStats(totalApiCalls: 5, completedApiCalls: 5),
          results: [
            {'id': '1', 'output': 'result1'},
            {'id': '2', 'output': 'result2'},
          ],
        );

        final json = WorkerMessageCodec.encodeEvent(original);
        final decoded = WorkerMessageCodec.decodeEvent(json) as BatchCompletedEvent;

        expect(decoded.stats.completedApiCalls, 5);
        expect(decoded.results.length, 2);
        expect(decoded.results[0]['id'], '1');
      });
    });

    group('BatchErrorEvent', () {
      test('roundtrip with message and details', () {
        final original = BatchErrorEvent(
          message: 'Something failed',
          details: 'Stack trace here',
        );

        final json = WorkerMessageCodec.encodeEvent(original);
        final decoded = WorkerMessageCodec.decodeEvent(json) as BatchErrorEvent;

        expect(decoded.message, 'Something failed');
        expect(decoded.details, 'Stack trace here');
      });

      test('roundtrip with null details', () {
        final original = BatchErrorEvent(message: 'Error occurred');

        final json = WorkerMessageCodec.encodeEvent(original);
        final decoded = WorkerMessageCodec.decodeEvent(json) as BatchErrorEvent;

        expect(decoded.message, 'Error occurred');
        expect(decoded.details, isNull);
      });
    });

    group('Command encode/decode', () {
      test('PauseBatchCommand roundtrip', () {
        final json = WorkerMessageCodec.encodeCommand(PauseBatchCommand());
        final decoded = WorkerMessageCodec.decodeCommand(json);

        expect(decoded, isA<PauseBatchCommand>());
      });

      test('ResumeBatchCommand roundtrip', () {
        final json = WorkerMessageCodec.encodeCommand(ResumeBatchCommand());
        final decoded = WorkerMessageCodec.decodeCommand(json);

        expect(decoded, isA<ResumeBatchCommand>());
      });

      test('returns null for invalid payload', () {
        expect(WorkerMessageCodec.decodeCommand('not a map'), isNull);
        expect(WorkerMessageCodec.decodeCommand({'no_type': true}), isNull);
        expect(WorkerMessageCodec.decodeCommand({'type': 'unknown'}), isNull);
      });

      test('returns null for invalid event payload', () {
        expect(WorkerMessageCodec.decodeEvent('not a map'), isNull);
        expect(WorkerMessageCodec.decodeEvent({'no_type': true}), isNull);
        expect(WorkerMessageCodec.decodeEvent({'type': 'unknown'}), isNull);
      });
    });
  });
}
```

**Verifikation:**
```bash
flutter test test/workers/worker_messages_test.dart
```

---

## Schritt 3: BatchesDao Tests (mittel)

**Datei:** `test/data/database/daos/batches_dao_test.dart` (neu erstellen)
**Quellcode:** `lib/data/database/daos/batches_dao.dart`
**Infrastruktur:** `test/test_helpers/test_harness.dart` (nutze `createTestDatabase()`)

```dart
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xtractaid/data/database/app_database.dart';

import '../../test_helpers/test_harness.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = createTestDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  /// Hilfs-Funktion: Batch mit gegebenem Status einfügen
  Future<void> insertTestBatch(String id, String status) async {
    await db.batchesDao.insertBatch(
      BatchesCompanion(
        id: Value(id),
        projectId: const Value('proj-1'),
        name: Value('Batch $id'),
        configJson: const Value('{}'),
        status: Value(status),
      ),
    );
  }

  group('BatchesDao', () {
    group('recoverStaleRunningBatches', () {
      test('changes running batch to failed', () async {
        await insertTestBatch('b1', 'running');

        final count = await db.batchesDao.recoverStaleRunningBatches();
        expect(count, 1);

        final batch = await db.batchesDao.getById('b1');
        expect(batch!.status, 'failed');
        expect(batch.completedAt, isNotNull);
      });

      test('does not change completed batch', () async {
        await insertTestBatch('b1', 'completed');

        final count = await db.batchesDao.recoverStaleRunningBatches();
        expect(count, 0);

        final batch = await db.batchesDao.getById('b1');
        expect(batch!.status, 'completed');
      });

      test('does not change failed batch', () async {
        await insertTestBatch('b1', 'failed');

        final count = await db.batchesDao.recoverStaleRunningBatches();
        expect(count, 0);

        final batch = await db.batchesDao.getById('b1');
        expect(batch!.status, 'failed');
      });

      test('does not change created batch', () async {
        await insertTestBatch('b1', 'created');

        final count = await db.batchesDao.recoverStaleRunningBatches();
        expect(count, 0);

        final batch = await db.batchesDao.getById('b1');
        expect(batch!.status, 'created');
      });

      test('recovers multiple running batches', () async {
        await insertTestBatch('b1', 'running');
        await insertTestBatch('b2', 'running');
        await insertTestBatch('b3', 'completed');

        final count = await db.batchesDao.recoverStaleRunningBatches();
        expect(count, 2);

        final b1 = await db.batchesDao.getById('b1');
        final b2 = await db.batchesDao.getById('b2');
        final b3 = await db.batchesDao.getById('b3');

        expect(b1!.status, 'failed');
        expect(b2!.status, 'failed');
        expect(b3!.status, 'completed');
      });

      test('returns 0 when no running batches exist', () async {
        await insertTestBatch('b1', 'completed');
        await insertTestBatch('b2', 'failed');

        final count = await db.batchesDao.recoverStaleRunningBatches();
        expect(count, 0);
      });
    });
  });
}
```

**Verifikation:**
```bash
flutter test test/data/database/daos/batches_dao_test.dart
```

---

## Schritt 4: ProjectFileService Tests (mittel)

**Datei:** `test/services/project_file_service_test.dart` (neu erstellen)
**Quellcode:** `lib/services/project_file_service.dart`

```dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:xtractaid/services/project_file_service.dart';

void main() {
  late ProjectFileService service;
  late Directory tempDir;

  setUp(() {
    service = ProjectFileService();
    tempDir = Directory.systemTemp.createTempSync('xtractaid_test_');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('ProjectFileService', () {
    group('deleteProjectFolder', () {
      test('deletes existing folder recursively', () async {
        // Erstelle einen Unterordner mit einer Datei
        final subDir = Directory('${tempDir.path}/sub');
        subDir.createSync();
        File('${subDir.path}/file.txt').writeAsStringSync('data');

        await service.deleteProjectFolder(tempDir.path);

        expect(tempDir.existsSync(), false);
      });

      test('does not throw for non-existent path', () async {
        // Sollte stillschweigend zurückkehren
        await service.deleteProjectFolder('${tempDir.path}/does_not_exist');
        // Kein Fehler = Erfolg
      });

      test('deletes folder with nested structure', () async {
        // Erstelle verschachtelte Struktur
        Directory('${tempDir.path}/a/b/c').createSync(recursive: true);
        File('${tempDir.path}/a/b/c/deep.txt').writeAsStringSync('deep');
        File('${tempDir.path}/root.txt').writeAsStringSync('root');

        await service.deleteProjectFolder(tempDir.path);

        expect(tempDir.existsSync(), false);
      });
    });

    group('createProject', () {
      test('creates folder with correct subdirectories', () async {
        final projectPath = '${tempDir.path}/my_project';

        await service.createProject(
          path: projectPath,
          name: 'Test Project',
          projectId: 'proj-123',
        );

        expect(Directory('$projectPath/prompts').existsSync(), true);
        expect(Directory('$projectPath/input').existsSync(), true);
        expect(Directory('$projectPath/results').existsSync(), true);
      });

      test('creates project.xtractaid.json with expected fields', () async {
        final projectPath = '${tempDir.path}/my_project';

        await service.createProject(
          path: projectPath,
          name: 'Test Project',
          projectId: 'proj-123',
        );

        final file = File('$projectPath/project.xtractaid.json');
        expect(file.existsSync(), true);

        final content = json.decode(file.readAsStringSync()) as Map<String, dynamic>;
        expect(content['id'], 'proj-123');
        expect(content['name'], 'Test Project');
        expect(content['version'], '1.0');
        expect(content.containsKey('created_at'), true);
      });
    });

    group('validateProject', () {
      test('returns JSON map for valid project', () async {
        final projectPath = '${tempDir.path}/valid_project';
        await service.createProject(
          path: projectPath,
          name: 'Valid',
          projectId: 'p1',
        );

        final result = await service.validateProject(projectPath);

        expect(result, isNotNull);
        expect(result!['id'], 'p1');
        expect(result['name'], 'Valid');
      });

      test('returns null when project file is missing', () async {
        final emptyDir = Directory('${tempDir.path}/empty');
        emptyDir.createSync();

        final result = await service.validateProject(emptyDir.path);

        expect(result, isNull);
      });

      test('returns null for invalid JSON', () async {
        final brokenDir = Directory('${tempDir.path}/broken');
        brokenDir.createSync();
        File('${brokenDir.path}/project.xtractaid.json')
            .writeAsStringSync('not valid json {{{');

        final result = await service.validateProject(brokenDir.path);

        expect(result, isNull);
      });
    });
  });
}
```

**Verifikation:**
```bash
flutter test test/services/project_file_service_test.dart
```

---

## Schritt 5: Pure Funktionen extrahieren (mittel – Refactoring)

> **Wichtig:** Dieser Schritt ändert bestehenden Code. Mach vorher ein `git stash` oder einen Branch.
> Nach jeder Extraktion: `flutter test` laufen lassen, um Regressionen zu finden.

### 5a. Datei `lib/core/utils/provider_helpers.dart` erstellen

```dart
/// Utility functions for LLM provider logic, extracted from settings_screen.dart.

/// Returns true if [type] is a local provider (no API key needed).
bool isLocalProviderType(String type) {
  return type == 'ollama' || type == 'lmstudio';
}

/// Returns a human-readable display name for a provider [type].
String providerDisplayName(String type) {
  return switch (type) {
    'openai' => 'OpenAI',
    'anthropic' => 'Anthropic',
    'google' => 'Google',
    'openrouter' => 'OpenRouter',
    'ollama' => 'Ollama',
    'lmstudio' => 'LM Studio',
    _ => type,
  };
}
```

**Dann in `lib/features/settings/settings_screen.dart`:**
1. `import 'package:xtractaid/core/utils/provider_helpers.dart';` hinzufügen
2. `_isLocalProviderType(type)` ersetzen durch `isLocalProviderType(type)`
3. `_providerDisplayName(type)` ersetzen durch `providerDisplayName(type)`
4. Die beiden privaten Methoden löschen

### 5b. Datei `lib/core/utils/batch_helpers.dart` erstellen

```dart
import 'package:xtractaid/core/l10n/generated/app_localizations.dart';
import 'package:xtractaid/providers/batch_execution_provider.dart';

/// Returns true if [status] represents a terminal batch state.
bool isTerminalBatchStatus(String? status) {
  return status == 'completed' || status == 'failed' || status == 'cancelled';
}

/// Returns a localized label for a [BatchExecutionStatus].
String batchExecutionStatusLabel(BatchExecutionStatus status, S t) {
  return switch (status) {
    BatchExecutionStatus.idle => t.execStatusIdle,
    BatchExecutionStatus.starting => t.execStatusStarting,
    BatchExecutionStatus.running => t.execStatusRunning,
    BatchExecutionStatus.paused => t.execStatusPaused,
    BatchExecutionStatus.completed => t.execStatusCompleted,
    BatchExecutionStatus.failed => t.execStatusFailed,
  };
}

/// Data class for a discovered model from a provider.
class DiscoveredModel {
  const DiscoveredModel({required this.provider, required this.id});
  final String provider;
  final String id;
}

/// Extracts model IDs from a provider API response [payload].
/// Ollama uses `models[].name`, other providers use `data[].id`.
List<DiscoveredModel> extractDiscoveredModels(
  String providerType,
  dynamic payload,
) {
  if (providerType == 'ollama') {
    if (payload is Map && payload['models'] is List) {
      final list = payload['models'] as List;
      return list
          .whereType<Map>()
          .map((m) => m['name']?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .map((id) => DiscoveredModel(provider: providerType, id: id))
          .toList();
    }
    return const [];
  }

  if (payload is Map && payload['data'] is List) {
    final list = payload['data'] as List;
    return list
        .whereType<Map>()
        .map((m) => m['id']?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .map((id) => DiscoveredModel(provider: providerType, id: id))
        .toList();
  }

  return const [];
}
```

**Dann in den Screen-Dateien:**
- `batch_wizard_screen.dart`: `_isTerminalBatchStatus()` durch `isTerminalBatchStatus()` ersetzen
- `batch_execution_screen.dart`: `_statusLabel()` durch `batchExecutionStatusLabel()` ersetzen
- `model_manager_screen.dart`: `_extractDiscoveredModels()` durch `extractDiscoveredModels()` ersetzen (und `_DiscoveredModel` durch `DiscoveredModel`)

**Verifikation nach jeder Änderung:**
```bash
flutter test
flutter analyze
```

---

## Schritt 6: Tests für extrahierte Funktionen (leicht)

### 6a. Datei `test/core/utils/provider_helpers_test.dart` (neu)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:xtractaid/core/utils/provider_helpers.dart';

void main() {
  group('isLocalProviderType', () {
    test('ollama is local', () {
      expect(isLocalProviderType('ollama'), true);
    });

    test('lmstudio is local', () {
      expect(isLocalProviderType('lmstudio'), true);
    });

    test('openai is not local', () {
      expect(isLocalProviderType('openai'), false);
    });

    test('anthropic is not local', () {
      expect(isLocalProviderType('anthropic'), false);
    });

    test('google is not local', () {
      expect(isLocalProviderType('google'), false);
    });

    test('openrouter is not local', () {
      expect(isLocalProviderType('openrouter'), false);
    });

    test('empty string is not local', () {
      expect(isLocalProviderType(''), false);
    });
  });

  group('providerDisplayName', () {
    test('maps openai to OpenAI', () {
      expect(providerDisplayName('openai'), 'OpenAI');
    });

    test('maps anthropic to Anthropic', () {
      expect(providerDisplayName('anthropic'), 'Anthropic');
    });

    test('maps google to Google', () {
      expect(providerDisplayName('google'), 'Google');
    });

    test('maps openrouter to OpenRouter', () {
      expect(providerDisplayName('openrouter'), 'OpenRouter');
    });

    test('maps ollama to Ollama', () {
      expect(providerDisplayName('ollama'), 'Ollama');
    });

    test('maps lmstudio to LM Studio', () {
      expect(providerDisplayName('lmstudio'), 'LM Studio');
    });

    test('returns unknown type as-is (fallback)', () {
      expect(providerDisplayName('custom_provider'), 'custom_provider');
    });
  });
}
```

### 6b. Datei `test/core/utils/batch_helpers_test.dart` (neu)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:xtractaid/core/utils/batch_helpers.dart';

void main() {
  group('isTerminalBatchStatus', () {
    test('completed is terminal', () {
      expect(isTerminalBatchStatus('completed'), true);
    });

    test('failed is terminal', () {
      expect(isTerminalBatchStatus('failed'), true);
    });

    test('cancelled is terminal', () {
      expect(isTerminalBatchStatus('cancelled'), true);
    });

    test('running is not terminal', () {
      expect(isTerminalBatchStatus('running'), false);
    });

    test('created is not terminal', () {
      expect(isTerminalBatchStatus('created'), false);
    });

    test('null is not terminal', () {
      expect(isTerminalBatchStatus(null), false);
    });

    test('empty string is not terminal', () {
      expect(isTerminalBatchStatus(''), false);
    });
  });

  group('extractDiscoveredModels', () {
    test('extracts Ollama models from models[].name', () {
      final payload = {
        'models': [
          {'name': 'llama3:latest', 'size': 4000000000},
          {'name': 'mistral:7b', 'size': 3000000000},
        ],
      };

      final result = extractDiscoveredModels('ollama', payload);

      expect(result.length, 2);
      expect(result[0].id, 'llama3:latest');
      expect(result[0].provider, 'ollama');
      expect(result[1].id, 'mistral:7b');
    });

    test('extracts OpenAI models from data[].id', () {
      final payload = {
        'data': [
          {'id': 'gpt-4o', 'object': 'model'},
          {'id': 'gpt-4o-mini', 'object': 'model'},
        ],
      };

      final result = extractDiscoveredModels('openai', payload);

      expect(result.length, 2);
      expect(result[0].id, 'gpt-4o');
      expect(result[0].provider, 'openai');
    });

    test('returns empty list for missing models key (Ollama)', () {
      final result = extractDiscoveredModels('ollama', {'other': []});
      expect(result, isEmpty);
    });

    test('returns empty list for missing data key (OpenAI)', () {
      final result = extractDiscoveredModels('openai', {'other': []});
      expect(result, isEmpty);
    });

    test('returns empty list for null payload', () {
      final result = extractDiscoveredModels('openai', null);
      expect(result, isEmpty);
    });

    test('skips entries with empty name (Ollama)', () {
      final payload = {
        'models': [
          {'name': 'llama3'},
          {'name': ''},
          {'name': null},
        ],
      };

      final result = extractDiscoveredModels('ollama', payload);
      expect(result.length, 1);
      expect(result[0].id, 'llama3');
    });

    test('works for lmstudio provider (uses data[].id)', () {
      final payload = {
        'data': [
          {'id': 'local-model-1'},
        ],
      };

      final result = extractDiscoveredModels('lmstudio', payload);
      expect(result.length, 1);
      expect(result[0].provider, 'lmstudio');
    });
  });

  // Hinweis: batchExecutionStatusLabel() braucht ein S-Objekt (Localization).
  // Für diesen Test brauchst du den buildTestApp()-Helper aus test_harness.dart
  // um einen Widget-Tree mit Localization aufzubauen und das S-Objekt zu erhalten.
  // Alternativ: diesen Test als Widget-Test implementieren.
  //
  // group('batchExecutionStatusLabel', () {
  //   testWidgets('returns non-empty labels for all statuses', (tester) async {
  //     await tester.pumpWidget(
  //       buildTestApp(db: createTestDatabase(), child: Builder(
  //         builder: (context) {
  //           final t = S.of(context);
  //           for (final status in BatchExecutionStatus.values) {
  //             expect(batchExecutionStatusLabel(status, t), isNotEmpty);
  //           }
  //           return const SizedBox.shrink();
  //         },
  //       )),
  //     );
  //   });
  // });
}
```

**Verifikation:**
```bash
flutter test test/core/utils/
```

---

## Schritt 7: BatchExecutionProvider Tests (fortgeschritten)

**Datei:** `test/providers/batch_execution_provider_test.dart` (neu erstellen)
**Quellcode:** `lib/providers/batch_execution_provider.dart`

### 7a. Zuerst: `_onWorkerEvent` testbar machen

In `lib/providers/batch_execution_provider.dart` eine `@visibleForTesting`-Hilfsmethode hinzufügen:

```dart
import 'package:flutter/foundation.dart'; // für @visibleForTesting

// In der Klasse BatchExecutionNotifier, nach _onWorkerEvent():
@visibleForTesting
void handleWorkerEventForTest(WorkerEvent event) => _onWorkerEvent(event);
```

### 7b. Tests schreiben

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:xtractaid/data/models/batch_stats.dart';
import 'package:xtractaid/data/models/log_entry.dart';
import 'package:xtractaid/providers/batch_execution_provider.dart';
import 'package:xtractaid/workers/worker_messages.dart';

void main() {
  late BatchExecutionNotifier notifier;

  setUp(() {
    notifier = BatchExecutionNotifier();
  });

  tearDown(() {
    notifier.dispose();
  });

  group('BatchExecutionNotifier._onWorkerEvent', () {
    test('ProgressEvent with stats updates state.stats', () {
      final stats = const BatchStats(totalApiCalls: 10, completedApiCalls: 3);
      final event = ProgressEvent(
        const BatchProgress(callCounter: 3, progressPercent: 0.3),
        stats: stats,
      );

      notifier.handleWorkerEventForTest(event);

      expect(notifier.state.status, BatchExecutionStatus.running);
      expect(notifier.state.stats, isNotNull);
      expect(notifier.state.stats!.completedApiCalls, 3);
      expect(notifier.state.progress!.callCounter, 3);
    });

    test('ProgressEvent without stats keeps existing stats', () {
      // Erst Stats setzen
      notifier.handleWorkerEventForTest(ProgressEvent(
        const BatchProgress(callCounter: 1),
        stats: const BatchStats(totalApiCalls: 10, completedApiCalls: 1),
      ));

      // Dann Event ohne Stats
      notifier.handleWorkerEventForTest(ProgressEvent(
        const BatchProgress(callCounter: 2),
      ));

      expect(notifier.state.stats, isNotNull);
      expect(notifier.state.stats!.completedApiCalls, 1); // alte Stats bleiben
      expect(notifier.state.progress!.callCounter, 2);     // Progress aktualisiert
    });

    test('ProgressEvent overwrites old stats with new stats', () {
      notifier.handleWorkerEventForTest(ProgressEvent(
        const BatchProgress(callCounter: 1),
        stats: const BatchStats(completedApiCalls: 1),
      ));

      notifier.handleWorkerEventForTest(ProgressEvent(
        const BatchProgress(callCounter: 2),
        stats: const BatchStats(completedApiCalls: 5),
      ));

      expect(notifier.state.stats!.completedApiCalls, 5);
    });

    test('LogEvent appends to logs', () {
      final entry = LogEntry(
        level: LogLevel.info,
        message: 'Test log',
        timestamp: DateTime.now(),
      );
      notifier.handleWorkerEventForTest(LogEvent(entry));

      expect(notifier.state.logs.length, 1);
      expect(notifier.state.logs.first.message, 'Test log');
    });

    test('CheckpointSavedEvent adds checkpoint log entry', () {
      notifier.handleWorkerEventForTest(CheckpointSavedEvent(42));

      expect(notifier.state.logs.length, 1);
      expect(notifier.state.logs.first.message, contains('42'));
      expect(notifier.state.logs.first.level, LogLevel.info);
    });

    test('BatchCompletedEvent sets completed status with stats and results', () {
      final results = [
        {'id': '1', 'output': 'done'},
      ];
      notifier.handleWorkerEventForTest(BatchCompletedEvent(
        stats: const BatchStats(totalApiCalls: 5, completedApiCalls: 5),
        results: results,
      ));

      expect(notifier.state.status, BatchExecutionStatus.completed);
      expect(notifier.state.stats!.completedApiCalls, 5);
      expect(notifier.state.results.length, 1);
    });

    test('BatchErrorEvent sets failed status with error message', () {
      notifier.handleWorkerEventForTest(BatchErrorEvent(
        message: 'API timeout',
        details: 'Connection refused',
      ));

      expect(notifier.state.status, BatchExecutionStatus.failed);
      expect(notifier.state.errorMessage, 'API timeout');
    });
  });
}
```

**Verifikation:**
```bash
flutter test test/providers/batch_execution_provider_test.dart
```

---

## Abschluss

Wenn alle 7 Schritte fertig sind:

```bash
# Alle Tests laufen lassen
flutter test

# Statische Analyse
flutter analyze

# Optional: Coverage-Report
flutter test --coverage
```

**Erwartetes Ergebnis:** ~56 neue Tests, alle grün, keine Analyzer-Warnings.

### Checkliste

- [ ] Schritt 1: LLM API Service Tests erweitert (~13 Tests)
- [ ] Schritt 2: WorkerMessageCodec Tests erstellt (~10 Tests)
- [ ] Schritt 3: BatchesDao Tests erstellt (~6 Tests)
- [ ] Schritt 4: ProjectFileService Tests erstellt (~8 Tests)
- [ ] Schritt 5: Pure Funktionen extrahiert (provider_helpers + batch_helpers)
- [ ] Schritt 6: Helper-Tests erstellt (~12 Tests)
- [ ] Schritt 7: BatchExecutionProvider Tests erstellt (~7 Tests)
- [ ] `flutter test` grün
- [ ] `flutter analyze` sauber
