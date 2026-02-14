import 'package:flutter/material.dart';

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
    final visible = _filter == null
        ? widget.entries
        : widget.entries.where((e) => e.level == _filter).toList();

    return Column(
      children: [
        Row(
          children: [
            const Text('Level:'),
            const SizedBox(width: 8),
            DropdownButton<LogLevel?>(
              value: _filter,
              items: const [
                DropdownMenuItem<LogLevel?>(value: null, child: Text('Alle')),
                DropdownMenuItem<LogLevel?>(value: LogLevel.info, child: Text('INFO')),
                DropdownMenuItem<LogLevel?>(value: LogLevel.warn, child: Text('WARN')),
                DropdownMenuItem<LogLevel?>(value: LogLevel.error, child: Text('ERROR')),
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
