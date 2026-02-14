// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'provider_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ProviderConfig _$ProviderConfigFromJson(Map<String, dynamic> json) {
  return _ProviderConfig.fromJson(json);
}

/// @nodoc
mixin _$ProviderConfig {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get type =>
      throw _privateConstructorUsedError; // openai, anthropic, google, openrouter, ollama, lmstudio
  String get baseUrl => throw _privateConstructorUsedError;
  String get authType => throw _privateConstructorUsedError;
  String? get modelsEndpoint => throw _privateConstructorUsedError;
  bool get isLocal => throw _privateConstructorUsedError;
  bool get isEnabled => throw _privateConstructorUsedError;

  /// Serializes this ProviderConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProviderConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProviderConfigCopyWith<ProviderConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProviderConfigCopyWith<$Res> {
  factory $ProviderConfigCopyWith(
    ProviderConfig value,
    $Res Function(ProviderConfig) then,
  ) = _$ProviderConfigCopyWithImpl<$Res, ProviderConfig>;
  @useResult
  $Res call({
    String id,
    String name,
    String type,
    String baseUrl,
    String authType,
    String? modelsEndpoint,
    bool isLocal,
    bool isEnabled,
  });
}

/// @nodoc
class _$ProviderConfigCopyWithImpl<$Res, $Val extends ProviderConfig>
    implements $ProviderConfigCopyWith<$Res> {
  _$ProviderConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProviderConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? baseUrl = null,
    Object? authType = null,
    Object? modelsEndpoint = freezed,
    Object? isLocal = null,
    Object? isEnabled = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            baseUrl: null == baseUrl
                ? _value.baseUrl
                : baseUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            authType: null == authType
                ? _value.authType
                : authType // ignore: cast_nullable_to_non_nullable
                      as String,
            modelsEndpoint: freezed == modelsEndpoint
                ? _value.modelsEndpoint
                : modelsEndpoint // ignore: cast_nullable_to_non_nullable
                      as String?,
            isLocal: null == isLocal
                ? _value.isLocal
                : isLocal // ignore: cast_nullable_to_non_nullable
                      as bool,
            isEnabled: null == isEnabled
                ? _value.isEnabled
                : isEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProviderConfigImplCopyWith<$Res>
    implements $ProviderConfigCopyWith<$Res> {
  factory _$$ProviderConfigImplCopyWith(
    _$ProviderConfigImpl value,
    $Res Function(_$ProviderConfigImpl) then,
  ) = __$$ProviderConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String type,
    String baseUrl,
    String authType,
    String? modelsEndpoint,
    bool isLocal,
    bool isEnabled,
  });
}

/// @nodoc
class __$$ProviderConfigImplCopyWithImpl<$Res>
    extends _$ProviderConfigCopyWithImpl<$Res, _$ProviderConfigImpl>
    implements _$$ProviderConfigImplCopyWith<$Res> {
  __$$ProviderConfigImplCopyWithImpl(
    _$ProviderConfigImpl _value,
    $Res Function(_$ProviderConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProviderConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? baseUrl = null,
    Object? authType = null,
    Object? modelsEndpoint = freezed,
    Object? isLocal = null,
    Object? isEnabled = null,
  }) {
    return _then(
      _$ProviderConfigImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        baseUrl: null == baseUrl
            ? _value.baseUrl
            : baseUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        authType: null == authType
            ? _value.authType
            : authType // ignore: cast_nullable_to_non_nullable
                  as String,
        modelsEndpoint: freezed == modelsEndpoint
            ? _value.modelsEndpoint
            : modelsEndpoint // ignore: cast_nullable_to_non_nullable
                  as String?,
        isLocal: null == isLocal
            ? _value.isLocal
            : isLocal // ignore: cast_nullable_to_non_nullable
                  as bool,
        isEnabled: null == isEnabled
            ? _value.isEnabled
            : isEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProviderConfigImpl implements _ProviderConfig {
  const _$ProviderConfigImpl({
    required this.id,
    required this.name,
    required this.type,
    required this.baseUrl,
    this.authType = 'bearer',
    this.modelsEndpoint,
    this.isLocal = false,
    this.isEnabled = true,
  });

  factory _$ProviderConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProviderConfigImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String type;
  // openai, anthropic, google, openrouter, ollama, lmstudio
  @override
  final String baseUrl;
  @override
  @JsonKey()
  final String authType;
  @override
  final String? modelsEndpoint;
  @override
  @JsonKey()
  final bool isLocal;
  @override
  @JsonKey()
  final bool isEnabled;

  @override
  String toString() {
    return 'ProviderConfig(id: $id, name: $name, type: $type, baseUrl: $baseUrl, authType: $authType, modelsEndpoint: $modelsEndpoint, isLocal: $isLocal, isEnabled: $isEnabled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProviderConfigImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.baseUrl, baseUrl) || other.baseUrl == baseUrl) &&
            (identical(other.authType, authType) ||
                other.authType == authType) &&
            (identical(other.modelsEndpoint, modelsEndpoint) ||
                other.modelsEndpoint == modelsEndpoint) &&
            (identical(other.isLocal, isLocal) || other.isLocal == isLocal) &&
            (identical(other.isEnabled, isEnabled) ||
                other.isEnabled == isEnabled));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    type,
    baseUrl,
    authType,
    modelsEndpoint,
    isLocal,
    isEnabled,
  );

  /// Create a copy of ProviderConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProviderConfigImplCopyWith<_$ProviderConfigImpl> get copyWith =>
      __$$ProviderConfigImplCopyWithImpl<_$ProviderConfigImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProviderConfigImplToJson(this);
  }
}

abstract class _ProviderConfig implements ProviderConfig {
  const factory _ProviderConfig({
    required final String id,
    required final String name,
    required final String type,
    required final String baseUrl,
    final String authType,
    final String? modelsEndpoint,
    final bool isLocal,
    final bool isEnabled,
  }) = _$ProviderConfigImpl;

  factory _ProviderConfig.fromJson(Map<String, dynamic> json) =
      _$ProviderConfigImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get type; // openai, anthropic, google, openrouter, ollama, lmstudio
  @override
  String get baseUrl;
  @override
  String get authType;
  @override
  String? get modelsEndpoint;
  @override
  bool get isLocal;
  @override
  bool get isEnabled;

  /// Create a copy of ProviderConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProviderConfigImplCopyWith<_$ProviderConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
