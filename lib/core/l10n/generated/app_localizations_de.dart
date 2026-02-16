// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class SDe extends S {
  SDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'XtractAid';

  @override
  String get navProjects => 'Projekte';

  @override
  String get navModels => 'Modelle';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get actionBack => 'Zurueck';

  @override
  String get actionNext => 'Weiter';

  @override
  String get actionCancel => 'Abbrechen';

  @override
  String get actionClose => 'Schliessen';

  @override
  String get actionSave => 'Speichern';

  @override
  String get actionDelete => 'Loeschen';

  @override
  String get actionOpen => 'Oeffnen';

  @override
  String get actionCreate => 'Erstellen';

  @override
  String get actionChange => 'Aendern';

  @override
  String get actionContinue => 'Fortfahren';

  @override
  String get actionDone => 'Fertig';

  @override
  String get actionStart => 'Start';

  @override
  String get actionPause => 'Pause';

  @override
  String get actionResume => 'Fortsetzen';

  @override
  String get actionStop => 'Stop';

  @override
  String get actionChooseFolder => 'Ordner waehlen';

  @override
  String get actionChooseFile => 'Datei waehlen';

  @override
  String get actionLoad => 'Laden';

  @override
  String get actionSelect => 'Waehlen';

  @override
  String get actionUnlock => 'Entsperren';

  @override
  String get actionReset => 'Zuruecksetzen';

  @override
  String get actionTestConnection => 'Verbindung testen';

  @override
  String get labelLanguage => 'Sprache';

  @override
  String get labelGerman => 'Deutsch';

  @override
  String get labelEnglish => 'English';

  @override
  String get labelPassword => 'Passwort';

  @override
  String get labelConfirmPassword => 'Passwort bestaetigen';

  @override
  String get labelCurrentPassword => 'Aktuelles Passwort';

  @override
  String get labelNewPassword => 'Neues Passwort';

  @override
  String get labelConfirmNewPassword => 'Neues Passwort bestaetigen';

  @override
  String get labelMasterPassword => 'Master-Passwort';

  @override
  String get labelApiKey => 'API-Key';

  @override
  String get labelProvider => 'Provider';

  @override
  String get labelModel => 'Model';

  @override
  String get labelProjectName => 'Projektname';

  @override
  String get labelStatus => 'Status:';

  @override
  String get labelUnknown => 'Unbekannt';

  @override
  String get labelLocal => 'lokal';

  @override
  String get labelCloud => 'cloud';

  @override
  String get setupTitle => 'Ersteinrichtung';

  @override
  String get setupStepWelcome => 'Willkommen';

  @override
  String get setupStepPassword => 'Master-Passwort';

  @override
  String get setupStepProvider => 'Provider waehlen';

  @override
  String get setupStepApiKey => 'API-Key und Test';

  @override
  String get setupStepBasicSettings => 'Grundeinstellungen';

  @override
  String get setupStepFinish => 'Fertig';

  @override
  String get setupStartApp => 'XtractAid starten';

  @override
  String get setupDescription =>
      'XtractAid analysiert Textdaten aus Dateien in Batches mit LLM-Modellen und erstellt strukturierte Ergebnisse.';

  @override
  String get setupGermanLabel => 'Deutsch (DE)';

  @override
  String get setupEnglishLabel => 'English (EN)';

  @override
  String get setupProviderHint =>
      'Cloud-Provider benoetigen einen API-Key. Lokale Provider (Ollama, LM Studio) laufen auf Ihrem Rechner.';

  @override
  String get setupLocalApiKeyHint =>
      'Lokaler Provider: API-Key wird nicht benoetigt. Bitte nur die Verbindung testen.';

  @override
  String get setupConnectionSuccess => 'Verbindung erfolgreich.';

  @override
  String get setupConnectionFailed => 'Verbindung fehlgeschlagen.';

  @override
  String get setupStrictLocalMode => 'Strict Local Mode';

  @override
  String get setupStrictLocalModeDesc =>
      'Nur lokale Provider erlauben (Ollama, LM Studio).';

  @override
  String get setupSettingsChangeLater =>
      'Diese Einstellungen koennen spaeter in den Einstellungen geaendert werden.';

  @override
  String get setupSummaryTitle => 'Setup-Zusammenfassung';

  @override
  String get setupSummaryConnection => 'Verbindung';

  @override
  String get setupSummaryPasswordSet => 'Gesetzt';

  @override
  String get setupSummaryPasswordNotSet => 'Nicht gesetzt';

  @override
  String get setupSummaryConnectionOk => 'OK';

  @override
  String get setupSummaryConnectionFail => 'Nicht getestet/fehlgeschlagen';

  @override
  String get setupNoProviderData => 'Keine Providerdaten gefunden.';

  @override
  String get setupProviderLoadError => 'Provider konnten nicht geladen werden.';

  @override
  String get setupSelectProvider => 'Bitte einen Provider auswaehlen.';

  @override
  String get setupLanguageSaveError =>
      'Sprache konnte nicht gespeichert werden.';

  @override
  String get setupMinPasswordLength => 'Mindestens 8 Zeichen erforderlich.';

  @override
  String get setupPasswordMismatch => 'Passwoerter stimmen nicht ueberein.';

  @override
  String get setupPasswordSaveError =>
      'Passwort konnte nicht gespeichert werden.';

  @override
  String get setupNoProviderSelected => 'Kein Provider ausgewaehlt.';

  @override
  String get setupEnterApiKey => 'Bitte API-Key eingeben.';

  @override
  String get setupTestConnectionFirst =>
      'Bitte zuerst eine erfolgreiche Verbindung pruefen.';

  @override
  String get setupProviderSaveError =>
      'Provider konnte nicht gespeichert werden.';

  @override
  String get setupSettingsSaveError =>
      'Grundeinstellungen konnten nicht gespeichert werden.';

  @override
  String get setupCompleteError => 'Setup konnte nicht abgeschlossen werden.';

  @override
  String get passwordStrength => 'Passwortstaerke';

  @override
  String get passwordWeak => 'Schwach (unter 8 Zeichen)';

  @override
  String get passwordMedium => 'Mittel (mindestens 8 Zeichen)';

  @override
  String get passwordStrong => 'Stark (12+ Zeichen)';

  @override
  String get authEnterPassword => 'Bitte Passwort eingeben.';

  @override
  String get authSetupIncomplete =>
      'Setup unvollstaendig. Bitte neu einrichten.';

  @override
  String get authWrongPassword => 'Falsches Passwort';

  @override
  String get authUnlockFailed => 'Entsperren fehlgeschlagen.';

  @override
  String get authForgotPassword => 'Passwort vergessen?';

  @override
  String get authResetWarning => 'Alle API-Keys werden geloescht. Fortfahren?';

  @override
  String get authResetFailed => 'Reset fehlgeschlagen.';

  @override
  String get projectsTitle => 'Projekte';

  @override
  String get projectsNew => 'Neues Projekt';

  @override
  String get projectsOpen => 'Projekt oeffnen';

  @override
  String get projectsEmpty => 'Erstellen Sie Ihr erstes Projekt';

  @override
  String get projectsCreateError => 'Projekt konnte nicht erstellt werden.';

  @override
  String get projectsInvalidProject => 'Kein gueltiges XtractAid-Projekt';

  @override
  String get projectsOpenError => 'Projekt konnte nicht geoeffnet werden.';

  @override
  String get projectsNotFound => 'Projekt nicht gefunden.';

  @override
  String get projectsLastOpened => 'Letzte Oeffnung:';

  @override
  String get projectsNever => 'Nie';

  @override
  String projectsDeleteConfirm(String name, String path) {
    return 'Projekt \"$name\" loeschen?\n\nPfad: $path\n\nDu kannst nur den Listeneintrag entfernen oder das gesamte Projekt inklusive Ordner und aller Batch-Daten loeschen.';
  }

  @override
  String get projectsDeleteListOnly => 'Nur aus Liste entfernen';

  @override
  String get projectsDeleteProject => 'Projekt loeschen';

  @override
  String projectsDeleteSuccessFull(String name) {
    return 'Projekt \"$name\" wurde vollstaendig geloescht.';
  }

  @override
  String projectsDeleteSuccessList(String name) {
    return 'Projekt \"$name\" wurde aus der Liste entfernt.';
  }

  @override
  String projectsDeleteFailed(String error) {
    return 'Projekt konnte nicht geloescht werden: $error';
  }

  @override
  String get projectCreateTitle => 'Neues Projekt erstellen';

  @override
  String get projectCreateNameHint => 'Bitte Projektname eingeben.';

  @override
  String get projectCreateFolderHint => 'Bitte Zielordner waehlen.';

  @override
  String get projectNoFolderSelected => 'Kein Ordner ausgewaehlt';

  @override
  String get projectOpenTitle => 'Projekt oeffnen';

  @override
  String get projectOpenFolderHint => 'Bitte Projektordner waehlen.';

  @override
  String get projectDetailNewBatch => 'Neuer Batch';

  @override
  String get projectDetailBatches => 'Batches';

  @override
  String get projectDetailPrompts => 'Prompts';

  @override
  String get projectDetailInput => 'Input';

  @override
  String get projectDetailNoBatches => 'Noch keine Batches vorhanden.';

  @override
  String get projectDetailNoPromptFiles => 'Keine Prompt-Dateien gefunden.';

  @override
  String get projectDetailNoInputFiles => 'Keine Input-Dateien gefunden.';

  @override
  String get batchWizardItemsTitle => 'Items laden';

  @override
  String get batchWizardPromptsTitle => 'Prompts waehlen';

  @override
  String get batchWizardChunksTitle => 'Chunks';

  @override
  String get batchWizardModelTitle => 'Model konfigurieren';

  @override
  String get batchWizardConfirmTitle => 'Bestaetigen + starten';

  @override
  String get batchWizardStartBatch => 'Batch starten';

  @override
  String batchWizardTitle(String projectName) {
    return 'Batch Wizard - $projectName';
  }

  @override
  String get batchWizardSelectSource =>
      'Bitte zuerst eine Eingabequelle waehlen.';

  @override
  String get batchWizardLoadItems => 'Bitte Items laden, bevor du fortfaehrst.';

  @override
  String get batchWizardSelectPrompt =>
      'Bitte mindestens einen Prompt auswaehlen.';

  @override
  String get batchWizardSelectModel => 'Bitte ein Model auswaehlen.';

  @override
  String get batchWizardConfirmPrivacy =>
      'Bitte die Datenschutz-Bestaetigung aktivieren.';

  @override
  String get batchWizardStartError => 'Batch kann nicht gestartet werden.';

  @override
  String get batchWizardSaveError => 'Batch konnte nicht gespeichert werden.';

  @override
  String get batchWizardNotLoaded =>
      'Batch Wizard konnte nicht geladen werden.';

  @override
  String get batchWizardProjectNotLoaded => 'Projekt nicht geladen.';

  @override
  String get batchWizardSaveChangesTitle => 'Batch-Aenderungen speichern';

  @override
  String get batchWizardSaveChangesMessage =>
      'Dieser Batch ist bereits abgeschlossen oder fehlgeschlagen. Moechtest du ihn aktualisieren oder als neuen Batch speichern?';

  @override
  String get batchWizardUpdateExisting => 'Bestehenden aktualisieren';

  @override
  String get batchWizardSaveAsNew => 'Als neu speichern';

  @override
  String get batchWizardRunningNotEditable =>
      'Laufende Batches koennen nicht bearbeitet werden.';

  @override
  String batchWizardGeneratedName(String timestamp) {
    return 'Batch $timestamp';
  }

  @override
  String batchWizardInactiveModelWarning(String status) {
    return 'Der ausgewaehlte Modellstatus ist \"$status\". Fuer neue Laeufe sollte ein aktives Modell verwendet werden.';
  }

  @override
  String get batchWizardItemsFallbackWarning =>
      'Items konnten nicht aus der Eingabequelle geladen werden. Es wird die gespeicherte Item-Anzahl verwendet.';

  @override
  String get batchDeleteTitle => 'Batch loeschen?';

  @override
  String batchDeleteDesc(String name) {
    return 'Batch \"$name\" loeschen? Dies kann nicht rueckgaengig gemacht werden.';
  }

  @override
  String get itemsExcelCsv => 'Excel/CSV';

  @override
  String get itemsDocFolder => 'Dokumenten-Ordner';

  @override
  String get itemsFileSource => 'Dateiquelle';

  @override
  String get itemsFolderSource => 'Ordnerquelle';

  @override
  String get itemsSummary => 'Zusammenfassung:';

  @override
  String itemsCount(int count, int warnings) {
    return '$count Items, $warnings Warnungen';
  }

  @override
  String get itemsIdColumn => 'ID-Spalte';

  @override
  String get itemsIdLabel => 'ID';

  @override
  String get itemsItemColumn => 'Item-Spalte';

  @override
  String get itemsPreviewText => 'Text (Vorschau)';

  @override
  String get chunksChunkSize => 'Chunk-Groesse:';

  @override
  String get chunksRepetitions => 'Wiederholungen:';

  @override
  String chunksCalcChunks(int items, int chunkSize, int chunks) {
    return '$items Items / $chunkSize = $chunks Chunks';
  }

  @override
  String chunksCalcCalls(int chunks, int prompts, int reps, int calls) {
    return '$chunks Chunks x $prompts Prompts x $reps Wdh. = $calls API-Calls';
  }

  @override
  String get chunksTooltip =>
      'Bei chunk_size > 1 werden mehrere Items gleichzeitig im Prompt gesendet. Dies spart API-Calls, kann aber die Qualitaet reduzieren.';

  @override
  String get confirmItems => 'Items:';

  @override
  String get confirmSource => 'Quelle:';

  @override
  String get confirmPrompts => 'Prompts:';

  @override
  String get confirmChunkSize => 'Chunk-Groesse:';

  @override
  String get confirmRepetitions => 'Wiederholungen:';

  @override
  String get confirmTotalCalls => 'Gesamt API-Calls:';

  @override
  String get confirmModel => 'Model:';

  @override
  String get confirmPrivacyCheckbox =>
      'Ich bestaetige, dass das Senden dieser Daten an den Cloud-Provider mit meinen Datenschutzanforderungen vereinbar ist.';

  @override
  String get promptPreview => 'Prompt-Vorschau';

  @override
  String get promptSelectorAvailable => 'Verfuegbar';

  @override
  String get promptSelectorSelected => 'Ausgewaehlt';

  @override
  String get promptImport => 'Importieren';

  @override
  String get promptImportTooltip =>
      'Prompt-Dateien von der Festplatte importieren';

  @override
  String promptImportSuccess(int count) {
    return '$count Prompt(s) importiert.';
  }

  @override
  String promptImportSkipped(String names) {
    return 'Uebersprungen (existiert bereits): $names';
  }

  @override
  String get modelContext => 'Kontext:';

  @override
  String get modelPriceLabel => 'Preis (Input/Output je 1M):';

  @override
  String get execTitle => 'Ausfuehrung';

  @override
  String get execBatchTitle => 'Batch-Ausfuehrung';

  @override
  String execBatchNameTitle(String name) {
    return 'Batch: $name';
  }

  @override
  String get execBatchId => 'Batch ID:';

  @override
  String get execCurrentPromptName => 'Aktueller Prompt-Name:';

  @override
  String get execCurrentModel => 'Aktuelles Modell:';

  @override
  String get execPreparingInput =>
      'Konfiguration geladen. Eingabedaten werden vorbereitet...';

  @override
  String get execRepetition => 'Repetition:';

  @override
  String get execPrompt => 'Prompt:';

  @override
  String get execChunk => 'Chunk:';

  @override
  String get execCompletedCalls => 'Completed Calls:';

  @override
  String get execFailedCalls => 'Failed Calls:';

  @override
  String get execInputTokens => 'Input Tokens:';

  @override
  String get execOutputTokens => 'Output Tokens:';

  @override
  String get execResults => 'Results:';

  @override
  String get execLoadingConfig => 'Batch-Konfiguration wird geladen...';

  @override
  String get execBatchNotFound => 'Batch nicht gefunden.';

  @override
  String get execProjectNotFound => 'Projekt nicht gefunden.';

  @override
  String get execInvalidConfig => 'Ungueltige Batch-Konfiguration.';

  @override
  String get execNoItems => 'Keine Items fuer die Ausfuehrung gefunden.';

  @override
  String get execLoadingPrompts => 'Prompts werden geladen...';

  @override
  String get execNoPrompts =>
      'Keine Prompt-Dateien aus der Batch-Konfiguration gefunden.';

  @override
  String execStartFailed(String error) {
    return 'Start fehlgeschlagen: $error';
  }

  @override
  String get execBatchStarted => 'Batch gestartet.';

  @override
  String execReportsCreated(String paths) {
    return 'Reports erstellt: $paths';
  }

  @override
  String execReportsFailed(String error) {
    return 'Report-Generierung fehlgeschlagen: $error';
  }

  @override
  String get execStatusIdle => 'LEERLAUF';

  @override
  String get execStatusStarting => 'STARTET';

  @override
  String get execStatusRunning => 'LAEUFT';

  @override
  String get execStatusPaused => 'PAUSIERT';

  @override
  String get execStatusCompleted => 'ABGESCHLOSSEN';

  @override
  String get execStatusFailed => 'FEHLER';

  @override
  String execProgressCalls(String percent, int completed, int total) {
    return '$percent%  |  $completed/$total Aufrufe';
  }

  @override
  String get modelsTitle => 'Modelle';

  @override
  String get modelsRegistry => 'Registry Models';

  @override
  String get modelsCustom => 'Custom Models';

  @override
  String get modelsDiscovered => 'Discovered Models';

  @override
  String modelsRegistryError(String error) {
    return 'Registry-Fehler: $error';
  }

  @override
  String get modelsNoRegistry => 'Keine Registry-Models gefunden.';

  @override
  String modelsCountLabel(int count) {
    return '$count Modelle';
  }

  @override
  String get modelsNoCustom => 'Keine Custom Model Overrides vorhanden.';

  @override
  String get modelsQueryProviders => 'Provider abfragen';

  @override
  String get modelsNoDiscovery => 'Noch keine Discovery-Daten.';

  @override
  String get modelsShowInactive => 'Inaktive/veraltete Modelle anzeigen';

  @override
  String modelsRegistryTileSubtitle(
    String id,
    int contextWindow,
    double inputPrice,
    double outputPrice,
  ) {
    return 'ID: $id | Kontext: $contextWindow | USD/M in/out: $inputPrice/$outputPrice';
  }

  @override
  String get modelsIdLabel => 'ID:';

  @override
  String get modelsProviderLabel => 'Provider:';

  @override
  String get modelsStatusLabel => 'Status:';

  @override
  String get modelsDescriptionLabel => 'Description:';

  @override
  String get modelsContextWindow => 'Context Window:';

  @override
  String get modelsMaxOutputTokens => 'Max Output Tokens:';

  @override
  String get modelsCapabilities => 'Capabilities';

  @override
  String get modelsCapabilityChat => 'chat';

  @override
  String get modelsCapabilityVision => 'vision';

  @override
  String get modelsCapabilityFn => 'fn';

  @override
  String get modelsCapabilityJson => 'json';

  @override
  String get modelsCapabilityReason => 'reason';

  @override
  String modelsPricingLabel(double inputPrice, double outputPrice) {
    return 'Pricing (USD/M in,out): $inputPrice, $outputPrice';
  }

  @override
  String modelsCapabilitySummary(
    String chat,
    String vision,
    String functionCalling,
    String jsonMode,
    String streaming,
    String reasoning,
    String extendedThinking,
  ) {
    return 'chat=$chat, vision=$vision, functionCalling=$functionCalling, jsonMode=$jsonMode, streaming=$streaming, reasoning=$reasoning, extendedThinking=$extendedThinking';
  }

  @override
  String modelsParameterDetails(
    String name,
    String supported,
    String type,
    String min,
    String max,
    String defaultValue,
    String values,
  ) {
    return '$name: supported=$supported, type=$type, min=$min, max=$max, default=$defaultValue, values=$values';
  }

  @override
  String get modelsParameters => 'Parameters';

  @override
  String modelsHideRegistryModelConfirm(String modelId) {
    return 'Modell \"$modelId\" aus den Registry-Modellen ausblenden? Du kannst es spaeter unter Custom Models wiederherstellen, indem du den Override loeschst.';
  }

  @override
  String modelsHideRegistryModelDone(String modelId) {
    return 'Modell \"$modelId\" wurde ausgeblendet.';
  }

  @override
  String get modelsContextWindowField => 'context_window';

  @override
  String get modelsMaxOutputTokensField => 'max_output_tokens';

  @override
  String get modelsNoParameterDefinitions =>
      'Keine Parameter-Definitionen gefunden.';

  @override
  String get modelsRawJson => 'JSON';

  @override
  String get modelsContextWindowPositive =>
      'context_window muss eine positive Ganzzahl sein.';

  @override
  String get modelsMaxOutputTokensPositive =>
      'max_output_tokens muss eine positive Ganzzahl sein.';

  @override
  String modelsParameterMeta(String type, String min, String max) {
    return 'type=$type   min=$min   max=$max';
  }

  @override
  String get modelsDefaultLabel => 'default';

  @override
  String get modelsApiNameOptional => 'api_name (optional)';

  @override
  String modelsInvalidIntegerDefault(String key) {
    return 'Ungueltiger Integer-Default fuer Parameter \"$key\".';
  }

  @override
  String modelsInvalidFloatDefault(String key) {
    return 'Ungueltiger Float-Default fuer Parameter \"$key\".';
  }

  @override
  String get modelsEditOverride => 'Override bearbeiten:';

  @override
  String get modelsOverrideJsonLabel => 'overrideJson';

  @override
  String get modelsJsonMustBeObject => 'JSON muss ein Objekt sein.';

  @override
  String modelsInvalidJson(String error) {
    return 'Ungueltiges JSON: $error';
  }

  @override
  String get modelsCreateCustomTitle => 'Custom Model erstellen';

  @override
  String get modelsCreateCustomModelId => 'modelId';

  @override
  String get modelsCreateCustomProvider => 'provider';

  @override
  String get modelsModelIdRequired => 'modelId ist erforderlich.';

  @override
  String get modelsModelNotFound => 'Modell nicht gefunden.';

  @override
  String modelsDiscoveryNotReachable(String baseUrl) {
    return 'Nicht erreichbar unter $baseUrl';
  }

  @override
  String modelsDiscoveryNoModels(String baseUrl) {
    return 'Keine Modelle gefunden unter $baseUrl';
  }

  @override
  String modelsDiscoveryFailedAt(String baseUrl, String error) {
    return 'Discovery fehlgeschlagen unter $baseUrl: $error';
  }

  @override
  String get modelsCustomModelDescription =>
      'Custom Model aus dem Model Manager hinzugefuegt';

  @override
  String get modelsOverrideSaved => 'Override gespeichert.';

  @override
  String get modelsOverrideDeleted => 'Override geloescht.';

  @override
  String modelsDiscoveryFailed(String error) {
    return 'Discovery fehlgeschlagen: $error';
  }

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsSectionGeneral => 'Allgemein';

  @override
  String get settingsSectionSecurity => 'Sicherheit';

  @override
  String get settingsSectionPrivacy => 'Datenschutz';

  @override
  String get settingsSectionAdvanced => 'Erweitert';

  @override
  String get settingsSectionReset => 'Zuruecksetzen';

  @override
  String get settingsChangePassword => 'Passwort aendern';

  @override
  String get settingsChangePasswordDesc =>
      'Master-Passwort fuer die Verschluesselung';

  @override
  String get settingsManageProviders => 'API-Provider verwalten';

  @override
  String get settingsManageProvidersDesc =>
      'API-Keys hinzufuegen, bearbeiten oder loeschen';

  @override
  String get settingsStrictLocalMode => 'Strict Local Mode';

  @override
  String get settingsStrictLocalModeDesc =>
      'Nur lokale Provider (Ollama, LM Studio) erlauben. Cloud-Provider werden deaktiviert.';

  @override
  String get settingsCheckpointInterval => 'Checkpoint-Intervall';

  @override
  String settingsCheckpointIntervalDesc(int count) {
    return 'Alle $count API-Calls wird ein Checkpoint gespeichert';
  }

  @override
  String get settingsResetApp => 'App zuruecksetzen';

  @override
  String get settingsResetAppDesc =>
      'Alle Einstellungen, Provider und API-Keys loeschen. Projekte bleiben erhalten.';

  @override
  String get settingsPasswordChanged => 'Passwort erfolgreich geaendert';

  @override
  String get settingsMinPasswordLength => 'Mindestens 8 Zeichen';

  @override
  String get settingsPasswordMismatch => 'Passwoerter stimmen nicht ueberein';

  @override
  String get settingsWrongPassword => 'Aktuelles Passwort ist falsch';

  @override
  String get settingsDecryptKeysFailed =>
      'Vorhandene Schluessel konnten nicht entschluesselt werden. Passwort wurde nicht geaendert.';

  @override
  String get settingsReEncryptionFailed =>
      'Neuverschluesselung fehlgeschlagen. Passwort wurde nicht geaendert.';

  @override
  String get settingsProviderTitle => 'API-Provider';

  @override
  String get settingsProviderAdd => 'Provider hinzufuegen';

  @override
  String get settingsProviderAddTitle => 'API-Provider hinzufuegen';

  @override
  String settingsProviderEditTitle(String name) {
    return 'Provider bearbeiten: $name';
  }

  @override
  String get settingsProviderName => 'Name';

  @override
  String get settingsProviderType => 'Typ';

  @override
  String get settingsProviderBaseUrl => 'Base-URL';

  @override
  String get settingsProviderApiKey => 'API-Key';

  @override
  String get settingsProviderApiKeyLocalOptional =>
      'Optional fuer lokale Provider.';

  @override
  String get settingsProviderApiKeyKeepHint =>
      'Leer lassen, um den gespeicherten Key zu behalten.';

  @override
  String get settingsProviderApiKeyRequiredHint =>
      'Fuer Cloud-Provider erforderlich.';

  @override
  String get settingsProviderClearApiKey => 'Gespeicherten API-Key loeschen';

  @override
  String get settingsProviderEnabled => 'Aktiviert';

  @override
  String get settingsProviderKeyStored => 'API-Key gespeichert';

  @override
  String get settingsProviderKeyMissing => 'Kein API-Key';

  @override
  String get settingsProviderNameRequired =>
      'Bitte einen Providernamen eingeben.';

  @override
  String get settingsProviderBaseUrlRequired => 'Bitte eine Base-URL eingeben.';

  @override
  String get settingsProviderApiKeyRequired =>
      'Bitte einen API-Key fuer diesen Providertyp eingeben.';

  @override
  String get settingsProviderEncryptionLocked =>
      'API-Key kann nicht gespeichert werden, solange die App gesperrt ist.';

  @override
  String get settingsProviderAdded => 'Provider hinzugefuegt.';

  @override
  String get settingsProviderUpdated => 'Provider aktualisiert.';

  @override
  String settingsProviderSaveError(String error) {
    return 'Provider konnte nicht gespeichert werden: $error';
  }

  @override
  String get settingsNoProviders => 'Keine Provider konfiguriert';

  @override
  String get settingsDeleteProvider => 'Provider loeschen?';

  @override
  String settingsDeleteProviderDesc(String name) {
    return 'Provider \"$name\" und den gespeicherten API-Key loeschen?';
  }

  @override
  String get settingsResetTitle => 'App zuruecksetzen?';

  @override
  String get settingsResetDesc =>
      'Alle Einstellungen, Provider und API-Keys werden geloescht. Projekt-Ordner auf der Festplatte bleiben erhalten.\n\nDiese Aktion kann nicht rueckgaengig gemacht werden.';

  @override
  String get costTitle => 'Kosten-Vorschau';

  @override
  String get costInputTokens => 'Input-Tokens:';

  @override
  String get costOutputTokens => 'Output-Tokens:';

  @override
  String get costApiCalls => 'API-Calls:';

  @override
  String get costTotal => 'Gesamt:';

  @override
  String get costDisclaimer =>
      'Schaetzung basierend auf modellnahem GPT-4o/o1-Tokenizer.';

  @override
  String get privacyTitle => 'Datenschutz-Hinweis';

  @override
  String privacyMessage(String provider, String region) {
    return 'Sie senden Daten an $provider ($region). DSGVO und interne Richtlinien beachten.';
  }

  @override
  String get privacyDontShowAgain => 'Nicht mehr anzeigen';

  @override
  String get privacyUnderstood => 'Verstanden';

  @override
  String get resumeTitle => 'Checkpoint gefunden';

  @override
  String get resumeSaved => 'Gespeichert:';

  @override
  String get resumeProgress => 'Fortschritt:';

  @override
  String get resumeCalls => 'Calls:';

  @override
  String get resumeTokens => 'Tokens:';

  @override
  String get resumeRestart => 'Neu starten';

  @override
  String get resumeContinue => 'Fortsetzen';

  @override
  String get logLevelAll => 'Alle';

  @override
  String get logLevelLabel => 'Level:';

  @override
  String get logLevelInfo => 'INFO';

  @override
  String get logLevelWarn => 'WARN';

  @override
  String get logLevelError => 'ERROR';

  @override
  String get noSourceSelected => 'Keine Quelle gewaehlt';

  @override
  String errorGeneric(String error) {
    return 'Fehler: $error';
  }
}
