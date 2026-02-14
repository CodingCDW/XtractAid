# XtractAid – Product Requirements Document (PRD)

> **Version:** 4.0  
> **Datum:** 2025-06-01  
> **Status:** Final Draft  
> **Zielgruppe:** Entwickler, Product Owner

---

## Inhaltsverzeichnis

1. [Executive Summary](#1-executive-summary)
2. [Zielgruppen & Use Cases](#2-zielgruppen--use-cases)
3. [Funktionale Anforderungen](#3-funktionale-anforderungen)
4. [Technische Architektur](#4-technische-architektur)
5. [Datenmodelle](#5-datenmodelle)
6. [API-Spezifikation](#6-api-spezifikation)
7. [UI/UX-Spezifikation](#7-uiux-spezifikation)
8. [Nicht-funktionale Anforderungen](#8-nicht-funktionale-anforderungen)
9. [MVP-Scope & Roadmap](#9-mvp-scope--roadmap)
10. [Anhang](#10-anhang)

---

## 1. Executive Summary

### 1.1 Produktvision

**XtractAid** ist eine Desktop-Anwendung für die batch-basierte Analyse von Textdaten mittels Large Language Models (LLMs). Die App richtet sich primär an Wissenschaftler, die große Mengen von Dokumenten oder Datensätzen systematisch analysieren, klassifizieren und bewerten müssen.

### 1.2 Kernkonzept

```
┌─────────┐     ┌─────────┐     ┌─────────┐     ┌──────────────────┐
│  Items  │  +  │ Prompts │  +  │   LLM   │  →  │ Strukturierte    │
│ (Texte) │     │ (Anleit)│     │ (API)   │     │ JSON-Ergebnisse  │
└─────────┘     └─────────┘     └─────────┘     └──────────────────┘
                                                         │
                                                         ▼
                                               ┌──────────────────┐
                                               │ Excel + Report   │
                                               └──────────────────┘
```

### 1.3 Kernfunktionen

| Funktion | Beschreibung |
|----------|--------------|
| **Batch-Verarbeitung** | Hunderte bis tausende Items in einem Durchlauf analysieren |
| **Multi-Prompt** | Mehrere Analyse-Prompts sequentiell auf Items anwenden |
| **Multi-Model** | Verschiedene LLMs vergleichen (Benchmark) |
| **Strukturierte Ausgabe** | JSON-Responses → Excel-Tabelle + HTML-Report |
| **Kostenvoranschlag** | Token-Schätzung und Kosten vor Start |
| **Checkpointing** | Fortschritt speichern, nach Unterbrechung fortsetzen |
| **Datenschutz** | Strict Local Mode für sensible Daten |

### 1.4 System-Prompt (Kernidentität)

> "You are an intelligent assistant designed to help with assessing items (summarize or excerpts or rate). The items can be words, phrases, sentences, titles, or other text. Be precise and thoughtful in your assessments. You always answer in a JSON format without any further comments or explanations."

---

## 2. Zielgruppen & Use Cases

### 2.1 Primäre Zielgruppen

| Persona | Beschreibung | Technisches Niveau |
|---------|--------------|-------------------|
| **Wissenschaftler:in** | Forscher an Universitäten/Instituten, führt Reviews, Metaanalysen, qualitative Studien durch | Mittel (Excel, keine Programmierung) |
| **Klinische Forscher:in** | Analysiert Patientendaten, Fallberichte, klinische Texte | Mittel |

### 2.2 Sekundäre Zielgruppen

| Persona | Beschreibung |
|---------|--------------|
| **HR-Manager:in** | Screening großer Bewerbungsmengen |
| **Controller:in** | Analyse von Rechnungen, Verträgen, Dokumenten |

### 2.3 Use Cases

#### UC1: Wissenschaftlicher Literatur-Review

**Akteur:** Wissenschaftler  
**Ziel:** Systematische Analyse von 300 wissenschaftlichen Artikeln für einen Review mit Metaanalyse

**Eingabe:**
- Ordner mit PDFs, DOCX, MD, TXT (wissenschaftliche Artikel)

**Gewünschte Extraktionen/Analysen:**

| Kategorie | Felder |
|-----------|--------|
| **Bibliografie** | Autoren, Titel, Journal, Jahr, DOI, URL, Sprache |
| **Klassifikation** | Artikeltyp (RCT, Review, Opinion), Studienebene, Outlet-Typ |
| **Inhalt** | Zusammenfassungen (Intro, Methoden, Ergebnisse, Diskussion) |
| **Relevanz** | Relevanz-Score (0-10), Screening-Entscheidung, Begründung |
| **Methodik** | Design, Stichprobe, Intervention, Kontrollgruppe |
| **Ergebnisse** | Effektstärken, Konfidenzintervalle, p-Werte |
| **Qualität** | Qualitätsbewertung nach Kriterien |

**Ausgabe:**
- Excel-Tabelle (eine Zeile = ein Artikel), sortierbar
- HTML-Report mit Inhaltsverzeichnis und Dossier pro Artikel

---

#### UC2: Qualitative Datenanalyse (Patientenberichte)

**Akteur:** Klinische Forscherin  
**Ziel:** Analyse von 150 Patientenberichten (psychiatrische Problematiken)

**Eingabe:**
- Excel-Tabelle (eine Zeile = ein Patientenbericht)

**Gewünschte Analysen:**

| Kategorie | Details |
|-----------|---------|
| **Emotionale Dimensionen** | Valenz, Arousal, Dominanz |
| **Kognitive Muster** | Katastrophisieren, Schwarz-Weiß-Denken, Übergeneralisierung |
| **Psychopathologie** | Symptome, Merkmale |
| **Diagnostik** | Wahrscheinlichste Diagnose, Differenzialdiagnosen |

**Ausgabe:**
- Excel-Tabelle (erweitert um Analyse-Spalten), sortierbar
- HTML-Report mit Inhaltsverzeichnis und Dossier pro Patient

---

#### UC3: Personalauswahl

**Akteur:** Personalreferentin  
**Eingabe:** 500 Bewerbungen (PDFs)  
**Analyse:** Datenextraktion, Skill-Matching mit Stellenanforderungen  
**Ausgabe:** Ranking-Tabelle, Report

---

#### UC4: Controlling/Rechnungsanalyse

**Akteur:** Controller  
**Eingabe:** Rechnungen (PDF, Scan) von Energieversorgern  
**Analyse:** Extraktion von Verbräuchen, Kosten, Preisen pro Immobilie/Versorger  
**Ausgabe:** Aggregierte Tabellen, Zeitreihen

---

## 3. Funktionale Anforderungen

### 3.1 Setup & Konfiguration

#### F-SETUP-01: Erster Start (Setup-Wizard)

Beim ersten Start führt ein Wizard durch die Grundkonfiguration:

| Schritt | Beschreibung | Pflicht |
|---------|--------------|---------|
| 1 | Willkommen & Sprachauswahl (DE/EN) | Ja |
| 2 | Master-Passwort setzen | Ja |
| 3 | Ersten Provider konfigurieren | Ja |
| 4 | API-Key eingeben & testen | Ja |
| 5 | Grundeinstellungen | Optional |
| 6 | Fertig | - |

#### F-SETUP-02: Master-Passwort

- **Zweck:** Verschlüsselung aller API-Keys
- **Algorithmus:** PBKDF2 mit Salt (100.000 Iterationen)
- **Abfrage:** Einmal pro App-Session bei Start
- **Änderung:** In Einstellungen möglich (erfordert altes Passwort) oder reset ohne Passwort

#### F-SETUP-03: API-Key-Sicherheit

| Anforderung | Implementierung |
|-------------|-----------------|
| Verschlüsselung | AES-256-GCM |
| Speicherort | SQLite-Datenbank (verschlüsselter Blob) |
| Logging | Keys werden NIEMALS geloggt (automatische Maskierung) |
| Export | Nicht möglich |

---

### 3.2 Model Registry

#### F-REGISTRY-01: Dreistufiges Registry-System

```
┌─────────────────────────────────────────────────────────────┐
│  Stufe 1: BUNDLED REGISTRY                                  │
│  - Mit App ausgeliefert (model_registry.json)               │
│  - Funktioniert offline                                     │
│  - Stand: App-Release-Datum                                 │
└─────────────────────────────────────────────────────────────┘
                              ↓ Override
┌─────────────────────────────────────────────────────────────┐
│  Stufe 2: REMOTE REGISTRY (optional)                        │
│  - GitHub-hosted JSON                                       │
│  - Wöchentlicher Auto-Check auf Updates                     │
│  - Community-maintained                                     │
└─────────────────────────────────────────────────────────────┘
                              ↓ Override
┌─────────────────────────────────────────────────────────────┐
│  Stufe 3: USER OVERRIDES                                    │
│  - Lokale SQLite-Datenbank                                  │
│  - User kann alles überschreiben                            │
│  - Eigene Modelle hinzufügen                                │
│  - HÖCHSTE PRIORITÄT                                        │
└─────────────────────────────────────────────────────────────┘
```

#### F-REGISTRY-02: Model-Informationen

Für jedes Model werden folgende Informationen gespeichert:

```json
{
  "model_id": "gpt-4o",
  "provider": "openai",
  "display_name": "GPT-4o",
  "description": "Most capable GPT-4 model, multimodal",
  
  "context_window": 128000,
  "max_output_tokens": 16384,
  
  "pricing": {
    "input_per_million": 2.50,
    "output_per_million": 10.00,
    "currency": "USD",
    "updated_at": "2025-05-15"
  },
  
  "capabilities": {
    "chat": true,
    "vision": true,
    "function_calling": true,
    "json_mode": true,
    "streaming": true,
    "reasoning": false
  },
  
  "parameters": {
    "temperature": {
      "supported": true,
      "type": "float",
      "min": 0.0,
      "max": 2.0,
      "default": 1.0
    },
    "max_tokens": {
      "supported": true,
      "type": "integer",
      "min": 1,
      "max": 16384,
      "default": 4096
    },
    "reasoning_effort": {
      "supported": false
    }
  },
  
  "status": "active"
}
```

#### F-REGISTRY-03: Provider-Konfiguration

| Provider | API-Endpoint | Auth-Typ | Model-Discovery | Lokal |
|----------|--------------|----------|-----------------|-------|
| OpenAI | `https://api.openai.com/v1` | Bearer Token | ✅ `/v1/models` | ❌ |
| Anthropic | `https://api.anthropic.com/v1` | x-api-key Header | ❌ Registry | ❌ |
| Google Gemini | `https://generativelanguage.googleapis.com/v1` | Query Parameter | ✅ `/v1/models` | ❌ |
| OpenRouter | `https://openrouter.ai/api/v1` | Bearer Token | ✅ inkl. Preise! | ❌ |
| Ollama | `http://localhost:11434` | Keine | ✅ `/api/tags` | ✅ |
| LM Studio | `http://localhost:1234/v1` | Keine | ✅ `/models` | ✅ |
| Custom | Benutzerdefiniert | Konfigurierbar | Optional | Konfigurierbar |

#### F-REGISTRY-04: Model Discovery

Für Provider mit Discovery-API:

```dart
/// Model Discovery für Provider mit Discovery-API.
Future<List<DiscoveredModel>> discoverModels(ProviderConfig provider, String? apiKey) async {
  if (provider.supportsModelList) {
    final response = await _dio.get(
      '${provider.baseUrl}${provider.modelsEndpoint}',
      options: Options(headers: _buildHeaders(provider.authType, apiKey)),
    );
    return parseModelList(response.data, provider);
  } else {
    // Fallback: Models aus Registry laden
    return registry.getModelsForProvider(provider.id);
  }
}
```

#### F-REGISTRY-05: Registry-Updates

- **Check-Intervall:** Wöchentlich (konfigurierbar)
- **Update-Quelle:** `https://raw.githubusercontent.com/xtractaid/model-registry/main/registry.json`
- **User-Notification:** Bei verfügbarem Update (nicht automatisch angewendet)
- **Offline-Fallback:** Bundled Registry funktioniert immer

---

### 3.3 Projektverwaltung

#### F-PROJ-01: Projektstruktur

Ein Projekt ist ein Ordner mit folgender Struktur:

```
/MeinProjekt/                     # Stammverzeichnis (vom User gewählt)
├── project.xtractaid.json        # Projektmetadaten
├── /prompts/                     # Prompt-Dateien (.txt, .md)
│   ├── P1_metadata.md
│   └── P2_summary.md
├── /input/                       # Eingabedateien (optional)
├── /batches/                     # Batch-Konfigurationen (.json)
│   └── batch_literature_review.json
└── /results/                     # Ergebnisse
    └── /{batch_name}_{timestamp}/
        ├── results.xlsx          # Haupt-Ergebnisdatei
        ├── results_log.md        # Detailliertes Log
        ├── report.html           # HTML-Report
        ├── /checkpoints/         # Checkpoint-Dateien
        └── /debug/               # Fehlgeschlagene Parses
```

#### F-PROJ-02: project.xtractaid.json

```json
{
  "id": "proj_abc123",
  "name": "Literature Review 2025",
  "created_at": "2025-06-01T10:00:00Z",
  "updated_at": "2025-06-01T14:30:00Z",
  "settings": {
    "strict_local_mode": false,
    "default_model": "claude-sonnet-4-20250514",
    "privacy_warning_dismissed": false,
    "language": "de"
  }
}
```

#### F-PROJ-03: Projektoperationen

| Operation | Beschreibung |
|-----------|--------------|
| Neues Projekt | Ordner erstellen, Struktur anlegen |
| Projekt öffnen | Ordner auswählen, Validierung |
| Kürzlich geöffnet | Liste der letzten 10 Projekte |
| Projekt schließen | Speichern, zurück zur Übersicht |

---

### 3.4 Input-Verarbeitung

#### F-INPUT-01: Unterstützte Eingabeformate

| Quelle | Formate | ID-Generierung |
|--------|---------|----------------|
| **Excel-Datei** | .xlsx, .xls, .csv | Spalte "ID" oder auto (Zeilennummer) |
| **Dokumenten-Ordner** | .pdf, .docx, .txt, .md | Dateiname = ID |

#### F-INPUT-02: Excel-Input

**Anforderungen:**
- Muss Spalten `ID` und `Item` enthalten
- `ID`: Eindeutiger Bezeichner (String oder Nummer)
- `Item`: Der zu analysierende Text

**Beispiel:**

| ID | Item |
|----|------|
| P001 | "Ich fühle mich seit Wochen antriebslos..." |
| P002 | "Die Angst kommt immer nachts..." |

**Verarbeitung:**
```dart
Future<List<Item>> loadExcel(String path) async {
  final bytes = await File(path).readAsBytes();
  final excel = Excel.decodeBytes(bytes);
  final sheet = excel.tables[excel.tables.keys.first]!;

  // Header-Validierung
  final headers = sheet.rows.first.map((c) => c?.value?.toString()).toList();
  assert(headers.contains('ID'), "Spalte 'ID' fehlt");
  assert(headers.contains('Item'), "Spalte 'Item' fehlt");

  final idIdx = headers.indexOf('ID');
  final itemIdx = headers.indexOf('Item');
  final items = <Item>[];
  final seenIds = <String>{};

  for (int i = 1; i < sheet.rows.length; i++) {
    final row = sheet.rows[i];
    final id = row[idIdx]?.value?.toString() ?? '';
    final text = row[itemIdx]?.value?.toString() ?? '';
    assert(!seenIds.contains(id), 'IDs müssen eindeutig sein');
    seenIds.add(id);
    items.add(Item(id: id, text: text));
  }

  assert(items.isNotEmpty, 'Datei ist leer');
  return items;
}
```

#### F-INPUT-03: Dokumenten-Ordner-Input

**Unterstützte Formate:**

| Format | Bibliothek | ID-Format |
|--------|------------|-----------|
| .txt | Direkt lesen (UTF-8) | `filename` (ohne Extension) |
| .md | Direkt lesen (UTF-8) | `filename` (ohne Extension) |
| .pdf | syncfusion_flutter_pdf | `filename.pdf` (mit Extension) |
| .docx | archive + xml (ZIP/XML-Parsing) | `filename` (ohne Extension) |

**Verarbeitung:**
```dart
Stream<Item> loadFolderStream(String folderPath) async* {
  final dir = Directory(folderPath);
  final files = await dir.list().where((f) => f is File).toList();
  files.sort((a, b) => a.path.compareTo(b.path));

  for (final file in files) {
    final ext = path.extension(file.path).toLowerCase();
    final fileName = path.basename(file.path);
    String content;
    String itemId;

    switch (ext) {
      case '.txt' || '.md':
        content = await (file as File).readAsString(encoding: utf8);
        itemId = path.basenameWithoutExtension(file.path);
      case '.pdf':
        content = await extractPdfText(file.path);
        itemId = fileName; // Behalte .pdf Extension
      case '.docx':
        content = await extractDocxText(file.path);
        itemId = path.basenameWithoutExtension(file.path);
      default:
        continue; // Überspringe unbekannte Formate
    }

    yield Item(id: itemId, text: content);
  }
}
```

**Fortschrittsanzeige:**
- Bei >10 Dateien: Fortschrittsbalken anzeigen
- Abbruch-Button verfügbar
- Statistik nach Laden: Anzahl, Gesamtzeichen, größtes Dokument

**Warnungen:**
- Bei >5 Mio. Zeichen kumulativ: Warnung anzeigen
- Bei leeren Dokumenten: Warnung im Log

#### F-INPUT-04: PDF-Text-Extraktion

```dart
Future<String> extractPdfText(String filepath) async {
  final bytes = await File(filepath).readAsBytes();
  final document = PdfDocument(inputBytes: bytes);
  final textSegments = <String>[];

  for (int i = 0; i < document.pages.count; i++) {
    try {
      final pageText = PdfTextExtractor(document).extractText(
        startPageIndex: i, endPageIndex: i,
      );
      if (pageText.trim().isNotEmpty) {
        textSegments.add(pageText);
      }
    } catch (e) {
      log.warning('Seite ${i + 1} konnte nicht extrahiert werden: $e');
    }
  }

  document.dispose();
  final content = textSegments.join('\n').trim();

  if (content.isEmpty) {
    log.warning('PDF enthält keinen extrahierbaren Text: $filepath');
  }

  return content;
}
```

---

### 3.5 Prompt-System

#### F-PROMPT-01: Prompt-Format

Prompts sind `.txt` oder `.md` Dateien mit einem speziellen Platzhalter:

```markdown
# Metadata Extraction

## TASK
Extract bibliographic metadata from the provided article.

## OUTPUT FORMAT
Return ONLY a valid JSON array. No markdown, no comments.

## FIELDS
- **ID**: Copy exactly from input
- **Title**: Full article title
- **Authors**: Format "Last1, First1; Last2, First2"
- **Year**: Publication year (integer)

## JSON SCHEMA
[
  {
    "ID": "exact_id_from_input",
    "Title": "...",
    "Authors": "...",
    "Year": 2024
  }
]

---

**IDs and Items:**
[Insert IDs and Items here]
```

**Platzhalter:** `[Insert IDs and Items here]`
- Wird durch die Items des aktuellen Chunks ersetzt
- Muss exakt so im Prompt vorkommen

#### F-PROMPT-02: Item-Injection

Der Platzhalter wird durch JSON-formatierte Items ersetzt:

```dart
String injectItems(String promptTemplate, List<Item> chunk) {
  final itemsJson = chunk.map((item) {
    final escapedText = item.text
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"');
    return '{"ID": "${item.id}", "Item": "$escapedText"}';
  }).join('\n');

  const placeholder = '[Insert IDs and Items here]';
  if (promptTemplate.contains(placeholder)) {
    return promptTemplate.replaceAll(placeholder, itemsJson);
  } else {
    // Fallback: An Ende anhängen
    log.warning('Platzhalter nicht gefunden, Items werden angehängt');
    return '$promptTemplate\n\n$itemsJson';
  }
}
```

**Beispiel-Output:**
```
**IDs and Items:**
{"ID": "article_001", "Item": "Introduction: This study examines..."}
{"ID": "article_002", "Item": "Abstract: Mental health chatbots..."}
```

#### F-PROMPT-03: Multi-Prompt-Verarbeitung

- User kann mehrere Prompts auswählen
- Prompts werden sequentiell auf jeden Item-Chunk angewendet
- Reihenfolge ist konfigurierbar (Drag & Drop)

**Ablauf:**
```
Für jeden Chunk:
    Für jeden Prompt:
        → API-Call
        → Response parsen
        → Ergebnisse speichern
```

#### F-PROMPT-04: Auto-Load

Beim Projekt-Öffnen werden automatisch alle `.txt` und `.md` Dateien aus dem `prompts/` Ordner geladen und zur Auswahl angeboten.

---

### 3.6 Batch-Konfiguration

#### F-BATCH-01: Batch-Definition

Ein Batch ist die zentrale Arbeitseinheit mit folgender Konfiguration:

```json
{
  "id": "batch_abc123",
  "name": "Literature Review - Metadata",
  "created_at": "2025-06-01T10:00:00Z",
  "status": "draft",
  
  "input": {
    "source_type": "folder",
    "source_path": "/path/to/articles",
    "item_count": 300,
    "total_chars": 12500000
  },
  
  "prompts": [
    "/path/to/prompts/P1_metadata.md",
    "/path/to/prompts/P2_summary.md"
  ],
  
  "chunk_settings": {
    "chunk_size": 1,
    "chunk_mode": "sequential",
    "repetitions": 1
  },
  
  "models": [
    {
      "model_id": "claude-sonnet-4-20250514",
      "parameters": {
        "temperature": 0.1,
        "max_tokens": 4000
      }
    }
  ],
  
  "execution": {
    "supervisor_mode": false,
    "checkpoint_interval": 10
  }
}
```

#### F-BATCH-02: Chunk-Einstellungen

| Parameter | Beschreibung | Default | Bereich |
|-----------|--------------|---------|---------|
| `chunk_size` | Items pro API-Call | 1 | 1-100 |
| `chunk_mode` | Aufteilungsart | sequential | sequential, random |
| `repetitions` | Wiederholungen mit Shuffle | 1 | 1-100 |

**Chunk-Berechnung:**
```dart
List<List<Item>> createChunks(List<Item> items, int chunkSize) {
  final chunks = <List<Item>>[];
  for (int i = 0; i < items.length; i += chunkSize) {
    chunks.add(items.sublist(i, min(i + chunkSize, items.length)));
  }
  return chunks;
}
```

**Repetitions mit Shuffle:**
```dart
Iterable<(int, List<Item>)> processRepetitions(
  List<Item> items, int repetitions, int chunkSize,
) sync* {
  for (int rep = 1; rep <= repetitions; rep++) {
    // Shuffle für jede Repetition
    final shuffled = List<Item>.from(items)..shuffle();
    final chunks = createChunks(shuffled, chunkSize);

    for (final chunk in chunks) {
      yield (rep, chunk);
    }
  }
}
```

#### F-BATCH-03: Model-Parameter

Die verfügbaren Parameter sind model-spezifisch (aus Registry):

| Parameter | Typ | Beschreibung | Beispiel-Models |
|-----------|-----|--------------|-----------------|
| `temperature` | float | Kreativität (0=deterministisch, 2=kreativ) | GPT-4, Claude |
| `max_tokens` | int | Maximale Output-Länge | Alle |
| `top_p` | float | Nucleus Sampling | GPT-4, Claude |
| `reasoning_effort` | enum | Reasoning-Intensität | o1, o3 |

**UI passt sich dynamisch an:**
- Parameter ohne `supported: true` werden ausgeblendet
- Slider-Bereiche aus `min`/`max` der Registry

#### F-BATCH-04: Supervisor-Modus

| Modus | Beschreibung |
|-------|--------------|
| **Auto** | Batch läuft ohne Unterbrechung durch |
| **Supervisor** | Bestätigung vor jedem API-Call, detaillierte debug statements (für Tests) |

---

### 3.7 Kostenvoranschlag

#### F-COST-01: Token-Schätzung

**Berechnung:**
```dart
TokenEstimate estimateTokens(BatchConfig batch, List<Item> items, List<String> promptContents) {
  // Input-Tokens
  int inputTokens = 0;
  final chunkCount = (items.length / batch.chunkSettings.chunkSize).ceil();

  for (final promptContent in promptContents) {
    final promptTokens = estimateTokenCount(promptContent);
    inputTokens += promptTokens * chunkCount * batch.chunkSettings.repetitions;
  }

  // Items-Tokens (Durchschnitt)
  final avgItemTokens = items.map((i) => estimateTokenCount(i.text)).reduce((a, b) => a + b) ~/ items.length;
  inputTokens += avgItemTokens * items.length * batch.chunkSettings.repetitions * promptContents.length;

  // Output-Tokens (Worst Case = max_tokens)
  final apiCalls = chunkCount * promptContents.length * batch.chunkSettings.repetitions;
  final maxTokens = batch.models.first.parameters['max_tokens'] as int? ?? 4096;
  final outputTokens = maxTokens * apiCalls;

  return TokenEstimate(inputTokens: inputTokens, outputTokens: outputTokens);
}
```

**Token-Schätzung:**
```dart
/// Schätzt Token-Anzahl für einen Text.
/// Verwendet chars/4 als universelle Annäherung.
int estimateTokenCount(String text) {
  return max(1, text.length ~/ 4);
}
```

#### F-COST-02: Kosten-Berechnung

```dart
CostEstimate estimateCost(TokenEstimate tokens, ModelInfo model) {
  final inputCost = (tokens.inputTokens / 1000000) * model.pricing.inputPerMillion;
  final outputCost = (tokens.outputTokens / 1000000) * model.pricing.outputPerMillion;

  return CostEstimate(
    inputTokens: tokens.inputTokens,
    outputTokens: tokens.outputTokens,
    inputCost: inputCost,
    outputCost: outputCost,
    totalCost: inputCost + outputCost,
  );
}
```

#### F-COST-03: Bestätigungs-Dialog

Vor Batch-Start wird ein Dialog angezeigt:

```
┌─────────────────────────────────────────────────────────────┐
│  Kostenvoranschlag                                          │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Model:       claude-sonnet-4-20250514                                  │
│  Items:       300 (300 Chunks à 1)                          │
│  Prompts:     2                                              │
│  Repetitions: 1                                              │
│  API-Calls:   600                                            │
│                                                              │
│  ─────────────────────────────────────────────────────────  │
│                                                              │
│  Geschätzte Input-Tokens:    2,600,000    (~$7.80)          │
│  Geschätzte Output-Tokens:   600,000      (~$9.00 max)      │
│                                                              │
│  ─────────────────────────────────────────────────────────  │
│                                                              │
│  GESCHÄTZTE GESAMTKOSTEN:    $16.80 (max)                   │
│                                                              │
│  ℹ️ Tatsächliche Kosten hängen von Output-Länge ab.          │
│                                                              │
│                        [Abbrechen]  [Batch starten]         │
└─────────────────────────────────────────────────────────────┘
```

**User muss bestätigen** bevor der Batch startet.

---

### 3.8 Batch-Ausführung

#### F-EXEC-01: Ausführungs-Ablauf

```
┌──────────────────┐
│   Batch starten  │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐     ┌──────────────────┐
│ Checkpoint laden?│────▶│ Resume-Abfrage   │
└────────┬─────────┘     └────────┬─────────┘
         │                        │
         ▼                        ▼
┌──────────────────┐     ┌──────────────────┐
│   Worker starten │◀────│  State laden     │
└────────┬─────────┘     └──────────────────┘
         │
         ▼
┌──────────────────────────────────────────────┐
│              Hauptschleife                    │
│  ┌────────────────────────────────────────┐  │
│  │  Für jede Repetition:                  │  │
│  │    DataFrame shufflen                  │  │
│  │    Für jeden Prompt:                   │  │
│  │      Für jeden Chunk:                  │  │
│  │        → Message bauen                 │  │
│  │        → API-Call (mit Retry)          │  │
│  │        → Response parsen               │  │
│  │        → Ergebnisse speichern          │  │
│  │        → Checkpoint (alle N Calls)     │  │
│  │        → Delay (falls konfiguriert)    │  │
│  └────────────────────────────────────────┘  │
└──────────────────────────────────────────────┘
         │
         ▼
┌──────────────────┐
│ Report erstellen │
└──────────────────┘
```

#### F-EXEC-02: Message-Konstruktion

```dart
List<ChatMessage> buildMessages({
  required List<Item> chunk,
  required String promptTemplate,
  required String? systemPrompt,
  required ModelInfo model,
}) {
  final messages = <ChatMessage>[];

  // System-Prompt (falls Model es unterstützt)
  final supportsSystem = model.parameters['system_prompt']?.supported ?? true;
  if (supportsSystem && systemPrompt != null && systemPrompt.isNotEmpty) {
    messages.add(ChatMessage(role: 'system', content: systemPrompt));
  }

  // User-Prompt mit injizierten Items
  final userPrompt = injectItems(promptTemplate, chunk);
  messages.add(ChatMessage(role: 'user', content: userPrompt));

  return messages;
}
```

#### F-EXEC-03: API-Call mit Retry

```dart
/// Führt einen LLM API-Call mit Retry-Logik durch.
/// Returns: LlmResponse mit responseText und outputTokens.
/// Throws: LlmApiException nach maxRetries.
Future<LlmResponse> callLlm({
  required String providerId,
  required String baseUrl,
  required String? apiKey,
  required String authType,
  required String modelId,
  required List<ChatMessage> messages,
  required Map<String, dynamic> params,
  int maxRetries = 5,
}) async {
  Exception? lastError;
  const baseDelay = 5; // Sekunden

  for (int attempt = 0; attempt < maxRetries; attempt++) {
    try {
      final response = await _dio.post(
        _getEndpoint(providerId, baseUrl, modelId),
        data: _buildRequestBody(providerId, modelId, messages, params),
        options: Options(headers: _buildHeaders(authType, apiKey)),
      );

      return _parseResponse(providerId, response.data);

    } on DioException catch (e) {
      lastError = e;

      if (e.response?.statusCode == 429) {
        // Rate Limit: Längere Pause
        final retryAfter = _getRetryAfter(e.response?.headers);
        final delay = max(30, retryAfter) * (attempt + 1);
        log.warning('Rate Limit, warte ${delay}s...');
        await Future.delayed(Duration(seconds: delay));
      } else if (e.response != null && e.response!.statusCode! >= 500) {
        // Server-Fehler: Exponential Backoff
        final delay = baseDelay * (attempt + 1);
        log.warning('Server-Fehler ${e.response!.statusCode}, Retry in ${delay}s...');
        await Future.delayed(Duration(seconds: delay));
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.connectionError) {
        // Verbindungsfehler
        final delay = baseDelay * (attempt + 1);
        log.warning('Verbindungsfehler, Retry in ${delay}s...');
        await Future.delayed(Duration(seconds: delay));
      } else {
        // Client-Fehler (4xx außer 429): Nicht retrybar
        rethrow;
      }
    }
  }

  throw LlmApiException('Max Retries erreicht: $lastError');
}
```

#### F-EXEC-04: Response-Parsing

LLM-Responses müssen als JSON geparst werden. Da LLMs nicht immer perfektes JSON liefern, gibt es eine Fallback-Kette:

```dart
/// Versucht JSON aus der LLM-Response zu extrahieren.
/// Returns: Liste von Maps mit "ID" und weiteren Feldern, oder null bei Fehlschlag.
List<Map<String, dynamic>>? parseResponse(String response) {
  // 1. Direkt parsen (idealer Fall)
  try {
    final data = jsonDecode(response.trim());
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map && data.containsKey('ID')) return [Map<String, dynamic>.from(data)];
  } on FormatException catch (_) {}

  // 2. Markdown Code-Fences entfernen
  final cleaned = response
      .replaceAll(RegExp(r'```json\s*'), '')
      .replaceAll(RegExp(r'```\s*'), '')
      .trim();
  try {
    final data = jsonDecode(cleaned);
    if (data is List) return data.cast<Map<String, dynamic>>();
  } on FormatException catch (_) {}

  // 3. <think>-Tags behandeln (für Reasoning-Modelle)
  if (response.contains('</think>')) {
    final postThink = response.split('</think>').last.trim();
    try {
      final data = jsonDecode(postThink);
      if (data is List) return data.cast<Map<String, dynamic>>();
    } on FormatException catch (_) {}
  }

  // 4. Regex für JSON-Array
  final arrayMatch = RegExp(r'\[\s*\{.*?"ID".*?\}\s*\]', dotAll: true).firstMatch(response);
  if (arrayMatch != null) {
    try {
      final data = jsonDecode(arrayMatch.group(0)!);
      if (data is List) return data.cast<Map<String, dynamic>>();
    } on FormatException catch (_) {}
  }

  // 5. Einzelne JSON-Objekte sammeln
  final objectMatches = RegExp(r'\{\s*"ID"\s*:.*?\}', dotAll: true).allMatches(response);
  final results = <Map<String, dynamic>>[];
  for (final match in objectMatches) {
    try {
      final obj = jsonDecode(match.group(0)!) as Map<String, dynamic>;
      if (obj.containsKey('ID')) results.add(obj);
    } on FormatException catch (_) {}
  }
  if (results.isNotEmpty) return results;

  // 6. Fehlschlag
  log.severe('JSON-Parsing fehlgeschlagen');
  return null;
}
```

#### F-EXEC-05: Ergebnis-Aggregation

Ergebnisse werden in einem Dictionary gesammelt:

```dart
// Struktur: results[itemId][fieldName] = value
final results = <String, Map<String, dynamic>>{};

void processResponse({
  required List<Map<String, dynamic>>? parsed,
  required List<Item> originalChunk,
  required String templateName,
  required int repetition,
}) {
  if (parsed == null) return;

  final processedIds = <String>{};

  for (final item in parsed) {
    final itemId = item['ID']?.toString();
    if (itemId == null) continue;

    processedIds.add(itemId);
    results.putIfAbsent(itemId, () => {});

    // Felder mit Präfix speichern
    for (final entry in item.entries) {
      if (entry.key != 'ID' && entry.key != 'Item') {
        final fieldName = '${entry.key}_from_${templateName}_rep_$repetition';
        results[itemId]![fieldName] = entry.value;
      }
    }
  }

  // Fehlende IDs markieren
  final expectedIds = originalChunk.map((i) => i.id).toSet();
  final missing = expectedIds.difference(processedIds);

  for (final itemId in missing) {
    results.putIfAbsent(itemId, () => {});
    results[itemId]!['MissingInResponse_${templateName}_rep_$repetition'] = true;
    log.warning('ID $itemId fehlt in Response');
  }
}
```

---

### 3.9 Checkpointing

#### F-CHKPT-01: Checkpoint-Format

```json
{
  "id": "chkpt_abc123",
  "batch_id": "batch_xyz789",
  "created_at": "2025-06-01T15:30:00Z",
  
  "progress": {
    "current_repetition": 1,
    "current_prompt_index": 0,
    "current_prompt_name": "P1_metadata",
    "current_chunk_index": 142,
    "llm_call_counter": 142
  },
  
  "tokens": {
    "total_input": 1247832,
    "total_output": 298221
  },
  
  "results": {
    "article_001": {"Title_from_P1_metadata_rep_1": "...", ...},
    "article_002": {...}
  },
  
  "config_snapshot": {
    "chunk_size": 1,
    "repetitions": 1,
    "prompts": ["P1_metadata.md", "P2_summary.md"],
    "model": "claude-sonnet-4-20250514"
  }
}
```

#### F-CHKPT-02: Checkpoint-Speicherung

```dart
/// Speichert Checkpoint alle N API-Calls.
Future<void> saveCheckpoint(WorkerState state, {int interval = 10}) async {
  if (state.llmCallCounter % interval != 0) return;

  final checkpoint = {
    'id': 'chkpt_${const Uuid().v4().substring(0, 8)}',
    'batch_id': state.batchId,
    'created_at': DateTime.now().toIso8601String(),
    'progress': {
      'current_repetition': state.currentRepetition,
      'current_prompt_index': state.currentPromptIndex,
      'current_prompt_name': state.currentPromptName,
      'current_chunk_index': state.currentChunkIndex,
      'llm_call_counter': state.llmCallCounter,
    },
    'tokens': {
      'total_input': state.totalInputTokens,
      'total_output': state.totalOutputTokens,
    },
    'results': state.results,
    'config_snapshot': state.config,
  };

  final filePath = '${state.outputDir}/checkpoints/checkpoint_${state.batchId}.json';
  await File(filePath).writeAsString(jsonEncode(checkpoint));

  log.info('Checkpoint gespeichert (Call #${state.llmCallCounter})');
}
```

#### F-CHKPT-03: Resume-Funktion

Beim Batch-Start:

```dart
/// Prüft ob ein Checkpoint existiert und lädt ihn.
Future<Map<String, dynamic>?> checkForResume(String batchId, String outputDir) async {
  final checkpointPath = '$outputDir/checkpoints/checkpoint_$batchId.json';
  final file = File(checkpointPath);

  if (!await file.exists()) return null;

  final content = await file.readAsString();
  return jsonDecode(content) as Map<String, dynamic>;
}
```

**Resume-Dialog:**
```
┌─────────────────────────────────────────────────────────────┐
│  Vorheriger Fortschritt gefunden                            │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Checkpoint vom: 01.06.2025 15:30:00                        │
│  Fortschritt: 142/300 Items (47%)                           │
│  Tokens: 1,247,832 input / 298,221 output                   │
│                                                              │
│  Möchten Sie fortsetzen oder neu starten?                   │
│                                                              │
│              [Neu starten]  [Fortsetzen]                    │
└─────────────────────────────────────────────────────────────┘
```

#### F-CHKPT-04: Checkpoint-Cleanup

- **Retention:** 7 Tage (konfigurierbar)
- **Automatisch:** Nach erfolgreichem Batch-Abschluss
- **Manuell:** In Einstellungen

---

### 3.10 Output-Generierung

#### F-OUTPUT-01: Excel-Export

```dart
/// Generiert Excel-Datei aus Ergebnissen.
Future<String> generateExcel(
  Map<String, Map<String, dynamic>> results,
  String outputPath,
) async {
  final workbook = Workbook();
  final sheet = workbook.worksheets[0];

  // Header sammeln
  final allKeys = <String>{'ID'};
  for (final fields in results.values) {
    allKeys.addAll(fields.keys.where((k) => k != 'Item'));
  }
  final headers = allKeys.toList();

  // Header-Zeile schreiben
  for (int col = 0; col < headers.length; col++) {
    sheet.getRangeByIndex(1, col + 1).setText(headers[col]);
  }

  // Daten-Zeilen schreiben
  int row = 2;
  for (final entry in results.entries) {
    sheet.getRangeByIndex(row, 1).setText(entry.key); // ID
    for (int col = 1; col < headers.length; col++) {
      final value = entry.value[headers[col]];
      if (value != null) {
        sheet.getRangeByIndex(row, col + 1).setText(value.toString());
      }
    }
    row++;
  }

  // Eindeutigen Dateinamen generieren
  var finalPath = outputPath;
  if (await File(finalPath).exists()) {
    final base = path.withoutExtension(finalPath);
    final ext = path.extension(finalPath);
    int counter = 1;
    while (await File('${base}_$counter$ext').exists()) {
      counter++;
    }
    finalPath = '${base}_$counter$ext';
  }

  final bytes = workbook.saveAsStream();
  await File(finalPath).writeAsBytes(bytes);
  workbook.dispose();

  log.info('Excel gespeichert: $finalPath');
  return finalPath;
}
```

#### F-OUTPUT-02: Log-Datei

Für jeden Batch wird eine detaillierte Log-Datei erstellt:

```markdown
# Batch Log: Literature Review - Metadata

## Session
- **Start:** 2025-06-01 14:30:00
- **Ende:** 2025-06-01 16:45:00
- **Dauer:** 2h 15m 0s
- **Status:** Completed

## Model
- **Requested:** claude-sonnet-4-20250514
- **Provider:** Anthropic

## Konfiguration
| Parameter | Wert |
|-----------|------|
| Temperature | 0.1 |
| Max Tokens | 4000 |
| Chunk Size | 1 |
| Repetitions | 1 |
| Request Delay | 0.0s |

## Input
- **Quelle:** /path/to/articles/
- **Typ:** Document Folder
- **Items:** 300
- **Gesamt-Zeichen:** ~12.5M

## Tokens
| Typ | Anzahl |
|-----|--------|
| Input | 2,547,832 |
| Output | 489,221 |
| Gesamt | 3,037,053 |

## Raten
| Metrik | Wert |
|--------|------|
| Tokens/Minute | 22,500 |
| Items/Minute | 2.2 |

## Kosten
| Typ | Betrag |
|-----|--------|
| Input | $7.64 |
| Output | $7.34 |
| **Gesamt** | **$14.98** |

## Fehler & Warnungen
| Zeit | Level | Item | Details |
|------|-------|------|---------|
| 14:32:15 | WARN | article_047 | Rate Limit, Retry 1/5 |
| 15:01:33 | ERROR | article_122 | JSON-Parsing fehlgeschlagen |

## System-Prompt
```
You are an intelligent assistant...
```

## Prompts

### P1_metadata.md
```markdown
[Vollständiger Prompt-Inhalt]
```

### P2_summary.md
```markdown
[Vollständiger Prompt-Inhalt]
```
```

#### F-OUTPUT-03: HTML-Report

```html
<!DOCTYPE html>
<html lang="de">
<head>
    <title>XtractAid Report: Literature Review</title>
    <style>
        /* Eingebettetes CSS für Standalone-Report */
    </style>
</head>
<body>
    <nav id="sidebar">
        <h2>Inhaltsverzeichnis</h2>
        <input type="search" placeholder="Suchen...">
        <ul>
            <li><a href="#summary">Zusammenfassung</a></li>
            <li><a href="#item_article_001">article_001</a></li>
            <li><a href="#item_article_002">article_002</a></li>
            <!-- ... -->
        </ul>
    </nav>
    
    <main>
        <section id="summary">
            <h1>Zusammenfassung</h1>
            <table>
                <tr><td>Items</td><td>300</td></tr>
                <tr><td>Erfolg</td><td>297 (99%)</td></tr>
                <tr><td>Fehler</td><td>3</td></tr>
                <tr><td>Kosten</td><td>$14.98</td></tr>
            </table>
        </section>
        
        <section id="item_article_001" class="dossier">
            <h2>article_001</h2>
            <dl>
                <dt>Title</dt>
                <dd>Delivering Cognitive Behavior Therapy...</dd>
                <dt>Authors</dt>
                <dd>Fitzpatrick, K; Darcy, A; Vierhile, M</dd>
                <dt>Year</dt>
                <dd>2017</dd>
                <dt>Relevance</dt>
                <dd>10/10</dd>
            </dl>
        </section>
        
        <!-- Weitere Items... -->
    </main>
    
    <script>
        // Filter, Sortierung, Navigation
    </script>
</body>
</html>
```

---

### 3.11 Datenschutz

#### F-PRIVACY-01: Datenschutz-Warnung

Vor jedem Batch mit Remote-Provider:

```
┌─────────────────────────────────────────────────────────────┐
│  ⚠️ Datenschutz-Hinweis                                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Sie senden Daten an externe Server:                        │
│                                                              │
│  Provider: Anthropic                                         │
│  Region: USA                                                 │
│                                                              │
│  Bitte stellen Sie sicher, dass dies mit Ihren              │
│  Datenschutzanforderungen (z.B. DSGVO) vereinbar ist.       │
│                                                              │
│  [ ] Diese Warnung für dieses Projekt nicht mehr anzeigen   │
│                                                              │
│                  [Abbrechen]  [Verstanden, fortfahren]      │
└─────────────────────────────────────────────────────────────┘
```

#### F-PRIVACY-02: Strict Local Mode

- **Aktivierung:** Global oder pro Projekt
- **Effekt:** Nur lokale Provider (Ollama, LM Studio) verfügbar
- **UI:** Remote-Provider ausgegraut mit Hinweis
- **Indikator:** 🔒 Symbol in der Titelleiste

---

### 3.12 Logging-System

#### F-LOG-01: Log-Levels

| Level | Verwendung | Beispiel |
|-------|------------|----------|
| `DEBUG` | Technische Details | "JSON-Parsing Versuch 2: Regex" |
| `INFO` | Normale Operationen | "Processing article_142.pdf" |
| `WARN` | Recoverable Probleme | "Rate Limit, Retry in 30s" |
| `ERROR` | Fehler | "JSON-Parsing fehlgeschlagen" |

#### F-LOG-02: Live-GUI-Log

- Scrollbares Textfeld im Batch-Ausführungs-Screen
- Farbcodierung: INFO=grau, WARN=orange, ERROR=rot
- Auto-Scroll zu neuen Einträgen
- Filter-Buttons: [Alle] [Nur Fehler] [Nur Warnungen]

#### F-LOG-03: Log-Maskierung

API-Keys werden automatisch maskiert:

```dart
String maskSecrets(String text) {
  // API-Key Patterns
  final patterns = [
    RegExp(r'sk-[a-zA-Z0-9]{20,}'),      // OpenAI
    RegExp(r'sk-ant-[a-zA-Z0-9]{20,}'),  // Anthropic
    RegExp(r'AIza[a-zA-Z0-9_-]{35}'),    // Google
  ];

  var masked = text;
  for (final pattern in patterns) {
    masked = masked.replaceAll(pattern, '[REDACTED]');
  }

  return masked;
}
```

---

### 3.13 LM Studio Integration

#### F-LMSTUDIO-01: Model-Loading via CLI

Wenn ein LM Studio Model ausgewählt wird:

```dart
/// Lädt ein Model in LM Studio via CLI.
Future<bool> loadLmStudioModel(
  String modelName,
  void Function(int progress)? onProgress,
) async {
  // 1. Alle Models entladen
  final unloadResult = await Process.run('lms', ['unload', '--all']);

  // 2. Gewünschtes Model laden
  final process = await Process.start('lms', ['load', modelName]);

  // Fortschritt parsen (LMS gibt Prozente aus)
  await for (final line in process.stdout.transform(utf8.decoder).transform(const LineSplitter())) {
    final match = RegExp(r'(\d+)%').firstMatch(line);
    if (match != null) {
      final progress = int.parse(match.group(1)!);
      onProgress?.call(progress);
    }
  }

  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    final stderr = await process.stderr.transform(utf8.decoder).join();
    throw LmStudioException(stderr);
  }

  // 3. Server-Readiness prüfen
  return await waitForLmStudioServer();
}
```

#### F-LMSTUDIO-02: Server-Polling

```dart
/// Wartet bis LM Studio Server bereit ist.
Future<bool> waitForLmStudioServer({
  String url = 'http://localhost:1234/v1',
  int timeoutSeconds = 60,
}) async {
  final dio = Dio();
  final stopwatch = Stopwatch()..start();

  while (stopwatch.elapsed.inSeconds < timeoutSeconds) {
    try {
      final response = await dio.get(
        '$url/models',
        options: Options(receiveTimeout: const Duration(seconds: 2)),
      );
      if (response.statusCode == 200) return true;
    } on DioException catch (_) {
      // Server noch nicht bereit
    }

    await Future.delayed(const Duration(seconds: 1));
  }

  return false;
}
```

---

## 4. Technische Architektur

### 4.1 Tech-Stack

| Schicht | Technologie | Begründung |
|---------|-------------|------------|
| **Desktop Framework** | Flutter (Windows/macOS) | Cross-Platform, ein Codebase, native Performance |
| **UI** | Flutter Widgets + Dart | Komponentenbasiert, großes Ecosystem |
| **State Management** | Riverpod | Reaktiv, typsicher, kein Boilerplate |
| **UI Components** | Material Design 3 | Modern, anpassbar, accessible |
| **Backend** | Dart Services + Isolates | Kein separater Prozess, gleiche Sprache |
| **Database** | SQLite (Drift ORM) | Lokal, kein Setup, portabel, typsicher |
| **IPC** | Direkte Aufrufe + Isolate SendPort/ReceivePort | Real-time Updates ohne Netzwerk-Overhead |

### 4.2 Architektur-Diagramm

```
┌─────────────────────────────────────────────────────────────────┐
│                    Flutter Desktop App                            │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │              Flutter UI (Main Isolate)                      │  │
│  │                                                            │  │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐      │  │
│  │  │  Setup   │ │  Project │ │  Batch   │ │  Results │      │  │
│  │  │  Wizard  │ │  Manager │ │  Wizard  │ │  Viewer  │      │  │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘      │  │
│  │                                                            │  │
│  │  ┌────────────────────────────────────────────────────┐   │  │
│  │  │              Shared Widgets                         │   │  │
│  │  │  FileSelector, PromptViewer, ModelConfigurator,    │   │  │
│  │  │  CostEstimate, ProgressBar, LogViewer, DataTable   │   │  │
│  │  └────────────────────────────────────────────────────┘   │  │
│  │                                                            │  │
│  │  ┌────────────────────────────────────────────────────┐   │  │
│  │  │              Riverpod Providers                     │   │  │
│  │  │  projectProvider, batchProvider, settingsProvider   │   │  │
│  │  └────────────────────────────────────────────────────┘   │  │
│  └───────────────────────────────────────────────────────────┘  │
│                              │                                   │
│                  Direkte Aufrufe + Isolate-Messages               │
│                              ▼                                   │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                   Dart Services Layer                      │  │
│  │                                                            │  │
│  │  ┌──────────────────────────────────────────────────────┐ │  │
│  │  │                    Services                           │ │  │
│  │  │  LlmApiService, FileParserService, JsonParserService,│ │  │
│  │  │  ModelRegistryService, EncryptionService,             │ │  │
│  │  │  CheckpointService, TokenEstimationService            │ │  │
│  │  └──────────────────────────────────────────────────────┘ │  │
│  │                                                            │  │
│  │  ┌──────────────────────────────────────────────────────┐ │  │
│  │  │              Dart Isolates (Worker)                   │ │  │
│  │  │  BatchExecutionWorker, FileParsingWorker             │ │  │
│  │  │  Kommunikation via SendPort/ReceivePort              │ │  │
│  │  └──────────────────────────────────────────────────────┘ │  │
│  └───────────────────────────────────────────────────────────┘  │
│                              │                                   │
│                              ▼                                   │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                  Drift SQLite Database                      │  │
│  │  settings, providers, models, projects, batches, logs     │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                               │
                               ▼
              ┌────────────────────────────────┐
              │        External APIs           │
              │  OpenAI, Anthropic, Google,    │
              │  OpenRouter, Ollama, LM Studio │
              └────────────────────────────────┘
```

### 4.3 Backend-Module

| Modul | Datei | Verantwortung |
|-------|-------|---------------|
| **LLM API** | `lib/services/llm_api_service.dart` | API-Calls, Retry-Logik, Provider-Adapter |
| **File Parser** | `lib/services/file_parser_service.dart` | Excel, PDF, DOCX, TXT, MD |
| **JSON Parser** | `lib/services/json_parser_service.dart` | Response-Parsing, `<think>`-Handling |
| **Report Generator** | `lib/services/report_generator_service.dart` | Excel, HTML, Log-Dateien |
| **Model Registry** | `lib/services/model_registry_service.dart` | Bundled + Remote + User Models |
| **Encryption** | `lib/services/encryption_service.dart` | API-Key-Verschlüsselung (AES-256-GCM) |
| **Checkpoint** | `lib/services/checkpoint_service.dart` | Speichern/Laden von State |
| **Token Estimation** | `lib/services/token_estimation_service.dart` | Token-Schätzung (chars/4) |

### 4.4 Flutter Widgets

| Widget | Wiederverwendbar | Beschreibung |
|--------|------------------|--------------|
| `FileSelector` | ✅ | Datei/Ordner-Auswahl mit Typ-Erkennung |
| `PromptSelector` | ✅ | Multi-Auswahl mit Drag & Drop |
| `PromptViewer` | ✅ | Prompt-Vorschau (read-only) |
| `ModelSelector` | ✅ | Dropdown mit Provider-Gruppierung |
| `ModelConfigurator` | ✅ | Dynamische Parameter-UI |
| `CostEstimateCard` | ✅ | Kosten-Vorschau |
| `ProgressBarWidget` | ✅ | Fortschritt mit Stats |
| `LogViewer` | ✅ | Live-Log mit Farbcodierung |
| `DataTableWidget` | ✅ | Ergebnistabelle mit Sort/Filter |
| `BatchWizardScreen` | ❌ Screen | 5-Schritt Batch-Erstellung |
| `BatchExecutionScreen` | ❌ Screen | Batch-Ausführungs-Ansicht |
| `ResultsScreen` | ❌ Screen | Ergebnis-Anzeige |
| `SettingsScreen` | ❌ Screen | Einstellungen |
| `ModelManagerScreen` | ❌ Screen | Model-Verwaltung |

---

## 5. Datenmodelle

### 5.1 SQLite Schema

```sql
-- Globale Einstellungen
CREATE TABLE settings (
    key TEXT PRIMARY KEY,
    value TEXT,
    updated_at TEXT
);

-- Provider
CREATE TABLE providers (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    base_url TEXT NOT NULL,
    auth_type TEXT NOT NULL,  -- 'bearer', 'x-api-key', 'query_param', 'none'
    api_key_encrypted BLOB,
    is_local INTEGER DEFAULT 0,
    is_active INTEGER DEFAULT 1,
    created_at TEXT,
    updated_at TEXT
);

-- Models (User Overrides)
CREATE TABLE models (
    id TEXT PRIMARY KEY,
    provider_id TEXT REFERENCES providers(id),
    model_name TEXT NOT NULL,
    display_name TEXT,
    
    -- Pricing (NULL = aus Registry)
    price_input REAL,
    price_output REAL,
    
    -- Parameters (JSON, NULL = aus Registry)
    parameters_override TEXT,
    
    -- User Notes
    notes TEXT,
    
    is_active INTEGER DEFAULT 1,
    created_at TEXT,
    updated_at TEXT
);

-- Projects
CREATE TABLE projects (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    path TEXT NOT NULL,
    settings TEXT,  -- JSON
    created_at TEXT,
    updated_at TEXT
);

-- Batches
CREATE TABLE batches (
    id TEXT PRIMARY KEY,
    project_id TEXT REFERENCES projects(id),
    name TEXT NOT NULL,
    config TEXT NOT NULL,  -- JSON
    status TEXT DEFAULT 'draft',
    stats TEXT,  -- JSON
    created_at TEXT,
    updated_at TEXT
);

-- Logs (für Langzeit-Statistiken)
CREATE TABLE batch_logs (
    id TEXT PRIMARY KEY,
    batch_id TEXT REFERENCES batches(id),
    started_at TEXT,
    completed_at TEXT,
    status TEXT,
    input_tokens INTEGER,
    output_tokens INTEGER,
    cost REAL,
    error_count INTEGER
);
```

### 5.2 Dart Datenklassen (freezed)

```dart
// Provider
@freezed
class ProviderConfig with _$ProviderConfig {
  const factory ProviderConfig({
    required String id,
    required String name,
    required String baseUrl,
    required String authType, // 'bearer', 'x-api-key', 'query_param', 'none'
    required bool isLocal,
    required bool isActive,
  }) = _ProviderConfig;
  factory ProviderConfig.fromJson(Map<String, dynamic> json) =>
      _$ProviderConfigFromJson(json);
}

// Model (merged from registry + user)
@freezed
class ModelInfo with _$ModelInfo {
  const factory ModelInfo({
    required String id,
    required String providerId,
    required String modelName,
    required String displayName,
    String? description,
    required int contextWindow,
    required int maxOutputTokens,
    required ModelPricing pricing,
    required ModelCapabilities capabilities,
    required Map<String, ModelParameter> parameters,
    required String status, // 'active', 'deprecated', 'preview'
    required String source, // 'bundled', 'remote', 'user'
  }) = _ModelInfo;
  factory ModelInfo.fromJson(Map<String, dynamic> json) =>
      _$ModelInfoFromJson(json);
}

@freezed
class ModelPricing with _$ModelPricing {
  const factory ModelPricing({
    required double inputPerMillion,
    required double outputPerMillion,
    required String currency,
    required String updatedAt,
  }) = _ModelPricing;
  factory ModelPricing.fromJson(Map<String, dynamic> json) =>
      _$ModelPricingFromJson(json);
}

@freezed
class ModelCapabilities with _$ModelCapabilities {
  const factory ModelCapabilities({
    required bool chat,
    required bool vision,
    required bool functionCalling,
    required bool jsonMode,
    required bool streaming,
    required bool reasoning,
  }) = _ModelCapabilities;
  factory ModelCapabilities.fromJson(Map<String, dynamic> json) =>
      _$ModelCapabilitiesFromJson(json);
}

@freezed
class ModelParameter with _$ModelParameter {
  const factory ModelParameter({
    required bool supported,
    required String type, // 'float', 'integer', 'enum', 'boolean'
    double? min,
    double? max,
    dynamic defaultValue,
    List<String>? values, // für enum
  }) = _ModelParameter;
  factory ModelParameter.fromJson(Map<String, dynamic> json) =>
      _$ModelParameterFromJson(json);
}

// Project
@freezed
class Project with _$Project {
  const factory Project({
    required String id,
    required String name,
    required String path,
    required ProjectSettings settings,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Project;
  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);
}

@freezed
class ProjectSettings with _$ProjectSettings {
  const factory ProjectSettings({
    required bool strictLocalMode,
    String? defaultModel,
    required bool privacyWarningDismissed,
    required String language, // 'de', 'en'
  }) = _ProjectSettings;
  factory ProjectSettings.fromJson(Map<String, dynamic> json) =>
      _$ProjectSettingsFromJson(json);
}

// Batch
@freezed
class BatchConfig with _$BatchConfig {
  const factory BatchConfig({
    required String id,
    required String projectId,
    required String name,
    required String status, // 'draft', 'ready', 'running', 'paused', 'completed', 'failed'
    required BatchInput input,
    required List<String> prompts,
    required ChunkSettings chunkSettings,
    required List<BatchModelConfig> models,
    required BatchExecution execution,
    BatchStats? stats,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _BatchConfig;
  factory BatchConfig.fromJson(Map<String, dynamic> json) =>
      _$BatchConfigFromJson(json);
}

@freezed
class BatchInput with _$BatchInput {
  const factory BatchInput({
    required String sourceType, // 'excel', 'folder'
    required String sourcePath,
    required int itemCount,
    int? totalChars,
  }) = _BatchInput;
  factory BatchInput.fromJson(Map<String, dynamic> json) =>
      _$BatchInputFromJson(json);
}

@freezed
class ChunkSettings with _$ChunkSettings {
  const factory ChunkSettings({
    required int chunkSize,
    required String chunkMode, // 'sequential', 'random'
    required int repetitions,
  }) = _ChunkSettings;
  factory ChunkSettings.fromJson(Map<String, dynamic> json) =>
      _$ChunkSettingsFromJson(json);
}

@freezed
class BatchModelConfig with _$BatchModelConfig {
  const factory BatchModelConfig({
    required String modelId,
    required Map<String, dynamic> parameters,
    CostEstimate? costEstimate,
  }) = _BatchModelConfig;
  factory BatchModelConfig.fromJson(Map<String, dynamic> json) =>
      _$BatchModelConfigFromJson(json);
}

@freezed
class BatchExecution with _$BatchExecution {
  const factory BatchExecution({
    required bool supervisorMode,
    required int checkpointInterval,
  }) = _BatchExecution;
  factory BatchExecution.fromJson(Map<String, dynamic> json) =>
      _$BatchExecutionFromJson(json);
}

@freezed
class BatchStats with _$BatchStats {
  const factory BatchStats({
    required int totalItems,
    required int processedItems,
    required int failedItems,
    required int totalInputTokens,
    required int totalOutputTokens,
    required double actualCost,
    required int durationSeconds,
    required double tokensPerMinute,
  }) = _BatchStats;
  factory BatchStats.fromJson(Map<String, dynamic> json) =>
      _$BatchStatsFromJson(json);
}

@freezed
class CostEstimate with _$CostEstimate {
  const factory CostEstimate({
    required int inputTokens,
    required int outputTokens,
    required double inputCost,
    required double outputCost,
    required double totalCost,
  }) = _CostEstimate;
  factory CostEstimate.fromJson(Map<String, dynamic> json) =>
      _$CostEstimateFromJson(json);
}
```

---

## 6. Service-Spezifikation

> **Hinweis:** Da die App als reine Flutter/Dart-Anwendung implementiert wird, gibt es keine REST-API oder WebSocket-Verbindung. Stattdessen werden Dart-Services direkt aufgerufen und Hintergrund-Worker kommunizieren über Isolate-Messages (SendPort/ReceivePort).

### 6.1 Dart Service-Methoden

#### ProjectRepository

```dart
Future<List<Project>> getAllProjects();
Future<Project> createProject(String name, String path);
Future<Project> getProject(String id);
Future<void> updateProject(Project project);
Future<void> deleteProject(String id);
```

#### BatchRepository

```dart
Future<List<BatchConfig>> getBatchesForProject(String projectId);
Future<BatchConfig> createBatch(BatchConfig config);
Future<BatchConfig> getBatch(String id);
Future<void> updateBatch(BatchConfig config);
Future<void> deleteBatch(String id);
```

#### ProviderRepository

```dart
Future<List<ProviderConfig>> getAllProviders();
Future<void> addProvider(ProviderConfig provider);
Future<void> updateProvider(ProviderConfig provider);
Future<void> deleteProvider(String id);
Future<bool> testConnection(ProviderConfig provider, String apiKey);
Future<List<DiscoveredModel>> discoverModels(String providerId);
```

#### ModelRegistryService

```dart
Future<List<ModelInfo>> getAllModels();         // Merged: Bundled + Remote + User
Future<ModelInfo?> getModel(String id);
Future<void> saveUserOverride(ModelInfo model);
Future<void> removeUserOverride(String id);
Future<bool> checkForRegistryUpdate();
Future<void> applyRegistryUpdate();
```

#### FileParserService

```dart
Future<List<Item>> parseExcel(String filePath);
Stream<Item> parseFolderStream(String folderPath);
Future<String> loadPrompt(String promptPath);
```

#### EncryptionService / SettingsRepository

```dart
Future<Map<String, String>> getAllSettings();
Future<void> updateSettings(Map<String, String> settings);
Future<bool> verifyPassword(String password);
Future<void> changePassword(String oldPassword, String newPassword);
```

### 6.2 Isolate-Kommunikation (Worker Messages)

Die Batch-Ausführung läuft in einem separaten Dart-Isolate. Die Kommunikation erfolgt über typisierte Nachrichten:

```dart
// Worker → Main Isolate Events:
sealed class WorkerEvent {}

class ProgressEvent extends WorkerEvent {
  final int current;
  final int total;
  final double percentage;
  final String currentItem;
  final String currentPrompt;
  final int tokensIn;
  final int tokensOut;
}

class LogEvent extends WorkerEvent {
  final String level;    // 'INFO', 'WARN', 'ERROR', 'DEBUG'
  final String message;
  final DateTime timestamp;
}

class CheckpointEvent extends WorkerEvent {
  final int callNumber;
}

class CompletedEvent extends WorkerEvent {
  final BatchStats stats;
}

class ErrorEvent extends WorkerEvent {
  final String message;
  final String? itemId;
}

// Main Isolate → Worker Commands:
sealed class WorkerCommand {}
class PauseBatchCommand extends WorkerCommand {}
class ResumeBatchCommand extends WorkerCommand {}
class StopBatchCommand extends WorkerCommand {}
```

---

## 7. UI/UX-Spezifikation

### 7.1 Hauptnavigation

```
┌─────────────────────────────────────────────────────────────┐
│  [Logo] XtractAid                    [⚙️] [❓] [🔒 Local]   │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────┐                                           │
│  │  📁 Projects │                                           │
│  │              │     ┌─────────────────────────────────┐   │
│  │  • Project A │     │                                 │   │
│  │  • Project B │     │      [Hauptbereich]             │   │
│  │  + Neu       │     │                                 │   │
│  ├──────────────┤     │                                 │   │
│  │  📦 Batches  │     │                                 │   │
│  │              │     │                                 │   │
│  │  • Batch 1   │     │                                 │   │
│  │  • Batch 2   │     │                                 │   │
│  │  + Neu       │     │                                 │   │
│  ├──────────────┤     │                                 │   │
│  │  📊 Results  │     │                                 │   │
│  ├──────────────┤     └─────────────────────────────────┘   │
│  │  🤖 Models   │                                           │
│  └──────────────┘                                           │
└─────────────────────────────────────────────────────────────┘
```

### 7.2 Batch-Wizard (5 Schritte)

#### Schritt 1: Items auswählen

```
┌─────────────────────────────────────────────────────────────┐
│  Schritt 1 von 5: Items auswählen                           │
│  ○────●────○────○────○                                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Quelle:  (●) Excel-Datei   ( ) Dokumenten-Ordner           │
│                                                              │
│  ┌─────────────────────────────────────────────────────────┐│
│  │ 📄 /Users/researcher/data/patients.xlsx                 ││
│  │                                        [Durchsuchen...] ││
│  └─────────────────────────────────────────────────────────┘│
│                                                              │
│  ✅ 150 Items geladen                                        │
│                                                              │
│  Vorschau:                                                  │
│  ┌─────────────────────────────────────────────────────────┐│
│  │ ID    │ Item (Vorschau)                                 ││
│  │───────┼─────────────────────────────────────────────────││
│  │ P001  │ "Ich fühle mich seit Wochen antriebslos..."     ││
│  │ P002  │ "Die Angst kommt immer nachts wenn ich..."      ││
│  │ P003  │ "Mein Arzt sagt ich soll mehr rausgehen..."     ││
│  │ ...   │ ...                                             ││
│  └─────────────────────────────────────────────────────────┘│
│                                                              │
│                                      [Zurück] [Weiter →]    │
└─────────────────────────────────────────────────────────────┘
```

#### Schritt 2: Prompts auswählen

```
┌─────────────────────────────────────────────────────────────┐
│  Schritt 2 von 5: Prompts auswählen                         │
│  ●────●────○────○────○                                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Verfügbar:                    Ausgewählt (Reihenfolge):    │
│  ┌───────────────────┐         ┌───────────────────┐        │
│  │ □ P3_quality.md   │    →    │ ≡ P1_diagnosis.md │        │
│  │ □ P4_treatment.md │    ←    │ ≡ P2_symptoms.md  │        │
│  └───────────────────┘         └───────────────────┘        │
│                                                              │
│  Vorschau: P1_diagnosis.md                                  │
│  ┌─────────────────────────────────────────────────────────┐│
│  │ # Diagnose-Extraktion                                   ││
│  │                                                         ││
│  │ ## AUFGABE                                              ││
│  │ Analysiere den Patientenbericht und extrahiere...       ││
│  │                                                         ││
│  │ [Insert IDs and Items here]  ← ✅ Platzhalter gefunden   ││
│  └─────────────────────────────────────────────────────────┘│
│                                                              │
│                                    [← Zurück] [Weiter →]    │
└─────────────────────────────────────────────────────────────┘
```

#### Schritt 3: Chunk-Einstellungen

```
┌─────────────────────────────────────────────────────────────┐
│  Schritt 3 von 5: Verarbeitungs-Einstellungen               │
│  ●────●────●────○────○                                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Chunk-Größe:    [    5    ] Items pro API-Call             │
│                  ○─────●───────────────────────────         │
│                  1     5                         100         │
│                                                              │
│  Wiederholungen: [    1    ] mal                            │
│                  ●─────────────────────────────────         │
│                  1                                100        │
│                                                              │
│  ℹ️ Bei mehreren Wiederholungen werden die Items            │
│     jedes Mal zufällig neu gemischt.                        │
│                                                              │
│  ┌─────────────────────────────────────────────────────────┐│
│  │ Zusammenfassung:                                        ││
│  │ • 150 Items ÷ 5 pro Chunk = 30 Chunks                   ││
│  │ • 2 Prompts × 30 Chunks × 1 Wdh. = 60 API-Calls         ││
│  └─────────────────────────────────────────────────────────┘│
│                                                              │
│                                    [← Zurück] [Weiter →]    │
└─────────────────────────────────────────────────────────────┘
```

#### Schritt 4: Model konfigurieren

```
┌─────────────────────────────────────────────────────────────┐
│  Schritt 4 von 5: Model konfigurieren                       │
│  ●────●────●────●────○                                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Model:   [claude-sonnet-4-20250514 ▼]                                  │
│           Anthropic • $3/$15 per M • 200K Kontext           │
│                                                              │
│  ─────────────────────────────────────────────────────────  │
│                                                              │
│  Temperature:    [  0.1  ]                                  │
│                  ●─────────────────────────────────         │
│                  0.0                              1.0        │
│                                                              │
│  Max Tokens:     [ 4000  ]                                  │
│                  ○─────────●───────────────────────         │
│                  100                            16384        │
│                                                              │
│  Request Delay:  [  0.0  ] Sekunden                         │
│                                                              │
│  ─────────────────────────────────────────────────────────  │
│                                                              │
│  [+ Weiteres Model für Vergleich hinzufügen]                │
│                                                              │
│                                    [← Zurück] [Weiter →]    │
└─────────────────────────────────────────────────────────────┘
```

#### Schritt 5: Bestätigung & Start

```
┌─────────────────────────────────────────────────────────────┐
│  Schritt 5 von 5: Überprüfen & Starten                      │
│  ●────●────●────●────●                                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────────────────────────────────────────────────────┐│
│  │ Zusammenfassung                                         ││
│  │─────────────────────────────────────────────────────────││
│  │ Items:       150 aus patients.xlsx                      ││
│  │ Prompts:     2 (P1_diagnosis.md, P2_symptoms.md)        ││
│  │ Chunks:      30 (à 5 Items)                             ││
│  │ Wdh.:        1                                          ││
│  │ Model:       claude-sonnet-4-20250514 @ temp 0.1                     ││
│  │ API-Calls:   60                                         ││
│  └─────────────────────────────────────────────────────────┘│
│                                                              │
│  ┌─────────────────────────────────────────────────────────┐│
│  │ Kostenvoranschlag                                       ││
│  │─────────────────────────────────────────────────────────││
│  │ Geschätzte Input-Tokens:    520,000     (~$1.56)        ││
│  │ Geschätzte Output-Tokens:   240,000     (~$3.60) max    ││
│  │ ───────────────────────────────────────────────         ││
│  │ GESCHÄTZTE GESAMTKOSTEN:    $5.16 (max)                 ││
│  └─────────────────────────────────────────────────────────┘│
│                                                              │
│  ⚠️ Daten werden an Anthropic-Server gesendet.              │
│  [✓] Ich bestätige die Datenschutz-Konformität             │
│                                                              │
│                              [← Zurück] [🚀 Batch starten]  │
└─────────────────────────────────────────────────────────────┘
```

### 7.3 Batch-Ausführung

```
┌─────────────────────────────────────────────────────────────┐
│  Batch: "Patienten-Diagnose"              [⏸ Pause] [⏹ Stop]│
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░  58% (35/60 Calls)             │
│                                                              │
│  ┌─────────────────────────────────────────────────────────┐│
│  │ Aktuell:                                                ││
│  │ Item-Gruppe:  P026-P030                                 ││
│  │ Prompt:       P1_diagnosis.md                           ││
│  │ Wiederholung: 1/1                                       ││
│  │ Chunk:        6/30                                      ││
│  └─────────────────────────────────────────────────────────┘│
│                                                              │
│  Live-Log:                                   [Filter: Alle ▼]│
│  ┌─────────────────────────────────────────────────────────┐│
│  │ 14:32:15 [INFO]  Verarbeite Chunk 5 (P021-P025)         ││
│  │ 14:32:19 [INFO]  ✓ OK: In=8,523 Out=1,245               ││
│  │ 14:32:19 [INFO]  Verarbeite Chunk 6 (P026-P030)         ││
│  │ 14:32:21 [WARN]  Rate Limit, warte 30s...               ││
│  │ 14:32:51 [INFO]  Retry 1/5...                           ││
│  │ 14:32:55 [INFO]  ✓ OK: In=7,891 Out=1,102               ││
│  │ 14:32:55 [INFO]  Checkpoint gespeichert (#35)           ││
│  └─────────────────────────────────────────────────────────┘│
│                                                              │
│  ┌─────────────────────────────────────────────────────────┐│
│  │ Statistik                                               ││
│  │─────────────────────────────────────────────────────────││
│  │ Vergangen:    25m              Verbleibend: ~18m (est.) ││
│  │ Tokens/min:   15,240           Items/min: 3.5           ││
│  │ Input:        382,000          Output: 98,000           ││
│  │ Kosten bisher: $1.62           Fehler: 1                ││
│  └─────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

---

## 8. Nicht-funktionale Anforderungen

### 8.1 Performance

| Anforderung | Zielwert |
|-------------|----------|
| App-Start | < 3 Sekunden |
| Batch-Start | < 1 Sekunde |
| UI-Responsiveness | < 100ms |
| Dokument-Laden | 100 PDFs in < 30s |
| Isolate-Message-Latenz | < 50ms |

### 8.2 Zuverlässigkeit

| Anforderung | Beschreibung |
|-------------|--------------|
| Crash Recovery | Checkpoint alle 10 Calls |
| Datenverlust | Max. 10 Calls bei Absturz |
| Langzeit-Stabilität | 8+ Stunden kontinuierlich |
| Graceful Shutdown | Warnung + Checkpoint bei Schließen |

### 8.3 Sicherheit

| Anforderung | Implementierung |
|-------------|-----------------|
| API-Key-Schutz | AES-256-GCM |
| Master-Passwort | PBKDF2 (100k Iterationen) |
| Log-Maskierung | Automatisch für alle Secrets |
| Keine Telemetrie | Keine Daten an Externe |

### 8.4 Usability

| Anforderung | Beschreibung |
|-------------|--------------|
| Onboarding | Setup-Wizard |
| Hilfe | Tooltips, In-App-Dokumentation |
| Fehler | Klare, verständliche Meldungen |
| Lokalisierung | Deutsch + Englisch |

---

## 9. MVP-Scope & Roadmap

### 9.1 MVP (Version 1.0)

| Kategorie | Feature | Priorität |
|-----------|---------|-----------|
| **Input** | Excel (.xlsx, .csv) | P0 |
| | Folder (PDF, DOCX, TXT, MD) | P0 |
| | Fortschrittsanzeige | P1 |
| **Prompts** | Multi-Prompt-Auswahl | P0 |
| | Platzhalter-Injection | P0 |
| | Auto-Load aus prompts/ | P1 |
| **Models** | Model Registry (bundled) | P0 |
| | OpenAI, Anthropic, Gemini | P0 |
| | Ollama, LM Studio | P0 |
| | Dynamische Parameter-UI | P0 |
| **Processing** | Chunk/Repetition | P0 |
| | Retry mit Backoff | P0 |
| | JSON-Parsing (Multi-Fallback) | P0 |
| | `<think>`-Tag Handling | P1 |
| **Checkpointing** | Speichern/Resume | P0 |
| **Cost** | Token-Schätzung | P0 |
| | Bestätigungs-Dialog | P0 |
| **Output** | Excel-Export | P0 |
| | Log-Datei (Markdown) | P0 |
| | HTML-Report | P1 |
| **Security** | API-Key-Verschlüsselung | P0 |
| | Strict Local Mode | P1 |
| | Datenschutz-Warnung | P1 |
| **UI** | Setup-Wizard | P0 |
| | Batch-Wizard (5 Steps) | P0 |
| | Live-Progress + Log | P0 |
| | Model Manager | P0 |

### 9.2 Version 1.x

| Version | Feature |
|---------|---------|
| 1.1 | Remote Registry Updates |
| 1.1 | Prompt-Editor (in-app) |
| 1.2 | Parallelisierung (mehrere Calls) |
| 1.2 | OCR für Scans |
| 1.3 | Erweiterte Report-Optionen |

### 9.3 Version 2.0

| Feature | Beschreibung |
|---------|--------------|
| PromptPal | Assistierte Prompt-Erstellung |
| Templates | Vorgefertigte Prompts |
| Plugin-System | Erweiterbar |
| Web-Version | Browser-basiert |

---

## 10. Anhang

### A. Model Registry JSON Schema

Siehe separate Datei: `model_registry_schema.json`

### B. Beispiel-Prompt

```markdown
# Diagnose-Extraktion für Patientenberichte

## AUFGABE
Analysiere den Patientenbericht und extrahiere die wahrscheinlichste 
psychiatrische Diagnose sowie Differenzialdiagnosen.

## AUSGABEFORMAT
- NUR ein valides JSON-Array zurückgeben
- Kein Markdown, keine Kommentare

## FELDER
- **ID**: Exakt wie im Input
- **PrimaryDiagnosis**: Hauptdiagnose (String)
- **PrimaryDiagnosis_ICD10**: ICD-10 Code
- **Confidence**: Konfidenz 0-100
- **DifferentialDiagnoses**: Array von Strings
- **KeySymptoms**: Array der erkannten Symptome

## JSON SCHEMA
```json
[
  {
    "ID": "P001",
    "PrimaryDiagnosis": "Major Depression",
    "PrimaryDiagnosis_ICD10": "F32.1",
    "Confidence": 85,
    "DifferentialDiagnoses": ["Dysthymia", "Adjustment Disorder"],
    "KeySymptoms": ["Antriebslosigkeit", "Schlafstörungen", "Hoffnungslosigkeit"]
  }
]
```

---

**IDs and Items:**
[Insert IDs and Items here]
```

### C. Glossar

| Begriff | Definition |
|---------|------------|
| **Batch** | Analyse-Einheit: Items + Prompts + Model |
| **Chunk** | Gruppe von Items pro API-Call |
| **Item** | Einzelner Text zur Analyse |
| **Checkpoint** | Gespeicherter Zwischenstand |
| **Repetition** | Wiederholte Analyse mit Shuffle |
| **Registry** | Datenbank mit Model-Informationen |
| **Strict Local Mode** | Nur lokale LLMs erlaubt |

### D. Tastaturkürzel

| Kürzel | Aktion |
|--------|--------|
| `Ctrl+N` | Neues Projekt |
| `Ctrl+O` | Projekt öffnen |
| `Ctrl+S` | Speichern |
| `Ctrl+Shift+N` | Neuer Batch |
| `F5` | Batch starten |
| `Ctrl+P` | Batch pausieren |
| `Escape` | Batch abbrechen |
| `F1` | Hilfe |
