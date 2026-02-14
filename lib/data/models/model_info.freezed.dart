// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'model_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ModelInfo _$ModelInfoFromJson(Map<String, dynamic> json) {
  return _ModelInfo.fromJson(json);
}

/// @nodoc
mixin _$ModelInfo {
  String get id => throw _privateConstructorUsedError;
  String get provider => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  int get contextWindow => throw _privateConstructorUsedError;
  int get maxOutputTokens => throw _privateConstructorUsedError;
  ModelPricing get pricing => throw _privateConstructorUsedError;
  ModelCapabilities get capabilities => throw _privateConstructorUsedError;
  Map<String, ModelParameter> get parameters =>
      throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;

  /// Serializes this ModelInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ModelInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ModelInfoCopyWith<ModelInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ModelInfoCopyWith<$Res> {
  factory $ModelInfoCopyWith(ModelInfo value, $Res Function(ModelInfo) then) =
      _$ModelInfoCopyWithImpl<$Res, ModelInfo>;
  @useResult
  $Res call({
    String id,
    String provider,
    String displayName,
    String description,
    int contextWindow,
    int maxOutputTokens,
    ModelPricing pricing,
    ModelCapabilities capabilities,
    Map<String, ModelParameter> parameters,
    String? notes,
    String status,
  });

  $ModelPricingCopyWith<$Res> get pricing;
  $ModelCapabilitiesCopyWith<$Res> get capabilities;
}

