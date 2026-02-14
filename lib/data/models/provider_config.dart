import 'package:freezed_annotation/freezed_annotation.dart';

part 'provider_config.freezed.dart';
part 'provider_config.g.dart';

@freezed
class ProviderConfig with _$ProviderConfig {
  const factory ProviderConfig({
    required String id,
    required String name,
    required String type, // openai, anthropic, google, openrouter, ollama, lmstudio
    required String baseUrl,
    @Default('bearer') String authType,
    String? modelsEndpoint,
    @Default(false) bool isLocal,
    @Default(true) bool isEnabled,
  }) = _ProviderConfig;

  factory ProviderConfig.fromJson(Map<String, dynamic> json) =>
      _$ProviderConfigFromJson(json);
}
