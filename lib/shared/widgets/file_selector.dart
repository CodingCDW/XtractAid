import 'package:flutter/material.dart';

class FileSelector extends StatelessWidget {
  const FileSelector({
    super.key,
    required this.label,
    required this.path,
    required this.onPick,
    this.pickButtonLabel = 'Waehlen',
    this.onLoad,
    this.loadButtonLabel = 'Laden',
    this.isLoading = false,
  });

  final String label;
  final String? path;
  final VoidCallback onPick;
  final String pickButtonLabel;
  final VoidCallback? onLoad;
  final String loadButtonLabel;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                path ?? 'Keine Quelle gewaehlt',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(onPressed: onPick, child: Text(pickButtonLabel)),
            if (onLoad != null) ...[
              const SizedBox(width: 8),
              FilledButton(
                onPressed: isLoading ? null : onLoad,
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(loadButtonLabel),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
