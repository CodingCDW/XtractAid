// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LogEntryImpl _$$LogEntryImplFromJson(Map<String, dynamic> json) =>
    _$LogEntryImpl(
      level: $enumDecode(_$LogLevelEnumMap, json['level']),
      message: json['message'] as String,
      details: json['details'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$$LogEntryImplToJson(_$LogEntryImpl instance) =>
    <String, dynamic>{
      'level': _$LogLevelEnumMap[instance.level]!,
      'message': instance.message,
      'details': instance.details,
      'timestamp': instance.timestamp.toIso8601String(),
    };

const _$LogLevelEnumMap = {
  LogLevel.info: 'info',
  LogLevel.warn: 'warn',
  LogLevel.error: 'error',
};
