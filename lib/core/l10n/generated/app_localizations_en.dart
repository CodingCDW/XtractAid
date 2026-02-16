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
  String get actionContinue => 'Continue';

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
  String get labelUnknown => 'Unknown';

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
  String projectsDeleteConfirm(String name, String path) {
    return 'Delete project \"$name\"?\n\nPath: $path\n\nYou can remove only the list entry, or delete the full project including folder and all batch data.';
  }

  @override
  String get projectsDeleteListOnly => 'Remove from list only';

  @override
  String get projectsDeleteProject => 'Delete project';

  @override
  String projectsDeleteSuccessFull(String name) {
    return 'Project \"$name\" was deleted completely.';
  }

  @override
  String projectsDeleteSuccessList(String name) {
    return 'Project \"$name\" was removed from the list.';
  }

  @override
  String projectsDeleteFailed(String error) {
    return 'Could not delete project: $error';
  }

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
  String get projectDetailNoPromptFiles => 'No prompt files found.';

  @override
  String get projectDetailNoInputFiles => 'No input files found.';

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
  String batchWizardTitle(String projectName) {
    return 'Batch Wizard - $projectName';
  }

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
  String get batchWizardSaveChangesTitle => 'Save batch changes';

  @override
  String get batchWizardSaveChangesMessage =>
      'This batch is already completed or failed. Do you want to update it or save as a new batch?';

  @override
  String get batchWizardUpdateExisting => 'Update existing';

  @override
  String get batchWizardSaveAsNew => 'Save as new';

  @override
  String get batchWizardRunningNotEditable =>
      'Running batches cannot be edited.';

  @override
  String batchWizardGeneratedName(String timestamp) {
    return 'Batch $timestamp';
  }

  @override
  String batchWizardInactiveModelWarning(String status) {
    return 'Selected model status is \"$status\". Consider selecting an active model for new runs.';
  }

  @override
  String get batchWizardItemsFallbackWarning =>
      'Items could not be loaded from input source. Using stored item count.';

  @override
  String get batchDeleteTitle => 'Delete batch?';

  @override
  String batchDeleteDesc(String name) {
    return 'Delete batch \"$name\"? This cannot be undone.';
  }

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
  String get itemsIdLabel => 'ID';

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
  String get promptSelectorAvailable => 'Available';

  @override
  String get promptSelectorSelected => 'Selected';

  @override
  String get promptImport => 'Import';

  @override
  String get promptImportTooltip => 'Import prompt files from disk';

  @override
  String promptImportSuccess(int count) {
    return '$count prompt(s) imported.';
  }

  @override
  String promptImportSkipped(String names) {
    return 'Skipped (already exists): $names';
  }

  @override
  String get modelContext => 'Context:';

  @override
  String get modelPriceLabel => 'Price (Input/Output per 1M):';

  @override
  String get execTitle => 'Execution';

  @override
  String get execBatchTitle => 'Batch Execution';

  @override
  String execBatchNameTitle(String name) {
    return 'Batch: $name';
  }

  @override
  String get execBatchId => 'Batch ID:';

  @override
  String get execCurrentPromptName => 'Current Prompt Name:';

  @override
  String get execCurrentModel => 'Current Model:';

  @override
  String get execPreparingInput =>
      'Configuration loaded. Preparing input data...';

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
  String get execStatusIdle => 'IDLE';

  @override
  String get execStatusStarting => 'STARTING';

  @override
  String get execStatusRunning => 'RUNNING';

  @override
  String get execStatusPaused => 'PAUSED';

  @override
  String get execStatusCompleted => 'COMPLETED';

  @override
  String get execStatusFailed => 'FAILED';

  @override
  String execProgressCalls(String percent, int completed, int total) {
    return '$percent%  |  $completed/$total Calls';
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
  String get modelsShowInactive => 'Show inactive/deprecated models';

  @override
  String modelsRegistryTileSubtitle(
    String id,
    int contextWindow,
    double inputPrice,
    double outputPrice,
  ) {
    return 'ID: $id | Context: $contextWindow | USD/M in/out: $inputPrice/$outputPrice';
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
    return 'Hide model \"$modelId\" from registry models? You can restore it later in Custom Models by deleting the override.';
  }

  @override
  String modelsHideRegistryModelDone(String modelId) {
    return 'Model \"$modelId\" was hidden.';
  }

  @override
  String get modelsContextWindowField => 'context_window';

  @override
  String get modelsMaxOutputTokensField => 'max_output_tokens';

  @override
  String get modelsNoParameterDefinitions => 'No parameter definitions found.';

  @override
  String get modelsRawJson => 'JSON';

  @override
  String get modelsContextWindowPositive =>
      'context_window must be a positive integer.';

  @override
  String get modelsMaxOutputTokensPositive =>
      'max_output_tokens must be a positive integer.';

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
    return 'Invalid integer default for parameter \"$key\".';
  }

  @override
  String modelsInvalidFloatDefault(String key) {
    return 'Invalid float default for parameter \"$key\".';
  }

  @override
  String get modelsEditOverride => 'Edit override:';

  @override
  String get modelsOverrideJsonLabel => 'overrideJson';

  @override
  String get modelsJsonMustBeObject => 'JSON must be an object.';

  @override
  String modelsInvalidJson(String error) {
    return 'Invalid JSON: $error';
  }

  @override
  String get modelsCreateCustomTitle => 'Create Custom Model';

  @override
  String get modelsCreateCustomModelId => 'modelId';

  @override
  String get modelsCreateCustomProvider => 'provider';

  @override
  String get modelsModelIdRequired => 'modelId is required.';

  @override
  String get modelsModelNotFound => 'Model not found.';

  @override
  String modelsDiscoveryNotReachable(String baseUrl) {
    return 'Not reachable at $baseUrl';
  }

  @override
  String modelsDiscoveryNoModels(String baseUrl) {
    return 'No models found at $baseUrl';
  }

  @override
  String modelsDiscoveryFailedAt(String baseUrl, String error) {
    return 'Discovery failed at $baseUrl: $error';
  }

  @override
  String get modelsCustomModelDescription =>
      'Custom model added from Model Manager';

  @override
  String get modelsOverrideSaved => 'Override saved.';

  @override
  String get modelsOverrideDeleted => 'Override deleted.';

  @override
  String modelsDiscoveryFailed(String error) {
    return 'Discovery failed: $error';
  }

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
  String get settingsDecryptKeysFailed =>
      'Failed to decrypt existing keys. Password not changed.';

  @override
  String get settingsReEncryptionFailed =>
      'Re-encryption failed. Password not changed.';

  @override
  String get settingsProviderTitle => 'API Providers';

  @override
  String get settingsProviderAdd => 'Add provider';

  @override
  String get settingsProviderAddTitle => 'Add API provider';

  @override
  String settingsProviderEditTitle(String name) {
    return 'Edit provider: $name';
  }

  @override
  String get settingsProviderName => 'Name';

  @override
  String get settingsProviderType => 'Type';

  @override
  String get settingsProviderBaseUrl => 'Base URL';

  @override
  String get settingsProviderApiKey => 'API Key';

  @override
  String get settingsProviderApiKeyLocalOptional =>
      'Optional for local providers.';

  @override
  String get settingsProviderApiKeyKeepHint =>
      'Leave empty to keep stored key.';

  @override
  String get settingsProviderApiKeyRequiredHint =>
      'Required for cloud providers.';

  @override
  String get settingsProviderClearApiKey => 'Delete stored API key';

  @override
  String get settingsProviderEnabled => 'Enabled';

  @override
  String get settingsProviderKeyStored => 'API key stored';

  @override
  String get settingsProviderKeyMissing => 'No API key';

  @override
  String get settingsProviderNameRequired => 'Please enter a provider name.';

  @override
  String get settingsProviderBaseUrlRequired => 'Please enter a base URL.';

  @override
  String get settingsProviderApiKeyRequired =>
      'Please enter an API key for this provider type.';

  @override
  String get settingsProviderEncryptionLocked =>
      'Cannot save API key while app is locked.';

  @override
  String get settingsProviderAdded => 'Provider added.';

  @override
  String get settingsProviderUpdated => 'Provider updated.';

  @override
  String settingsProviderSaveError(String error) {
    return 'Could not save provider: $error';
  }

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
  String get logLevelInfo => 'INFO';

  @override
  String get logLevelWarn => 'WARN';

  @override
  String get logLevelError => 'ERROR';

  @override
  String get noSourceSelected => 'No source selected';

  @override
  String errorGeneric(String error) {
    return 'Error: $error';
  }
}
