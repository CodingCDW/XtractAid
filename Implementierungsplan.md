# XtractAid Flutter -- Entwicklungsplan

## Fortschritt

| Phase | Status | Anmerkungen |
|-------|--------|-------------|
| Phase 0: Spec-Updates | ERLEDIGT | Alle 3 Spec-Dokumente auf Flutter/Dart aktualisiert |
| Phase 1: Foundation | ERLEDIGT | Projekt, DB, Models, Encryption, Registry, App-Shell, Navigation. `dart analyze`: 0 Fehler, `flutter build windows`: OK |
| Phase 2: Core Services | ERLEDIGT | 9 Services implementiert (inkl. `pdf_ocr_service.dart` Stub). Kritische Bugs K1-K5 behoben, Haertung H1-H8 abgeschlossen |
| Phase 3: Frontend Core | ERLEDIGT | 3.1-3.5 umgesetzt. Stille `catch (_)` durch Logging ersetzt (M8), `mounted`-Checks ergaenzt (M10) |
| Phase 4: Integration | ERLEDIGT | 4.1-4.6 implementiert. Worker-Retry (K4), Checkpoint bei Stop (H2), Race Condition behoben (K6), Kostenberechnung (H7) |
| Phase 5: Polish | IN ARBEIT | 5.1-5.4 ERLEDIGT. 5.9 Bug-Fixes ERLEDIGT (K1-K7, H1-H8, M2-M8/M10). 5.10 P0-Features ERLEDIGT (F1-F4, F12, F13). Offen: Widget/Integration Tests (5.4b), Distribution (5.5), Lokalisierungsluecken (5.1b) |
| -- Code Review | ERLEDIGT | 2025-02-15: Umfassender Review. 18+ Bugs identifiziert |
| -- Bug-Fix-Runde | ERLEDIGT | 2026-02-15: Alle kritischen (7/7), hohen (8/8) und mittleren (8/10) Bugs behoben. `dart analyze`: **0 Errors/0 Warnings/0 Info**. `flutter test`: **61/61** |
| -- PRD-Abgleich | ERLEDIGT | 2025-02-15: 13 Features geprueft. P0-Features (F1-F4) implementiert. F12+F13 fertig. Offen: P1-Features (F5-F9), teilweise Features (F10, F11) |

---

## Wie dieses Projekt funktioniert (Einstieg fuer Entwickler)

### Was ist XtractAid?

XtractAid ist eine **Windows-Desktop-App** (spaeter auch macOS) fuer Wissenschaftler und Forscher. Sie laedt Textdaten aus Excel/PDF/DOCX-Dateien, sendet diese in Batches an LLM-APIs (OpenAI, Anthropic, Google, Ollama, LM Studio) und sammelt die strukturierten JSON-Antworten in Excel-Tabellen und HTML-Reports.

**Typischer Workflow:**
1. User erstellt ein Projekt (Ordner mit `prompts/`, `input/`, `results/`)
2. User laedt Items (z.B. 300 Abstracts aus einer Excel-Datei)
3. User waehlt Prompts (z.B. "Extrahiere Metadaten" + "Erstelle Zusammenfassung")
4. User konfiguriert: Chunk-Groesse, Wiederholungen, LLM-Model, Parameter
5. App sendet Items chunkweise an LLM, parst JSON-Antworten, speichert Checkpoints
6. Ergebnisse: Excel mit einer Zeile pro Item + HTML-Dossier + Markdown-Log

### Tech-Stack

| Was | Technologie | Wo |
|-----|-------------|-----|
| Framework | Flutter (Desktop) | Gesamte App |
| Sprache | Dart | Alles |
| State | Riverpod (`flutter_riverpod`) | `lib/providers/` |
| Datenbank | Drift + SQLite | `lib/data/database/` |
| Navigation | GoRouter | `lib/core/router/app_router.dart` |
| HTTP | Dio | `lib/services/llm_api_service.dart` |
| Verschluesselung | AES-256-GCM via `encrypt` + `pointycastle` | `lib/services/encryption_service.dart` |
| Datenklassen | freezed + json_serializable | `lib/data/models/` |
| UI | Material Design 3 | `lib/core/theme/app_theme.dart` |

### Architektur (Schichtmodell)

```
Flutter UI (Main Isolate)
    |
    | Riverpod Providers (State-Management)
    |
    v
Dart Services Layer (Geschaeftslogik)
    |
    |-- Direkte Aufrufe (fuer schnelle Operationen)
    |-- Isolate SendPort/ReceivePort (fuer langlebige Batch-Worker)
    |
    v
Drift SQLite + Dateisystem + Externe LLM-APIs
```

**Wichtig:** Es gibt kein Python-Backend, keinen REST-Server, kein Tauri. Alles ist reines Flutter/Dart. Die PRD (`specs/XtractAid_PRD_Final.md`) wurde urspruenglich fuer React+Tauri+FastAPI geschrieben und in Phase 0 auf Flutter/Dart umgeschrieben.

### Projekt-Befehle

```bash
# Abhaengigkeiten installieren
flutter pub get

# Analyse (muss 0 Fehler zeigen)
dart analyze lib/

# Windows-Build
flutter build windows

# Tests
flutter test

# Code-Generierung (falls freezed/drift-Modelle geaendert werden)
dart run build_runner build --delete-conflicting-outputs
```

**Hinweis:** Die freezed/drift `.g.dart` und `.freezed.dart` Dateien sind generiert und vorhanden. Bei Aenderungen an den Datenklassen oder Drift-Tabellen muss `dart run build_runner build --delete-conflicting-outputs` erneut ausgefuehrt werden.

---

## Was existiert bereits (Detail-Referenz)

### Datenbank (Drift SQLite)

**Datei:** `lib/data/database/app_database.dart`
**DB-Pfad:** `getApplicationSupportDirectory()/xtractaid.db` (per `path_provider`)
**Isolate-sicher:** Ja, via `NativeDatabase.createInBackground()`

6 Tabellen mit je einem DAO:

| Tabelle | Primaerschluessel | Wichtige Spalten | DAO-Methoden |
|---------|-------------------|------------------|--------------|
| `settings` | `key` (Text) | `value` (Text), `updatedAt` | `getValue(key)`, `setValue(key, value)`, `getAll()` |
| `providers` | `id` (Text) | `name`, `type` (openai/anthropic/...), `baseUrl`, `encryptedApiKey` (Blob, nullable), `isEnabled` | `getAll()`, `watchAll()`, `getEnabled()`, `insertProvider()` |
| `models` | `modelId` (Text) | `overrideJson` (Text = JSON-String mit User-Parametern) | `getAllUserOverrides()`, `upsertOverride()` |
| `projects` | `id` (Text) | `name`, `path` (absoluter Ordnerpfad), `lastOpenedAt` | `getRecent(limit:10)`, `watchAll()`, `touchLastOpened(id)` |
| `batches` | `id` (Text) | `projectId`, `name`, `configJson` (BatchConfig als JSON), `status` (created/running/paused/completed/failed/cancelled) | `getByProject()`, `watchByProject()`, `updateStatus()` |
| `batch_logs` | autoincrement `id` | `batchId`, `level`, `message`, `inputTokens`, `outputTokens`, `costUsd` | `getByBatch()`, `watchByBatch()` |

**Zugriff:** Ueber den Riverpod-Provider `databaseProvider` (`lib/providers/database_provider.dart`), der eine Singleton-`AppDatabase`-Instanz bereitstellt.

**Achtung (Provider-Name-Clash):** Drift generiert eine Klasse `Provider` aus `providers_table.dart`. Um Konflikte mit Riverpods `Provider` zu vermeiden, importiert `database_provider.dart` Riverpod mit Prefix: `import '...flutter_riverpod.dart' as riverpod;`.

### Datenklassen (freezed)

Alle in `lib/data/models/`. Jede hat `fromJson`/`toJson`:

| Klasse | Datei | Zweck |
|--------|-------|-------|
| `ProviderConfig` | `provider_config.dart` | API-Provider (id, name, type, baseUrl, authType, isLocal, isEnabled) |
| `ModelInfo` | `model_info.dart` | Model-Metadaten (id, provider, displayName, contextWindow, maxOutputTokens, pricing, capabilities, parameters) |
| `ModelPricing` | `model_info.dart` | Preise (inputPerMillion, outputPerMillion, currency) |
| `ModelCapabilities` | `model_info.dart` | Faehigkeiten (chat, vision, jsonMode, reasoning, extendedThinking...) |
| `ModelParameter` | `model_info.dart` | Ein Parameter (supported, type=float/integer/enum, min, max, defaultValue, values) |
| `BatchConfig` | `batch_config.dart` | Batch-Konfiguration (batchId, projectId, input, promptFiles, chunkSettings, models, privacyConfirmed) |
| `BatchInput` | `batch_config.dart` | Input-Quelle (type=excel/folder, path, sheetName, idColumn, itemColumn, itemCount) |
| `ChunkSettings` | `batch_config.dart` | Chunk-Config (chunkSize, repetitions, shuffleBetweenReps) |
| `BatchModelConfig` | `batch_config.dart` | Model fuer Batch (modelId, providerId, parameters-Map) |
| `BatchStats` | `batch_stats.dart` | Laufzeit-Statistiken (totalApiCalls, completedApiCalls, tokens, cost, timing) |
| `BatchProgress` | `batch_stats.dart` | Fortschritt (currentRepetition, currentPromptIndex, currentChunkIndex, callCounter, progressPercent) |
| `CostEstimate` | `cost_estimate.dart` | Vorab-Kostenberechnung (estimatedInputTokens, estimatedApiCalls, estimatedCostUsd) |
| `TokenEstimate` | `cost_estimate.dart` | Token-Zaehlung (inputTokens, outputTokens, totalTokens) |
| `Item` | `item.dart` | Ein Datensatz (id, text, source) |
| `Checkpoint` | `checkpoint.dart` | Checkpoint (batchId, progress, stats, config, results, savedAt) |
| `LogEntry` | `log_entry.dart` | Log-Eintrag (level=info/warn/error, message, details, timestamp) |

### Services (alle in `lib/services/`)

