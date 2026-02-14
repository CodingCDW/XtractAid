// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'XtractAid';

  @override
  String get navProjects => 'Projects';

  @override
  String get navModels => 'Models';

  @override
  String get navSettings => 'Settings';

  @override
  String get actionBack => 'Back';

  @override
  String get actionNext => 'Next';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionClose => 'Close';

  @override
  String get actionSave => 'Save';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionOpen => 'Open';

  @override
  String get actionCreate => 'Create';

  @override
  String get actionChange => 'Change';

  @override
  String get actionDone => 'Done';

  @override
  String get actionStart => 'Start';

  @override
  String get actionPause => 'Pause';

  @override
  String get actionResume => 'Resume';

  @override
  String get actionStop => 'Stop';

  @override
  String get actionChooseFolder => 'Choose Folder';

  @override
  String get actionChooseFile => 'Choose File';

  @override
  String get actionLoad => 'Load';

  @override
  String get actionSelect => 'Select';

  @override
  String get actionUnlock => 'Unlock';

  @override
  String get actionReset => 'Reset';

  @override
  String get actionTestConnection => 'Test Connection';

  @override
  String get labelLanguage => 'Language';

  @override
  String get labelGerman => 'Deutsch';

  @override
  String get labelEnglish => 'English';

  @override
  String get labelPassword => 'Password';

  @override
  String get labelConfirmPassword => 'Confirm Password';

  @override
  String get labelCurrentPassword => 'Current Password';

  @override
  String get labelNewPassword => 'New Password';

  @override
  String get labelConfirmNewPassword => 'Confirm New Password';

  @override
  String get labelMasterPassword => 'Master Password';

  @override
  String get labelApiKey => 'API Key';

  @override
  String get labelProvider => 'Provider';

  @override
  String get labelModel => 'Model';

  @override
  String get labelProjectName => 'Project Name';

  @override
  String get labelStatus => 'Status:';

  @override
  String get labelLocal => 'local';

  @override
  String get labelCloud => 'cloud';

  @override
  String get setupTitle => 'Initial Setup';

  @override
  String get setupStepWelcome => 'Welcome';

  @override
  String get setupStepPassword => 'Master Password';

  @override
  String get setupStepProvider => 'Choose Provider';

  @override
  String get setupStepApiKey => 'API Key & Test';

  @override
  String get setupStepBasicSettings => 'Basic Settings';

  @override
  String get setupStepFinish => 'Done';

  @override
  String get setupStartApp => 'Start XtractAid';

  @override
  String get setupDescription =>
      'XtractAid analyzes text data from files in batches using LLM models and produces structured results.';

  @override
  String get setupGermanLabel => 'Deutsch (DE)';

  @override
  String get setupEnglishLabel => 'English (EN)';

  @override
  String get setupProviderHint =>
      'Cloud providers require an API key. Local providers (Ollama, LM Studio) run on your machine.';

  @override
  String get setupLocalApiKeyHint =>
      'Local provider: No API key required. Please test the connection only.';

  @override
  String get setupConnectionSuccess => 'Connection successful.';

  @override
  String get setupConnectionFailed => 'Connection failed.';

  @override
  String get setupStrictLocalMode => 'Strict Local Mode';

  @override
  String get setupStrictLocalModeDesc =>
      'Only allow local providers (Ollama, LM Studio).';

  @override
  String get setupSettingsChangeLater =>
      'These settings can be changed later in Settings.';

  @override
  String get setupSummaryTitle => 'Setup Summary';

  @override
  String get setupSummaryConnection => 'Connection';

  @override
  String get setupSummaryPasswordSet => 'Set';

  @override
  String get setupSummaryPasswordNotSet => 'Not set';

  @override
  String get setupSummaryConnectionOk => 'OK';

  @override
  String get setupSummaryConnectionFail => 'Not tested/failed';

  @override
  String get setupNoProviderData => 'No provider data found.';

  @override
  String get setupProviderLoadError => 'Could not load providers.';

  @override
  String get setupSelectProvider => 'Please select a provider.';

  @override
  String get setupLanguageSaveError => 'Could not save language.';

  @override
  String get setupMinPasswordLength => 'At least 8 characters required.';

  @override
  String get setupPasswordMismatch => 'Passwords do not match.';

  @override
  String get setupPasswordSaveError => 'Could not save password.';

  @override
  String get setupNoProviderSelected => 'No provider selected.';

  @override
  String get setupEnterApiKey => 'Please enter an API key.';

  @override
  String get setupTestConnectionFirst => 'Please test the connection first.';

  @override
  String get setupProviderSaveError => 'Could not save provider.';

  @override
  String get setupSettingsSaveError => 'Could not save basic settings.';

  @override
  String get setupCompleteError => 'Could not complete setup.';

  @override
  String get passwordStrength => 'Password Strength';

  @override
  String get passwordWeak => 'Weak (under 8 characters)';

  @override
  String get passwordMedium => 'Medium (at least 8 characters)';

  @override
  String get passwordStrong => 'Strong (12+ characters)';

  @override
  String get authEnterPassword => 'Please enter your password.';

  @override
  String get authSetupIncomplete => 'Setup incomplete. Please set up again.';

  @override
  String get authWrongPassword => 'Wrong password';

  @override
  String get authUnlockFailed => 'Unlock failed.';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authResetWarning => 'All API keys will be deleted. Continue?';

  @override
  String get authResetFailed => 'Reset failed.';

  @override
  String get projectsTitle => 'Projects';

  @override
  String get projectsNew => 'New Project';

  @override
  String get projectsOpen => 'Open Project';

  @override
  String get projectsEmpty => 'Create your first project';

  @override
  String get projectsCreateError => 'Could not create project.';

  @override
  String get projectsInvalidProject => 'Not a valid XtractAid project';

  @override
  String get projectsOpenError => 'Could not open project.';

  @override
  String get projectsNotFound => 'Project not found.';

  @override
  String get projectsLastOpened => 'Last opened:';

  @override
  String get projectsNever => 'Never';

  @override
  String get projectCreateTitle => 'Create New Project';

  @override
  String get projectCreateNameHint => 'Please enter a project name.';

  @override
  String get projectCreateFolderHint => 'Please choose a target folder.';

  @override
  String get projectNoFolderSelected => 'No folder selected';

  @override
  String get projectOpenTitle => 'Open Project';

  @override
  String get projectOpenFolderHint => 'Please choose a project folder.';

  @override
  String get projectDetailNewBatch => 'New Batch';

  @override
  String get projectDetailBatches => 'Batches';

  @override
  String get projectDetailPrompts => 'Prompts';

  @override
  String get projectDetailInput => 'Input';

  @override
  String get projectDetailNoBatches => 'No batches yet.';

  @override
  String get batchWizardItemsTitle => 'Load Items';

  @override
  String get batchWizardPromptsTitle => 'Choose Prompts';

  @override
  String get batchWizardChunksTitle => 'Chunks';

  @override
  String get batchWizardModelTitle => 'Configure Model';

  @override
  String get batchWizardConfirmTitle => 'Confirm & Start';

  @override
  String get batchWizardStartBatch => 'Start Batch';

  @override
  String get batchWizardSelectSource => 'Please select an input source first.';

  @override
  String get batchWizardLoadItems => 'Please load items before continuing.';

  @override
  String get batchWizardSelectPrompt => 'Please select at least one prompt.';

  @override
  String get batchWizardSelectModel => 'Please select a model.';

  @override
  String get batchWizardConfirmPrivacy =>
      'Please confirm the privacy agreement.';

  @override
  String get batchWizardStartError => 'Cannot start batch.';

  @override
  String get batchWizardSaveError => 'Could not save batch.';

  @override
  String get batchWizardNotLoaded => 'Batch Wizard could not be loaded.';

  @override
  String get batchWizardProjectNotLoaded => 'Project not loaded.';

  @override
  String get itemsExcelCsv => 'Excel/CSV';

  @override
  String get itemsDocFolder => 'Documents Folder';

  @override
  String get itemsFileSource => 'File source';

  @override
  String get itemsFolderSource => 'Folder source';

  @override
  String get itemsSummary => 'Summary:';

  @override
  String itemsCount(int count, int warnings) {
    return '$count items, $warnings warnings';
  }

  @override
  String get itemsIdColumn => 'ID Column';

  @override
  String get itemsItemColumn => 'Item Column';

  @override
  String get itemsPreviewText => 'Text (Preview)';

  @override
  String get chunksChunkSize => 'Chunk Size:';

  @override
  String get chunksRepetitions => 'Repetitions:';

  @override
  String chunksCalcChunks(int items, int chunkSize, int chunks) {
    return '$items Items / $chunkSize = $chunks Chunks';
  }

  @override
  String chunksCalcCalls(int chunks, int prompts, int reps, int calls) {
    return '$chunks Chunks x $prompts Prompts x $reps Reps = $calls API Calls';
  }

  @override
  String get chunksTooltip =>
      'With chunk_size > 1, multiple items are sent together in one prompt. This saves API calls but may reduce quality.';

  @override
  String get confirmItems => 'Items:';

  @override
  String get confirmSource => 'Source:';

  @override
  String get confirmPrompts => 'Prompts:';

  @override
  String get confirmChunkSize => 'Chunk Size:';

  @override
  String get confirmRepetitions => 'Repetitions:';

  @override
  String get confirmTotalCalls => 'Total API Calls:';

  @override
  String get confirmModel => 'Model:';

  @override
  String get confirmPrivacyCheckbox =>
      'I confirm that sending this data to the cloud provider is compatible with my data privacy requirements.';

  @override
  String get promptPreview => 'Prompt Preview';

  @override
  String get modelContext => 'Context:';

  @override
  String get modelPriceLabel => 'Price (Input/Output per 1M):';

  @override
  String get execTitle => 'Execution';

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
  String get execLoadingConfig => 'Loading batch configuration...';

  @override
  String get execBatchNotFound => 'Batch not found.';

  @override
  String get execProjectNotFound => 'Project not found.';

  @override
  String get execInvalidConfig => 'Invalid batch configuration.';

  @override
  String get execNoItems => 'No items found for execution.';

  @override
  String get execLoadingPrompts => 'Loading prompts...';

  @override
  String get execNoPrompts => 'No prompt files found from batch configuration.';

  @override
  String execStartFailed(String error) {
    return 'Start failed: $error';
  }

  @override
  String get execBatchStarted => 'Batch started.';

  @override
  String execReportsCreated(String paths) {
    return 'Reports created: $paths';
  }

  @override
  String execReportsFailed(String error) {
    return 'Report generation failed: $error';
  }

  @override
  String get modelsTitle => 'Models';

  @override
  String get modelsRegistry => 'Registry Models';

  @override
  String get modelsCustom => 'Custom Models';

  @override
  String get modelsDiscovered => 'Discovered Models';

  @override
  String modelsRegistryError(String error) {
    return 'Registry error: $error';
  }

  @override
  String get modelsNoRegistry => 'No registry models found.';

  @override
  String modelsCountLabel(int count) {
    return '$count models';
  }

  @override
  String get modelsNoCustom => 'No custom model overrides.';

  @override
  String get modelsQueryProviders => 'Query Providers';

  @override
  String get modelsNoDiscovery => 'No discovery data yet.';

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
  String get modelsParameters => 'Parameters';

  @override
  String get modelsEditOverride => 'Edit override:';

  @override
  String get modelsOverrideSaved => 'Override saved.';

  @override
  String get modelsOverrideDeleted => 'Override deleted.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionGeneral => 'General';

  @override
  String get settingsSectionSecurity => 'Security';

  @override
  String get settingsSectionPrivacy => 'Privacy';

  @override
  String get settingsSectionAdvanced => 'Advanced';

  @override
  String get settingsSectionReset => 'Reset';

  @override
  String get settingsChangePassword => 'Change Password';

  @override
  String get settingsChangePasswordDesc => 'Master password for encryption';

  @override
  String get settingsManageProviders => 'Manage API Providers';

  @override
  String get settingsManageProvidersDesc => 'Add, edit, or delete API keys';

  @override
  String get settingsStrictLocalMode => 'Strict Local Mode';

  @override
  String get settingsStrictLocalModeDesc =>
      'Only allow local providers (Ollama, LM Studio). Cloud providers are disabled.';

  @override
  String get settingsCheckpointInterval => 'Checkpoint Interval';

  @override
  String settingsCheckpointIntervalDesc(int count) {
    return 'A checkpoint is saved every $count API calls';
  }

  @override
  String get settingsResetApp => 'Reset App';

  @override
  String get settingsResetAppDesc =>
      'Delete all settings, providers, and API keys. Projects are preserved.';

  @override
  String get settingsPasswordChanged => 'Password changed successfully';

  @override
  String get settingsMinPasswordLength => 'At least 8 characters';

  @override
  String get settingsPasswordMismatch => 'Passwords do not match';

  @override
  String get settingsWrongPassword => 'Current password is incorrect';

  @override
  String get settingsProviderTitle => 'API Providers';

  @override
  String get settingsNoProviders => 'No providers configured';

  @override
  String get settingsDeleteProvider => 'Delete provider?';

  @override
  String settingsDeleteProviderDesc(String name) {
    return 'Delete provider \"$name\" and its stored API key?';
  }

  @override
  String get settingsResetTitle => 'Reset App?';

  @override
  String get settingsResetDesc =>
      'All settings, providers, and API keys will be deleted. Project folders on disk will be preserved.\n\nThis action cannot be undone.';

  @override
  String get costTitle => 'Cost Preview';

  @override
  String get costInputTokens => 'Input Tokens:';

  @override
  String get costOutputTokens => 'Output Tokens:';

  @override
  String get costApiCalls => 'API Calls:';

  @override
  String get costTotal => 'Total:';

  @override
  String get costDisclaimer => 'Estimate based on GPT-4o/o1 tokenizer.';

  @override
  String get privacyTitle => 'Privacy Notice';

  @override
  String privacyMessage(String provider, String region) {
    return 'You are sending data to $provider ($region). Please consider GDPR and internal policies.';
  }

  @override
  String get privacyDontShowAgain => 'Don\'t show again';

  @override
  String get privacyUnderstood => 'Understood';

  @override
  String get resumeTitle => 'Checkpoint Found';

  @override
  String get resumeSaved => 'Saved:';

  @override
  String get resumeProgress => 'Progress:';

  @override
  String get resumeCalls => 'Calls:';

  @override
  String get resumeTokens => 'Tokens:';

  @override
  String get resumeRestart => 'Restart';

  @override
  String get resumeContinue => 'Continue';

  @override
  String get logLevelAll => 'All';

  @override
  String get logLevelLabel => 'Level:';

  @override
  String get noSourceSelected => 'No source selected';

  @override
  String errorGeneric(String error) {
    return 'Error: $error';
  }
}
