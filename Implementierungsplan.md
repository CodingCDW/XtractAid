# XtractAid Flutter -- Entwicklungsplan

## Fortschritt

| Phase | Status | Anmerkungen |
|-------|--------|-------------|
| Phase 0: Spec-Updates | ERLEDIGT | Alle 3 Spec-Dokumente auf Flutter/Dart aktualisiert |
| Phase 1: Foundation | ERLEDIGT | Projekt, DB, Models, Encryption, Registry, App-Shell, Navigation |
| Phase 2: Core Services | ERLEDIGT | 9 Services implementiert. Kritische Bugs K1-K5 behoben, Haertung H1-H8 abgeschlossen |
| Phase 3: Frontend Core | ERLEDIGT | Setup Wizard, Auth, Project Manager, Batch Wizard, Shared Widgets |
| Phase 4: Integration | ERLEDIGT | Worker, Execution Screen, Reports, Model Manager |
| Phase 5: Polish | IN ARBEIT | 5.1-5.4 weitgehend erledigt. Bug-Fixes ERLEDIGT (29 Fixes). 5.11 API-Fix ERLEDIGT. Offen: Testabdeckung vertiefen (5.4b), Distribution (5.5), Lokalisierungsluecken (5.1b) |
| -- Code Review + Bug-Fixes | ERLEDIGT | 2026-02-15: K1-K7 (7/7), H1-H8 (8/8), M2-M10 (8/10), F1-F4 (4/4), F12+F13 (2/2). `dart analyze`: 0/0/0. `flutter test`: 73/73 |
| -- PRD-Abgleich | ERLEDIGT | P0-Features (F1-F4) implementiert. Offen: P1-Features (F5-F9), teilweise Features (F10, F11) |
| -- API-400-Fix (5.11) | ERLEDIGT | Parameter-Allowlist + Key-Remap fuer OpenAI/Anthropic. 13 neue Tests. `dart analyze`: 0/0/0 |

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