| Service | Datei | Oeffentliche Methoden | Benutzt von |
|---------|-------|----------------------|-------------|
| `EncryptionService` | `encryption_service.dart` | `unlock(password, salt)`, `lock()`, `encryptData(plaintext)` -> Uint8List, `decryptData(blob)` -> String, `hashPassword()`, `verifyPassword()`, `generateSalt()` | Setup Wizard, Auth Screen, Provider-Verwaltung |
| `ModelRegistryService` | `model_registry_service.dart` | `getMergedRegistry()`, `getProviders()`, `getModelIds()`, `getModelsByProvider()`, `getModelInfo(modelId)` -> ModelInfo, `getModelParameters(modelId)`, `getModelPricing(modelId)` | Model Manager, Batch Wizard (Model-Auswahl), Kosten-Berechnung |
| `FileParserService` | `file_parser_service.dart` | `parseExcel(path, idColumn, itemColumn)`, `parseCsv()`, `parsePdf()`, `parseDocx()`, `parseTextFile()`, `parseFile(path)` (auto-detect), `parseFolderStream()` (async* Stream) | Batch Wizard Schritt 1 (Item-Laden) |
| `LlmApiService` | `llm_api_service.dart` | `callLlm(providerType, baseUrl, modelId, messages, apiKey, parameters)` -> LlmResponse, `testConnection(providerType, baseUrl, apiKey)` -> bool | Batch Worker (API-Calls), Setup Wizard (Verbindungstest) |
| `JsonParserService` | `json_parser_service.dart` | `parseResponse(response, debugDir)` -> List<Map>? | Batch Worker (Antwort-Parsing) |
| `CheckpointService` | `checkpoint_service.dart` | `saveCheckpoint(...)`, `loadCheckpoint(projectPath, batchId)`, `hasCheckpoint()`, `deleteCheckpoint()`, `cleanupOldCheckpoints()` | Batch Worker (Speichern/Laden), Resume Dialog |
| `TokenEstimationService` | `token_estimation_service.dart` | `estimateTokens(text)` -> int, `estimateBatchCost(promptTexts, totalItems, chunkSize, reps, maxTokens, pricing)` -> CostEstimate | Batch Wizard Schritt 5 (Kosten-Vorschau) |
| `PromptService` | `prompt_service.dart` | `loadPrompts(promptsDir)` -> Map<name,content>, `hasPlaceholder(text)`, `injectItems(template, items)`, `validatePrompt(text)`, `createChunks(items, chunkSize)` | Batch Wizard Schritt 2, Batch Worker |
| `ProjectFileService` | `project_file_service.dart` | `createProject(path, name, projectId)`, `validateProject(path)` -> Map?, `promptsDir(path)`, `inputDir(path)`, `resultsDir(path)` | Project Manager |
| `LmStudioCliService` | `lm_studio_cli_service.dart` | `loadModel(modelId, onProgress)`, `waitForServer(baseUrl, timeout, pollInterval)`, `isCliAvailable()` | LM Studio Provider-Setup, Model Manager (Discovered-Tab) |
| `PdfOcrService` | `pdf_ocr_service.dart` | `ocrPdf(pdfPath)` -> String? (Stub, liefert `null`) | FileParserService (OCR-Fallback, Phase 5.6.2) |

### Riverpod Providers (alle in `lib/providers/`)

| Provider | Typ | Liefert | Benutzt |
|----------|-----|---------|---------|
| `databaseProvider` | `riverpod.Provider<AppDatabase>` | Singleton DB-Instanz | Fast alles |
| `encryptionProvider` | `Provider<EncryptionService>` | Singleton EncryptionService | Auth, Provider-Verwaltung |
| `modelRegistryProvider` | `Provider<ModelRegistryService>` | Singleton ModelRegistryService | Model-UIs |
| `mergedRegistryProvider` | `FutureProvider<Map>` | Zusammengefuehrte Registry (bundled+remote+user) | Model-UIs |
| `isSetupCompleteProvider` | `FutureProvider<bool>` | `true` wenn `settings['setup_complete'] == 'true'` | `app.dart` (initiale Route) |

### Navigation (GoRouter)

**Datei:** `lib/core/router/app_router.dart`

```
/setup          -> SetupWizardScreen (vor erstem Setup)
/auth           -> PasswordScreen (Passwort-Eingabe)
/projects       -> ProjectManagerScreen (in AppShell mit NavigationRail)
/models         -> ModelManagerScreen (in AppShell)
/settings       -> SettingsScreen (in AppShell)
```

**App-Start-Logik** (`lib/app.dart`): `isSetupCompleteProvider` bestimmt die Initial-Route:
- `false` -> `/setup`
- `true` -> `/auth`

Nach erfolgreicher Passwort-Eingabe navigiert `/auth` zu `/projects`.

### UI-Shell

**Datei:** `lib/core/shell/app_shell.dart`

`NavigationRail` (links) mit 3 Destinations: Projects, Models, Settings. Rechts der Content-Bereich (`child`). Das `ShellRoute`-Layout gilt nur fuer `/projects`, `/models`, `/settings`.

### Platzhalter-Screens

Alle urspruenglichen Platzhalter-Screens sind inzwischen implementiert:

| Screen | Datei | Status |
|--------|-------|--------|
| `SettingsScreen` | `lib/features/settings/settings_screen.dart` | Implementiert (Phase 5.2), Bug offen (5.9.1 K7) |
| `ModelManagerScreen` | `lib/features/model_manager/model_manager_screen.dart` | Implementiert (Phase 4.6), Lokalisierungsluecken (5.9.3) |

### Konstanten

**Datei:** `lib/core/constants/app_constants.dart`

Wichtige Werte:
- `pbkdf2Iterations`: 100.000
- `saltLength`: 32 Bytes
- `ivLength`: 12 Bytes (AES-GCM)
- `keyLength`: 32 Bytes (AES-256)
- `defaultCheckpointInterval`: 10 API-Calls
- `charsPerToken`: entfernt (ersetzt durch tokenizer-basierte Schaetzung in `TokenEstimationService`)
- `itemPlaceholder`: `[Insert IDs and Items here]`
- `maxChunkSize`: 100
- `maxRepetitions`: 100
- `maxRetries`: 5 (LLM-Calls)
- `rateLimitDelay`: 30 Sekunden (bei 429)
- `projectSubdirs`: `['prompts', 'input', 'batches', 'results']`
- `projectFileName`: `project.xtractaid.json`

### PRD-Referenz

Die vollstaendige Anforderungsspezifikation ist in `specs/XtractAid_PRD_Final.md`. Wichtige Requirement-IDs:

| ID | Thema | PRD-Zeile |
|----|-------|-----------|
| F-SETUP-01 | Setup-Wizard (6 Schritte) | 152 |
| F-SETUP-02 | Master-Passwort | 165 |
| F-SETUP-03 | API-Key-Sicherheit | 172 |
| F-PROJ-01 | Projektstruktur | 308 |
| F-PROJ-02 | project.xtractaid.json | 330 |
| F-PROJ-03 | Projektoperationen | 347 |
| F-BATCH-01 | Batch-Definition | 593 |
| F-BATCH-02 | Chunk-Einstellungen | 639 |
| F-BATCH-03 | Model-Parameter | 675 |
| F-EXEC-01 | Ausfuehrungs-Ablauf | 790 |
| F-EXEC-04 | Response-Parsing | 915 |
| F-EXEC-05 | Ergebnis-Aggregation | 975 |
| F-CHKPT-03 | Resume-Dialog | 1093 |
| F-OUTPUT-01 | Excel-Export | 1136 |
| F-OUTPUT-02 | Log-Datei | 1193 |
| F-OUTPUT-03 | HTML-Report | 1269 |
| F-PRIVACY-01 | Datenschutz-Warnung | 1331 |
| F-PRIVACY-02 | Strict Local Mode | 1354 |

---

## Phase 3: Frontend Core -- ERLEDIGT

### 3.1 Setup Wizard

**PRD-Referenz:** F-SETUP-01, F-SETUP-02, F-SETUP-03

**Status:** Umgesetzt in `lib/features/setup_wizard/setup_wizard_screen.dart` + `lib/features/setup_wizard/steps/*`

**Struktur:** Einen `StatefulWidget` oder `ConsumerStatefulWidget` mit `Stepper` oder eigenem `PageView`-basiertem Wizard erstellen. Dazu 6 Step-Widgets als eigene Dateien.

**Neue Dateien:**
```
lib/features/setup_wizard/
  setup_wizard_screen.dart         -- Haupt-Screen mit Step-Navigation
  steps/
    step_welcome.dart              -- Schritt 1
    step_password.dart             -- Schritt 2
    step_provider.dart             -- Schritt 3
    step_api_key.dart              -- Schritt 4
    step_basic_settings.dart       -- Schritt 5
    step_finish.dart               -- Schritt 6
```

**Schritt 1 -- Willkommen:**
- Logo/Titel "XtractAid"
- Kurze Beschreibung was die App macht
- Sprachauswahl-Dropdown (DE/EN) -> speichern in `settings['language']` via `db.settingsDao.setValue()`
- "Weiter"-Button

**Schritt 2 -- Master-Passwort:**
- 2 TextFields: "Passwort" + "Passwort bestaetigen"
- Passwort-Staerke-Indikator (visueller Balken: rot < 8 Zeichen, gelb < 12, gruen >= 12)
- Min. 8 Zeichen Validierung
- Bei "Weiter":
  1. `final salt = encryptionService.generateSalt();`
  2. `final hash = encryptionService.hashPassword(password, salt);`
  3. `db.settingsDao.setValue('password_hash', hash);`
  4. `db.settingsDao.setValue('password_salt', base64Encode(salt));`
  5. `encryptionService.unlock(password, salt);`
- Services holen via `ref.read(encryptionProvider)` und `ref.read(databaseProvider)`

**Schritt 3 -- Provider waehlen:**
- `DropdownButtonFormField` mit 6 Optionen:
  - OpenAI (cloud), Anthropic (cloud), Google Gemini (cloud), OpenRouter (cloud), Ollama (lokal), LM Studio (lokal)
- Info-Text unter dem Dropdown: "Cloud-Provider benoetigen einen API-Key. Lokale Provider (Ollama, LM Studio) laufen auf Ihrem Rechner."
- Provider-Infos aus `ModelRegistryService.getProviders()` laden

