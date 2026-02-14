import 'package:flutter/material.dart';

import '../../../data/models/item.dart';

class StepItems extends StatelessWidget {
  const StepItems({
    super.key,
    required this.inputType,
    required this.inputPath,
    required this.idColumn,
    required this.itemColumn,
    required this.onInputTypeChanged,
    required this.onPickFile,
    required this.onPickFolder,
    required this.onParse,
    required this.onIdColumnChanged,
    required this.onItemColumnChanged,
    required this.isParsing,
    required this.parsedItems,
    required this.warnings,
    required this.progressText,
  });

  final String inputType;
  final String? inputPath;
  final String idColumn;
  final String itemColumn;
  final ValueChanged<String> onInputTypeChanged;
  final VoidCallback onPickFile;
  final VoidCallback onPickFolder;
  final VoidCallback onParse;
  final ValueChanged<String> onIdColumnChanged;
  final ValueChanged<String> onItemColumnChanged;
  final bool isParsing;
  final List<Item> parsedItems;
  final List<String> warnings;
  final String? progressText;

  @override
  Widget build(BuildContext context) {
    final preview = parsedItems.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Excel/CSV'),
              selected: inputType == 'excel',
              onSelected: (_) => onInputTypeChanged('excel'),
            ),
            ChoiceChip(
              label: const Text('Dokumenten-Ordner'),
              selected: inputType == 'folder',
              onSelected: (_) => onInputTypeChanged('folder'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                inputPath ?? 'Keine Quelle gewaehlt',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: inputType == 'excel' ? onPickFile : onPickFolder,
              child: Text(inputType == 'excel' ? 'Datei waehlen' : 'Ordner waehlen'),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: isParsing ? null : onParse,
              child: isParsing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Laden'),
            ),
          ],
        ),
        if (inputType == 'excel') ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: idColumn,
                  decoration: const InputDecoration(
                    labelText: 'ID-Spalte',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: onIdColumnChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  initialValue: itemColumn,
                  decoration: const InputDecoration(
                    labelText: 'Item-Spalte',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: onItemColumnChanged,
                ),
              ),
            ],
          ),
        ],
        if (progressText != null) ...[
          const SizedBox(height: 12),
          Text(progressText!),
        ],
        const SizedBox(height: 12),
        Text('Zusammenfassung: ${parsedItems.length} Items, ${warnings.length} Warnungen'),
        if (warnings.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: warnings.map((w) => Text('- $w')).toList(),
            ),
          ),
        ],
        const SizedBox(height: 12),
        if (preview.isNotEmpty)
          SizedBox(
            height: 260,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Text (Vorschau)')),
                ],
                rows: preview
                    .map(
                      (item) => DataRow(
                        cells: [
                          DataCell(Text(item.id)),
                          DataCell(
                            SizedBox(
                              width: 520,
                              child: Text(
                                item.text.length > 200
                                    ? '${item.text.substring(0, 200)}...'
                                    : item.text,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
      ],
    );
  }
}
