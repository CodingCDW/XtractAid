# XtractAid – Dokumentationsübersicht

## Finale Dokumente

### 1. Product Requirements Document (PRD)
**Datei:** `XtractAid_PRD_Final.md`

Vollständige Spezifikation für Entwickler:
- Executive Summary & Vision
- Use Cases (4 detaillierte Szenarien)
- Funktionale Anforderungen (13 Kategorien, 50+ Einzelanforderungen)
- Technische Architektur (Flutter + Dart + SQLite)
- Datenmodelle (SQLite Schema + Dart Datenklassen)
- Service-Spezifikation (Dart Services + Isolate-Kommunikation)
- UI/UX-Spezifikation (Wireframes für alle Screens)
- Nicht-funktionale Anforderungen
- MVP-Scope & Roadmap
- Anhang (Beispiel-Prompt, Glossar, Tastaturkürzel)

**Seitenumfang:** ~80 Seiten

---

### 2. Model Registry Spezifikation
**Datei:** `XtractAid_ModelRegistry_Spec.md`

Detaillierte Spezifikation des 3-Stufen Model Registry Systems:
- Bundled Registry (mit App ausgeliefert)
- Remote Registry (GitHub-hosted, Auto-Updates)
- User Overrides (lokale Anpassungen)
- Vollständiges JSON-Schema mit allen Model-Feldern
- Service-Implementierung (Dart)
- UI-Integration (Flutter)
- Update-Mechanismus

**Enthält:** Vollständige `model_registry.json` mit allen aktuellen Models

---

## Für Entwickler: Quick Start

### 1. PRD lesen
Beginnen Sie mit `XtractAid_PRD_Final.md`:
- **Abschnitt 1-2:** Verstehen Sie die Vision und Use Cases
- **Abschnitt 3:** Detaillierte funktionale Anforderungen
- **Abschnitt 4-6:** Technische Architektur und Datenmodelle

### 2. Tech-Stack aufsetzen

- flutter
- dart
- sqlite


### 3. Empfohlene Implementierungsreihenfolge

**Phase 1: Foundation (Woche 1-2)**
- [ ] Projektstruktur (Flutter Desktop App)
- [ ] SQLite-Schema
- [ ] Model Registry Service (bundled JSON laden)
- [ ] Encryption Service (API-Keys)
- [ ] Basis-App-Shell + Navigation (GoRouter)

**Phase 2: Core Services (Woche 2-4)**
- [ ] File Parser (Excel, PDF, DOCX, TXT, MD)
- [ ] LLM Worker (API-Calls, Retry-Logik)
- [ ] JSON Parser (Multi-Fallback)
- [ ] Checkpoint Service
- [ ] Tokenizer Service

**Phase 3: Frontend Core (Woche 4-6)**
- [ ] Setup Wizard
- [ ] Project Manager
- [ ] Batch Wizard (5 Schritte)
- [ ] Shared Widgets (FileSelector, PromptViewer, etc.)

**Phase 4: Integration (Woche 6-8)**
- [ ] Isolate-Kommunikation für Real-time Updates
- [ ] Batch-Ausführungs-Screen
- [ ] Report Generator (Excel, HTML, Log)
- [ ] Model Manager UI

**Phase 5: Polish (Woche 8-10)**
- [ ] Lokalisierung (DE/EN)
- [ ] Fehlerbehandlung & UX
- [ ] Tests
- [ ] Distribution (Installer)

---

## Schlüsselkonzepte

### Batch-Workflow
```
Items + Prompts + Model → Chunks → API-Calls → JSON-Parsing → Ergebnisse → Excel/HTML
```

### Item-Injection
```
Prompt-Template mit Platzhalter:
  [Insert IDs and Items here]

Wird ersetzt durch:
  {"ID": "P001", "Item": "Patientenbericht..."}
  {"ID": "P002", "Item": "Weiterer Text..."}
```

### Checkpoint-System
- Alle 10 API-Calls: Automatisch speichern
- Bei Absturz/Stop: Resume möglich
- Beinhaltet: Progress, Tokens, Ergebnisse, Config

### Model Registry (3 Stufen)
```
Bundled (offline) → Remote (updates) → User (overrides)
```

---

## Kontakt & Feedback

Bei Fragen zur Spezifikation: [TODO: Kontakt]