**Schritt 4 -- API-Key eingeben + testen:**
- Falls lokaler Provider (Ollama/LM Studio): Key-Feld ueberspringen, nur Verbindungstest
- Falls Cloud-Provider: `TextField(obscureText: true)` fuer API-Key
- "Verbindung testen"-Button:
  1. `final ok = await llmApiService.testConnection(providerType: type, baseUrl: url, apiKey: key);`
  2. Gruener Haken oder roter Fehler-Text
- Bei "Weiter":
  1. API-Key verschluesseln: `final blob = encryptionService.encryptData(apiKey);`
  2. Provider in DB speichern: `db.providersDao.insertProvider(ProvidersCompanion(id: Value(uuid), name: ..., type: ..., baseUrl: ..., encryptedApiKey: Value(blob)))`
- `LlmApiService` muss hier instanziiert werden (noch kein Provider dafuer -- entweder direkt `LlmApiService()` oder neuen Riverpod-Provider erstellen)

**Schritt 5 -- Grundeinstellungen (optional):**
- Checkbox "Strict Local Mode" -> nur lokale Provider erlauben (F-PRIVACY-02)
- Hinweis: "Diese Einstellungen koennen spaeter in den Einstellungen geaendert werden."
- Speichern: `db.settingsDao.setValue('strict_local_mode', 'true'/'false')`

**Schritt 6 -- Fertig:**
- Zusammenfassung: Gewaehlter Provider, Verbindung OK, Passwort gesetzt
- "XtractAid starten"-Button:
  1. `db.settingsDao.setValue('setup_complete', 'true');`
  2. `context.go('/projects');`
  3. `ref.invalidate(isSetupCompleteProvider);` (damit App-State aktualisiert wird)

### 3.2 Auth Screen (Passwort-Eingabe)

**PRD-Referenz:** F-SETUP-02

**Status:** Umgesetzt in `lib/features/auth/password_screen.dart` (Passwort-Check + Reset-Flow)

**Datei:** `lib/features/auth/password_screen.dart` -- als `ConsumerStatefulWidget` umschreiben.

**Funktionalitaet:**
1. Zentriertes Layout: Logo, "XtractAid"-Titel, Passwort-TextField, "Entsperren"-Button
2. Bei Submit:
   - Salt laden: `final saltB64 = await db.settingsDao.getValue('password_salt');`
   - Hash laden: `final storedHash = await db.settingsDao.getValue('password_hash');`
   - Verifizieren: `encryptionService.verifyPassword(password, base64Decode(saltB64!), storedHash!)`
   - Bei Erfolg: `encryptionService.unlock(password, salt)` + `context.go('/projects')`
   - Bei Fehler: Fehlermeldung "Falsches Passwort" unter dem Feld anzeigen
3. "Passwort vergessen?"-Link:
   - Dialog: "Alle API-Keys werden geloescht. Fortfahren?"
   - Bei Ja: Alle Provider-Eintraege loeschen, settings `password_hash`/`password_salt`/`setup_complete` loeschen, `context.go('/setup')`

### 3.3 Project Manager

**PRD-Referenz:** F-PROJ-01, F-PROJ-02, F-PROJ-03

**Status:** Umgesetzt in `lib/features/project_manager/project_manager_screen.dart` + `lib/features/project_manager/project_detail_screen.dart` + `lib/features/project_manager/widgets/*`

**Neue Dateien:**
```
lib/features/project_manager/
  project_manager_screen.dart     -- Haupt-Screen
  widgets/
    project_card.dart             -- Card-Widget fuer ein Projekt
    new_project_dialog.dart       -- Dialog zum Erstellen
    open_project_dialog.dart      -- Dialog zum Oeffnen (Ordner waehlen)
```

**Neuer Provider:**
```
lib/providers/project_provider.dart
  -- projectListProvider: StreamProvider -> db.projectsDao.watchAll()
  -- currentProjectProvider: StateProvider<Project?> -> aktuell geoeffnetes Projekt
```

**Screen-Layout:**
- AppBar: "Projects" + FAB oder Buttons "Neues Projekt" + "Projekt oeffnen"
- Body: Liste der letzten 10 Projekte als Cards (`db.projectsDao.getRecent()`)
- Jede Card zeigt: Projektname, Pfad, Letzte Oeffnung, "Oeffnen"-Button
- Leerer State: Illustration + "Erstellen Sie Ihr erstes Projekt"

**Neues Projekt erstellen (Dialog):**
1. TextField: Projektname
2. "Ordner waehlen"-Button -> `FilePicker.platform.getDirectoryPath()`
3. "Erstellen"-Button:
   - `final projectId = const Uuid().v4();`
   - `await projectFileService.createProject(path: '$chosenDir/$name', name: name, projectId: projectId);`
   - `await db.projectsDao.insertProject(ProjectsCompanion(id: Value(projectId), name: Value(name), path: Value('$chosenDir/$name')));`
   - `db.projectsDao.touchLastOpened(projectId);`
   - Projekt oeffnen -> Batch-Uebersicht (Route: `/projects/$projectId/batches`)

**Projekt oeffnen (Dialog):**
1. `FilePicker.platform.getDirectoryPath()` -> Ordner waehlen
2. `projectFileService.validateProject(path)` -> null = ungueltig
3. Falls gueltig: In DB einfuegen (falls noch nicht vorhanden), `touchLastOpened`, navigieren
4. Falls ungueltig: Fehlermeldung "Kein gueltiges XtractAid-Projekt"

**Routing-Erweiterung:** Neue Routes in `app_router.dart` hinzufuegen:
```
/projects                         -> ProjectManagerScreen (Uebersicht)
/projects/:projectId              -> ProjectDetailScreen (Batches + Prompts)
/projects/:projectId/batch/new    -> BatchWizardScreen
/projects/:projectId/batch/:batchId -> BatchExecutionScreen (Phase 4)
```

**ProjectDetailScreen** (neue Datei: `lib/features/project_manager/project_detail_screen.dart`):
- Zeigt: Projektname, Pfad, Erstellt am
- Tab oder Abschnitte:
  - **Batches:** Liste der Batches (`db.batchesDao.watchByProject(projectId)`) mit Status-Badge (created/running/completed/failed), "Neuer Batch"-Button -> Batch Wizard
  - **Prompts:** Liste der `.txt`/`.md`-Dateien aus `prompts/`-Ordner
  - **Input:** Liste der Dateien aus `input/`-Ordner

### 3.4 Batch Wizard (5 Schritte)

**PRD-Referenz:** F-BATCH-01, F-BATCH-02, F-BATCH-03, F-PRIVACY-01, Abschnitt 7.2

**Status:** Umgesetzt in `lib/features/batch_wizard/batch_wizard_screen.dart` + `lib/features/batch_wizard/steps/*`

**Neue Dateien:**
```
lib/features/batch_wizard/
  batch_wizard_screen.dart        -- Haupt-Screen mit Stepper
  steps/
    step_items.dart               -- Schritt 1: Items laden
    step_prompts.dart             -- Schritt 2: Prompts waehlen
    step_chunks.dart              -- Schritt 3: Chunk-Einstellungen
    step_model.dart               -- Schritt 4: Model konfigurieren
    step_confirm.dart             -- Schritt 5: Bestaetigung + Start
```

**Daten-Fluss:** Der Wizard sammelt schrittweise Daten und baut am Ende ein `BatchConfig`-Objekt zusammen. Verwende einen lokalen `StateNotifier` oder einen `ChangeNotifier` im Wizard-Screen, der die Zwischenergebnisse haelt.

**Schritt 1 -- Items laden:**
- Radio-Buttons: "Excel-Datei" oder "Dokumenten-Ordner"
- Bei Excel:
  - `FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['xlsx', 'xls', 'csv'])`
  - `fileParserService.parseExcel(path)` -> `ParseResult`
  - Sheet-Auswahl Dropdown (falls mehrere Sheets)
  - Spalten-Mapping: ID-Spalte + Item-Spalte Dropdowns (aus Header-Zeile)
- Bei Ordner:
  - `FilePicker.platform.getDirectoryPath()`
  - `fileParserService.parseFolderStream(path)` -> Stream mit Fortschritt
- **Vorschau-Tabelle:** Die ersten 10 Items als `DataTable` anzeigen (ID + Text, Text abgeschnitten auf 200 Zeichen)
- **Zusammenfassung:** "X Items geladen, Y Warnungen"
- Warnungen in gelber Box anzeigen

**Schritt 2 -- Prompts waehlen:**
- Lade Prompts: `promptService.loadPrompts(projectFileService.promptsDir(projectPath))`
- Dual-Liste:
  - Links: "Verfuegbar" (alle nicht-ausgewaehlten Prompts)
  - Rechts: "Ausgewaehlt" (mit Drag&Drop-Reihenfolge via `ReorderableListView`)
  - Buttons: ">>" (hinzufuegen), "<<" (entfernen)
- Vorschau-Bereich: Inhalt des ausgewaehlten Prompts anzeigen
- Warnung falls Prompt keinen Platzhalter hat: `promptService.validatePrompt()`
- Falls keine Prompts im `prompts/`-Ordner: Hinweis mit Link "Prompt-Dateien (.txt, .md) in den prompts/-Ordner legen"

**Schritt 3 -- Chunk-Einstellungen:**
- `Slider` fuer Chunk-Groesse: 1-100 (default 1), Label: "Items pro API-Call"
- `Slider` fuer Wiederholungen: 1-100 (default 1), Label: "Wiederholungen (mit Shuffle)"
- Berechnungs-Box:
  - "X Items / Y Chunk-Groesse = Z Chunks"
  - "Z Chunks x N Prompts x R Wiederholungen = T API-Calls total"
- Tooltip: "Bei chunk_size > 1 werden mehrere Items gleichzeitig im Prompt gesendet. Dies spart API-Calls, kann aber die Qualitaet reduzieren."

**Schritt 4 -- Model konfigurieren:**
- **ModelSelector-Widget** (-> `lib/shared/widgets/model_selector.dart`):
  - `DropdownButtonFormField` gruppiert nach Provider
  - Zeigt: Model-Name, Kontext-Fenster, Preis/1M Tokens
  - Daten aus `modelRegistryService.getModelsByProvider()`