## Detail-Referenz: Datenbank, Models, Services, Providers, Navigation

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
| `ModelRegistryService` | `model_registry_service.dart` | `getMergedRegistry()`, `getProviders()`, `getModelIds()`, `getModelsByProvider()`, `getModelInfo(modelId)` -> ModelInfo, `getModelParameters(modelId)`, `getModelPricing(modelId)` | Model Manager, Batch Wizard, Kosten-Berechnung |
| `FileParserService` | `file_parser_service.dart` | `parseExcel(path, idColumn, itemColumn)`, `parseCsv()`, `parsePdf()`, `parseDocx()`, `parseTextFile()`, `parseFile(path)` (auto-detect), `parseFolderStream()` (async* Stream) | Batch Wizard Schritt 1 |
| `LlmApiService` | `llm_api_service.dart` | `callLlm(providerType, baseUrl, modelId, messages, apiKey, parameters)` -> LlmResponse, `testConnection(providerType, baseUrl, apiKey)` -> bool | Batch Worker, Setup Wizard |
| `JsonParserService` | `json_parser_service.dart` | `parseResponse(response, debugDir)` -> List<Map>? | Batch Worker |
| `CheckpointService` | `checkpoint_service.dart` | `saveCheckpoint(...)`, `loadCheckpoint(projectPath, batchId)`, `hasCheckpoint()`, `deleteCheckpoint()`, `cleanupOldCheckpoints()` | Batch Worker, Resume Dialog |
| `TokenEstimationService` | `token_estimation_service.dart` | `estimateTokens(text)` -> int, `estimateBatchCost(promptTexts, totalItems, chunkSize, reps, maxTokens, pricing)` -> CostEstimate | Batch Wizard Schritt 5 |
| `PromptService` | `prompt_service.dart` | `loadPrompts(promptsDir)` -> Map<name,content>, `hasPlaceholder(text)`, `injectItems(template, items)`, `validatePrompt(text)`, `createChunks(items, chunkSize)` | Batch Wizard, Batch Worker |
| `ProjectFileService` | `project_file_service.dart` | `createProject(path, name, projectId)`, `validateProject(path)` -> Map?, `promptsDir(path)`, `inputDir(path)`, `resultsDir(path)` | Project Manager |
| `LmStudioCliService` | `lm_studio_cli_service.dart` | `loadModel(modelId, onProgress)`, `waitForServer(baseUrl, timeout, pollInterval)`, `isCliAvailable()` | LM Studio Provider-Setup |
| `PdfOcrService` | `pdf_ocr_service.dart` | `ocrPdf(pdfPath)` -> String? (Stub, liefert `null`) | FileParserService (OCR-Fallback) |

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
/setup                            -> SetupWizardScreen (vor erstem Setup)
/auth                             -> PasswordScreen (Passwort-Eingabe)
/projects                         -> ProjectManagerScreen (in AppShell mit NavigationRail)
/projects/:projectId              -> ProjectDetailScreen (Batches + Prompts)
/projects/:projectId/batch/new    -> BatchWizardScreen
/projects/:projectId/batch/:batchId -> BatchExecutionScreen
/models                           -> ModelManagerScreen (in AppShell)
/settings                         -> SettingsScreen (in AppShell)
```

**App-Start-Logik** (`lib/app.dart`): `isSetupCompleteProvider` bestimmt die Initial-Route:
- `false` -> `/setup`
- `true` -> `/auth`

Nach erfolgreicher Passwort-Eingabe navigiert `/auth` zu `/projects`.

### UI-Shell

**Datei:** `lib/core/shell/app_shell.dart`

`NavigationRail` (links) mit 3 Destinations: Projects, Models, Settings. Rechts der Content-Bereich (`child`). Das `ShellRoute`-Layout gilt nur fuer `/projects`, `/models`, `/settings`.

### Konstanten

**Datei:** `lib/core/constants/app_constants.dart`

Wichtige Werte:
- `pbkdf2Iterations`: 100.000
- `saltLength`: 32 Bytes
- `ivLength`: 12 Bytes (AES-GCM)
- `keyLength`: 32 Bytes (AES-256)
- `defaultCheckpointInterval`: 10 API-Calls
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

## Abgeschlossene Phasen (Zusammenfassung)

### Phase 3: Frontend Core -- ERLEDIGT

Alle UI-Screens implementiert:
- **Setup Wizard** (6 Schritte): `lib/features/setup_wizard/` -- Willkommen, Passwort, Provider, API-Key, Einstellungen, Fertig
- **Auth Screen**: `lib/features/auth/password_screen.dart` -- Passwort-Check + Reset-Flow
- **Project Manager**: `lib/features/project_manager/` -- Projekt-Uebersicht, Detail-Screen mit Batches/Prompts/Input-Tabs
- **Batch Wizard** (5 Schritte): `lib/features/batch_wizard/` -- Items, Prompts, Chunks, Model, Bestaetigung
- **Shared Widgets**: `lib/shared/widgets/` -- FileSelector, PromptViewer, PromptSelector, ModelSelector, ModelConfigurator, CostEstimateCard, ProgressBar, LogViewer, PrivacyWarningDialog, ResumeDialog

### Phase 4: Integration -- ERLEDIGT

- **Worker Messages**: `lib/workers/worker_messages.dart` -- Sealed Classes fuer bidirektionale Isolate-Kommunikation (StartBatch, Pause, Resume, Stop / Progress, Log, Checkpoint, Completed, Error)
- **Batch Execution Worker**: `lib/workers/batch_execution_worker.dart` -- Hauptschleife (Repetitions x Prompts x Chunks), Pause/Stop-Flags, Retry-Logik, Checkpoint-Speicherung
- **Batch Execution Provider**: `lib/providers/batch_execution_provider.dart` -- StateNotifier (idle/starting/running/paused/completed/failed), Isolate-Management
- **Batch Execution Screen**: `lib/features/batch_execution/batch_execution_screen.dart` -- Fortschritt, Statistiken, Log-Viewer, Resume-Dialog
- **Report Generator**: `lib/services/report_generator_service.dart` -- Excel (MIT `excel` Paket), Markdown-Log, HTML-Dossier
- **Model Manager**: `lib/features/model_manager/model_manager_screen.dart` -- 3 Tabs (Registry, Custom, Discovered)

---

## Phase 5: Polish -- IN ARBEIT

### 5.1 Lokalisierung (DE/EN) -- ERLEDIGT (Luecken offen)

**Erledigt:**
- ARB-Dateien unter `lib/core/l10n/`: `app_de.arb` (Template), `app_en.arb` (200+ Keys)
- `l10n.yaml` Konfiguration, Output-Klasse `S` in `lib/core/l10n/generated/`
- `localeProvider` + `localeLoaderProvider` in `providers/settings_provider.dart`
- 27 UI-Dateien lokalisiert

**Offene Lokalisierungsluecken:**
- `password_screen.dart:100` -- hardcodiertes `'Fortfahren'`
- `batch_execution_screen.dart:85,105,181,182` -- hardcodierte englische Labels
- `model_manager_screen.dart:141,145` -- hardcodiertes `'Bearbeiten'`, `'Loeschen'`
- `project_detail_screen.dart` -- hardcodierte `'Keine Prompt-Dateien gefunden'`, `'Keine Input-Dateien gefunden'`
- `prompt_selector.dart:26,115` -- hardcodiertes `'Verfuegbar'`, `'Ausgewaehlt'`
- `batch_wizard_screen.dart:329` -- hardcodiertes `'Fertig'`
- `settings_provider.dart:16` -- hardcodierter Default `Locale('de')` statt System-Locale-Erkennung

### 5.2 Settings Screen -- ERLEDIGT

Vollstaendig implementiert in `lib/features/settings/settings_screen.dart`: Sprache, Passwort-Aenderung (mit transaktionaler Re-Verschluesselung K7), Provider-Verwaltung, Strict Local Mode, Checkpoint-Intervall, App-Reset.

### 5.3 Fehlerbehandlung + UX -- ERLEDIGT

- Globaler Error Handler (`main.dart`): `FlutterError.onError` + `PlatformDispatcher.instance.onError`
- Graceful Shutdown: `_AppLifecycleWrapper` pausiert laufende Batches bei App-Schliessung
- Tastaturkuerzel: Escape=Zurueck, Ctrl+N=Neues Projekt, Ctrl+O=Oeffnen, F5=Batch starten

### 5.4 Testing -- TEILWEISE ERLEDIGT

**Aktueller Testbestand im Repo:**
- Service-Tests (`test/services/`): `encryption_service_test.dart`, `json_parser_service_test.dart`, `llm_api_service_test.dart`, `prompt_service_test.dart`, `report_generator_service_test.dart`, `token_estimation_service_test.dart`
- Widget-Tests (`test/widgets/`): Setup Wizard, Batch Wizard, Settings, Auth + `test/widget_test.dart` (Smoke)
- Integration-Tests (`integration_test/`): `e2e_flow_test.dart`, `ollama_10_items_flow_test.dart`

**Letzter dokumentierter Gesamtlauf:**
- `flutter test`: **73/73** (Code-Review/Bug-Fix-Runde am 2026-02-15)

**Offen (5.4b):**
- Widget-Tests von Smoke auf robuste Flow- und Fehlerfall-Abdeckung erweitern
- Integrationstests um reale API/Provider-Szenarien (inkl. Resume/Retry) erweitern

### 5.5 Windows-Distribution -- OFFEN

- `flutter build windows --release`
- MSIX-Paket (`msix` Flutter-Package) oder Inno Setup
- App-Icon in `windows/runner/resources/app_icon.ico`

#### 5.5.1 Build-Toolchain fuer OCR
- Rust Toolchain: `rustup default stable-x86_64-pc-windows-msvc`
- LLVM/Clang + `LIBCLANG_PATH`
- VS Build Tools mit C++ Workload + Windows SDK + CMake-Tools
- Lokale Verifikation: `scripts/setup_windows_build.ps1`

#### 5.5.2 CI Build-Haertung
- Rust + LLVM in GitHub Actions installieren
- Cargo-Caching (`~/.cargo/registry`, `~/.cargo/git`, Key: `pubspec.lock`)

#### 5.5.3 Release-on-Tag fuer QA
- Trigger auf Tags `v*`
- `build/windows/x64/runner/Release/*` als `XtractAid-Windows.zip` in GitHub Release

### 5.6 Dokument-Pipeline Hardening -- TEILWEISE ERLEDIGT

#### 5.6.1 DOCX-Parsing-Qualitaet -- OFFEN
- Pure-Dart-OOXML-Parser erweitern (Header/Footer, Footnotes, robustere XML-Namespaces)
- Testkorpus aufbauen (mind. 30 DOCX-Dateien)
- Akzeptanzkriterium: >= 98% erfolgreich extrahiert

#### 5.6.2 PDF-Textextraktion -- OFFEN
- `pdfrx` (PDFium via FFI) fuer Digital-PDF integriert
- Qualitaets-Scoring einfuehren
- OCR-Fallback mit `pdf_ocr` hinter Feature-Flag, nur bei gruenem Toolchain-Gate

#### 5.6.3 Praezise Token-Schaetzung -- TEILWEISE ERLEDIGT
- **Erledigt:** `tiktoken_tokenizer_gpt4o_o1` integriert, `o200k_base` Tokenizer, LRU-Cache
- **Offen:** Fallback `chars/4` noch aktiv fuer Nicht-OpenAI-Modelle, Magic Number 16 undokumentiert, UI-Hinweis aktualisieren

#### 5.6.4 Syncfusion-Lizenzrisiko -- ERLEDIGT
Vollstaendige Migration auf MIT/Apache-Stack. CI-Lizenz-Guard vorhanden.

### 5.7 Qualitaets-, Build- und Compliance-Gates -- OFFEN

- Regressionstests fuer `FileParserService` und `TokenEstimationService` in CI
- Buildgroessen-Budget definieren
- Smoke-Test vor Release
- CI-Lizenz-Guard aktiv: `scripts/check_dependency_allowlist.dart`

### 5.8 Junior Guide: Problem -> Loesung

| Problem | Ursache | Loesung |
|---------|---------|---------|
| `flutter build windows` bricht mit `MSB8066` bei `pdf_ocr_cargokit` ab | Rust-Toolchain fehlt | `rustup` + LLVM installieren, `scripts/setup_windows_build.ps1` |
| OCR-Build instabil | Native OCR-Abhaengigkeiten schwergewichtig | OCR nur ueber Feature-Flag, Standard-Build ohne OCR |
| CI-Builds mit Rust zu langsam | Rust Crates ohne Cache | Cargo-Cache mit `pubspec.lock`-Key |
| QA bekommt kein lauffaehiges Windows-Paket | Flutter erzeugt Ordnerverbund, keine Einzel-EXE | Release-Ordner zippen, GitHub Release auf Tag `v*` |

### 5.9 Bug-Fixes und Haertung -- ZUSAMMENFASSUNG

Ergebnis des Code Reviews vom 2026-02-15. **29 Fixes/Features** implementiert.

**Kritisch (7/7 behoben):** K1-K3 FileParser Crashes, K4 Worker Retry-Logik, K5 Google API-Key im Header, K6 Race Condition Provider, K7 Transaktionale Re-Encryption.

**Hoch (8/8 behoben):** H1 Dateigroessen-Limit, H2 Checkpoint bei Stop, H3 Batch-Timeout, H4 Registry-Casts, H5 Leere Response, H6 Report File-Write, H7 Kostenberechnung, H8 Markdown-Escaping.

**Mittel (8/10 behoben):** M2-M8, M10 behoben. **Aufgeschoben:** M1 (Services via Riverpod -- reiner Refactor), M9 (Default-Base-URLs -- Fallbacks, keine Auswirkung).

**Niedrig (offen -- spaeter):**
- N1: Dark-Theme (Phase 6)
- N2: Accessibility-Labels
- N3: Datumsformatierung mit `intl`
- N4: Fehlende Grenzen in `app_constants.dart`
- N5: PDF-Qualitaets-Heuristik Magic Numbers dokumentieren

### 5.10 Fehlende PRD-Features

**P0 -- ALLE IMPLEMENTIERT:** F1 Ergebnis-Aggregation, F2 API-Key-Maskierung, F3 System-Prompt, F4 Request Delay, F12 Checkpoint Auto-Cleanup, F13 Retry-Logik.

**P1 -- Offen (vor Version 1.0):**

| # | PRD-Ref | Feature | Aufwand |
|---|---------|---------|---------|
| F6 | F-PRIVACY-02 | Strict-Local-Mode Lock-Icon in Titelleiste + Remote-Provider ausgrauen | Klein |
| F7 | F-PROJ-02 | Projekt-Settings in `project.xtractaid.json` (aktuell nur global in DB) | Mittel |
| F9 | D (Anhang) | Fehlende Tastaturkuerzel: Ctrl+S, Ctrl+Shift+N, Ctrl+P, F1 | Klein |
| F11 | F-INPUT-03 | "Groesstes Dokument"-Statistik in Folder-Loading UI | Klein |

**Version 1.1:**

| # | PRD-Ref | Feature | Aufwand |
|---|---------|---------|---------|
| F5 | F-BATCH-04 | Supervisor-Modus (Schritt-fuer-Schritt-Bestaetigung) | Gross |
| F8 | 4.4 | ResultsScreen mit Sort/Filter-DataTable | Gross |
| F10 | F-REGISTRY-05 | Remote Registry Auto-Update (woechentlicher Hintergrund-Check) | Mittel |

---

## 5.11 API-Calls geben HTTP 400 zurueck -- ERLEDIGT

### Problem

Die Batch-Ausfuehrung schickt API-Anfragen an LLM-Provider, bekommt aber **HTTP 400 Bad Request** zurueck. Ursache: In `lib/services/llm_api_service.dart` wird der `parameters`-Map direkt per Spread-Operator (`...parameters`) in den HTTP-Body eingefuegt -- **alle** Parameter (inkl. unbekannter wie `reasoning_effort`) werden an die API geschickt.

### Betroffene Stellen

| Datei | Zeile | Problem |
|-------|-------|---------|
| `llm_api_service.dart:186` | `_callOpenAiCompatible()` | `...parameters` schickt unbekannte Parameter an OpenAI |
| `llm_api_service.dart:242` | `_callAnthropic()` | `...parameters` + `max_tokens` doppelt gesetzt |

**Nicht betroffen:** `_callGoogle()` und `_callOllama()` filtern Parameter korrekt.

### Datenfluss

```
model_registry.json          <- Definiert alle Parameter pro Model
        |
BatchWizardScreen             <- _defaultParameterValues() baut Map mit ALLEN "supported: true" Parametern
        |
BatchConfig.models[0]         <- parameters-Map in Config gespeichert
        |
Worker Isolate                <- Config serialisiert an Worker
        |
LlmApiService.callLlm()      <- parameters-Map 1:1 an Provider-Methode
        |
...parameters im HTTP-Body    <- ALLES wird an die API geschickt!
```

### Loesung (6 Schritte)

#### Schritt 1: Filter-Hilfsfunktion erstellen

**Datei:** `lib/services/llm_api_service.dart`

```dart
static Map<String, dynamic> _filterParameters({
  required Map<String, dynamic> parameters,
  required Set<String> allowedKeys,
  Map<String, String> keyRemap = const {},
}) {
  final result = <String, dynamic>{};
  for (final key in allowedKeys) {
    if (!parameters.containsKey(key)) continue;
    final value = parameters[key];
    if (value == null) continue;
    final outputKey = keyRemap[key] ?? key;
    result[outputKey] = value;
  }
  return result;
}
```

#### Schritt 2: `_callOpenAiCompatible` reparieren

Neuer Parameter `isNativeOpenAi`. Allowlist: `{'temperature', 'max_tokens', 'top_p', 'frequency_penalty', 'presence_penalty', 'seed'}`. Bei echtem OpenAI: `max_tokens` -> `max_completion_tokens` remappen. `reasoning_effort` nur hinzufuegen wenn nicht `"none"`.

#### Schritt 3: `_callAnthropic` reparieren

Allowlist: `{'temperature', 'max_tokens', 'top_p', 'top_k'}`. `max_tokens` als Pflichtfeld mit Fallback 4096. Kein doppeltes Setzen mehr.

#### Schritt 4: Logging fuer Fehlerdiagnose

- Error-Response-Body bei 4xx loggen (statt nur "DioException 400")
- `_sanitizeForLog()` Hilfsfunktion (Messages kuerzen, Parameter sichtbar)
- Request-Body vor Senden auf `fine`-Level loggen

#### Schritt 5: `model_registry.json` aktualisieren

Bei OpenAI-Modellen `api_name: "max_completion_tokens"` ergaenzen (dokumentarisch).

#### Schritt 6: Tests schreiben

**Datei:** `test/services/llm_api_service_test.dart` (neue Datei)

| Test | Was wird geprueft |
|------|------------------|
| `_filterParameters` basic | Nur Allowlist-Keys kommen durch |
| `_filterParameters` remap | `max_tokens` -> `max_completion_tokens` |
| `_filterParameters` null | Null-Werte uebersprungen |
| OpenAI ohne reasoning | `reasoning_effort: "none"` nicht im Body |
| OpenAI mit reasoning | `reasoning_effort: "high"` im Body |
| OpenAI remap | Body hat `max_completion_tokens` |
| OpenRouter kein remap | Body hat `max_tokens` |
| Anthropic filtert | Unbekannte Parameter nicht im Body |
| Anthropic max_tokens | Immer gesetzt, Fallback 4096 |

### Verifikation

1. `flutter test test/services/llm_api_service_test.dart` -- Unit-Tests laufen
2. `flutter test` -- Komplette Test-Suite gruen
3. Manueller Test: Batch mit OpenAI-Modell -> kein 400
4. Manueller Test: Batch mit Anthropic-Modell -> nur erlaubte Parameter
5. Fehlerfall provozieren -> API-Fehlermeldung in Logs sichtbar

---

## Offene Risiken

| Risiko | Mitigation | Status |
|--------|-----------|--------|
| DOCX-Parsing-Qualitaet | Erweiterter Parser + Testkorpus | Offen (5.6.1) |
| PDF-Textextraktion bei komplexen PDFs | `pdfrx` + qualitaetsgesteuerter OCR-Fallback | Offen (5.6.2) |
| Token-Schaetzung Fallback chars/4 | Tiktoken integriert, aber Nicht-OpenAI nutzt Fallback | Teilweise (5.6.3) |
| OCR Build-Umgebung fehlt (Rust/LLVM) | `scripts/setup_windows_build.ps1` + CI-Gate | Offen (5.5.1/5.5.2) |
| Testtiefe in UI/E2E noch begrenzt | Vorhandene Tests sind noch nicht vollstaendig fuer kritische Fehlerfaelle | **Offen -- Hoch** (5.4b) |
| Kein ResultsScreen | User betrachtet Ergebnisse nur extern | Offen -- Mittel (F8, v1.1) |
| ~~API 400 durch ungefilterte Parameter~~ | ~~Allowlist + Key-Remap in 5.11~~ | **Erledigt** |

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
lib/data/database/tables/settings_table.dart
lib/data/database/tables/providers_table.dart
lib/data/database/tables/models_table.dart
lib/data/database/tables/projects_table.dart
lib/data/database/tables/batches_table.dart
lib/data/database/tables/batch_logs_table.dart
lib/data/database/daos/settings_dao.dart
lib/data/database/daos/providers_dao.dart
lib/data/database/daos/models_dao.dart
lib/data/database/daos/projects_dao.dart
lib/data/database/daos/batches_dao.dart
lib/data/database/daos/batch_logs_dao.dart
lib/data/models/provider_config.dart
lib/data/models/model_info.dart
lib/data/models/batch_config.dart
lib/data/models/batch_stats.dart
lib/data/models/cost_estimate.dart
lib/data/models/item.dart
lib/data/models/checkpoint.dart
lib/data/models/log_entry.dart
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
lib/services/pdf_ocr_service.dart
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
lib/features/settings/settings_screen.dart
lib/core/l10n/app_de.arb
lib/core/l10n/app_en.arb
lib/core/utils/log_masking.dart
scripts/check_dependency_allowlist.dart
scripts/setup_windows_build.ps1
test/services/encryption_service_test.dart
test/services/json_parser_service_test.dart
test/services/llm_api_service_test.dart
test/services/prompt_service_test.dart
test/services/report_generator_service_test.dart
test/services/token_estimation_service_test.dart
test/widgets/auth_screen_test.dart
test/widgets/batch_wizard_screen_test.dart
test/widgets/settings_screen_test.dart
test/widgets/setup_wizard_screen_test.dart
test/widget_test.dart
integration_test/e2e_flow_test.dart
integration_test/ollama_10_items_flow_test.dart
```

---

## Verifizierung

| Phase | Pruefung | Ergebnis |
|-------|----------|----------|
| Phase 1 | `dart analyze`: 0 Fehler, `flutter build windows`: OK | Bestanden |
| Phase 2 | `dart analyze`: 0 Fehler, `flutter build windows`: OK | Bestanden |
| Phase 3 | Setup Wizard, Projekt anlegen/oeffnen, Batch Wizard | Bestanden |
| Phase 4 | Batch-Durchlauf (10 Items, Ollama lokal), Excel-Export, Pause/Resume | Bestanden |
| Phase 5 | DE/EN Sprachwechsel, Testbestand in `test/` + `integration_test/` erweitert, `dart analyze`: 0/0/0 | Bestanden |
| Bug-Fix-Runde | 29 Fixes, `dart analyze`: 0/0/0, `flutter test`: 73/73 (Stand 2026-02-15) | Bestanden |
| 5.11 API-Fix | 13/13 Tests bestanden, `dart analyze`: 0/0/0 | Bestanden |

---

## Naechste Schritte (priorisiert)

1. ~~**5.11 API-400-Fix** -- ERLEDIGT~~
2. **5.1b Lokalisierungsluecken** -- 7 Dateien mit hardcodierten Strings
3. **5.4b Testabdeckung vertiefen** -- Widget/E2E fuer kritische Flows + Fehlerfaelle
4. **5.5 Windows-Distribution** -- MSIX oder Inno Setup + CI Release-Pipeline
5. **5.6 Dokument-Pipeline** -- DOCX-Hardening, PDF-OCR, Token-Schaetzung
6. **P1-Features** -- F6 Lock-Icon, F9 Tastaturkuerzel, F7 Projekt-Settings
