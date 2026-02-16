import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../shared/widgets/prompt_selector.dart';
import '../../../shared/widgets/prompt_viewer.dart';

class StepPrompts extends StatelessWidget {
  const StepPrompts({
    super.key,
    required this.availablePrompts,
    required this.selectedPrompts,
    required this.onAddPrompt,
    required this.onRemovePromptAt,
    required this.onReorderSelected,
    this.onImportPrompts,
    required this.previewPromptName,
    required this.previewPromptContent,
    required this.onPreviewChanged,
    required this.warningText,
  });

  final List<String> availablePrompts;
  final List<String> selectedPrompts;
  final ValueChanged<String> onAddPrompt;
  final ValueChanged<int> onRemovePromptAt;
  final void Function(int oldIndex, int newIndex) onReorderSelected;
  final VoidCallback? onImportPrompts;
  final String? previewPromptName;
  final String previewPromptContent;
  final ValueChanged<String?> onPreviewChanged;
  final String? warningText;

  @override
  Widget build(BuildContext context) {
    final t = S.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (warningText != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(warningText!),
          ),
        const SizedBox(height: 12),
        PromptSelector(
          availablePrompts: availablePrompts,
          selectedPrompts: selectedPrompts,
          onAddPrompt: onAddPrompt,
          onRemovePromptAt: onRemovePromptAt,
          onReorderSelected: onReorderSelected,
          onImport: onImportPrompts,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: previewPromptName,
          decoration: InputDecoration(
            labelText: t.promptPreview,
            border: const OutlineInputBorder(),
          ),
          items: {
            ...selectedPrompts,
            ...availablePrompts,
          }.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
          onChanged: onPreviewChanged,
        ),
        const SizedBox(height: 8),
        PromptViewer(
          text: previewPromptContent,
          placeholder: AppConstants.itemPlaceholder,
        ),
      ],
    );
  }
}