/// @nodoc
class _$ModelInfoCopyWithImpl<$Res, $Val extends ModelInfo>
    implements $ModelInfoCopyWith<$Res> {
  _$ModelInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ModelInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? provider = null,
    Object? displayName = null,
    Object? description = null,
    Object? contextWindow = null,
    Object? maxOutputTokens = null,
    Object? pricing = null,
    Object? capabilities = null,
    Object? parameters = null,
    Object? notes = freezed,
    Object? status = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            provider: null == provider
                ? _value.provider
                : provider // ignore: cast_nullable_to_non_nullable
                      as String,
            displayName: null == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            contextWindow: null == contextWindow
                ? _value.contextWindow
                : contextWindow // ignore: cast_nullable_to_non_nullable
                      as int,
            maxOutputTokens: null == maxOutputTokens
                ? _value.maxOutputTokens
                : maxOutputTokens // ignore: cast_nullable_to_non_nullable
                      as int,
            pricing: null == pricing
                ? _value.pricing
                : pricing // ignore: cast_nullable_to_non_nullable
                      as ModelPricing,
            capabilities: null == capabilities
                ? _value.capabilities
                : capabilities // ignore: cast_nullable_to_non_nullable
                      as ModelCapabilities,
            parameters: null == parameters
                ? _value.parameters
                : parameters // ignore: cast_nullable_to_non_nullable
                      as Map<String, ModelParameter>,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }

  /// Create a copy of ModelInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ModelPricingCopyWith<$Res> get pricing {
    return $ModelPricingCopyWith<$Res>(_value.pricing, (value) {
      return _then(_value.copyWith(pricing: value) as $Val);
    });
  }

  /// Create a copy of ModelInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ModelCapabilitiesCopyWith<$Res> get capabilities {
    return $ModelCapabilitiesCopyWith<$Res>(_value.capabilities, (value) {
      return _then(_value.copyWith(capabilities: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ModelInfoImplCopyWith<$Res>
    implements $ModelInfoCopyWith<$Res> {
  factory _$$ModelInfoImplCopyWith(
    _$ModelInfoImpl value,
    $Res Function(_$ModelInfoImpl) then,
  ) = __$$ModelInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String provider,
    String displayName,
    String description,
    int contextWindow,
    int maxOutputTokens,
    ModelPricing pricing,
    ModelCapabilities capabilities,
    Map<String, ModelParameter> parameters,
    String? notes,
    String status,
  });

  @override
  $ModelPricingCopyWith<$Res> get pricing;
  @override
  $ModelCapabilitiesCopyWith<$Res> get capabilities;
}

/// @nodoc
class __$$ModelInfoImplCopyWithImpl<$Res>
    extends _$ModelInfoCopyWithImpl<$Res, _$ModelInfoImpl>
    implements _$$ModelInfoImplCopyWith<$Res> {
  __$$ModelInfoImplCopyWithImpl(
    _$ModelInfoImpl _value,
    $Res Function(_$ModelInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ModelInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? provider = null,
    Object? displayName = null,
    Object? description = null,
    Object? contextWindow = null,
    Object? maxOutputTokens = null,
    Object? pricing = null,
    Object? capabilities = null,
    Object? parameters = null,
    Object? notes = freezed,
    Object? status = null,
  }) {
    return _then(
      _$ModelInfoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        provider: null == provider
            ? _value.provider
            : provider // ignore: cast_nullable_to_non_nullable
                  as String,
        displayName: null == displayName
            ? _value.displayName
            : displayName // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        contextWindow: null == contextWindow
            ? _value.contextWindow
            : contextWindow // ignore: cast_nullable_to_non_nullable
                  as int,
        maxOutputTokens: null == maxOutputTokens
            ? _value.maxOutputTokens
            : maxOutputTokens // ignore: cast_nullable_to_non_nullable
                  as int,
        pricing: null == pricing
            ? _value.pricing
            : pricing // ignore: cast_nullable_to_non_nullable
                  as ModelPricing,
        capabilities: null == capabilities
            ? _value.capabilities
            : capabilities // ignore: cast_nullable_to_non_nullable
                  as ModelCapabilities,
        parameters: null == parameters
            ? _value._parameters
            : parameters // ignore: cast_nullable_to_non_nullable
                  as Map<String, ModelParameter>,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ModelInfoImpl implements _ModelInfo {
  const _$ModelInfoImpl({
    required this.id,
    required this.provider,
    required this.displayName,
    this.description = '',
    required this.contextWindow,
    this.maxOutputTokens = 4096,
    required this.pricing,
    this.capabilities = const ModelCapabilities(),
    final Map<String, ModelParameter> parameters = const {},
    this.notes,
    this.status = 'active',
  }) : _parameters = parameters;

  factory _$ModelInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ModelInfoImplFromJson(json);

  @override
  final String id;
  @override
  final String provider;
  @override
  final String displayName;
  @override
  @JsonKey()
  final String description;
  @override
  final int contextWindow;
  @override
  @JsonKey()
  final int maxOutputTokens;
  @override
  final ModelPricing pricing;
  @override
  @JsonKey()
  final ModelCapabilities capabilities;
  final Map<String, ModelParameter> _parameters;
  @override
  @JsonKey()
  Map<String, ModelParameter> get parameters {
    if (_parameters is EqualUnmodifiableMapView) return _parameters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_parameters);
  }

  @override
  final String? notes;
  @override
  @JsonKey()
  final String status;

  @override
  String toString() {
    return 'ModelInfo(id: $id, provider: $provider, displayName: $displayName, description: $description, contextWindow: $contextWindow, maxOutputTokens: $maxOutputTokens, pricing: $pricing, capabilities: $capabilities, parameters: $parameters, notes: $notes, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ModelInfoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.provider, provider) ||
                other.provider == provider) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.contextWindow, contextWindow) ||
                other.contextWindow == contextWindow) &&
            (identical(other.maxOutputTokens, maxOutputTokens) ||
                other.maxOutputTokens == maxOutputTokens) &&
            (identical(other.pricing, pricing) || other.pricing == pricing) &&
            (identical(other.capabilities, capabilities) ||
                other.capabilities == capabilities) &&
            const DeepCollectionEquality().equals(
              other._parameters,
              _parameters,
            ) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    provider,
    displayName,
    description,
    contextWindow,
    maxOutputTokens,
    pricing,
    capabilities,
    const DeepCollectionEquality().hash(_parameters),
    notes,
    status,
  );

  /// Create a copy of ModelInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ModelInfoImplCopyWith<_$ModelInfoImpl> get copyWith =>
      __$$ModelInfoImplCopyWithImpl<_$ModelInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ModelInfoImplToJson(this);
  }
}