- **ModelConfigurator-Widget** (-> `lib/shared/widgets/model_configurator.dart`):
  - Dynamisch basierend auf `modelRegistryService.getModelParameters(modelId)`
  - Fuer jeden Parameter mit `supported: true`:
    - `type: 'float'` -> `Slider` mit `min`/`max`/`defaultValue`
    - `type: 'integer'` -> `Slider` mit ganzzahligen Steps
    - `type: 'enum'` -> `DropdownButtonFormField` mit `values`-Liste
  - Labels: Parametername + aktueller Wert
- "Weiteres Model hinzufuegen"-Button (Multi-Model: speichert Liste von `BatchModelConfig`)
- Falls Provider lokal (Ollama/LM Studio): Kein API-Key noetig, Hinweis "Lokales Model"

**Schritt 5 -- Bestaetigung + Start:**
- **Zusammenfassung:** Tabelle mit Items (Anzahl, Quelle), Prompts (Namen), Chunks, Repetitions, Model(s), Gesamt-API-Calls
- **Kosten-Vorschau:** `tokenEstimationService.estimateBatchCost(...)` -> CostEstimate anzeigen:
  - Geschaetzte Input-Tokens + Kosten
  - Geschaetzte Output-Tokens + Kosten
  - Gesamt-Kosten (USD)
  - Hinweis: "Schaetzung basierend auf ~4 Zeichen/Token"
- **Datenschutz-Checkbox** (nur bei Cloud-Providern, PRD F-PRIVACY-01):
  - Text: "Ich bestaetige, dass das Senden dieser Daten an [Provider] mit meinen Datenschutzanforderungen vereinbar ist."
  - Muss angehakt sein bevor "Starten" aktiv wird
  - Dialog `PrivacyWarningDialog` beim ersten Mal anzeigen
- **"Batch starten"-Button:**
  1. `BatchConfig`-Objekt zusammenbauen
  2. In DB speichern: `db.batchesDao.insertBatch(BatchesCompanion(id: Value(batchId), projectId: ..., configJson: Value(jsonEncode(config.toJson())), status: Value('created')))`
  3. Navigieren zu `/projects/$projectId/batch/$batchId` (Execution Screen, Phase 4)

### 3.5 Shared Widgets

**Verzeichnis:** `lib/shared/widgets/`

**Status:** Umgesetzt in `lib/shared/widgets/*` (inkl. Nutzung in Batch Wizard Schritten)

Diese Widgets werden von mehreren Screens benutzt. Sie sollten alle **stateless** oder **Consumer-Widgets** sein und ihre Daten ueber Parameter erhalten.

| Widget | Datei | Beschreibung | Benutzt von |
|--------|-------|-------------|-------------|
| `FileSelector` | `file_selector.dart` | FilePicker-Button + Pfad-Anzeige + Typ-Erkennung (Excel/Ordner) | Batch Wizard Schritt 1 |
| `PromptViewer` | `prompt_viewer.dart` | Zeigt Prompt-Text mit Syntax-Highlighting fuer den Platzhalter `[Insert IDs and Items here]` (blau/fett hervorgehoben) | Batch Wizard Schritt 2 |
| `PromptSelector` | `prompt_selector.dart` | Dual-Liste (verfuegbar/ausgewaehlt) mit Buttons und ReorderableListView | Batch Wizard Schritt 2 |
| `ModelSelector` | `model_selector.dart` | Grouped Dropdown mit Provider-Gruppierung, zeigt Preis + Context-Window | Batch Wizard Schritt 4 |
| `ModelConfigurator` | `model_configurator.dart` | Dynamische Parameter-UI (Slider/Dropdown) basierend auf `ModelParameter`-Map | Batch Wizard Schritt 4, Model Manager |
| `CostEstimateCard` | `cost_estimate_card.dart` | Card mit Input/Output-Tokens, API-Calls, geschaetzten Kosten in USD | Batch Wizard Schritt 5 |
| `ProgressBarWidget` | `progress_bar.dart` | LinearProgressIndicator + Prozent + "X/Y Calls" Text | Execution Screen (Phase 4) |
| `LogViewer` | `log_viewer.dart` | ListView von LogEntry mit Farbcodierung: INFO=grau, WARN=amber, ERROR=rot. Auto-scroll, Filter-Dropdown | Execution Screen (Phase 4) |
| `PrivacyWarningDialog` | `privacy_warning_dialog.dart` | AlertDialog: "Datenschutz-Hinweis: Sie senden Daten an [Provider] ([Region]). DSGVO beachten." + "Nicht mehr anzeigen"-Checkbox + "Abbrechen"/"Verstanden"-Buttons | Batch Wizard Schritt 5 |
| `ResumeDialog` | `resume_dialog.dart` | AlertDialog: Checkpoint-Info (Datum, Fortschritt, Tokens) + "Neu starten"/"Fortsetzen"-Buttons | Execution Screen (Phase 4) |

---

## Phase 4: Integration -- ERLEDIGT

### 4.1 Worker Messages (Sealed Classes)

**Status:** Umgesetzt in `lib/workers/worker_messages.dart`

**Neue Datei:** `lib/workers/worker_messages.dart`

Definiere sealed classes fuer die bidirektionale Isolate-Kommunikation:

```dart
// Main Isolate -> Worker
sealed class WorkerCommand {}
class StartBatchCommand extends WorkerCommand {
  final BatchConfig config;
  final List<Item> items;
  final Map<String, String> prompts; // name -> content
  final String projectPath;
  final String? apiKey; // entschluesselt
  StartBatchCommand({required this.config, ...});
}
class PauseBatchCommand extends WorkerCommand {}
class ResumeBatchCommand extends WorkerCommand {}
class StopBatchCommand extends WorkerCommand {}

// Worker -> Main Isolate
sealed class WorkerEvent {}
class ProgressEvent extends WorkerEvent { final BatchProgress progress; }
class LogEvent extends WorkerEvent { final LogEntry entry; }
class CheckpointSavedEvent extends WorkerEvent { final int callCount; }
class BatchCompletedEvent extends WorkerEvent { final BatchStats stats; final List<Map<String, dynamic>> results; }
class BatchErrorEvent extends WorkerEvent { final String message; final String? details; }
```

### 4.2 Batch Execution Worker (Isolate)

**Status:** Vollstaendig umgesetzt in `lib/workers/batch_execution_worker.dart` (Start/Pause/Resume/Stop, Event-Emission, API-Loop, Checkpoints, Fehlerbehandlung)

**Datei:** `lib/workers/batch_execution_worker.dart`

Dies ist das Herzstueck der App. Ein langlebiger Isolate, der:

1. `Isolate.spawn()` mit `SendPort` fuer bidirektionale Kommunikation
2. Empfaengt `StartBatchCommand` mit Config, Items, Prompts
3. **Hauptschleife** (PRD F-EXEC-01):
   ```
   fuer jede Repetition (1..reps):
     items shufflen (falls shuffle=true)
     fuer jeden Prompt:
       chunks = promptService.createChunks(items, chunkSize)
       fuer jeden Chunk:
         -- Pause/Stop-Flag pruefen --
         message = promptService.injectItems(promptTemplate, chunkItems)
         response = llmApiService.callLlm(...)
         parsed = jsonParserService.parseResponse(response.content)
         results.addAll(parsed)
         callCounter++
         if (callCounter % checkpointInterval == 0):
           checkpointService.saveCheckpoint(...)
           sende CheckpointSavedEvent
         sende ProgressEvent
         sende LogEvent
   sende BatchCompletedEvent
   ```
4. **Services im Isolate:** LlmApiService, JsonParserService, CheckpointService, PromptService muessen INNERHALB des Isolates instanziiert werden (sie koennen nicht ueber SendPort uebergeben werden). Die Services benutzen nur Dio (HTTP) und Dateisystem-Operationen -- beides funktioniert in Isolates.
5. **Pause/Stop:** Zwischen jedem Chunk wird ein Flag geprueft. Bei Pause: `Completer` blockiert. Bei Stop: Schleife abbrechen, letzten Checkpoint speichern.

### 4.3 Batch Execution Provider (Riverpod)

**Status:** Vollstaendig umgesetzt in `lib/providers/batch_execution_provider.dart`

**Datei:** `lib/providers/batch_execution_provider.dart`

- `StateNotifier<BatchExecutionState>` mit States: `idle`, `starting`, `running(progress, logs, stats)`, `paused`, `completed(stats, results)`, `failed(error)`
- Startet Isolate, sendet Commands, empfaengt Events
- Aktualisiert State bei jedem Event (ProgressEvent -> progress updaten, LogEvent -> logs-Liste erweitern, etc.)
- Bei App-Schliessung: StopBatchCommand senden

### 4.4 Batch Execution Screen

**Status:** Vollstaendig umgesetzt in `lib/features/batch_execution/batch_execution_screen.dart` und Router an `/projects/:projectId/batch/:batchId` angebunden

**Datei:** `lib/features/batch_execution/batch_execution_screen.dart`

**Hinweis:** Die urspruenglich geplanten Unter-Widgets (`execution_stats_panel.dart`, `execution_controls.dart`) wurden nicht als separate Dateien erstellt. Die Statistik-Anzeige und die Steuer-Buttons sind direkt in `batch_execution_screen.dart` integriert.

**Layout** (PRD 7.3):
- **Oben:** Batch-Name + Status-Badge + Pause/Stop-Buttons
- **Mitte-Links:** Fortschrittsbalken (ProgressBarWidget) + aktuelle Position (Rep X/Y, Prompt "name", Chunk Z/W)
- **Mitte-Rechts:** Statistik-Panel (Dauer, verbleibend, Tokens/min, Items/min, Input/Output-Tokens, Kosten, Fehler)
- **Unten:** LogViewer (mit Filter: All/Errors/Warnings)

**Resume-Logik:** Beim Oeffnen des Screens pruefen: `checkpointService.hasCheckpoint(projectPath, batchId)` -> Falls ja: `ResumeDialog` anzeigen -> Bei "Fortsetzen": Checkpoint laden und an Worker uebergeben.

### 4.5 Report-Generierung

**Status:** Vollstaendig umgesetzt in `lib/services/report_generator_service.dart` und im Execution-Screen angebunden (Excel + Markdown + HTML)

**Datei:** `lib/services/report_generator_service.dart`

3 Formate:

**Excel (P0, aktueller Stand):**
- Nutzt `excel` (MIT, v4.0.6) -- Syncfusion vollstaendig entfernt
- Erste Zeile: Header (ID + alle JSON-Keys aus den Ergebnissen)
- Jede weitere Zeile: ein Item mit seinen Ergebnis-Werten
- Speichern: `File('$resultsDir/results.xlsx').writeAsBytesSync(workbook.encode()!)`
- **Bekanntes Problem (Code Review):** File-Write ohne try/catch (Phase 5.9.2 H6)

**Markdown Log (P0):**
- Session-Info (Start, Ende, Dauer, Status)
- Konfiguration (Model, Chunks, Reps, Prompts)
- Token-Statistiken (Input, Output, Gesamt)
- Kosten-Zusammenfassung
- Fehler-Tabelle
- Prompt-Inhalte

**HTML Report (P1):**
- Standalone HTML mit eingebettetem CSS + JS
- Sidebar-Navigation (Item-Liste mit Suche)
- Summary-Abschnitt (Items, Erfolgsquote, Fehler, Kosten)
- Pro Item ein "Dossier" mit allen Ergebnis-Feldern als Definition-List

### 4.6 Model Manager UI

**Status:** Vollstaendig umgesetzt in `lib/features/model_manager/model_manager_screen.dart` (Tabs: Registry, Custom, Discovered)

**Layout:** `DefaultTabController` mit 3 Tabs:

1. **Registry Models:** Liste aller Models aus `getMergedRegistry()` mit Provider-Gruppierung, Preis, Context-Window, Capabilities-Badges
2. **Custom Models:** User Overrides aus `db.modelsDao`, Bearbeiten/Loeschen
3. **Discovered Models:** (optional P1) API-Discovery -- `GET /models` an Provider senden und verfuegbare Models auflisten

Jedes Model hat einen Detail-Dialog mit allen Feldern (Pricing, Parameters, Capabilities).

---

## Phase 5: Polish -- IN ARBEIT

### 5.1 Lokalisierung (DE/EN) -- ERLEDIGT (Luecken offen)
- ARB-Dateien unter `lib/core/l10n/`: `app_de.arb` (Template), `app_en.arb` (200+ Keys)
- `l10n.yaml` Konfiguration, Output-Klasse `S` in `lib/core/l10n/generated/`
- `localeProvider` + `localeLoaderProvider` in `providers/settings_provider.dart`
- `app.dart` mit `locale`, `localizationsDelegates`, `supportedLocales` verdrahtet
- 27 UI-Dateien lokalisiert: Shell, Settings, Auth, Setup Wizard (6 Steps), Projects (5 Dateien), Batch Wizard (6 Dateien), Batch Execution, Model Manager, 6 Shared Widgets
- `dart analyze`: 0 Errors/Warnings, `flutter test`: 61/61 bestanden
- **Bekannte Luecken (Code Review 2025-02-15):**
  - `password_screen.dart:100` -- hardcodiertes `'Fortfahren'`
  - `batch_execution_screen.dart:85,105,181,182` -- hardcodierte englische Labels (`'Batch Execution'`, `'Batch ID:'`, `'Current Prompt Name:'`, `'Current Model:'`)
  - `model_manager_screen.dart:141,145` -- hardcodiertes `'Bearbeiten'`, `'Loeschen'`
  - `project_detail_screen.dart` -- hardcodierte `'Keine Prompt-Dateien gefunden'`, `'Keine Input-Dateien gefunden'`
  - `prompt_selector.dart:26,115` -- hardcodiertes `'Verfuegbar'`, `'Ausgewaehlt'`
  - `batch_wizard_screen.dart:329` -- hardcodiertes `'Fertig'`
  - `settings_provider.dart:16` -- hardcodierter Default `Locale('de')` statt System-Locale-Erkennung

### 5.2 Settings Screen -- ERLEDIGT (Bug offen)
- `lib/features/settings/settings_screen.dart` vollstaendig implementiert (war Platzhalter)
- 5 Abschnitte: Allgemein (Sprache), Sicherheit (Passwort aendern + Provider verwalten), Datenschutz (Strict Local Mode), Erweitert (Checkpoint-Intervall Slider), Reset
- Passwort-Aenderung mit Verifikation und automatischer Re-Verschluesselung aller API-Keys
- Provider-Verwaltungsdialog mit Enable/Disable Toggle und Delete
- App-Reset mit Bestaetigungsdialog
- **Bug (Code Review 2025-02-15):** Re-Verschluesselung bei Passwort-Aenderung (Zeilen 298-315) ist nicht transaktional. Wenn die Re-Verschluesselung eines Providers fehlschlaegt, bleibt der Encryption-State inkonsistent. Loesung: Erst alle Keys entschluesseln, dann neues Passwort setzen, dann alle Keys re-verschluesseln. Rollback bei Fehler.

### 5.3 Fehlerbehandlung + UX -- ERLEDIGT
- Globaler Error Handler in `main.dart`: `FlutterError.onError` + `PlatformDispatcher.instance.onError` mit `logging`-basiertem Output
- Graceful Shutdown: `_AppLifecycleWrapper` mit `WidgetsBindingObserver` -- bei `paused`/`detached` werden laufende Batches automatisch pausiert (Checkpoint)
- `ProviderContainer` + `UncontrolledProviderScope` fuer Lifecycle-Zugriff ausserhalb des Widget-Trees
- Tastaturkuerzel via `CallbackShortcuts`: Escape=Zurueck (`app_shell.dart`), Ctrl+N=Neues Projekt, Ctrl+O=Oeffnen (`project_manager_screen.dart`), F5=Batch starten (`batch_execution_screen.dart`)

### 5.4 Testing -- TEILWEISE ERLEDIGT
- **Unit Tests** (`test/services/`): 4 Services mit 61 Tests implementiert:
  - `encryption_service_test.dart` (13 Tests): Salt, Hash, Verify, Unlock/Lock, Encrypt/Decrypt Roundtrip
  - `json_parser_service_test.dart` (9 Tests): Alle 5 Strategien, Fehlerfall, leerer String
  - `prompt_service_test.dart` (12 Tests): Platzhalter, Injection, Validierung, Chunks
  - `token_estimation_service_test.dart` (10 Tests): Tokenizer, Batch-Kosten, Call-Kosten
- **Null-Safety-Fix** in `ModelRegistryService`: Sichere `is Map`-Checks statt unsicherer Casts, Logging statt stiller `catch (_)`
- **Verifiziert (Code Review 2025-02-15):** `flutter test`: 61/61 bestanden, 0 Fehler
- **Offen -- Widget Tests** (`test/widgets/`): Keine vorhanden. Prioritaet:
  - Setup Wizard: Passwort-Validierung, Provider-Auswahl, Verbindungstest
  - Batch Wizard: Item-Parsing, Prompt-Auswahl, Kosten-Schaetzung
  - Settings: Passwort-Aenderung, Provider-Toggle, Reset
  - Auth: Passwort-Eingabe, Fehlerfall, Reset-Flow
- **Offen -- Integration Tests** (`integration_test/`): Keine vorhanden. Prioritaet:
  - Ende-zu-Ende: Setup -> Auth -> Projekt -> Batch -> Ergebnis
  - Batch mit lokalem Ollama (10 Items, 1 Prompt)

### 5.5 Windows-Distribution
- `flutter build windows --release`
- MSIX-Paket (`msix` Flutter-Package) oder Inno Setup
- App-Icon in `windows/runner/resources/app_icon.ico`
- Build-Voraussetzungen fuer OCR-native Plugins (Rust/LLVM/CMake/MSVC) ueber `scripts/setup_windows_build.ps1` vorab pruefen.

### 5.5.1 Build-Toolchain fuer OCR (NEU, P0 fuer `pdf_ocr`)
- Rust Toolchain auf Windows bereitstellen: `rustup`, `rustc`, `cargo`.
- Erzwingen: `rustup default stable-x86_64-pc-windows-msvc` (kein GNU-Target).
- LLVM/Clang installieren und `LIBCLANG_PATH` setzen (typisch: `C:\Program Files\LLVM\bin`).
- VS Build Tools mit C++ Workload + Windows SDK + CMake-Tools sicherstellen.
- Lokale Verifikation: `powershell -ExecutionPolicy Bypass -File scripts/setup_windows_build.ps1 -InstallHints`.

### 5.5.2 CI Build-Haertung (NEU)
- In GitHub Actions vor `flutter build windows`:
  - Rust Toolchain installieren/aktivieren (`stable-x86_64-pc-windows-msvc`).
  - LLVM installieren und `LIBCLANG_PATH` in `GITHUB_ENV` setzen.
- Cargo-Caching aktivieren:
  - `~/.cargo/registry`
  - `~/.cargo/git`
  - Cache-Key mit `pubspec.lock` hashen.
- Erwartung: Erster Lauf langsam (Cache Miss), Folge-Laeufe deutlich schneller (Cache Hit).

### 5.5.3 Release-on-Tag fuer QA (NEU)
- Trigger auf Tags `v*` aktivieren.
- `build/windows/x64/runner/Release/*` zu `XtractAid-Windows.zip` packen.
- Artifact in GitHub Release hochladen (`softprops/action-gh-release`).
- QA-Flow: ZIP herunterladen, entpacken, `xtractaid.exe` direkt starten (portable Bundle).

### 5.6 Dokument-Pipeline Hardening (NEU, Prioritaet P0)

Ziel: Die Risiken DOCX-Qualitaet, komplexe PDF-Extraktion, ungenaue Token-Schaetzung und Syncfusion-Lizenz in einem konsistenten Open-Source-Stack beseitigen, ohne den Standard-Build unnoetig aufzublaehen.

#### 5.6.1 DOCX-Parsing-Qualitaet
- Bestehenden Pure-Dart-OOXML-Parser in `FileParserService.parseDocx()` erweitern (Dokument + Header/Footer + Footnotes + robustere XML-Namespace-Behandlung).
- Fallback-Logik fuer defekte oder nicht-standardkonforme Dateien beibehalten.
- Parsing im Hintergrund (`compute`) ausfuehren, inkl. Timeout und klaren Fehlercodes.
- Testkorpus aufbauen (mind. 30 DOCX-Dateien: Tabellen, Fussnoten, Header/Footer, Sonderzeichen, lange Dokumente).
- Akzeptanzkriterium: >= 98% erfolgreich extrahierte Dokumente ohne Crash und semantisch lesbarer Klartext.

