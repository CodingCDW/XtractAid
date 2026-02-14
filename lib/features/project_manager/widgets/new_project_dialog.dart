import 'package:flutter/material.dart';

import '../../../core/l10n/generated/app_localizations.dart';

class NewProjectDialogResult {
  const NewProjectDialogResult({
    required this.name,
    required this.baseDirectory,
  });

  final String name;
  final String baseDirectory;
}

class NewProjectDialog extends StatefulWidget {
  const NewProjectDialog({
    super.key,
    required this.onPickDirectory,
  });

  final Future<String?> Function() onPickDirectory;

  @override
  State<NewProjectDialog> createState() => _NewProjectDialogState();
}

class _NewProjectDialogState extends State<NewProjectDialog> {
  final _nameController = TextEditingController();
  String? _selectedDirectory;
  String? _errorText;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDirectory() async {
    final dir = await widget.onPickDirectory();
    if (dir == null) {
      return;
    }
    setState(() {
      _selectedDirectory = dir;
    });
  }

  void _submit() {
    final t = S.of(context)!;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _errorText = t.projectCreateNameHint;
      });
      return;
    }
    final baseDir = _selectedDirectory;
    if (baseDir == null || baseDir.isEmpty) {
      setState(() {
        _errorText = t.projectCreateFolderHint;
      });
      return;
    }

    Navigator.of(context).pop(
      NewProjectDialogResult(name: name, baseDirectory: baseDir),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = S.of(context)!;
    return AlertDialog(
      title: Text(t.projectCreateTitle),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: t.labelProjectName,
              ),
            ),
            const SizedBox(height: 12),
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
          child: Text(t.actionCreate),
        ),
      ],
    );
  }
}
