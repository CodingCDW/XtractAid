import 'package:freezed_annotation/freezed_annotation.dart';

part 'log_entry.freezed.dart';
part 'log_entry.g.dart';

enum LogLevel { info, warn, error }

@freezed
class LogEntry with _$LogEntry {
  const factory LogEntry({
    required LogLevel level,
    required String message,
    String? details,
    required DateTime timestamp,
  }) = _LogEntry;

  factory LogEntry.fromJson(Map<String, dynamic> json) =>
      _$LogEntryFromJson(json);
}
