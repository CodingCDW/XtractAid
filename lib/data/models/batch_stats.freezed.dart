// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'batch_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BatchStats _$BatchStatsFromJson(Map<String, dynamic> json) {
  return _BatchStats.fromJson(json);
}

/// @nodoc
mixin _$BatchStats {
  int get totalApiCalls => throw _privateConstructorUsedError;
  int get completedApiCalls => throw _privateConstructorUsedError;
  int get failedApiCalls => throw _privateConstructorUsedError;
  int get totalInputTokens => throw _privateConstructorUsedError;
  int get totalOutputTokens => throw _privateConstructorUsedError;
  double get totalCost => throw _privateConstructorUsedError;
  int get totalItems => throw _privateConstructorUsedError;
  int get processedItems => throw _privateConstructorUsedError;
  DateTime? get startedAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;

  /// Serializes this BatchStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BatchStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BatchStatsCopyWith<BatchStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BatchStatsCopyWith<$Res> {
  factory $BatchStatsCopyWith(
    BatchStats value,
    $Res Function(BatchStats) then,
  ) = _$BatchStatsCopyWithImpl<$Res, BatchStats>;
  @useResult
  $Res call({
    int totalApiCalls,
    int completedApiCalls,
    int failedApiCalls,
    int totalInputTokens,
    int totalOutputTokens,
    double totalCost,
    int totalItems,
    int processedItems,
    DateTime? startedAt,
    DateTime? completedAt,
  });
}

/// @nodoc
class _$BatchStatsCopyWithImpl<$Res, $Val extends BatchStats>
    implements $BatchStatsCopyWith<$Res> {
  _$BatchStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BatchStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalApiCalls = null,
    Object? completedApiCalls = null,
    Object? failedApiCalls = null,
    Object? totalInputTokens = null,
    Object? totalOutputTokens = null,
    Object? totalCost = null,
    Object? totalItems = null,
    Object? processedItems = null,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            totalApiCalls: null == totalApiCalls
                ? _value.totalApiCalls
                : totalApiCalls // ignore: cast_nullable_to_non_nullable
                      as int,
            completedApiCalls: null == completedApiCalls
                ? _value.completedApiCalls
                : completedApiCalls // ignore: cast_nullable_to_non_nullable
                      as int,
            failedApiCalls: null == failedApiCalls
                ? _value.failedApiCalls
                : failedApiCalls // ignore: cast_nullable_to_non_nullable
                      as int,
            totalInputTokens: null == totalInputTokens
                ? _value.totalInputTokens
                : totalInputTokens // ignore: cast_nullable_to_non_nullable
                      as int,
            totalOutputTokens: null == totalOutputTokens
                ? _value.totalOutputTokens
                : totalOutputTokens // ignore: cast_nullable_to_non_nullable
                      as int,
            totalCost: null == totalCost
                ? _value.totalCost
                : totalCost // ignore: cast_nullable_to_non_nullable
                      as double,
            totalItems: null == totalItems
                ? _value.totalItems
                : totalItems // ignore: cast_nullable_to_non_nullable
                      as int,
            processedItems: null == processedItems
                ? _value.processedItems
                : processedItems // ignore: cast_nullable_to_non_nullable
                      as int,
            startedAt: freezed == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BatchStatsImplCopyWith<$Res>
    implements $BatchStatsCopyWith<$Res> {
  factory _$$BatchStatsImplCopyWith(
    _$BatchStatsImpl value,
    $Res Function(_$BatchStatsImpl) then,
  ) = __$$BatchStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int totalApiCalls,
    int completedApiCalls,
    int failedApiCalls,
    int totalInputTokens,
    int totalOutputTokens,
    double totalCost,
    int totalItems,
    int processedItems,
    DateTime? startedAt,
    DateTime? completedAt,
  });
}

