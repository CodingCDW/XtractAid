// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'checkpoint.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Checkpoint _$CheckpointFromJson(Map<String, dynamic> json) {
  return _Checkpoint.fromJson(json);
}

/// @nodoc
mixin _$Checkpoint {
  String get batchId => throw _privateConstructorUsedError;
  BatchProgress get progress => throw _privateConstructorUsedError;
  BatchStats get stats => throw _privateConstructorUsedError;
  BatchConfig get config => throw _privateConstructorUsedError;
  List<Map<String, dynamic>> get results => throw _privateConstructorUsedError;
  DateTime get savedAt => throw _privateConstructorUsedError;

  /// Serializes this Checkpoint to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Checkpoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CheckpointCopyWith<Checkpoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CheckpointCopyWith<$Res> {
  factory $CheckpointCopyWith(
    Checkpoint value,
    $Res Function(Checkpoint) then,
  ) = _$CheckpointCopyWithImpl<$Res, Checkpoint>;
  @useResult
  $Res call({
    String batchId,
    BatchProgress progress,
    BatchStats stats,
    BatchConfig config,
    List<Map<String, dynamic>> results,
    DateTime savedAt,
  });

  $BatchProgressCopyWith<$Res> get progress;
  $BatchStatsCopyWith<$Res> get stats;
  $BatchConfigCopyWith<$Res> get config;
}

/// @nodoc
class _$CheckpointCopyWithImpl<$Res, $Val extends Checkpoint>
    implements $CheckpointCopyWith<$Res> {
  _$CheckpointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Checkpoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? batchId = null,
    Object? progress = null,
    Object? stats = null,
    Object? config = null,
    Object? results = null,
    Object? savedAt = null,
  }) {
    return _then(
      _value.copyWith(
            batchId: null == batchId
                ? _value.batchId
                : batchId // ignore: cast_nullable_to_non_nullable
                      as String,
            progress: null == progress
                ? _value.progress
                : progress // ignore: cast_nullable_to_non_nullable
                      as BatchProgress,
            stats: null == stats
                ? _value.stats
                : stats // ignore: cast_nullable_to_non_nullable
                      as BatchStats,
            config: null == config
                ? _value.config
                : config // ignore: cast_nullable_to_non_nullable
                      as BatchConfig,
            results: null == results
                ? _value.results
                : results // ignore: cast_nullable_to_non_nullable
                      as List<Map<String, dynamic>>,
            savedAt: null == savedAt
                ? _value.savedAt
                : savedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }

  /// Create a copy of Checkpoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BatchProgressCopyWith<$Res> get progress {
    return $BatchProgressCopyWith<$Res>(_value.progress, (value) {
      return _then(_value.copyWith(progress: value) as $Val);
    });
  }

  /// Create a copy of Checkpoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BatchStatsCopyWith<$Res> get stats {
    return $BatchStatsCopyWith<$Res>(_value.stats, (value) {
      return _then(_value.copyWith(stats: value) as $Val);
    });
  }

  /// Create a copy of Checkpoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BatchConfigCopyWith<$Res> get config {
    return $BatchConfigCopyWith<$Res>(_value.config, (value) {
      return _then(_value.copyWith(config: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CheckpointImplCopyWith<$Res>
    implements $CheckpointCopyWith<$Res> {
  factory _$$CheckpointImplCopyWith(
    _$CheckpointImpl value,
    $Res Function(_$CheckpointImpl) then,
  ) = __$$CheckpointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String batchId,
    BatchProgress progress,
    BatchStats stats,
    BatchConfig config,
    List<Map<String, dynamic>> results,
    DateTime savedAt,
  });

  @override
  $BatchProgressCopyWith<$Res> get progress;
  @override
  $BatchStatsCopyWith<$Res> get stats;
  @override
  $BatchConfigCopyWith<$Res> get config;
}

/// @nodoc
class __$$CheckpointImplCopyWithImpl<$Res>
    extends _$CheckpointCopyWithImpl<$Res, _$CheckpointImpl>
    implements _$$CheckpointImplCopyWith<$Res> {
  __$$CheckpointImplCopyWithImpl(
    _$CheckpointImpl _value,
    $Res Function(_$CheckpointImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Checkpoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? batchId = null,
    Object? progress = null,
    Object? stats = null,
    Object? config = null,
    Object? results = null,
    Object? savedAt = null,
  }) {
    return _then(
      _$CheckpointImpl(
        batchId: null == batchId
            ? _value.batchId
            : batchId // ignore: cast_nullable_to_non_nullable
                  as String,
        progress: null == progress
            ? _value.progress
            : progress // ignore: cast_nullable_to_non_nullable
                  as BatchProgress,
        stats: null == stats
            ? _value.stats
            : stats // ignore: cast_nullable_to_non_nullable
                  as BatchStats,
        config: null == config
            ? _value.config
            : config // ignore: cast_nullable_to_non_nullable
                  as BatchConfig,
        results: null == results
            ? _value._results
            : results // ignore: cast_nullable_to_non_nullable
                  as List<Map<String, dynamic>>,
        savedAt: null == savedAt
            ? _value.savedAt
            : savedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CheckpointImpl implements _Checkpoint {
  const _$CheckpointImpl({
    required this.batchId,
    required this.progress,
    required this.stats,
    required this.config,
    final List<Map<String, dynamic>> results = const [],
    required this.savedAt,
  }) : _results = results;

  factory _$CheckpointImpl.fromJson(Map<String, dynamic> json) =>
      _$$CheckpointImplFromJson(json);

  @override
  final String batchId;
  @override
  final BatchProgress progress;
  @override
  final BatchStats stats;
  @override
  final BatchConfig config;
  final List<Map<String, dynamic>> _results;
  @override
  @JsonKey()
  List<Map<String, dynamic>> get results {
    if (_results is EqualUnmodifiableListView) return _results;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_results);
  }

  @override
  final DateTime savedAt;

  @override
  String toString() {
    return 'Checkpoint(batchId: $batchId, progress: $progress, stats: $stats, config: $config, results: $results, savedAt: $savedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CheckpointImpl &&
            (identical(other.batchId, batchId) || other.batchId == batchId) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.stats, stats) || other.stats == stats) &&
            (identical(other.config, config) || other.config == config) &&
            const DeepCollectionEquality().equals(other._results, _results) &&
            (identical(other.savedAt, savedAt) || other.savedAt == savedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    batchId,
    progress,
    stats,
    config,
    const DeepCollectionEquality().hash(_results),
    savedAt,
  );

  /// Create a copy of Checkpoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CheckpointImplCopyWith<_$CheckpointImpl> get copyWith =>
      __$$CheckpointImplCopyWithImpl<_$CheckpointImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CheckpointImplToJson(this);
  }
}

abstract class _Checkpoint implements Checkpoint {
  const factory _Checkpoint({
    required final String batchId,
    required final BatchProgress progress,
    required final BatchStats stats,
    required final BatchConfig config,
    final List<Map<String, dynamic>> results,
    required final DateTime savedAt,
  }) = _$CheckpointImpl;

  factory _Checkpoint.fromJson(Map<String, dynamic> json) =
      _$CheckpointImpl.fromJson;

  @override
  String get batchId;
  @override
  BatchProgress get progress;
  @override
  BatchStats get stats;
  @override
  BatchConfig get config;
  @override
  List<Map<String, dynamic>> get results;
  @override
  DateTime get savedAt;

  /// Create a copy of Checkpoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CheckpointImplCopyWith<_$CheckpointImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
