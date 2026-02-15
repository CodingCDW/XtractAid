/// Masks known API key patterns in text to prevent accidental leakage in logs.
String maskSecrets(String text) {
  // OpenAI keys: sk-... (48+ chars)
  // Anthropic keys: sk-ant-... (40+ chars)
  // Google keys: AIza... (39 chars)
  return text
      .replaceAll(
        RegExp(r'sk-ant-[A-Za-z0-9_-]{20,}'),
        '[REDACTED:anthropic-key]',
      )
      .replaceAll(
        RegExp(r'sk-[A-Za-z0-9_-]{20,}'),
        '[REDACTED:openai-key]',
      )
      .replaceAll(
        RegExp(r'AIza[A-Za-z0-9_-]{30,}'),
        '[REDACTED:google-key]',
      );
}