abstract class _ModelInfo implements ModelInfo {
  const factory _ModelInfo({
    required final String id,
    required final String provider,
    required final String displayName,
    final String description,
    required final int contextWindow,
    final int maxOutputTokens,
    required final ModelPricing pricing,
    final ModelCapabilities capabilities,
    final Map<String, ModelParameter> parameters,
    final String? notes,
    final String status,
  }) = _$ModelInfoImpl;

  factory _ModelInfo.fromJson(Map<String, dynamic> json) =
      _$ModelInfoImpl.fromJson;

  @override
  String get id;
  @override
  String get provider;
  @override
  String get displayName;
  @override
  String get description;
  @override
  int get contextWindow;
  @override
  int get maxOutputTokens;
  @override
  ModelPricing get pricing;
  @override
  ModelCapabilities get capabilities;
  @override
  Map<String, ModelParameter> get parameters;
  @override
  String? get notes;
  @override
  String get status;

  /// Create a copy of ModelInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ModelInfoImplCopyWith<_$ModelInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ModelPricing _$ModelPricingFromJson(Map<String, dynamic> json) {
  return _ModelPricing.fromJson(json);
}

/// @nodoc
mixin _$ModelPricing {
  double get inputPerMillion => throw _privateConstructorUsedError;
  double get outputPerMillion => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  String? get updatedAt => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this ModelPricing to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ModelPricing
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ModelPricingCopyWith<ModelPricing> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ModelPricingCopyWith<$Res> {
  factory $ModelPricingCopyWith(
    ModelPricing value,
    $Res Function(ModelPricing) then,
  ) = _$ModelPricingCopyWithImpl<$Res, ModelPricing>;
  @useResult
  $Res call({
    double inputPerMillion,
    double outputPerMillion,
    String currency,
    String? updatedAt,
    String? notes,
  });
}

/// @nodoc
class _$ModelPricingCopyWithImpl<$Res, $Val extends ModelPricing>
    implements $ModelPricingCopyWith<$Res> {
  _$ModelPricingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ModelPricing
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? inputPerMillion = null,
    Object? outputPerMillion = null,
    Object? currency = null,
    Object? updatedAt = freezed,
    Object? notes = freezed,
  }) {
    return _then(
      _value.copyWith(
            inputPerMillion: null == inputPerMillion
                ? _value.inputPerMillion
                : inputPerMillion // ignore: cast_nullable_to_non_nullable
                      as double,
            outputPerMillion: null == outputPerMillion
                ? _value.outputPerMillion
                : outputPerMillion // ignore: cast_nullable_to_non_nullable
                      as double,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ModelPricingImplCopyWith<$Res>
    implements $ModelPricingCopyWith<$Res> {
  factory _$$ModelPricingImplCopyWith(
    _$ModelPricingImpl value,
    $Res Function(_$ModelPricingImpl) then,
  ) = __$$ModelPricingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double inputPerMillion,
    double outputPerMillion,
    String currency,
    String? updatedAt,
    String? notes,
  });
}

/// @nodoc
class __$$ModelPricingImplCopyWithImpl<$Res>
    extends _$ModelPricingCopyWithImpl<$Res, _$ModelPricingImpl>
    implements _$$ModelPricingImplCopyWith<$Res> {
  __$$ModelPricingImplCopyWithImpl(
    _$ModelPricingImpl _value,
    $Res Function(_$ModelPricingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ModelPricing
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? inputPerMillion = null,
    Object? outputPerMillion = null,
    Object? currency = null,
    Object? updatedAt = freezed,
    Object? notes = freezed,
  }) {
    return _then(
      _$ModelPricingImpl(
        inputPerMillion: null == inputPerMillion
            ? _value.inputPerMillion
            : inputPerMillion // ignore: cast_nullable_to_non_nullable
                  as double,
        outputPerMillion: null == outputPerMillion
            ? _value.outputPerMillion
            : outputPerMillion // ignore: cast_nullable_to_non_nullable
                  as double,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ModelPricingImpl implements _ModelPricing {
  const _$ModelPricingImpl({
    this.inputPerMillion = 0,
    this.outputPerMillion = 0,
    this.currency = 'USD',
    this.updatedAt,
    this.notes,
  });

  factory _$ModelPricingImpl.fromJson(Map<String, dynamic> json) =>
      _$$ModelPricingImplFromJson(json);

  @override
  @JsonKey()
  final double inputPerMillion;
  @override
  @JsonKey()
  final double outputPerMillion;
  @override
  @JsonKey()
  final String currency;
  @override
  final String? updatedAt;
  @override
  final String? notes;

  @override
  String toString() {
    return 'ModelPricing(inputPerMillion: $inputPerMillion, outputPerMillion: $outputPerMillion, currency: $currency, updatedAt: $updatedAt, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ModelPricingImpl &&
            (identical(other.inputPerMillion, inputPerMillion) ||
                other.inputPerMillion == inputPerMillion) &&
            (identical(other.outputPerMillion, outputPerMillion) ||
                other.outputPerMillion == outputPerMillion) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    inputPerMillion,
    outputPerMillion,
    currency,
    updatedAt,
    notes,
  );

  /// Create a copy of ModelPricing
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ModelPricingImplCopyWith<_$ModelPricingImpl> get copyWith =>
      __$$ModelPricingImplCopyWithImpl<_$ModelPricingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ModelPricingImplToJson(this);
  }
}

abstract class _ModelPricing implements ModelPricing {
  const factory _ModelPricing({
    final double inputPerMillion,
    final double outputPerMillion,
    final String currency,
    final String? updatedAt,
    final String? notes,
  }) = _$ModelPricingImpl;

  factory _ModelPricing.fromJson(Map<String, dynamic> json) =
      _$ModelPricingImpl.fromJson;

  @override
  double get inputPerMillion;
  @override
  double get outputPerMillion;
  @override
  String get currency;
  @override
  String? get updatedAt;
  @override
  String? get notes;

  /// Create a copy of ModelPricing
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ModelPricingImplCopyWith<_$ModelPricingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ModelCapabilities _$ModelCapabilitiesFromJson(Map<String, dynamic> json) {
  return _ModelCapabilities.fromJson(json);
}

/// @nodoc
mixin _$ModelCapabilities {
  bool get chat => throw _privateConstructorUsedError;
  bool get vision => throw _privateConstructorUsedError;
  bool get functionCalling => throw _privateConstructorUsedError;
  bool get jsonMode => throw _privateConstructorUsedError;
  bool get streaming => throw _privateConstructorUsedError;
  bool get reasoning => throw _privateConstructorUsedError;
  bool get extendedThinking => throw _privateConstructorUsedError;

  /// Serializes this ModelCapabilities to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ModelCapabilities
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ModelCapabilitiesCopyWith<ModelCapabilities> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ModelCapabilitiesCopyWith<$Res> {
  factory $ModelCapabilitiesCopyWith(
    ModelCapabilities value,
    $Res Function(ModelCapabilities) then,
  ) = _$ModelCapabilitiesCopyWithImpl<$Res, ModelCapabilities>;
  @useResult
  $Res call({
    bool chat,
    bool vision,
    bool functionCalling,
    bool jsonMode,
    bool streaming,
    bool reasoning,
    bool extendedThinking,
  });
}

/// @nodoc
class _$ModelCapabilitiesCopyWithImpl<$Res, $Val extends ModelCapabilities>
    implements $ModelCapabilitiesCopyWith<$Res> {
  _$ModelCapabilitiesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ModelCapabilities
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? chat = null,
    Object? vision = null,
    Object? functionCalling = null,
    Object? jsonMode = null,
    Object? streaming = null,
    Object? reasoning = null,
    Object? extendedThinking = null,
  }) {
    return _then(
      _value.copyWith(
            chat: null == chat
                ? _value.chat
                : chat // ignore: cast_nullable_to_non_nullable
                      as bool,
            vision: null == vision
                ? _value.vision
                : vision // ignore: cast_nullable_to_non_nullable
                      as bool,
            functionCalling: null == functionCalling
                ? _value.functionCalling
                : functionCalling // ignore: cast_nullable_to_non_nullable
                      as bool,
            jsonMode: null == jsonMode
                ? _value.jsonMode
                : jsonMode // ignore: cast_nullable_to_non_nullable
                      as bool,
            streaming: null == streaming
                ? _value.streaming
                : streaming // ignore: cast_nullable_to_non_nullable
                      as bool,
            reasoning: null == reasoning
                ? _value.reasoning
                : reasoning // ignore: cast_nullable_to_non_nullable
                      as bool,
            extendedThinking: null == extendedThinking
                ? _value.extendedThinking
                : extendedThinking // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ModelCapabilitiesImplCopyWith<$Res>
    implements $ModelCapabilitiesCopyWith<$Res> {
  factory _$$ModelCapabilitiesImplCopyWith(
    _$ModelCapabilitiesImpl value,
    $Res Function(_$ModelCapabilitiesImpl) then,
  ) = __$$ModelCapabilitiesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool chat,
    bool vision,
    bool functionCalling,
    bool jsonMode,
    bool streaming,
    bool reasoning,
    bool extendedThinking,
  });
}

/// @nodoc
class __$$ModelCapabilitiesImplCopyWithImpl<$Res>
    extends _$ModelCapabilitiesCopyWithImpl<$Res, _$ModelCapabilitiesImpl>
    implements _$$ModelCapabilitiesImplCopyWith<$Res> {
  __$$ModelCapabilitiesImplCopyWithImpl(
    _$ModelCapabilitiesImpl _value,
    $Res Function(_$ModelCapabilitiesImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ModelCapabilities
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? chat = null,
    Object? vision = null,
    Object? functionCalling = null,
    Object? jsonMode = null,
    Object? streaming = null,
    Object? reasoning = null,
    Object? extendedThinking = null,
  }) {
    return _then(
      _$ModelCapabilitiesImpl(
        chat: null == chat
            ? _value.chat
            : chat // ignore: cast_nullable_to_non_nullable
                  as bool,
        vision: null == vision
            ? _value.vision
            : vision // ignore: cast_nullable_to_non_nullable
                  as bool,
        functionCalling: null == functionCalling
            ? _value.functionCalling
            : functionCalling // ignore: cast_nullable_to_non_nullable
                  as bool,
        jsonMode: null == jsonMode
            ? _value.jsonMode
            : jsonMode // ignore: cast_nullable_to_non_nullable
                  as bool,
        streaming: null == streaming
            ? _value.streaming
            : streaming // ignore: cast_nullable_to_non_nullable
                  as bool,
        reasoning: null == reasoning
            ? _value.reasoning
            : reasoning // ignore: cast_nullable_to_non_nullable
                  as bool,
        extendedThinking: null == extendedThinking
            ? _value.extendedThinking
            : extendedThinking // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ModelCapabilitiesImpl implements _ModelCapabilities {
  const _$ModelCapabilitiesImpl({
    this.chat = true,
    this.vision = false,
    this.functionCalling = false,
    this.jsonMode = false,
    this.streaming = true,
    this.reasoning = false,
    this.extendedThinking = false,
  });

  factory _$ModelCapabilitiesImpl.fromJson(Map<String, dynamic> json) =>
      _$$ModelCapabilitiesImplFromJson(json);

  @override
  @JsonKey()
  final bool chat;
  @override
  @JsonKey()
  final bool vision;
  @override
  @JsonKey()
  final bool functionCalling;
  @override
  @JsonKey()
  final bool jsonMode;
  @override
  @JsonKey()
  final bool streaming;
  @override
  @JsonKey()
  final bool reasoning;
  @override
  @JsonKey()
  final bool extendedThinking;

  @override
  String toString() {
    return 'ModelCapabilities(chat: $chat, vision: $vision, functionCalling: $functionCalling, jsonMode: $jsonMode, streaming: $streaming, reasoning: $reasoning, extendedThinking: $extendedThinking)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ModelCapabilitiesImpl &&
            (identical(other.chat, chat) || other.chat == chat) &&
            (identical(other.vision, vision) || other.vision == vision) &&
            (identical(other.functionCalling, functionCalling) ||
                other.functionCalling == functionCalling) &&
            (identical(other.jsonMode, jsonMode) ||
                other.jsonMode == jsonMode) &&
            (identical(other.streaming, streaming) ||
                other.streaming == streaming) &&
            (identical(other.reasoning, reasoning) ||
                other.reasoning == reasoning) &&
            (identical(other.extendedThinking, extendedThinking) ||
                other.extendedThinking == extendedThinking));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    chat,
    vision,
    functionCalling,
    jsonMode,
    streaming,
    reasoning,
    extendedThinking,
  );

  /// Create a copy of ModelCapabilities
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ModelCapabilitiesImplCopyWith<_$ModelCapabilitiesImpl> get copyWith =>
      __$$ModelCapabilitiesImplCopyWithImpl<_$ModelCapabilitiesImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ModelCapabilitiesImplToJson(this);
  }
}

abstract class _ModelCapabilities implements ModelCapabilities {
  const factory _ModelCapabilities({
    final bool chat,
    final bool vision,
    final bool functionCalling,
    final bool jsonMode,
    final bool streaming,
    final bool reasoning,
    final bool extendedThinking,
  }) = _$ModelCapabilitiesImpl;

  factory _ModelCapabilities.fromJson(Map<String, dynamic> json) =
      _$ModelCapabilitiesImpl.fromJson;

  @override
  bool get chat;
  @override
  bool get vision;
  @override
  bool get functionCalling;
  @override
  bool get jsonMode;
  @override
  bool get streaming;
  @override
  bool get reasoning;
  @override
  bool get extendedThinking;

  /// Create a copy of ModelCapabilities
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ModelCapabilitiesImplCopyWith<_$ModelCapabilitiesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ModelParameter _$ModelParameterFromJson(Map<String, dynamic> json) {
  return _ModelParameter.fromJson(json);
}

/// @nodoc
mixin _$ModelParameter {
  bool get supported => throw _privateConstructorUsedError;
  String? get type =>
      throw _privateConstructorUsedError; // float, integer, enum
  double? get min => throw _privateConstructorUsedError;
  double? get max => throw _privateConstructorUsedError;
  dynamic get defaultValue => throw _privateConstructorUsedError;
  List<String>? get values =>
      throw _privateConstructorUsedError; // For enum type
  String? get apiName => throw _privateConstructorUsedError;

  /// Serializes this ModelParameter to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ModelParameter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ModelParameterCopyWith<ModelParameter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ModelParameterCopyWith<$Res> {
  factory $ModelParameterCopyWith(
    ModelParameter value,
    $Res Function(ModelParameter) then,
  ) = _$ModelParameterCopyWithImpl<$Res, ModelParameter>;
  @useResult
  $Res call({
    bool supported,
    String? type,
    double? min,
    double? max,
    dynamic defaultValue,
    List<String>? values,
    String? apiName,
  });
}

/// @nodoc
class _$ModelParameterCopyWithImpl<$Res, $Val extends ModelParameter>
    implements $ModelParameterCopyWith<$Res> {
  _$ModelParameterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ModelParameter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? supported = null,
    Object? type = freezed,
    Object? min = freezed,
    Object? max = freezed,
    Object? defaultValue = freezed,
    Object? values = freezed,
    Object? apiName = freezed,
  }) {
    return _then(
      _value.copyWith(
            supported: null == supported
                ? _value.supported
                : supported // ignore: cast_nullable_to_non_nullable
                      as bool,
            type: freezed == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String?,
            min: freezed == min
                ? _value.min
                : min // ignore: cast_nullable_to_non_nullable
                      as double?,
            max: freezed == max
                ? _value.max
                : max // ignore: cast_nullable_to_non_nullable
                      as double?,
            defaultValue: freezed == defaultValue
                ? _value.defaultValue
                : defaultValue // ignore: cast_nullable_to_non_nullable
                      as dynamic,
            values: freezed == values
                ? _value.values
                : values // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            apiName: freezed == apiName
                ? _value.apiName
                : apiName // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ModelParameterImplCopyWith<$Res>
    implements $ModelParameterCopyWith<$Res> {
  factory _$$ModelParameterImplCopyWith(
    _$ModelParameterImpl value,
    $Res Function(_$ModelParameterImpl) then,
  ) = __$$ModelParameterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool supported,
    String? type,
    double? min,
    double? max,
    dynamic defaultValue,
    List<String>? values,
    String? apiName,
  });
}

/// @nodoc
class __$$ModelParameterImplCopyWithImpl<$Res>
    extends _$ModelParameterCopyWithImpl<$Res, _$ModelParameterImpl>
    implements _$$ModelParameterImplCopyWith<$Res> {
  __$$ModelParameterImplCopyWithImpl(
    _$ModelParameterImpl _value,
    $Res Function(_$ModelParameterImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ModelParameter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? supported = null,
    Object? type = freezed,
    Object? min = freezed,
    Object? max = freezed,
    Object? defaultValue = freezed,
    Object? values = freezed,
    Object? apiName = freezed,
  }) {
    return _then(
      _$ModelParameterImpl(
        supported: null == supported
            ? _value.supported
            : supported // ignore: cast_nullable_to_non_nullable
                  as bool,
        type: freezed == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String?,
        min: freezed == min
            ? _value.min
            : min // ignore: cast_nullable_to_non_nullable
                  as double?,
        max: freezed == max
            ? _value.max
            : max // ignore: cast_nullable_to_non_nullable
                  as double?,
        defaultValue: freezed == defaultValue
            ? _value.defaultValue
            : defaultValue // ignore: cast_nullable_to_non_nullable
                  as dynamic,
        values: freezed == values
            ? _value._values
            : values // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        apiName: freezed == apiName
            ? _value.apiName
            : apiName // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ModelParameterImpl implements _ModelParameter {
  const _$ModelParameterImpl({
    required this.supported,
    this.type,
    this.min,
    this.max,
    this.defaultValue,
    final List<String>? values,
    this.apiName,
  }) : _values = values;

  factory _$ModelParameterImpl.fromJson(Map<String, dynamic> json) =>
      _$$ModelParameterImplFromJson(json);

  @override
  final bool supported;
  @override
  final String? type;
  // float, integer, enum
  @override
  final double? min;
  @override
  final double? max;
  @override
  final dynamic defaultValue;
  final List<String>? _values;
  @override
  List<String>? get values {
    final value = _values;
    if (value == null) return null;
    if (_values is EqualUnmodifiableListView) return _values;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  // For enum type
  @override
  final String? apiName;

  @override
  String toString() {
    return 'ModelParameter(supported: $supported, type: $type, min: $min, max: $max, defaultValue: $defaultValue, values: $values, apiName: $apiName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ModelParameterImpl &&
            (identical(other.supported, supported) ||
                other.supported == supported) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.min, min) || other.min == min) &&
            (identical(other.max, max) || other.max == max) &&
            const DeepCollectionEquality().equals(
              other.defaultValue,
              defaultValue,
            ) &&
            const DeepCollectionEquality().equals(other._values, _values) &&
            (identical(other.apiName, apiName) || other.apiName == apiName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    supported,
    type,
    min,
    max,
    const DeepCollectionEquality().hash(defaultValue),
    const DeepCollectionEquality().hash(_values),
    apiName,
  );

  /// Create a copy of ModelParameter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ModelParameterImplCopyWith<_$ModelParameterImpl> get copyWith =>
      __$$ModelParameterImplCopyWithImpl<_$ModelParameterImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ModelParameterImplToJson(this);
  }
}

abstract class _ModelParameter implements ModelParameter {
  const factory _ModelParameter({
    required final bool supported,
    final String? type,
    final double? min,
    final double? max,
    final dynamic defaultValue,
    final List<String>? values,
    final String? apiName,
  }) = _$ModelParameterImpl;

  factory _ModelParameter.fromJson(Map<String, dynamic> json) =
      _$ModelParameterImpl.fromJson;

  @override
  bool get supported;
  @override
  String? get type; // float, integer, enum
  @override
  double? get min;
  @override
  double? get max;
  @override
  dynamic get defaultValue;
  @override
  List<String>? get values; // For enum type
  @override
  String? get apiName;

  /// Create a copy of ModelParameter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ModelParameterImplCopyWith<_$ModelParameterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
