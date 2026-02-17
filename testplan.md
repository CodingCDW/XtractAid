# Testplan: Bewertung und Umsetzung der Testkandidaten

## Kontext

Die App hat aktuell 12 Testdateien mit ~91 Unit-Tests + 4 Widget-Tests. 50% der Services sind getestet, die Feature-/UI-Schicht kaum. Es gibt keine externen Mocking-Libraries (nur custom Dio-Interceptoren) und einen soliden Test-Harness (`test_helpers/test_harness.dart`) mit In-Memory-SQLite und Riverpod-Overrides.

Ziel: Die Testkandidaten aus beiden Listen bewerten (Wert x Testbarkeit), eine Empfehlung geben, und einen konkreten Umsetzungsplan erstellen.

---

## Bewertung der Kandidaten

### Empfohlen (hoher Wert, gut testbar)

| # | Kandidat | Begründung |
|---|----------|------------|
| 2.2 | `_normalizeOllamaBaseUrl()` | Viele Edge-Cases (Suffixe, Leerzeichen, leerer String). Bestehender Test deckt nur `/v1/` ab. Indirekt testbar via Interceptor. |
| 2.3 | `_extractOllamaMissingModel()` | Regex auf verschiedene Ollama-Fehlertexte. Nur 1 Test vorhanden. Indirekt testbar via Interceptor. |
| 2.1 | `_callOllama()` Fallback `/api/chat` → `/api/generate` | Bereits 1 Test. Weitere Szenarien nötig: Chat-200 (kein Fallback), anderer HTTP-Fehler (kein Fallback). |
| 2.5 | `WorkerMessageCodec` ProgressEvent encode/decode | Reine statische JSON-Funktionen. Kritische Serialisierungsgrenze (Isolate↔Main). Stats-Feld optional = Rückwärtskompatibilität. |
| 2.8 | `recoverStaleRunningBatches()` | Kritisch für App-Startup-Recovery. Pure SQL-Logik. Testbar mit In-Memory-DB aus test_harness. |
| 2.16 | `deleteProjectFolder()` | Einfacher File-I/O. Testbar mit temp-Directory. Auch `createProject`/`validateProject` gleich mittesten. |
| 2.7 | `BatchExecutionNotifier._onWorkerEvent()` | StateNotifier-Pattern perfekt für Tests. Erfordert `@visibleForTesting` auf `_onWorkerEvent` oder Hilfsmethode. |

### Empfohlen mit Extraktion (pure Logik in UI-State-Klassen gefangen)

| # | Kandidat | Begründung |
|---|----------|------------|
| 1.4 | `_isLocalProviderType()` | Trivial, aber dokumentiert Verhalten. Pure Funktion → extrahieren nach Utility-Datei. |
| 1.5 | `_providerDisplayName()` | Switch-Expression. Pure Funktion → extrahieren. |
| 1.8 | `_isTerminalBatchStatus()` | Trivial. Pure Funktion → extrahieren. |
| 1.10 | `_statusLabel()` | Switch auf Enum → extrahieren. Braucht `S` (Localization) als Parameter, ist aber bereits so designed. |
| 2.11 | `_extractDiscoveredModels()` | Pure JSON-Parsing für Ollama/OpenAI-Formate → extrahieren. |

### Nicht empfohlen (niedriger ROI)

