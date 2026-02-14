import 'package:flutter/material.dart';

import '../../../core/l10n/generated/app_localizations.dart';

class OpenProjectDialogResult {
  const OpenProjectDialogResult({required this.directory});

  final String directory;
}

class OpenProjectDialog extends StatefulWidget {
  const OpenProjectDialog({
    super.key,
    required this.onPickDirectory,
  });

  final Future<String?> Function() onPickDirectory;

  @override
  State<OpenProjectDialog> createState() => _OpenProjectDialogState();
}

class _OpenProjectDialogState extends State<OpenProjectDialog> {
  String? _selectedDirectory;
  String? _errorText;

  Future<void> _pickDirectory() async {
    final dir = await widget.onPickDirectory();
    if (dir == null) {
      return;
    }
    setState(() {
      _selectedDirectory = dir;
      _errorText = null;
    });
  }

  void _submit() {
    final t = S.of(context)!;
    final dir = _selectedDirectory;
    if (dir == null || dir.isEmpty) {
      setState(() {
        _errorText = t.projectOpenFolderHint;
      });
      return;
    }
    Navigator.of(context).pop(OpenProjectDialogResult(directory: dir));
  }

  @override
  Widget build(BuildContext context) {
    final t = S.of(context)!;
    return AlertDialog(
      title: Text(t.projectOpenTitle),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDirectory ?? t.projectNoFolderSelected,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: _pickDirectory,
                  child: Text(t.actionChooseFolder),
                ),
              ],
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorText!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.actionCancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(t.actionOpen),
        ),
      ],
    );
  }
}