/// @nodoc
class __$$BatchStatsImplCopyWithImpl<$Res>
    extends _$BatchStatsCopyWithImpl<$Res, _$BatchStatsImpl>
    implements _$$BatchStatsImplCopyWith<$Res> {
  __$$BatchStatsImplCopyWithImpl(
    _$BatchStatsImpl _value,
    $Res Function(_$BatchStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BatchStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalApiCalls = null,
    Object? completedApiCalls = null,
    Object? failedApiCalls = null,
    Object? totalInputTokens = null,
    Object? totalOutputTokens = null,
    Object? totalCost = null,
    Object? totalItems = null,
    Object? processedItems = null,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
  }) {
    return _then(
      _$BatchStatsImpl(
        totalApiCalls: null == totalApiCalls
            ? _value.totalApiCalls
            : totalApiCalls // ignore: cast_nullable_to_non_nullable
                  as int,
        completedApiCalls: null == completedApiCalls
            ? _value.completedApiCalls
            : completedApiCalls // ignore: cast_nullable_to_non_nullable
                  as int,
        failedApiCalls: null == failedApiCalls
            ? _value.failedApiCalls
            : failedApiCalls // ignore: cast_nullable_to_non_nullable
                  as int,
        totalInputTokens: null == totalInputTokens
            ? _value.totalInputTokens
            : totalInputTokens // ignore: cast_nullable_to_non_nullable
                  as int,
        totalOutputTokens: null == totalOutputTokens
            ? _value.totalOutputTokens
            : totalOutputTokens // ignore: cast_nullable_to_non_nullable
                  as int,
        totalCost: null == totalCost
            ? _value.totalCost
            : totalCost // ignore: cast_nullable_to_non_nullable
                  as double,
        totalItems: null == totalItems
            ? _value.totalItems
            : totalItems // ignore: cast_nullable_to_non_nullable
                  as int,
        processedItems: null == processedItems
            ? _value.processedItems
            : processedItems // ignore: cast_nullable_to_non_nullable
                  as int,
        startedAt: freezed == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BatchStatsImpl implements _BatchStats {
  const _$BatchStatsImpl({
    this.totalApiCalls = 0,
    this.completedApiCalls = 0,
    this.failedApiCalls = 0,
    this.totalInputTokens = 0,
    this.totalOutputTokens = 0,
    this.totalCost = 0.0,
    this.totalItems = 0,
    this.processedItems = 0,
    this.startedAt,
    this.completedAt,
  });

  factory _$BatchStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$BatchStatsImplFromJson(json);

  @override
  @JsonKey()
  final int totalApiCalls;
  @override
  @JsonKey()
  final int completedApiCalls;
  @override
  @JsonKey()
  final int failedApiCalls;
  @override
  @JsonKey()
  final int totalInputTokens;
  @override
  @JsonKey()
  final int totalOutputTokens;
  @override
  @JsonKey()
  final double totalCost;
  @override
  @JsonKey()
  final int totalItems;
  @override
  @JsonKey()
  final int processedItems;
  @override
  final DateTime? startedAt;
  @override
  final DateTime? completedAt;

  @override
  String toString() {
    return 'BatchStats(totalApiCalls: $totalApiCalls, completedApiCalls: $completedApiCalls, failedApiCalls: $failedApiCalls, totalInputTokens: $totalInputTokens, totalOutputTokens: $totalOutputTokens, totalCost: $totalCost, totalItems: $totalItems, processedItems: $processedItems, startedAt: $startedAt, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BatchStatsImpl &&
            (identical(other.totalApiCalls, totalApiCalls) ||
                other.totalApiCalls == totalApiCalls) &&
            (identical(other.completedApiCalls, completedApiCalls) ||
                other.completedApiCalls == completedApiCalls) &&
            (identical(other.failedApiCalls, failedApiCalls) ||
                other.failedApiCalls == failedApiCalls) &&
            (identical(other.totalInputTokens, totalInputTokens) ||
                other.totalInputTokens == totalInputTokens) &&
            (identical(other.totalOutputTokens, totalOutputTokens) ||
                other.totalOutputTokens == totalOutputTokens) &&
            (identical(other.totalCost, totalCost) ||
                other.totalCost == totalCost) &&
            (identical(other.totalItems, totalItems) ||
                other.totalItems == totalItems) &&
            (identical(other.processedItems, processedItems) ||
                other.processedItems == processedItems) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    totalApiCalls,
    completedApiCalls,
    failedApiCalls,
    totalInputTokens,
    totalOutputTokens,
    totalCost,
    totalItems,
    processedItems,
    startedAt,
    completedAt,
  );

  /// Create a copy of BatchStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BatchStatsImplCopyWith<_$BatchStatsImpl> get copyWith =>
      __$$BatchStatsImplCopyWithImpl<_$BatchStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BatchStatsImplToJson(this);
  }
}

abstract class _BatchStats implements BatchStats {
  const factory _BatchStats({
    final int totalApiCalls,
    final int completedApiCalls,
    final int failedApiCalls,
    final int totalInputTokens,
    final int totalOutputTokens,
    final double totalCost,
    final int totalItems,
    final int processedItems,
    final DateTime? startedAt,
    final DateTime? completedAt,
  }) = _$BatchStatsImpl;

  factory _BatchStats.fromJson(Map<String, dynamic> json) =
      _$BatchStatsImpl.fromJson;

  @override
  int get totalApiCalls;
  @override
  int get completedApiCalls;
  @override
  int get failedApiCalls;
  @override
  int get totalInputTokens;
  @override
  int get totalOutputTokens;
  @override
  double get totalCost;
  @override
  int get totalItems;
  @override
  int get processedItems;
  @override
  DateTime? get startedAt;
  @override
  DateTime? get completedAt;

  /// Create a copy of BatchStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BatchStatsImplCopyWith<_$BatchStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BatchProgress _$BatchProgressFromJson(Map<String, dynamic> json) {
  return _BatchProgress.fromJson(json);
}

/// @nodoc
mixin _$BatchProgress {
  int get currentRepetition => throw _privateConstructorUsedError;
  int get totalRepetitions => throw _privateConstructorUsedError;
  int get currentPromptIndex => throw _privateConstructorUsedError;
  int get totalPrompts => throw _privateConstructorUsedError;
  int get currentChunkIndex => throw _privateConstructorUsedError;
  int get totalChunks => throw _privateConstructorUsedError;
  int get callCounter => throw _privateConstructorUsedError;
  double get progressPercent => throw _privateConstructorUsedError;
  String? get currentModelId => throw _privateConstructorUsedError;
  String? get currentPromptName => throw _privateConstructorUsedError;

  /// Serializes this BatchProgress to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BatchProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BatchProgressCopyWith<BatchProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BatchProgressCopyWith<$Res> {
  factory $BatchProgressCopyWith(
    BatchProgress value,
    $Res Function(BatchProgress) then,
  ) = _$BatchProgressCopyWithImpl<$Res, BatchProgress>;
  @useResult
  $Res call({
    int currentRepetition,
    int totalRepetitions,
    int currentPromptIndex,
    int totalPrompts,
    int currentChunkIndex,
    int totalChunks,
    int callCounter,
    double progressPercent,
    String? currentModelId,
    String? currentPromptName,
  });
}

/// @nodoc
class _$BatchProgressCopyWithImpl<$Res, $Val extends BatchProgress>
    implements $BatchProgressCopyWith<$Res> {
  _$BatchProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BatchProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentRepetition = null,
    Object? totalRepetitions = null,
    Object? currentPromptIndex = null,
    Object? totalPrompts = null,
    Object? currentChunkIndex = null,
    Object? totalChunks = null,
    Object? callCounter = null,
    Object? progressPercent = null,
    Object? currentModelId = freezed,
    Object? currentPromptName = freezed,
  }) {
    return _then(
      _value.copyWith(
            currentRepetition: null == currentRepetition
                ? _value.currentRepetition
                : currentRepetition // ignore: cast_nullable_to_non_nullable
                      as int,
            totalRepetitions: null == totalRepetitions
                ? _value.totalRepetitions
                : totalRepetitions // ignore: cast_nullable_to_non_nullable
                      as int,
            currentPromptIndex: null == currentPromptIndex
                ? _value.currentPromptIndex
                : currentPromptIndex // ignore: cast_nullable_to_non_nullable
                      as int,
            totalPrompts: null == totalPrompts
                ? _value.totalPrompts
                : totalPrompts // ignore: cast_nullable_to_non_nullable
                      as int,
            currentChunkIndex: null == currentChunkIndex
                ? _value.currentChunkIndex
                : currentChunkIndex // ignore: cast_nullable_to_non_nullable
                      as int,
            totalChunks: null == totalChunks
                ? _value.totalChunks
                : totalChunks // ignore: cast_nullable_to_non_nullable
                      as int,
            callCounter: null == callCounter
                ? _value.callCounter
                : callCounter // ignore: cast_nullable_to_non_nullable
                      as int,
            progressPercent: null == progressPercent
                ? _value.progressPercent
                : progressPercent // ignore: cast_nullable_to_non_nullable
                      as double,
            currentModelId: freezed == currentModelId
                ? _value.currentModelId
                : currentModelId // ignore: cast_nullable_to_non_nullable
                      as String?,
            currentPromptName: freezed == currentPromptName
                ? _value.currentPromptName
                : currentPromptName // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BatchProgressImplCopyWith<$Res>
    implements $BatchProgressCopyWith<$Res> {
  factory _$$BatchProgressImplCopyWith(
    _$BatchProgressImpl value,
    $Res Function(_$BatchProgressImpl) then,
  ) = __$$BatchProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int currentRepetition,
    int totalRepetitions,
    int currentPromptIndex,
    int totalPrompts,
    int currentChunkIndex,
    int totalChunks,
    int callCounter,
    double progressPercent,
    String? currentModelId,
    String? currentPromptName,
  });
}

/// @nodoc
class __$$BatchProgressImplCopyWithImpl<$Res>
    extends _$BatchProgressCopyWithImpl<$Res, _$BatchProgressImpl>
    implements _$$BatchProgressImplCopyWith<$Res> {
  __$$BatchProgressImplCopyWithImpl(
    _$BatchProgressImpl _value,
    $Res Function(_$BatchProgressImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BatchProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentRepetition = null,
    Object? totalRepetitions = null,
    Object? currentPromptIndex = null,
    Object? totalPrompts = null,
    Object? currentChunkIndex = null,
    Object? totalChunks = null,
    Object? callCounter = null,
    Object? progressPercent = null,
    Object? currentModelId = freezed,
    Object? currentPromptName = freezed,
  }) {
    return _then(
      _$BatchProgressImpl(
        currentRepetition: null == currentRepetition
            ? _value.currentRepetition
            : currentRepetition // ignore: cast_nullable_to_non_nullable
                  as int,
        totalRepetitions: null == totalRepetitions
            ? _value.totalRepetitions
            : totalRepetitions // ignore: cast_nullable_to_non_nullable
                  as int,
        currentPromptIndex: null == currentPromptIndex
            ? _value.currentPromptIndex
            : currentPromptIndex // ignore: cast_nullable_to_non_nullable
                  as int,
        totalPrompts: null == totalPrompts
            ? _value.totalPrompts
            : totalPrompts // ignore: cast_nullable_to_non_nullable
                  as int,
        currentChunkIndex: null == currentChunkIndex
            ? _value.currentChunkIndex
            : currentChunkIndex // ignore: cast_nullable_to_non_nullable
                  as int,
        totalChunks: null == totalChunks
            ? _value.totalChunks
            : totalChunks // ignore: cast_nullable_to_non_nullable
                  as int,
        callCounter: null == callCounter
            ? _value.callCounter
            : callCounter // ignore: cast_nullable_to_non_nullable
                  as int,
        progressPercent: null == progressPercent
            ? _value.progressPercent
            : progressPercent // ignore: cast_nullable_to_non_nullable
                  as double,
        currentModelId: freezed == currentModelId
            ? _value.currentModelId
            : currentModelId // ignore: cast_nullable_to_non_nullable
                  as String?,
        currentPromptName: freezed == currentPromptName
            ? _value.currentPromptName
            : currentPromptName // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BatchProgressImpl implements _BatchProgress {
  const _$BatchProgressImpl({
    this.currentRepetition = 0,
    this.totalRepetitions = 0,
    this.currentPromptIndex = 0,
    this.totalPrompts = 0,
    this.currentChunkIndex = 0,
    this.totalChunks = 0,
    this.callCounter = 0,
    this.progressPercent = 0.0,
    this.currentModelId,
    this.currentPromptName,
  });

  factory _$BatchProgressImpl.fromJson(Map<String, dynamic> json) =>
      _$$BatchProgressImplFromJson(json);

  @override
  @JsonKey()
  final int currentRepetition;
  @override
  @JsonKey()
  final int totalRepetitions;
  @override
  @JsonKey()
  final int currentPromptIndex;
  @override
  @JsonKey()
  final int totalPrompts;
  @override
  @JsonKey()
  final int currentChunkIndex;
  @override
  @JsonKey()
  final int totalChunks;
  @override
  @JsonKey()
  final int callCounter;
  @override
  @JsonKey()
  final double progressPercent;
  @override
  final String? currentModelId;
  @override
  final String? currentPromptName;

  @override
  String toString() {
    return 'BatchProgress(currentRepetition: $currentRepetition, totalRepetitions: $totalRepetitions, currentPromptIndex: $currentPromptIndex, totalPrompts: $totalPrompts, currentChunkIndex: $currentChunkIndex, totalChunks: $totalChunks, callCounter: $callCounter, progressPercent: $progressPercent, currentModelId: $currentModelId, currentPromptName: $currentPromptName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BatchProgressImpl &&
            (identical(other.currentRepetition, currentRepetition) ||
                other.currentRepetition == currentRepetition) &&
            (identical(other.totalRepetitions, totalRepetitions) ||
                other.totalRepetitions == totalRepetitions) &&
            (identical(other.currentPromptIndex, currentPromptIndex) ||
                other.currentPromptIndex == currentPromptIndex) &&
            (identical(other.totalPrompts, totalPrompts) ||
                other.totalPrompts == totalPrompts) &&
            (identical(other.currentChunkIndex, currentChunkIndex) ||
                other.currentChunkIndex == currentChunkIndex) &&
            (identical(other.totalChunks, totalChunks) ||
                other.totalChunks == totalChunks) &&
            (identical(other.callCounter, callCounter) ||
                other.callCounter == callCounter) &&
            (identical(other.progressPercent, progressPercent) ||
                other.progressPercent == progressPercent) &&
            (identical(other.currentModelId, currentModelId) ||
                other.currentModelId == currentModelId) &&
            (identical(other.currentPromptName, currentPromptName) ||
                other.currentPromptName == currentPromptName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    currentRepetition,
    totalRepetitions,
    currentPromptIndex,
    totalPrompts,
    currentChunkIndex,
    totalChunks,
    callCounter,
    progressPercent,
    currentModelId,
    currentPromptName,
  );

  /// Create a copy of BatchProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BatchProgressImplCopyWith<_$BatchProgressImpl> get copyWith =>
      __$$BatchProgressImplCopyWithImpl<_$BatchProgressImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BatchProgressImplToJson(this);
  }
}

abstract class _BatchProgress implements BatchProgress {
  const factory _BatchProgress({
    final int currentRepetition,
    final int totalRepetitions,
    final int currentPromptIndex,
    final int totalPrompts,
    final int currentChunkIndex,
    final int totalChunks,
    final int callCounter,
    final double progressPercent,
    final String? currentModelId,
    final String? currentPromptName,
  }) = _$BatchProgressImpl;

  factory _BatchProgress.fromJson(Map<String, dynamic> json) =
      _$BatchProgressImpl.fromJson;

  @override
  int get currentRepetition;
  @override
  int get totalRepetitions;
  @override
  int get currentPromptIndex;
  @override
  int get totalPrompts;
  @override
  int get currentChunkIndex;
  @override
  int get totalChunks;
  @override
  int get callCounter;
  @override
  double get progressPercent;
  @override
  String? get currentModelId;
  @override
  String? get currentPromptName;

  /// Create a copy of BatchProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BatchProgressImplCopyWith<_$BatchProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