| # | Kandidat | Begründung |
|---|----------|------------|
| 1.1 | `_saveProvider()` | Mischt DB, Encryption und UI (SnackBar). Testbar nur nach aufwändigem Refactoring. Die einzelnen Teile (DB-Insert, Encryption) sind anderswo besser testbar. |
| 1.2 | `_showProviderEditorDialog()` | Schwerer Dialog-Code. Validierungslogik könnte extrahiert werden, aber Aufwand/Nutzen gering. |
| 1.3 | `_showManageProvidersDialog()` | Komplex verschachtelter Dialog mit CRUD. Widget-Test wäre extrem aufwändig. |
| 1.6 | `_deleteProject()` | DB-Kaskade (logs→batches→project→folder). Sinnvoller: DAO-Methoden einzeln testen + `deleteProjectFolder` separat. |
| 1.7 | `_confirmDeleteProject()` | Reiner Dialog-Wrapper. Kein eigener Logik-Wert. |
| 1.9 | `_showBatchSaveModeDialog()` | Einfacher Dialog, Enum-Rückgabe. Kein testbarer Mehrwert. |
| 2.6 | Worker Isolate ProgressEvent-Sending | Isolate-Kommunikation sehr schwer zu mocken. Indirekt durch Codec-Tests + Provider-Tests abgedeckt. |
| 2.9 | Startup-Integrationstest (stale batches) | Braucht vollen App-Bootstrap. `recoverStaleRunningBatches()` als Unit-Test deckt Kernlogik ab. |
| 2.10 | `_discoverModels()` / `_discoverLocalModels()` | Netzwerk-abhängig, viele Provider-Dependencies. Aufwand/Nutzen schlecht. |
| 2.12 | `_softDeleteRegistryModel()` | Mix aus DB + Provider-Cache + UI. Besser DAO-Methode `upsertOverride` separat testen. |
| 2.13 | Slider-Logik (Widget-Test) | UI-gekoppelt. Math-Funktionen könnten extrahiert werden, aber geringer Nutzen. |
| 2.14/15 | `_deleteProject()` Tests | Redundant zu 1.6 – gleiche Analyse. |
| 2.17 | Running-Batch Buttons deaktiviert | Simpler Inline-Check `status == 'running'`. Widget-Test möglich, aber trivialer Wert. |
| 2.18 | Route-Test `/batch/:batchId/edit` | Einfache GoRouter-Konfiguration. Wenig Fehleranfälligkeit. |

---

## Umsetzungsplan

### Schritt 1: `test/services/llm_api_service_test.dart` erweitern

Bestehende Datei um folgende Gruppen ergänzen:

**Gruppe: `_normalizeOllamaBaseUrl via callLlm`**
- URL mit `/api/chat` Suffix → wird auf Basis normalisiert
- URL mit `/api/generate` Suffix → wird auf Basis normalisiert
- URL mit `/api` Suffix → wird auf Basis normalisiert
- URL mit `/v1/api/chat` Suffix → wird auf Basis normalisiert
- URL nur mit trailing slashes `///` → wird bereinigt
- Leere URL → Fallback auf `http://localhost:11434`
- URL ohne Suffix → bleibt unverändert

**Gruppe: `_extractOllamaMissingModel via callLlm`**
- Error-Text `model "xyz" not found` → extrahiert `xyz`
- Error-Text `model 'xyz' not found` (einfache Anführungszeichen)
- Error-Text `model xyz not found` (ohne Anführungszeichen)
- Error-Text ohne "not found" → kein Match, Fallback auf generate

**Gruppe: `Ollama chat/generate fallback (erweitert)`**
- Chat-Endpoint antwortet mit 200 → kein Fallback auf generate
- Chat-Endpoint antwortet mit 500 → kein Fallback (nur 404 triggert Fallback)

Dateien: `test/services/llm_api_service_test.dart`

---

### Schritt 2: `test/workers/worker_messages_test.dart` neu erstellen

**Gruppe: `ProgressEvent encode/decode`**
- Encode mit stats → JSON enthält `stats`-Key
- Encode ohne stats → JSON enthält keinen `stats`-Key
- Decode mit stats → `ProgressEvent.stats` ist befüllt
- Decode ohne stats → `ProgressEvent.stats` ist null
- Roundtrip: encode → decode ergibt identische Werte

**Gruppe: `BatchCompletedEvent encode/decode`**
- Roundtrip mit Stats und Results

**Gruppe: `BatchErrorEvent encode/decode`**
- Roundtrip mit message + details
- Roundtrip mit message ohne details

**Gruppe: `Command encode/decode`**
- StartBatchCommand Roundtrip
- PauseBatchCommand Roundtrip
- Ungültige/fehlende Payloads → null

Dateien: `lib/workers/worker_messages.dart`

---

### Schritt 3: `test/data/database/daos/batches_dao_test.dart` neu erstellen

Nutzt `createTestDatabase()` aus test_harness.

**Gruppe: `recoverStaleRunningBatches`**
- Batch mit Status `running` → wird zu `failed`, `updatedAt` und `completedAt` gesetzt
- Batch mit Status `completed` → bleibt unverändert
- Batch mit Status `failed` → bleibt unverändert
- Batch mit Status `pending` → bleibt unverändert
- Mehrere running Batches → alle werden recovered
- Keine running Batches → Return 0, nichts geändert

Dateien: `lib/data/database/daos/batches_dao.dart`, `test/test_helpers/test_harness.dart`

---

### Schritt 4: `test/services/project_file_service_test.dart` neu erstellen

Nutzt `Directory.systemTemp.createTempSync()` für isolierte Tests.

