import 'package:flutter/material.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../data/models/log_entry.dart';

class LogViewer extends StatefulWidget {
  const LogViewer({
    super.key,
    required this.entries,
  });

  final List<LogEntry> entries;

  @override
  State<LogViewer> createState() => _LogViewerState();
}

class _LogViewerState extends State<LogViewer> {
  LogLevel? _filter;

  @override
  Widget build(BuildContext context) {
    final t = S.of(context)!;
    final visible = _filter == null
        ? widget.entries
        : widget.entries.where((e) => e.level == _filter).toList();

    return Column(
      children: [
        Row(
          children: [
            Text(t.logLevelLabel),
            const SizedBox(width: 8),
            DropdownButton<LogLevel?>(
              value: _filter,
              items: [
                DropdownMenuItem<LogLevel?>(value: null, child: Text(t.logLevelAll)),
                DropdownMenuItem<LogLevel?>(value: LogLevel.info, child: Text(t.logLevelInfo)),
                DropdownMenuItem<LogLevel?>(value: LogLevel.warn, child: Text(t.logLevelWarn)),
                DropdownMenuItem<LogLevel?>(value: LogLevel.error, child: Text(t.logLevelError)),
              ],
              onChanged: (value) => setState(() => _filter = value),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: visible.length,
            itemBuilder: (context, index) {
              final e = visible[index];
              final color = switch (e.level) {
                LogLevel.info => Colors.grey.shade700,
                LogLevel.warn => Colors.amber.shade800,
                LogLevel.error => Colors.red.shade700,
              };
              return ListTile(
                dense: true,
                leading: Text(e.level.name.toUpperCase(), style: TextStyle(color: color)),
                title: Text(e.message),
                subtitle: e.details == null ? null : Text(e.details!),
                trailing: Text(
                  '${e.timestamp.hour.toString().padLeft(2, '0')}:${e.timestamp.minute.toString().padLeft(2, '0')}:${e.timestamp.second.toString().padLeft(2, '0')}',
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