#### 5.6.2 PDF-Textextraktion bei komplexen PDFs
- Digitale Textextraktion auf `pdfrx` (PDFium via FFI, MIT) migrieren.
- Qualitaets-Scoring einfuehren (Textlaenge, druckbare Zeichenquote, Wiederholungsmuster, Nulltext-Erkennung).
- OCR-Fallback nur bei schlechter Textqualitaet aktivieren, nicht pauschal.
- OCR mit `pdf_ocr` (MIT/Apache) hinter Feature-Flag (`enableOcrFallback`) integrieren, aber nur wenn Toolchain-Gate gruen ist.
- Bei fehlender Toolchain: OCR-Hook aktiv lassen, `pdf_ocr` nicht im Standard-Build erzwingen.
- Buildgroesse steuern: OCR als optionaler Add-on-Installer/Build-Flavor, Standard-Release ohne OCR-Ballast.
- Akzeptanzkriterium: Komplexe PDF-Suite (mind. 20 Dateien) mit signifikant weniger Leer-/Garbage-Extraktionen gegenueber aktuellem Stand.

#### 5.6.3 Praezise Token-Schaetzung -- TEILWEISE ERLEDIGT
- **Erledigt:** `tiktoken_tokenizer_gpt4o_o1` ist in `pubspec.yaml` und `TokenEstimationService` integriert. Primaer wird `o200k_base` Tokenizer verwendet.
- **Erledigt:** Caching via `_tokenCache` mit Hash aus `(modelId, text)` vorhanden.
- **Offen:** Fallback auf `chars/4` ist noch aktiv (Zeile 39) -- sollte geloggt werden wenn Fallback greift.
- **Offen:** Modell-Mapping fuer Nicht-OpenAI-Modelle fehlt (Anthropic, Google, Ollama nutzen immer Fallback).
- **Offen:** Cache-Eviction ist `clear()` bei >1000 Eintraegen statt LRU -- bei grossen Batches ineffizient.
- **Offen:** Magic Number 16 (Formatting-Overhead) in `estimateBatchCost()` nicht dokumentiert.
- **Offen:** UI-Hinweis von "ungefaehr" auf "modellbasiert geschaetzt" umstellen.
- Akzeptanzkriterium: mittlere Abweichung <= 3% gegenueber API-Usage bei Referenz-Testset (mind. 100 Prompts).

#### 5.6.4 Syncfusion-Lizenzrisiko eliminieren -- ERLEDIGT
- **Erledigt:** `syncfusion_flutter_xlsio` und `syncfusion_flutter_pdf` sind NICHT in `pubspec.yaml` oder `pubspec.lock`.
- **Erledigt:** Excel-Export in `ReportGeneratorService` nutzt `excel` (MIT, v4.0.6).
- **Erledigt:** PDF-Verarbeitung nutzt `pdfrx` (MIT, v1.1.22) + Stub `PdfOcrService`.
- **Erledigt:** CI-Lizenz-Guard vorhanden: `scripts/check_dependency_allowlist.dart`.
- **Verifiziert (Code Review 2025-02-15):** `grep -i syncfusion pubspec.lock` -> keine Treffer.

### 5.7 Qualitaets-, Build- und Compliance-Gates (NEU)
- Regressionstests fuer `FileParserService` und `TokenEstimationService` in CI verpflichtend.
- Buildgroessen-Budget definieren (Standard-Windows-Release darf nur moderat wachsen; OCR separat).
- Smoke-Test vor Release: DOCX, Digital-PDF, Scan-PDF (mit OCR-Flag), XLSX-Export, Batch-Ende-zu-Ende.
- Ergebnisprotokoll je Release: Parsing-Qualitaet, Token-Abweichung, Artefaktgroesse, Lizenzreport.
- CI-Lizenz-/Dependency-Guard aktiv: `scripts/check_dependency_allowlist.dart` + `.github/workflows/ci.yml`.
- Toolchain-Gate aktiv: `scripts/setup_windows_build.ps1` muss auf OCR-Build-Runnern erfolgreich sein.

### 5.8 Junior Guide: Problem -> Loesung (NEU)

#### Problem 1: `flutter build windows` bricht mit `MSB8066` bei `pdf_ocr_cargokit` ab
- Ursache: Rust-Toolchain fehlt oder ist nicht im PATH (haeufig auch fehlendes LLVM/libclang).
- Loesung:
  1. `rustup`, `rustc`, `cargo` installieren.
  2. `rustup default stable-x86_64-pc-windows-msvc` setzen.
  3. LLVM installieren und `LIBCLANG_PATH` konfigurieren.
  4. Mit `scripts/setup_windows_build.ps1` pruefen.

#### Problem 2: OCR-Build ist lokal/CI instabil
- Ursache: Native OCR-Abhaengigkeiten sind schwergewichtig und umgebungssensitiv.
- Loesung:
  1. OCR nur ueber Feature-Flag/Fallback einschalten.
  2. Standard-Build ohne harte OCR-Abhaengigkeit stabil halten.
  3. OCR erst aktivieren, wenn Toolchain-Gate gruen ist.

#### Problem 3: CI-Builds dauern mit Rust zu lange
- Ursache: Rust Crates werden ohne Cache bei jedem Lauf neu geladen.
- Loesung:
  1. Cargo-Registry/Git in CI cachen.
  2. Cache-Key an `pubspec.lock` koppeln.
  3. Ersten Lauf als Cache-Miss akzeptieren, Folge-Laeufe nutzen Cache-Hits.

#### Problem 4: QA bekommt kein lauffaehiges Windows-Paket
- Ursache: Flutter Windows erzeugt einen Ordnerverbund, keine Einzel-EXE.
- Loesung:
  1. Release-Ordner zippen.
  2. Upload als GitHub Release auf Tag `v*`.
  3. QA testet portable ZIP (entpacken, EXE starten).

### 5.9 Bug-Fixes und Haertung (Code Review 2025-02-15, Prioritaet P0)

Ergebnis des umfassenden Code Reviews. Alle Issues sind nach Schweregrad sortiert und muessen vor dem ersten Release behoben werden.

#### 5.9.1 KRITISCH -- Blockiert Produktion -- **ALLE BEHOBEN**

| # | Datei | Problem | Loesung | Status |
|---|-------|---------|---------|--------|
| K1 | `file_parser_service.dart` | `Excel.decodeBytes()` ohne try/catch -- App crasht bei korrupten Excel-Dateien | try/catch mit benutzerfreundlicher Fehlermeldung | **ERLEDIGT** |
| K2 | `file_parser_service.dart` | `compute()` fuer DOCX-Parsing hat kein Timeout -- UI friert bei grossen/defekten Dateien ein | 30-Sekunden `.timeout()` auf `compute()` mit `TimeoutException`-Handling | **ERLEDIGT** |
| K3 | `file_parser_service.dart` | Sheet-Name existiert nicht -> Null-Pointer-Crash auf `.rows` | `tables.isEmpty` + `containsKey(sheetName)` Check | **ERLEDIGT** |
| K4 | `batch_execution_worker.dart` | Einzelner API-Fehler bricht gesamten Batch ab -- kein Retry, kein Skip | Retry-Loop (maxRetries, exponential backoff), dann Skip+Continue, `failedApiCalls` zaehlen | **ERLEDIGT** |
| K5 | `llm_api_service.dart` | Google API-Key im URL-Query-Parameter sichtbar (`?key=$apiKey`) | API-Key in Header `x-goog-api-key` verschoben | **ERLEDIGT** |
| K6 | `batch_execution_provider.dart` | Race Condition: `state` wird VOR Command-Senden geaendert (pause/resume/stop) | Null/Running-Guard vor Command-Senden, `errorMessage` bei Stop | **ERLEDIGT** |
| K7 | `settings_screen.dart` | Re-Verschluesselung bei Passwort-Aenderung nicht transaktional -- inkonsistenter State bei Teil-Fehler | 4-Schritt-Atomare Re-Encryption: decrypt all -> new hash -> re-encrypt all -> persist, mit Rollback | **ERLEDIGT** |

#### 5.9.2 HOCH -- Vor Release beheben -- **ALLE BEHOBEN**

| # | Datei | Problem | Loesung | Status |
|---|-------|---------|---------|--------|
| H1 | `file_parser_service.dart` | Keine Dateigroessen-Pruefung -- Memory Exhaustion bei grossen Dateien | `_checkFileSize()` mit 500 MB Limit vor jedem Parse-Aufruf | **ERLEDIGT** |
| H2 | `batch_execution_worker.dart` | Bei Stop/Pause wird kein Checkpoint gespeichert -- Datenverlust | Checkpoint-Save vor `return` bei Stop-Request mit vollem `BatchProgress` | **ERLEDIGT** |
| H3 | `batch_execution_worker.dart` | Kein Gesamt-Timeout fuer Batch -- haengende Batches blockieren ewig | `maxBatchDuration` (24h) Check in Worker-Loop, `AppConstants` erweitert | **ERLEDIGT** |
| H4 | `model_registry_service.dart` | Unsichere Casts bei Remote-Registry-Merge (`addAll` auf ungepruefte Maps) | Defensive `is Map` Checks vor `addAll()` bei Providers und Models | **ERLEDIGT** |
| H5 | `llm_api_service.dart` | `(data['choices'] as List).first` ohne Bounds-Check -- Crash bei leerer Response | `choices == null \|\| choices.isEmpty` Check, Return `LlmResponse(content: '', finishReason: 'empty')` | **ERLEDIGT** |
| H6 | `report_generator_service.dart` | File-Write ohne try/catch -- Crash bei fehlenden Berechtigungen | `try/on FileSystemException catch` um `generateReports()` | **ERLEDIGT** |
| H7 | `batch_execution_worker.dart` | Kosten werden im Worker nicht berechnet (nur Tokens) | Per-Call-Kostenberechnung aus `inputTokens * inputPricePerMillion + outputTokens * outputPricePerMillion`, Pricing via `StartBatchCommand` | **ERLEDIGT** |
| H8 | `report_generator_service.dart` | Markdown-Escaping unvollstaendig (nur `\|` und `\n`) | `_escapeMd()` erweitert: `\\`, Backticks, `*`, `_`, `[`, `]` | **ERLEDIGT** |

