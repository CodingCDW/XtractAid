import 'package:flutter/material.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../data/models/item.dart';
import '../../../shared/widgets/file_selector.dart';

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
    final t = S.of(context)!;
    final preview = parsedItems.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: Text(t.itemsExcelCsv),
              selected: inputType == 'excel',
              onSelected: (_) => onInputTypeChanged('excel'),
            ),
            ChoiceChip(
              label: Text(t.itemsDocFolder),
              selected: inputType == 'folder',
              onSelected: (_) => onInputTypeChanged('folder'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FileSelector(
          label: inputType == 'excel' ? t.itemsFileSource : t.itemsFolderSource,
          path: inputPath,
          onPick: inputType == 'excel' ? onPickFile : onPickFolder,
          pickButtonLabel: inputType == 'excel' ? t.actionChooseFile : t.actionChooseFolder,
          onLoad: onParse,
          loadButtonLabel: t.actionLoad,
          isLoading: isParsing,
        ),
        if (inputType == 'excel') ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: idColumn,
                  decoration: InputDecoration(
                    labelText: t.itemsIdColumn,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: onIdColumnChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  initialValue: itemColumn,
                  decoration: InputDecoration(
                    labelText: t.itemsItemColumn,
                    border: const OutlineInputBorder(),
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
        Text('${t.itemsSummary} ${t.itemsCount(parsedItems.length, warnings.length)}'),
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
                  columns: [
                  DataColumn(label: Text(t.itemsIdLabel)),
                  DataColumn(label: Text(t.itemsPreviewText)),
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
