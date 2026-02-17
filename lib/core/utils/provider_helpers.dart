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