**Gruppe: `deleteProjectFolder`**
- Vorhandener Ordner → wird rekursiv gelöscht
- Nicht vorhandener Pfad → kein Fehler, kehrt still zurück
- Ordner mit Unterstruktur (Dateien + Unterordner) → komplett gelöscht

**Gruppe: `createProject` (Bonus)**
- Erstellt Ordner mit korrekter Unterstruktur (`prompts`, `input`, `results`)
- `project.xtractaid.json` enthält erwartete Felder

**Gruppe: `validateProject`**
- Gültiges Projekt → gibt JSON-Map zurück
- Fehlende Datei → gibt null zurück
- Kaputtes JSON → gibt null zurück

Dateien: `lib/services/project_file_service.dart`

---

### Schritt 5: Pure Funktionen aus UI-Screens extrahieren

Neue Datei `lib/core/utils/provider_helpers.dart`:
```dart
bool isLocalProviderType(String type)
String providerDisplayName(String type)
```
→ Import in `settings_screen.dart`, private Methoden durch Aufrufe ersetzen.

Neue Datei `lib/core/utils/batch_helpers.dart`:
```dart
bool isTerminalBatchStatus(String? status)
String batchExecutionStatusLabel(BatchExecutionStatus status, S t)
List<DiscoveredModel> extractDiscoveredModels(String providerType, dynamic payload)
```
→ Imports in `batch_wizard_screen.dart`, `batch_execution_screen.dart`, `model_manager_screen.dart` anpassen.

Dateien:
- Neu: `lib/core/utils/provider_helpers.dart`
- Neu: `lib/core/utils/batch_helpers.dart`
- Ändern: `lib/features/settings/settings_screen.dart`
- Ändern: `lib/features/batch_wizard/batch_wizard_screen.dart`
- Ändern: `lib/features/batch_execution/batch_execution_screen.dart`
- Ändern: `lib/features/model_manager/model_manager_screen.dart`

---

### Schritt 6: `test/core/utils/provider_helpers_test.dart` + `batch_helpers_test.dart` erstellen

**provider_helpers_test.dart:**
- `isLocalProviderType`: `ollama`→true, `lmstudio`→true, `openai`→false, `anthropic`→false, `''`→false
- `providerDisplayName`: alle bekannten Typen + Fallback für unbekannten Typ

**batch_helpers_test.dart:**
- `isTerminalBatchStatus`: `completed`/`failed`/`cancelled`→true, `running`/`pending`/`null`/`''`→false
- `batchExecutionStatusLabel`: alle 6 Enum-Werte liefern nicht-leeren String (in `en` und `de`)
- `extractDiscoveredModels`: Ollama-Format (`models[].name`), OpenAI-Format (`data[].id`), leere Liste, null-Handling

---

### Schritt 7: `test/providers/batch_execution_provider_test.dart` neu erstellen

`_onWorkerEvent` ist privat. Lösungsansatz: `@visibleForTesting` Hilfsmethode in `BatchExecutionNotifier` hinzufügen:
```dart
@visibleForTesting
void handleWorkerEventForTest(WorkerEvent event) => _onWorkerEvent(event);
```

**Gruppe: `_onWorkerEvent state transitions`**
- ProgressEvent mit Stats → state.stats wird aktualisiert, status = running
- ProgressEvent ohne Stats → state.stats bleibt, status = running
- ProgressEvent überschreibt alte Stats
- LogEvent → state.logs wächst um 1
- CheckpointSavedEvent → state.logs enthält Checkpoint-Eintrag
- BatchCompletedEvent → status = completed, stats + results gesetzt
- BatchErrorEvent → status = failed, errorMessage gesetzt

Dateien: `lib/providers/batch_execution_provider.dart`

---

## Zusammenfassung

| Schritt | Typ | Neue Tests (ca.) |
|---------|-----|------------------|
| 1. LLM API Service erweitern | Extend | ~13 |
| 2. WorkerMessageCodec | Neu | ~10 |
| 3. BatchesDao | Neu | ~6 |
| 4. ProjectFileService | Neu | ~8 |
| 5. Pure-Function-Extraktion | Refactoring | — |
| 6. Provider/Batch Helpers | Neu | ~12 |
| 7. BatchExecutionProvider | Neu | ~7 |
| **Gesamt** | | **~56 neue Tests** |

## Verifikation

Nach jedem Schritt:
```bash
flutter test
```

Am Ende:
```bash
flutter test --coverage
flutter analyze
```
