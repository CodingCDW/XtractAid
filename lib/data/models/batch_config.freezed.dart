// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'batch_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BatchConfig _$BatchConfigFromJson(Map<String, dynamic> json) {
  return _BatchConfig.fromJson(json);
}

/// @nodoc
mixin _$BatchConfig {
  String get batchId => throw _privateConstructorUsedError;
  String get projectId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  BatchInput get input => throw _privateConstructorUsedError;
  List<String> get promptFiles => throw _privateConstructorUsedError;
  ChunkSettings get chunkSettings => throw _privateConstructorUsedError;
  List<BatchModelConfig> get models => throw _privateConstructorUsedError;
  bool get privacyConfirmed => throw _privateConstructorUsedError;

  /// Serializes this BatchConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BatchConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BatchConfigCopyWith<BatchConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BatchConfigCopyWith<$Res> {
  factory $BatchConfigCopyWith(
    BatchConfig value,
    $Res Function(BatchConfig) then,
  ) = _$BatchConfigCopyWithImpl<$Res, BatchConfig>;
  @useResult
  $Res call({
    String batchId,
    String projectId,
    String name,
    BatchInput input,
    List<String> promptFiles,
    ChunkSettings chunkSettings,
    List<BatchModelConfig> models,
    bool privacyConfirmed,
  });

  $BatchInputCopyWith<$Res> get input;
  $ChunkSettingsCopyWith<$Res> get chunkSettings;
}

