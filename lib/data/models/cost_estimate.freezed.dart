// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cost_estimate.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CostEstimate _$CostEstimateFromJson(Map<String, dynamic> json) {
  return _CostEstimate.fromJson(json);
}

/// @nodoc
mixin _$CostEstimate {
  int get estimatedInputTokens => throw _privateConstructorUsedError;
  int get estimatedOutputTokens => throw _privateConstructorUsedError;
  int get estimatedApiCalls => throw _privateConstructorUsedError;
  double get estimatedCostUsd => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;

  /// Serializes this CostEstimate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CostEstimate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CostEstimateCopyWith<CostEstimate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CostEstimateCopyWith<$Res> {
  factory $CostEstimateCopyWith(
    CostEstimate value,
    $Res Function(CostEstimate) then,
  ) = _$CostEstimateCopyWithImpl<$Res, CostEstimate>;
  @useResult
  $Res call({
    int estimatedInputTokens,
    int estimatedOutputTokens,
    int estimatedApiCalls,
    double estimatedCostUsd,
    String currency,
  });
}

/// @nodoc
class _$CostEstimateCopyWithImpl<$Res, $Val extends CostEstimate>
    implements $CostEstimateCopyWith<$Res> {
  _$CostEstimateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CostEstimate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? estimatedInputTokens = null,
    Object? estimatedOutputTokens = null,
    Object? estimatedApiCalls = null,
    Object? estimatedCostUsd = null,
    Object? currency = null,
  }) {
    return _then(
      _value.copyWith(
            estimatedInputTokens: null == estimatedInputTokens
                ? _value.estimatedInputTokens
                : estimatedInputTokens // ignore: cast_nullable_to_non_nullable
                      as int,
            estimatedOutputTokens: null == estimatedOutputTokens
                ? _value.estimatedOutputTokens
                : estimatedOutputTokens // ignore: cast_nullable_to_non_nullable
                      as int,
            estimatedApiCalls: null == estimatedApiCalls
                ? _value.estimatedApiCalls
                : estimatedApiCalls // ignore: cast_nullable_to_non_nullable
                      as int,
            estimatedCostUsd: null == estimatedCostUsd
                ? _value.estimatedCostUsd
                : estimatedCostUsd // ignore: cast_nullable_to_non_nullable
                      as double,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CostEstimateImplCopyWith<$Res>
    implements $CostEstimateCopyWith<$Res> {
  factory _$$CostEstimateImplCopyWith(
    _$CostEstimateImpl value,
    $Res Function(_$CostEstimateImpl) then,
  ) = __$$CostEstimateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int estimatedInputTokens,
    int estimatedOutputTokens,
    int estimatedApiCalls,
    double estimatedCostUsd,
    String currency,
  });
}

/// @nodoc
class __$$CostEstimateImplCopyWithImpl<$Res>
    extends _$CostEstimateCopyWithImpl<$Res, _$CostEstimateImpl>
    implements _$$CostEstimateImplCopyWith<$Res> {
  __$$CostEstimateImplCopyWithImpl(
    _$CostEstimateImpl _value,
    $Res Function(_$CostEstimateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CostEstimate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? estimatedInputTokens = null,
    Object? estimatedOutputTokens = null,
    Object? estimatedApiCalls = null,
    Object? estimatedCostUsd = null,
    Object? currency = null,
  }) {
    return _then(
      _$CostEstimateImpl(
        estimatedInputTokens: null == estimatedInputTokens
            ? _value.estimatedInputTokens
            : estimatedInputTokens // ignore: cast_nullable_to_non_nullable
                  as int,
        estimatedOutputTokens: null == estimatedOutputTokens
            ? _value.estimatedOutputTokens
            : estimatedOutputTokens // ignore: cast_nullable_to_non_nullable
                  as int,
        estimatedApiCalls: null == estimatedApiCalls
            ? _value.estimatedApiCalls
            : estimatedApiCalls // ignore: cast_nullable_to_non_nullable
                  as int,
        estimatedCostUsd: null == estimatedCostUsd
            ? _value.estimatedCostUsd
            : estimatedCostUsd // ignore: cast_nullable_to_non_nullable
                  as double,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CostEstimateImpl implements _CostEstimate {
  const _$CostEstimateImpl({
    this.estimatedInputTokens = 0,
    this.estimatedOutputTokens = 0,
    this.estimatedApiCalls = 0,
    this.estimatedCostUsd = 0.0,
    this.currency = 'USD',
  });

  factory _$CostEstimateImpl.fromJson(Map<String, dynamic> json) =>
      _$$CostEstimateImplFromJson(json);

  @override
  @JsonKey()
  final int estimatedInputTokens;
  @override
  @JsonKey()
  final int estimatedOutputTokens;
  @override
  @JsonKey()
  final int estimatedApiCalls;
  @override
  @JsonKey()
  final double estimatedCostUsd;
  @override
  @JsonKey()
  final String currency;

  @override
  String toString() {
    return 'CostEstimate(estimatedInputTokens: $estimatedInputTokens, estimatedOutputTokens: $estimatedOutputTokens, estimatedApiCalls: $estimatedApiCalls, estimatedCostUsd: $estimatedCostUsd, currency: $currency)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CostEstimateImpl &&
            (identical(other.estimatedInputTokens, estimatedInputTokens) ||
                other.estimatedInputTokens == estimatedInputTokens) &&
            (identical(other.estimatedOutputTokens, estimatedOutputTokens) ||
                other.estimatedOutputTokens == estimatedOutputTokens) &&
            (identical(other.estimatedApiCalls, estimatedApiCalls) ||
                other.estimatedApiCalls == estimatedApiCalls) &&
            (identical(other.estimatedCostUsd, estimatedCostUsd) ||
                other.estimatedCostUsd == estimatedCostUsd) &&
            (identical(other.currency, currency) ||
                other.currency == currency));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    estimatedInputTokens,
    estimatedOutputTokens,
    estimatedApiCalls,
    estimatedCostUsd,
    currency,
  );

  /// Create a copy of CostEstimate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CostEstimateImplCopyWith<_$CostEstimateImpl> get copyWith =>
      __$$CostEstimateImplCopyWithImpl<_$CostEstimateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CostEstimateImplToJson(this);
  }
}

abstract class _CostEstimate implements CostEstimate {
  const factory _CostEstimate({
    final int estimatedInputTokens,
    final int estimatedOutputTokens,
    final int estimatedApiCalls,
    final double estimatedCostUsd,
    final String currency,
  }) = _$CostEstimateImpl;

  factory _CostEstimate.fromJson(Map<String, dynamic> json) =
      _$CostEstimateImpl.fromJson;

  @override
  int get estimatedInputTokens;
  @override
  int get estimatedOutputTokens;
  @override
  int get estimatedApiCalls;
  @override
  double get estimatedCostUsd;
  @override
  String get currency;

  /// Create a copy of CostEstimate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CostEstimateImplCopyWith<_$CostEstimateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TokenEstimate _$TokenEstimateFromJson(Map<String, dynamic> json) {
  return _TokenEstimate.fromJson(json);
}

/// @nodoc
mixin _$TokenEstimate {
  int get inputTokens => throw _privateConstructorUsedError;
  int get outputTokens => throw _privateConstructorUsedError;
  int get totalTokens => throw _privateConstructorUsedError;

  /// Serializes this TokenEstimate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TokenEstimate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TokenEstimateCopyWith<TokenEstimate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TokenEstimateCopyWith<$Res> {
  factory $TokenEstimateCopyWith(
    TokenEstimate value,
    $Res Function(TokenEstimate) then,
  ) = _$TokenEstimateCopyWithImpl<$Res, TokenEstimate>;
  @useResult
  $Res call({int inputTokens, int outputTokens, int totalTokens});
}

/// @nodoc
class _$TokenEstimateCopyWithImpl<$Res, $Val extends TokenEstimate>
    implements $TokenEstimateCopyWith<$Res> {
  _$TokenEstimateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TokenEstimate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? inputTokens = null,
    Object? outputTokens = null,
    Object? totalTokens = null,
  }) {
    return _then(
      _value.copyWith(
            inputTokens: null == inputTokens
                ? _value.inputTokens
                : inputTokens // ignore: cast_nullable_to_non_nullable
                      as int,
            outputTokens: null == outputTokens
                ? _value.outputTokens
                : outputTokens // ignore: cast_nullable_to_non_nullable
                      as int,
            totalTokens: null == totalTokens
                ? _value.totalTokens
                : totalTokens // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TokenEstimateImplCopyWith<$Res>
    implements $TokenEstimateCopyWith<$Res> {
  factory _$$TokenEstimateImplCopyWith(
    _$TokenEstimateImpl value,
    $Res Function(_$TokenEstimateImpl) then,
  ) = __$$TokenEstimateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int inputTokens, int outputTokens, int totalTokens});
}

/// @nodoc
class __$$TokenEstimateImplCopyWithImpl<$Res>
    extends _$TokenEstimateCopyWithImpl<$Res, _$TokenEstimateImpl>
    implements _$$TokenEstimateImplCopyWith<$Res> {
  __$$TokenEstimateImplCopyWithImpl(
    _$TokenEstimateImpl _value,
    $Res Function(_$TokenEstimateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TokenEstimate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? inputTokens = null,
    Object? outputTokens = null,
    Object? totalTokens = null,
  }) {
    return _then(
      _$TokenEstimateImpl(
        inputTokens: null == inputTokens
            ? _value.inputTokens
            : inputTokens // ignore: cast_nullable_to_non_nullable
                  as int,
        outputTokens: null == outputTokens
            ? _value.outputTokens
            : outputTokens // ignore: cast_nullable_to_non_nullable
                  as int,
        totalTokens: null == totalTokens
            ? _value.totalTokens
            : totalTokens // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TokenEstimateImpl implements _TokenEstimate {
  const _$TokenEstimateImpl({
    this.inputTokens = 0,
    this.outputTokens = 0,
    this.totalTokens = 0,
  });

  factory _$TokenEstimateImpl.fromJson(Map<String, dynamic> json) =>
      _$$TokenEstimateImplFromJson(json);

  @override
  @JsonKey()
  final int inputTokens;
  @override
  @JsonKey()
  final int outputTokens;
  @override
  @JsonKey()
  final int totalTokens;

  @override
  String toString() {
    return 'TokenEstimate(inputTokens: $inputTokens, outputTokens: $outputTokens, totalTokens: $totalTokens)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TokenEstimateImpl &&
            (identical(other.inputTokens, inputTokens) ||
                other.inputTokens == inputTokens) &&
            (identical(other.outputTokens, outputTokens) ||
                other.outputTokens == outputTokens) &&
            (identical(other.totalTokens, totalTokens) ||
                other.totalTokens == totalTokens));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, inputTokens, outputTokens, totalTokens);

  /// Create a copy of TokenEstimate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TokenEstimateImplCopyWith<_$TokenEstimateImpl> get copyWith =>
      __$$TokenEstimateImplCopyWithImpl<_$TokenEstimateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TokenEstimateImplToJson(this);
  }
}

abstract class _TokenEstimate implements TokenEstimate {
  const factory _TokenEstimate({
    final int inputTokens,
    final int outputTokens,
    final int totalTokens,
  }) = _$TokenEstimateImpl;

  factory _TokenEstimate.fromJson(Map<String, dynamic> json) =
      _$TokenEstimateImpl.fromJson;

  @override
  int get inputTokens;
  @override
  int get outputTokens;
  @override
  int get totalTokens;

  /// Create a copy of TokenEstimate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TokenEstimateImplCopyWith<_$TokenEstimateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
