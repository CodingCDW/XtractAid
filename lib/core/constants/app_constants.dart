/// Application-wide constants.
abstract final class AppConstants {
  static const String appName = 'XtractAid';
  static const String appVersion = '0.1.0';

  // Encryption
  static const int pbkdf2Iterations = 100000;
  static const int saltLength = 32;
  static const int ivLength = 12;
  static const int keyLength = 32; // AES-256

  // Checkpoint
  static const int defaultCheckpointInterval = 10; // API calls
  static const int checkpointRetentionDays = 7;

  // Registry
  static const String remoteRegistryUrl =
      'https://raw.githubusercontent.com/xtractaid/model-registry/main/registry.json';
  static const List<String> remoteRegistryUrls = [remoteRegistryUrl];
  static const Duration registryCacheDuration = Duration(days: 7);

  // Project structure
  static const String projectFileName = 'project.xtractaid.json';
  static const List<String> projectSubdirs = [
    'prompts',
    'input',
    'batches',
    'results',
  ];

  // Item injection placeholder
  static const String itemPlaceholder = '[Insert IDs and Items here]';

  // System prompt for LLM API calls (PRD 1.4)
  static const String systemPrompt =
      'You are an intelligent assistant that extracts structured data from text. '
      'Always respond with valid JSON. Follow the user instructions precisely '
      'and return only the requested fields.';

  // Batch limits
  static const int maxChunkSize = 100;
  static const int maxRepetitions = 100;
  static const int maxRetries = 5;
  static const Duration rateLimitDelay = Duration(seconds: 30);
  static const Duration maxBatchDuration = Duration(hours: 24);

  // Document pipeline
  static const bool enableOcrFallback = false;

  // UI
  static const int recentProjectsLimit = 10;
}