/// @nodoc
class _$BatchConfigCopyWithImpl<$Res, $Val extends BatchConfig>
    implements $BatchConfigCopyWith<$Res> {
  _$BatchConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BatchConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? batchId = null,
    Object? projectId = null,
    Object? name = null,
    Object? input = null,
    Object? promptFiles = null,
    Object? chunkSettings = null,
    Object? models = null,
    Object? privacyConfirmed = null,
  }) {
    return _then(
      _value.copyWith(
            batchId: null == batchId
                ? _value.batchId
                : batchId // ignore: cast_nullable_to_non_nullable
                      as String,
            projectId: null == projectId
                ? _value.projectId
                : projectId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            input: null == input
                ? _value.input
                : input // ignore: cast_nullable_to_non_nullable
                      as BatchInput,
            promptFiles: null == promptFiles
                ? _value.promptFiles
                : promptFiles // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            chunkSettings: null == chunkSettings
                ? _value.chunkSettings
                : chunkSettings // ignore: cast_nullable_to_non_nullable
                      as ChunkSettings,
            models: null == models
                ? _value.models
                : models // ignore: cast_nullable_to_non_nullable
                      as List<BatchModelConfig>,
            privacyConfirmed: null == privacyConfirmed
                ? _value.privacyConfirmed
                : privacyConfirmed // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }

  /// Create a copy of BatchConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BatchInputCopyWith<$Res> get input {
    return $BatchInputCopyWith<$Res>(_value.input, (value) {
      return _then(_value.copyWith(input: value) as $Val);
    });
  }

  /// Create a copy of BatchConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ChunkSettingsCopyWith<$Res> get chunkSettings {
    return $ChunkSettingsCopyWith<$Res>(_value.chunkSettings, (value) {
      return _then(_value.copyWith(chunkSettings: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BatchConfigImplCopyWith<$Res>
    implements $BatchConfigCopyWith<$Res> {
  factory _$$BatchConfigImplCopyWith(
    _$BatchConfigImpl value,
    $Res Function(_$BatchConfigImpl) then,
  ) = __$$BatchConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String batchId,
    String projectId,
    String name,
    BatchInput input,
    List<String> promptFiles,
    ChunkSettings chunkSettings,
    List<BatchModelConfig> models,
    bool privacyConfirmed,
  });

  @override
  $BatchInputCopyWith<$Res> get input;
  @override
  $ChunkSettingsCopyWith<$Res> get chunkSettings;
}

/// @nodoc
class __$$BatchConfigImplCopyWithImpl<$Res>
    extends _$BatchConfigCopyWithImpl<$Res, _$BatchConfigImpl>
    implements _$$BatchConfigImplCopyWith<$Res> {
  __$$BatchConfigImplCopyWithImpl(
    _$BatchConfigImpl _value,
    $Res Function(_$BatchConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BatchConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? batchId = null,
    Object? projectId = null,
    Object? name = null,
    Object? input = null,
    Object? promptFiles = null,
    Object? chunkSettings = null,
    Object? models = null,
    Object? privacyConfirmed = null,
  }) {
    return _then(
      _$BatchConfigImpl(
        batchId: null == batchId
            ? _value.batchId
            : batchId // ignore: cast_nullable_to_non_nullable
                  as String,
        projectId: null == projectId
            ? _value.projectId
            : projectId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        input: null == input
            ? _value.input
            : input // ignore: cast_nullable_to_non_nullable
                  as BatchInput,
        promptFiles: null == promptFiles
            ? _value._promptFiles
            : promptFiles // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        chunkSettings: null == chunkSettings
            ? _value.chunkSettings
            : chunkSettings // ignore: cast_nullable_to_non_nullable
                  as ChunkSettings,
        models: null == models
            ? _value._models
            : models // ignore: cast_nullable_to_non_nullable
                  as List<BatchModelConfig>,
        privacyConfirmed: null == privacyConfirmed
            ? _value.privacyConfirmed
            : privacyConfirmed // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BatchConfigImpl implements _BatchConfig {
  const _$BatchConfigImpl({
    required this.batchId,
    required this.projectId,
    required this.name,
    required this.input,
    required final List<String> promptFiles,
    required this.chunkSettings,
    required final List<BatchModelConfig> models,
    this.privacyConfirmed = false,
  }) : _promptFiles = promptFiles,
       _models = models;

  factory _$BatchConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$BatchConfigImplFromJson(json);

  @override
  final String batchId;
  @override
  final String projectId;
  @override
  final String name;
  @override
  final BatchInput input;
  final List<String> _promptFiles;
  @override
  List<String> get promptFiles {
    if (_promptFiles is EqualUnmodifiableListView) return _promptFiles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_promptFiles);
  }

  @override
  final ChunkSettings chunkSettings;
  final List<BatchModelConfig> _models;
  @override
  List<BatchModelConfig> get models {
    if (_models is EqualUnmodifiableListView) return _models;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_models);
  }

  @override
  @JsonKey()
  final bool privacyConfirmed;

  @override
  String toString() {
    return 'BatchConfig(batchId: $batchId, projectId: $projectId, name: $name, input: $input, promptFiles: $promptFiles, chunkSettings: $chunkSettings, models: $models, privacyConfirmed: $privacyConfirmed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BatchConfigImpl &&
            (identical(other.batchId, batchId) || other.batchId == batchId) &&
            (identical(other.projectId, projectId) ||
                other.projectId == projectId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.input, input) || other.input == input) &&
            const DeepCollectionEquality().equals(
              other._promptFiles,
              _promptFiles,
            ) &&
            (identical(other.chunkSettings, chunkSettings) ||
                other.chunkSettings == chunkSettings) &&
            const DeepCollectionEquality().equals(other._models, _models) &&
            (identical(other.privacyConfirmed, privacyConfirmed) ||
                other.privacyConfirmed == privacyConfirmed));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    batchId,
    projectId,
    name,
    input,
    const DeepCollectionEquality().hash(_promptFiles),
    chunkSettings,
    const DeepCollectionEquality().hash(_models),
    privacyConfirmed,
  );

  /// Create a copy of BatchConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BatchConfigImplCopyWith<_$BatchConfigImpl> get copyWith =>
      __$$BatchConfigImplCopyWithImpl<_$BatchConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BatchConfigImplToJson(this);
  }
}

abstract class _BatchConfig implements BatchConfig {
  const factory _BatchConfig({
    required final String batchId,
    required final String projectId,
    required final String name,
    required final BatchInput input,
    required final List<String> promptFiles,
    required final ChunkSettings chunkSettings,
    required final List<BatchModelConfig> models,
    final bool privacyConfirmed,
  }) = _$BatchConfigImpl;

  factory _BatchConfig.fromJson(Map<String, dynamic> json) =
      _$BatchConfigImpl.fromJson;

  @override
  String get batchId;
  @override
  String get projectId;
  @override
  String get name;
  @override
  BatchInput get input;
  @override
  List<String> get promptFiles;
  @override
  ChunkSettings get chunkSettings;
  @override
  List<BatchModelConfig> get models;
  @override
  bool get privacyConfirmed;

  /// Create a copy of BatchConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BatchConfigImplCopyWith<_$BatchConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BatchInput _$BatchInputFromJson(Map<String, dynamic> json) {
  return _BatchInput.fromJson(json);
}

/// @nodoc
mixin _$BatchInput {
  String get type => throw _privateConstructorUsedError; // excel, folder
  String get path => throw _privateConstructorUsedError;
  String? get sheetName => throw _privateConstructorUsedError;
  String? get idColumn => throw _privateConstructorUsedError;
  String? get itemColumn => throw _privateConstructorUsedError;
  int get itemCount => throw _privateConstructorUsedError;

  /// Serializes this BatchInput to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BatchInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BatchInputCopyWith<BatchInput> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BatchInputCopyWith<$Res> {
  factory $BatchInputCopyWith(
    BatchInput value,
    $Res Function(BatchInput) then,
  ) = _$BatchInputCopyWithImpl<$Res, BatchInput>;
  @useResult
  $Res call({
    String type,
    String path,
    String? sheetName,
    String? idColumn,
    String? itemColumn,
    int itemCount,
  });
}

/// @nodoc
class _$BatchInputCopyWithImpl<$Res, $Val extends BatchInput>
    implements $BatchInputCopyWith<$Res> {
  _$BatchInputCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BatchInput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? path = null,
    Object? sheetName = freezed,
    Object? idColumn = freezed,
    Object? itemColumn = freezed,
    Object? itemCount = null,
  }) {
    return _then(
      _value.copyWith(
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            path: null == path
                ? _value.path
                : path // ignore: cast_nullable_to_non_nullable
                      as String,
            sheetName: freezed == sheetName
                ? _value.sheetName
                : sheetName // ignore: cast_nullable_to_non_nullable
                      as String?,
            idColumn: freezed == idColumn
                ? _value.idColumn
                : idColumn // ignore: cast_nullable_to_non_nullable
                      as String?,
            itemColumn: freezed == itemColumn
                ? _value.itemColumn
                : itemColumn // ignore: cast_nullable_to_non_nullable
                      as String?,
            itemCount: null == itemCount
                ? _value.itemCount
                : itemCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BatchInputImplCopyWith<$Res>
    implements $BatchInputCopyWith<$Res> {
  factory _$$BatchInputImplCopyWith(
    _$BatchInputImpl value,
    $Res Function(_$BatchInputImpl) then,
  ) = __$$BatchInputImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String type,
    String path,
    String? sheetName,
    String? idColumn,
    String? itemColumn,
    int itemCount,
  });
}

/// @nodoc
class __$$BatchInputImplCopyWithImpl<$Res>
    extends _$BatchInputCopyWithImpl<$Res, _$BatchInputImpl>
    implements _$$BatchInputImplCopyWith<$Res> {
  __$$BatchInputImplCopyWithImpl(
    _$BatchInputImpl _value,
    $Res Function(_$BatchInputImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BatchInput
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? path = null,
    Object? sheetName = freezed,
    Object? idColumn = freezed,
    Object? itemColumn = freezed,
    Object? itemCount = null,
  }) {
    return _then(
      _$BatchInputImpl(
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        path: null == path
            ? _value.path
            : path // ignore: cast_nullable_to_non_nullable
                  as String,
        sheetName: freezed == sheetName
            ? _value.sheetName
            : sheetName // ignore: cast_nullable_to_non_nullable
                  as String?,
        idColumn: freezed == idColumn
            ? _value.idColumn
            : idColumn // ignore: cast_nullable_to_non_nullable
                  as String?,
        itemColumn: freezed == itemColumn
            ? _value.itemColumn
            : itemColumn // ignore: cast_nullable_to_non_nullable
                  as String?,
        itemCount: null == itemCount
            ? _value.itemCount
            : itemCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BatchInputImpl implements _BatchInput {
  const _$BatchInputImpl({
    required this.type,
    required this.path,
    this.sheetName,
    this.idColumn,
    this.itemColumn,
    this.itemCount = 0,
  });

  factory _$BatchInputImpl.fromJson(Map<String, dynamic> json) =>
      _$$BatchInputImplFromJson(json);

  @override
  final String type;
  // excel, folder
  @override
  final String path;
  @override
  final String? sheetName;
  @override
  final String? idColumn;
  @override
  final String? itemColumn;
  @override
  @JsonKey()
  final int itemCount;

  @override
  String toString() {
    return 'BatchInput(type: $type, path: $path, sheetName: $sheetName, idColumn: $idColumn, itemColumn: $itemColumn, itemCount: $itemCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BatchInputImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.path, path) || other.path == path) &&
            (identical(other.sheetName, sheetName) ||
                other.sheetName == sheetName) &&
            (identical(other.idColumn, idColumn) ||
                other.idColumn == idColumn) &&
            (identical(other.itemColumn, itemColumn) ||
                other.itemColumn == itemColumn) &&
            (identical(other.itemCount, itemCount) ||
                other.itemCount == itemCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    type,
    path,
    sheetName,
    idColumn,
    itemColumn,
    itemCount,
  );

  /// Create a copy of BatchInput
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BatchInputImplCopyWith<_$BatchInputImpl> get copyWith =>
      __$$BatchInputImplCopyWithImpl<_$BatchInputImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BatchInputImplToJson(this);
  }
}

abstract class _BatchInput implements BatchInput {
  const factory _BatchInput({
    required final String type,
    required final String path,
    final String? sheetName,
    final String? idColumn,
    final String? itemColumn,
    final int itemCount,
  }) = _$BatchInputImpl;

  factory _BatchInput.fromJson(Map<String, dynamic> json) =
      _$BatchInputImpl.fromJson;

  @override
  String get type; // excel, folder
  @override
  String get path;
  @override
  String? get sheetName;
  @override
  String? get idColumn;
  @override
  String? get itemColumn;
  @override
  int get itemCount;

  /// Create a copy of BatchInput
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BatchInputImplCopyWith<_$BatchInputImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChunkSettings _$ChunkSettingsFromJson(Map<String, dynamic> json) {
  return _ChunkSettings.fromJson(json);
}

/// @nodoc
mixin _$ChunkSettings {
  int get chunkSize => throw _privateConstructorUsedError;
  int get repetitions => throw _privateConstructorUsedError;
  bool get shuffleBetweenReps => throw _privateConstructorUsedError;
  int get requestDelaySeconds => throw _privateConstructorUsedError;

  /// Serializes this ChunkSettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChunkSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChunkSettingsCopyWith<ChunkSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChunkSettingsCopyWith<$Res> {
  factory $ChunkSettingsCopyWith(
    ChunkSettings value,
    $Res Function(ChunkSettings) then,
  ) = _$ChunkSettingsCopyWithImpl<$Res, ChunkSettings>;
  @useResult
  $Res call({
    int chunkSize,
    int repetitions,
    bool shuffleBetweenReps,
    int requestDelaySeconds,
  });
}

/// @nodoc
class _$ChunkSettingsCopyWithImpl<$Res, $Val extends ChunkSettings>
    implements $ChunkSettingsCopyWith<$Res> {
  _$ChunkSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChunkSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? chunkSize = null,
    Object? repetitions = null,
    Object? shuffleBetweenReps = null,
    Object? requestDelaySeconds = null,
  }) {
    return _then(
      _value.copyWith(
            chunkSize: null == chunkSize
                ? _value.chunkSize
                : chunkSize // ignore: cast_nullable_to_non_nullable
                      as int,
            repetitions: null == repetitions
                ? _value.repetitions
                : repetitions // ignore: cast_nullable_to_non_nullable
                      as int,
            shuffleBetweenReps: null == shuffleBetweenReps
                ? _value.shuffleBetweenReps
                : shuffleBetweenReps // ignore: cast_nullable_to_non_nullable
                      as bool,
            requestDelaySeconds: null == requestDelaySeconds
                ? _value.requestDelaySeconds
                : requestDelaySeconds // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChunkSettingsImplCopyWith<$Res>
    implements $ChunkSettingsCopyWith<$Res> {
  factory _$$ChunkSettingsImplCopyWith(
    _$ChunkSettingsImpl value,
    $Res Function(_$ChunkSettingsImpl) then,
  ) = __$$ChunkSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int chunkSize,
    int repetitions,
    bool shuffleBetweenReps,
    int requestDelaySeconds,
  });
}

/// @nodoc
class __$$ChunkSettingsImplCopyWithImpl<$Res>
    extends _$ChunkSettingsCopyWithImpl<$Res, _$ChunkSettingsImpl>
    implements _$$ChunkSettingsImplCopyWith<$Res> {
  __$$ChunkSettingsImplCopyWithImpl(
    _$ChunkSettingsImpl _value,
    $Res Function(_$ChunkSettingsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChunkSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? chunkSize = null,
    Object? repetitions = null,
    Object? shuffleBetweenReps = null,
    Object? requestDelaySeconds = null,
  }) {
    return _then(
      _$ChunkSettingsImpl(
        chunkSize: null == chunkSize
            ? _value.chunkSize
            : chunkSize // ignore: cast_nullable_to_non_nullable
                  as int,
        repetitions: null == repetitions
            ? _value.repetitions
            : repetitions // ignore: cast_nullable_to_non_nullable
                  as int,
        shuffleBetweenReps: null == shuffleBetweenReps
            ? _value.shuffleBetweenReps
            : shuffleBetweenReps // ignore: cast_nullable_to_non_nullable
                  as bool,
        requestDelaySeconds: null == requestDelaySeconds
            ? _value.requestDelaySeconds
            : requestDelaySeconds // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChunkSettingsImpl implements _ChunkSettings {
  const _$ChunkSettingsImpl({
    this.chunkSize = 10,
    this.repetitions = 1,
    this.shuffleBetweenReps = true,
    this.requestDelaySeconds = 0,
  });

  factory _$ChunkSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChunkSettingsImplFromJson(json);

  @override
  @JsonKey()
  final int chunkSize;
  @override
  @JsonKey()
  final int repetitions;
  @override
  @JsonKey()
  final bool shuffleBetweenReps;
  @override
  @JsonKey()
  final int requestDelaySeconds;

  @override
  String toString() {
    return 'ChunkSettings(chunkSize: $chunkSize, repetitions: $repetitions, shuffleBetweenReps: $shuffleBetweenReps, requestDelaySeconds: $requestDelaySeconds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChunkSettingsImpl &&
            (identical(other.chunkSize, chunkSize) ||
                other.chunkSize == chunkSize) &&
            (identical(other.repetitions, repetitions) ||
                other.repetitions == repetitions) &&
            (identical(other.shuffleBetweenReps, shuffleBetweenReps) ||
                other.shuffleBetweenReps == shuffleBetweenReps) &&
            (identical(other.requestDelaySeconds, requestDelaySeconds) ||
                other.requestDelaySeconds == requestDelaySeconds));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    chunkSize,
    repetitions,
    shuffleBetweenReps,
    requestDelaySeconds,
  );

  /// Create a copy of ChunkSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChunkSettingsImplCopyWith<_$ChunkSettingsImpl> get copyWith =>
      __$$ChunkSettingsImplCopyWithImpl<_$ChunkSettingsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChunkSettingsImplToJson(this);
  }
}

abstract class _ChunkSettings implements ChunkSettings {
  const factory _ChunkSettings({
    final int chunkSize,
    final int repetitions,
    final bool shuffleBetweenReps,
    final int requestDelaySeconds,
  }) = _$ChunkSettingsImpl;

  factory _ChunkSettings.fromJson(Map<String, dynamic> json) =
      _$ChunkSettingsImpl.fromJson;

  @override
  int get chunkSize;
  @override
  int get repetitions;
  @override
  bool get shuffleBetweenReps;
  @override
  int get requestDelaySeconds;

  /// Create a copy of ChunkSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChunkSettingsImplCopyWith<_$ChunkSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BatchModelConfig _$BatchModelConfigFromJson(Map<String, dynamic> json) {
  return _BatchModelConfig.fromJson(json);
}

/// @nodoc
mixin _$BatchModelConfig {
  String get modelId => throw _privateConstructorUsedError;
  String get providerId => throw _privateConstructorUsedError;
  Map<String, dynamic> get parameters => throw _privateConstructorUsedError;

  /// Serializes this BatchModelConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BatchModelConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BatchModelConfigCopyWith<BatchModelConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BatchModelConfigCopyWith<$Res> {
  factory $BatchModelConfigCopyWith(
    BatchModelConfig value,
    $Res Function(BatchModelConfig) then,
  ) = _$BatchModelConfigCopyWithImpl<$Res, BatchModelConfig>;
  @useResult
  $Res call({
    String modelId,
    String providerId,
    Map<String, dynamic> parameters,
  });
}

/// @nodoc
class _$BatchModelConfigCopyWithImpl<$Res, $Val extends BatchModelConfig>
    implements $BatchModelConfigCopyWith<$Res> {
  _$BatchModelConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BatchModelConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? modelId = null,
    Object? providerId = null,
    Object? parameters = null,
  }) {
    return _then(
      _value.copyWith(
            modelId: null == modelId
                ? _value.modelId
                : modelId // ignore: cast_nullable_to_non_nullable
                      as String,
            providerId: null == providerId
                ? _value.providerId
                : providerId // ignore: cast_nullable_to_non_nullable
                      as String,
            parameters: null == parameters
                ? _value.parameters
                : parameters // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BatchModelConfigImplCopyWith<$Res>
    implements $BatchModelConfigCopyWith<$Res> {
  factory _$$BatchModelConfigImplCopyWith(
    _$BatchModelConfigImpl value,
    $Res Function(_$BatchModelConfigImpl) then,
  ) = __$$BatchModelConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String modelId,
    String providerId,
    Map<String, dynamic> parameters,
  });
}

/// @nodoc
class __$$BatchModelConfigImplCopyWithImpl<$Res>
    extends _$BatchModelConfigCopyWithImpl<$Res, _$BatchModelConfigImpl>
    implements _$$BatchModelConfigImplCopyWith<$Res> {
  __$$BatchModelConfigImplCopyWithImpl(
    _$BatchModelConfigImpl _value,
    $Res Function(_$BatchModelConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BatchModelConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? modelId = null,
    Object? providerId = null,
    Object? parameters = null,
  }) {
    return _then(
      _$BatchModelConfigImpl(
        modelId: null == modelId
            ? _value.modelId
            : modelId // ignore: cast_nullable_to_non_nullable
                  as String,
        providerId: null == providerId
            ? _value.providerId
            : providerId // ignore: cast_nullable_to_non_nullable
                  as String,
        parameters: null == parameters
            ? _value._parameters
            : parameters // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BatchModelConfigImpl implements _BatchModelConfig {
  const _$BatchModelConfigImpl({
    required this.modelId,
    required this.providerId,
    final Map<String, dynamic> parameters = const {},
  }) : _parameters = parameters;

  factory _$BatchModelConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$BatchModelConfigImplFromJson(json);

  @override
  final String modelId;
  @override
  final String providerId;
  final Map<String, dynamic> _parameters;
  @override
  @JsonKey()
  Map<String, dynamic> get parameters {
    if (_parameters is EqualUnmodifiableMapView) return _parameters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_parameters);
  }

  @override
  String toString() {
    return 'BatchModelConfig(modelId: $modelId, providerId: $providerId, parameters: $parameters)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BatchModelConfigImpl &&
            (identical(other.modelId, modelId) || other.modelId == modelId) &&
            (identical(other.providerId, providerId) ||
                other.providerId == providerId) &&
            const DeepCollectionEquality().equals(
              other._parameters,
              _parameters,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    modelId,
    providerId,
    const DeepCollectionEquality().hash(_parameters),
  );

  /// Create a copy of BatchModelConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BatchModelConfigImplCopyWith<_$BatchModelConfigImpl> get copyWith =>
      __$$BatchModelConfigImplCopyWithImpl<_$BatchModelConfigImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BatchModelConfigImplToJson(this);
  }
}

abstract class _BatchModelConfig implements BatchModelConfig {
  const factory _BatchModelConfig({
    required final String modelId,
    required final String providerId,
    final Map<String, dynamic> parameters,
  }) = _$BatchModelConfigImpl;

  factory _BatchModelConfig.fromJson(Map<String, dynamic> json) =
      _$BatchModelConfigImpl.fromJson;

  @override
  String get modelId;
  @override
  String get providerId;
  @override
  Map<String, dynamic> get parameters;

  /// Create a copy of BatchModelConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BatchModelConfigImplCopyWith<_$BatchModelConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