#### 5.9.3 MITTEL -- Code-Qualitaet und UX -- **8/10 BEHOBEN**

| # | Datei | Problem | Loesung | Status |
|---|-------|---------|---------|--------|
| M1 | Diverse UI-Dateien | Services direkt instanziiert statt via Riverpod | Riverpod-Provider fuer alle Services einfuehren | Aufgeschoben (reiner Refactor, keine Funktionsaenderung) |
| M2 | `batch_execution_provider.dart` | Hardcodierter deutscher String ("Checkpoint gespeichert bei Call...") | Englischer Log-String: "Checkpoint saved at call ..." | **ERLEDIGT** |
| M3 | `batch_execution_provider.dart` | `stop()` setzt Status auf `failed` ohne Error-Message | `errorMessage: 'Batch stopped by user.'` gesetzt (via K6) | **ERLEDIGT** |
| M4 | `token_estimation_service.dart` | Cache leert sich komplett bei >1000 Eintraegen | LRU-Cache via `LinkedHashMap`, Eviction des aeltesten Eintrags bei >1000 | **ERLEDIGT** |
| M5 | `token_estimation_service.dart` | Tiktoken-Initialisierung bei Class-Load ohne Error-Handling | Lazy Init via `_getO200kTokenizer()`/`_getCl100kTokenizer()` mit try/catch und Fallback-Logging | **ERLEDIGT** |
| M6 | `llm_api_service.dart` | Hardcodierter Test-Modellname `'claude-3-5-haiku-20241022'` | Aktualisiert auf `'claude-haiku-4-5-20251001'` | **ERLEDIGT** |
| M7 | `model_registry_service.dart` | In-Memory-Cache wird nie invalidiert | `_inMemoryCacheTtl = Duration(hours: 1)` fuer Session-Cache | **ERLEDIGT** |
| M8 | Diverse UI-Dateien | Stille `catch (_)` Bloecke ohne Logging | Alle `catch (_)` durch `catch (e) { _log.warning('...', e); }` ersetzt in SetupWizard + BatchWizard | **ERLEDIGT** |
| M9 | `batch_execution_worker.dart` | Hardcodierte Default-Base-URLs fuer Provider | Aufgeschoben (URLs sind Fallbacks, tatsaechliche URLs kommen via Command) | Aufgeschoben |
| M10 | `setup_wizard_screen.dart` + `batch_wizard_screen.dart` | `BuildContext` nach async Gap ohne `mounted`-Check | `if (mounted)` Guards vor allen `S.of(context)` nach async Gaps -- 0 Info-Meldungen in `dart analyze` | **ERLEDIGT** |

#### 5.9.4 NIEDRIG -- Verbesserungen fuer spaeter

| # | Datei | Problem | Loesung |
|---|-------|---------|---------|
| N1 | `app_theme.dart` | Nur Light-Theme vorhanden | Dark-Theme ergaenzen (Phase 6) |
| N2 | Diverse UI-Dateien | Keine Accessibility-Labels (Semantics) | `Semantics`-Widgets fuer Screen-Reader hinzufuegen |
| N3 | `project_card.dart` | Manuelle Datumsformatierung statt `intl` | `DateFormat` aus `intl`-Paket nutzen |
| N4 | `app_constants.dart` | Fehlende Grenzen: `maxBatchSize`, `maxRequestSizeKb`, `maxTotalTokensPerBatch` | Sinnvolle Defaults definieren |
| N5 | `file_parser_service.dart` | PDF-Qualitaets-Heuristik (0.7 printable, 0.05 unique) nicht dokumentiert | Magic Numbers als benannte Konstanten mit Kommentar |

### 5.10 Fehlende PRD-Features (PRD-Abgleich 2025-02-15)

Systematischer Vergleich der PRD (`specs/XtractAid_PRD_Final.md`) mit dem implementierten Code. Diese Features sind in der PRD spezifiziert, aber im Code nicht oder nur teilweise vorhanden.

#### 5.10.1 NICHT IMPLEMENTIERT -- MVP P0 -- **ALLE IMPLEMENTIERT**

| # | PRD-Ref | Feature | Beschreibung | Status |
|---|---------|---------|-------------|--------|
| F1 | F-EXEC-05 | **Ergebnis-Aggregation mit Namenskonvention** | Result-Keys als `fieldName_from_templateName_rep_N`, fehlende Items als `MissingInResponse_from_templateName_rep_N = true` | **ERLEDIGT** |
| F2 | F-LOG-03 | **API-Key-Maskierung in Logs** | `maskSecrets()` in `lib/core/utils/log_masking.dart`: OpenAI, Anthropic, Google Key-Patterns -> `[REDACTED:*-key]`. Integriert in Worker `_emitLog`/`_emitError` | **ERLEDIGT** |
| F3 | PRD 1.4 | **System-Prompt bei API-Calls** | `AppConstants.systemPrompt` als `role: 'system'` vor User-Prompt im Worker eingefuegt | **ERLEDIGT** |
| F4 | PRD 7.3 | **Request Delay (konfigurierbar)** | `requestDelaySeconds` in `ChunkSettings` (freezed), `Future.delayed` nach jedem API-Call im Worker | **ERLEDIGT** |

#### 5.10.2 NICHT IMPLEMENTIERT -- MVP P1

| # | PRD-Ref | Feature | Beschreibung | Aufwand |
|---|---------|---------|-------------|---------|
| F5 | F-BATCH-04 | **Supervisor-Modus** | Schritt-fuer-Schritt-Bestaetigung vor jedem API-Call (fuer Tests/Debugging). Kein Code vorhanden. Benoetigt neues UI-Element + Worker-Command `ConfirmCallCommand`. | Gross |
| F6 | F-PRIVACY-02 | **Strict-Local-Mode Lock-Icon** | Wenn `strict_local_mode = true`, soll ein Schloss-Symbol in der Titelleiste (`AppShell`) erscheinen. Remote-Provider muessen ausgegraut werden in Batch Wizard Schritt 4 und Model Manager. | Klein |
| F7 | F-PROJ-02 | **Project-Settings in `project.xtractaid.json`** | PRD spezifiziert `settings`-Objekt in der Projektdatei: `strict_local_mode`, `default_model`, `privacy_warning_dismissed`, `language`. Aktuell werden diese nur global in der DB gespeichert, nicht pro Projekt. | Mittel |
| F8 | 4.4 | **ResultsScreen / DataTableWidget** | PRD zeigt einen dedizierten Results-Viewer-Screen mit Sort/Filter-Tabelle. Fehlt komplett -- nach Batch-Abschluss gibt es keinen Weg, Ergebnisse in der App zu betrachten (nur via externe Excel/HTML-Dateien). | Gross |
| F9 | D (Anhang) | **Fehlende Tastaturkuerzel** | Implementiert: Escape, Ctrl+N, Ctrl+O, F5. Fehlend: `Ctrl+S` (Speichern), `Ctrl+Shift+N` (Neuer Batch), `Ctrl+P` (Batch pausieren), `F1` (Hilfe). | Klein |

#### 5.10.3 TEILWEISE IMPLEMENTIERT

| # | PRD-Ref | Feature | Ist-Zustand | Delta | Status |
|---|---------|---------|-------------|-------|--------|
| F10 | F-REGISTRY-05 | **Remote Registry Auto-Update** | Remote-Fetch on-demand, In-Memory-Cache TTL 1h, Remote-Cache 7 Tage. | Woechentlicher Hintergrund-Check mit User-Notification fehlt | Offen |
| F11 | F-INPUT-03 | **Folder-Loading Statistiken** | >5M-Chars-Warnung funktioniert. Item-Count wird angezeigt. | "Groesstes Dokument"-Statistik fehlt in UI | Offen |
| F12 | F-CHKPT-04 | **Checkpoint Auto-Cleanup** | `cleanupOldCheckpoints()` wird nach `BatchCompletedEvent` im Provider automatisch getriggert (unawaited, mit Error-Handling) | -- | **ERLEDIGT** |
| F13 | F-EXEC-03 | **Retry-Logik im Worker** | Worker hat Retry-Loop mit exponential Backoff (maxRetries), dann Skip+Continue. `failedApiCalls` werden gezaehlt. Durch K4 vollstaendig implementiert | -- | **ERLEDIGT** |

#### 5.10.4 Priorisierte Reihenfolge fuer Implementierung

**Sofort (vor MVP-Release) -- ALLE ERLEDIGT:**
1. ~~F3 -- System-Prompt~~ **ERLEDIGT**
2. ~~F2 -- Log-Maskierung~~ **ERLEDIGT**
3. ~~F1 -- Ergebnis-Aggregation~~ **ERLEDIGT**
4. ~~F4 -- Request Delay~~ **ERLEDIGT**
5. ~~F12 -- Checkpoint Auto-Cleanup~~ **ERLEDIGT**
6. ~~F13 -- Worker-Level-Recovery~~ **ERLEDIGT**

**Vor Version 1.0:**
7. F6 -- Lock-Icon fuer Strict Local Mode
8. F9 -- Fehlende Tastaturkuerzel
9. F7 -- Projekt-Settings in JSON
10. F11 -- Folder-Loading Statistiken

**Version 1.1:**
11. F8 -- ResultsScreen mit DataTable
12. F5 -- Supervisor-Modus
13. F10 -- Remote Registry Auto-Update

---

## Bisher erstellte Dateien

### Phase 1 (Foundation)
```
pubspec.yaml
assets/model_registry.json
lib/main.dart
lib/app.dart
lib/core/constants/app_constants.dart
lib/core/theme/app_theme.dart
lib/core/router/app_router.dart
lib/core/shell/app_shell.dart
lib/data/database/app_database.dart
lib/data/database/app_database.g.dart                     (generiert)
lib/data/database/tables/settings_table.dart
lib/data/database/tables/providers_table.dart
lib/data/database/tables/models_table.dart
lib/data/database/tables/projects_table.dart
lib/data/database/tables/batches_table.dart
lib/data/database/tables/batch_logs_table.dart
lib/data/database/daos/settings_dao.dart
lib/data/database/daos/settings_dao.g.dart                (generiert)
lib/data/database/daos/providers_dao.dart
lib/data/database/daos/providers_dao.g.dart               (generiert)
lib/data/database/daos/models_dao.dart
lib/data/database/daos/models_dao.g.dart                  (generiert)
lib/data/database/daos/projects_dao.dart
lib/data/database/daos/projects_dao.g.dart                (generiert)
lib/data/database/daos/batches_dao.dart
lib/data/database/daos/batches_dao.g.dart                 (generiert)
lib/data/database/daos/batch_logs_dao.dart
lib/data/database/daos/batch_logs_dao.g.dart              (generiert)
lib/data/models/provider_config.dart
lib/data/models/provider_config.freezed.dart              (generiert)
lib/data/models/provider_config.g.dart                    (generiert)
lib/data/models/model_info.dart
lib/data/models/model_info.freezed.dart                   (generiert)
lib/data/models/model_info.g.dart                         (generiert)
lib/data/models/batch_config.dart
lib/data/models/batch_config.freezed.dart                 (generiert)
lib/data/models/batch_config.g.dart                       (generiert)
lib/data/models/batch_stats.dart
lib/data/models/batch_stats.freezed.dart                  (generiert)
lib/data/models/batch_stats.g.dart                        (generiert)
lib/data/models/cost_estimate.dart
lib/data/models/cost_estimate.freezed.dart                (generiert)
lib/data/models/cost_estimate.g.dart                      (generiert)
lib/data/models/item.dart
lib/data/models/item.freezed.dart                         (generiert)
lib/data/models/item.g.dart                               (generiert)
lib/data/models/checkpoint.dart
lib/data/models/checkpoint.freezed.dart                   (generiert)
lib/data/models/checkpoint.g.dart                         (generiert)
lib/data/models/log_entry.dart
lib/data/models/log_entry.freezed.dart                    (generiert)
lib/data/models/log_entry.g.dart                          (generiert)
lib/services/encryption_service.dart
lib/services/model_registry_service.dart
lib/providers/database_provider.dart
lib/providers/encryption_provider.dart
lib/providers/model_registry_provider.dart
lib/providers/settings_provider.dart
```

### Phase 2 (Core Services)
```
lib/services/file_parser_service.dart
lib/services/llm_api_service.dart
lib/services/json_parser_service.dart
lib/services/checkpoint_service.dart
lib/services/token_estimation_service.dart
lib/services/prompt_service.dart
lib/services/project_file_service.dart
lib/services/lm_studio_cli_service.dart
lib/services/pdf_ocr_service.dart                         (Stub fuer OCR-Fallback)
```

### Phase 3 (Frontend Core)
```
lib/features/setup_wizard/setup_wizard_screen.dart
lib/features/setup_wizard/steps/step_welcome.dart
lib/features/setup_wizard/steps/step_password.dart
lib/features/setup_wizard/steps/step_provider.dart
lib/features/setup_wizard/steps/step_api_key.dart
lib/features/setup_wizard/steps/step_basic_settings.dart
lib/features/setup_wizard/steps/step_finish.dart
lib/features/auth/password_screen.dart
lib/features/project_manager/project_manager_screen.dart
lib/features/project_manager/project_detail_screen.dart
lib/features/project_manager/widgets/project_card.dart
lib/features/project_manager/widgets/new_project_dialog.dart
lib/features/project_manager/widgets/open_project_dialog.dart
lib/providers/project_provider.dart
lib/features/batch_wizard/batch_wizard_screen.dart
lib/features/batch_wizard/steps/step_items.dart
lib/features/batch_wizard/steps/step_prompts.dart
lib/features/batch_wizard/steps/step_chunks.dart
lib/features/batch_wizard/steps/step_model.dart
lib/features/batch_wizard/steps/step_confirm.dart
lib/shared/widgets/file_selector.dart
lib/shared/widgets/prompt_viewer.dart
lib/shared/widgets/prompt_selector.dart
lib/shared/widgets/model_selector.dart
lib/shared/widgets/model_configurator.dart
lib/shared/widgets/cost_estimate_card.dart
lib/shared/widgets/progress_bar.dart
lib/shared/widgets/log_viewer.dart
lib/shared/widgets/privacy_warning_dialog.dart
lib/shared/widgets/resume_dialog.dart
```

### Phase 4 (Integration)
```
lib/workers/worker_messages.dart
lib/workers/batch_execution_worker.dart
lib/providers/batch_execution_provider.dart
lib/features/batch_execution/batch_execution_screen.dart
lib/services/report_generator_service.dart
lib/features/model_manager/model_manager_screen.dart
```

### Phase 5 (Polish)
```
lib/features/settings/settings_screen.dart                (implementiert in Phase 5.2, K7 Atomic Re-Encryption)
lib/core/l10n/generated/app_localizations.dart            (generiert)
lib/core/l10n/generated/app_localizations_de.dart         (generiert)
lib/core/l10n/generated/app_localizations_en.dart         (generiert)
lib/core/utils/log_masking.dart                           (NEU: F2 API-Key-Maskierung)
scripts/check_dependency_allowlist.dart                   (CI-Lizenz-Guard)
scripts/setup_windows_build.ps1                           (Toolchain-Pruefung)
test/services/encryption_service_test.dart
test/services/json_parser_service_test.dart
test/services/prompt_service_test.dart
test/services/token_estimation_service_test.dart
test/widget_test.dart                                     (Minimal-Test -> erweitern in Phase 5.4)
```

---

## Risiken

| Risiko | Mitigation | Status |
|--------|-----------|--------|
| ~~Batch-Worker bricht bei Einzelfehler ab~~ | Retry-Logik + Skip-and-Continue (K4) | **Erledigt** |
| ~~API-Key im URL bei Google~~ | Header-basierte Authentifizierung (K5) | **Erledigt** |
| ~~Daten-Korruption bei Passwort-Aenderung~~ | Transaktionale Re-Verschluesselung (K7) | **Erledigt** |
| ~~File-Parser crasht bei korrupten Dateien~~ | Error-Handling + Timeout + Groessenprüfung (K1-K3, H1) | **Erledigt** |
| DOCX-Parsing-Qualitaet | Erweiterter Pure-Dart-OOXML-Parser + Fallback-Logik + Testkorpus | In Arbeit (Phase 5.6.1) |
| PDF-Textextraktion bei komplexen PDFs | `pdfrx` fuer Digital-PDF + qualitaetsgesteuerter OCR-Fallback (Feature-Flag + OCR-Service-Hook), `pdf_ocr` nur mit gruenem Toolchain-Gate | In Arbeit (Phase 5.6.2) |
| Isolate-Kommunikation Komplexitaet | Klares sealed-class Protokoll mit WorkerMessageCodec | Erledigt (Phase 4) |
| Token-Schaetzung ungenau (Fallback chars/4) | Tiktoken integriert mit Lazy-Init (M5), LRU-Cache (M4). Fallback fuer Nicht-OpenAI-Modelle noch aktiv | Teilweise erledigt |
| Syncfusion Lizenz | Vollstaendige Migration auf MIT/Apache-Stack | **Erledigt** (verifiziert 2025-02-15) |
| OCR Build-Umgebung fehlt (Rust/LLVM/CMake) | `scripts/setup_windows_build.ps1` lokal + Toolchain-Setup in CI + Runner-Gate | In Arbeit (Phase 5.5.1/5.5.2) |
| Lange CI-Buildzeiten durch Rust | Cargo-Cache mit `pubspec.lock`-basiertem Key | Geplant (Phase 5.5.2) |
| freezed Code-Gen nicht aktiv | Code-Gen laeuft, `.freezed.dart`/`.g.dart` vorhanden | Erledigt |
| ~~Stille Fehlerbehandlung~~ | Alle `catch (_)` durch `catch (e) { _log.warning(...) }` ersetzt (M8) | **Erledigt** |
| **Fehlende Widget-Tests** | 0% UI-Test-Abdeckung. Mindestens kritische Flows testen (Phase 5.4) | **Offen -- Hoch** |
| ~~Kein System-Prompt bei API-Calls~~ | `AppConstants.systemPrompt` als `role: 'system'` im Worker (F3) | **Erledigt** |
| ~~API-Keys nicht in Logs maskiert~~ | `maskSecrets()` in Worker-Logger integriert (F2) | **Erledigt** |
| ~~Ergebnis-Aggregation ohne Namenskonvention~~ | `fieldName_from_templateName_rep_N` Konvention im Worker (F1) | **Erledigt** |
| **Kein ResultsScreen** | User kann Ergebnisse nur extern betrachten (Excel/HTML) (F8) | **Offen -- Mittel** |

---

## Verifizierung

Nach jeder Phase:

| Phase | Pruefung |
|-------|----------|
| Phase 0 | Grep: keine Python/React/Tauri-Reste in Spec-Dokumenten |
| Phase 1 | `dart analyze`: 0 Fehler, `flutter build windows`: OK, App startet |
| Phase 2 | `dart analyze`: 0 Fehler, `flutter build windows`: OK |
| Phase 3 | Setup Wizard komplett durchlaufbar, Projekt anlegen/oeffnen, Batch Wizard konfigurierbar, Passwort-Screen funktioniert |
| Phase 4 | Kompletter Batch-Durchlauf (10 Items, 1 Prompt, Ollama lokal), Excel-Export pruefbar, Live-Log, Pause/Resume funktioniert |
| Phase 5 | DE/EN Sprachwechsel, Unit Tests gruen, Windows-Installer laeuft auf sauberem System, DOCX/PDF/Token-Hardening nachweisbar, keine Syncfusion-Abhaengigkeit in `pubspec.lock`, OCR-Toolchain-Gate dokumentiert/verifiziert, CI Cargo-Cache aktiv, Tag-Release-Flow fuer QA laeuft |
| **Code Review** | 2025-02-15: `dart analyze`: 0/0/3. `flutter test`: 61/61. 18+ Bugs identifiziert |
| **Bug-Fix-Runde** | 2026-02-15: `dart analyze`: **0 Errors/0 Warnings/0 Info**. `flutter test`: **61/61**. K1-K7 (7/7), H1-H8 (8/8), M2-M10 (8/10), F1-F4 (4/4), F12+F13 (2/2) behoben. Gesamt: **29 Fixes/Features** implementiert |
| **PRD-Abgleich** | P0-Features (F1-F4) ERLEDIGT. F12+F13 ERLEDIGT. Verbleibend: P1-Features (F5-F9), teilweise Features (F10, F11). Naechster Schritt: Lokalisierung, Widget-Tests, Distribution |
