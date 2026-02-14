import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/prompt_selector.dart';
import '../../../shared/widgets/prompt_viewer.dart';

class StepPrompts extends StatelessWidget {
  const StepPrompts({
    super.key,
    required this.availablePrompts,
    required this.selectedPrompts,
    required this.onAddPrompt,
    required this.onRemovePrompt,
    required this.onReorderSelected,
    required this.previewPromptName,
    required this.previewPromptContent,
    required this.onPreviewChanged,
    required this.warningText,
  });

  final List<String> availablePrompts;
  final List<String> selectedPrompts;
  final ValueChanged<String> onAddPrompt;
  final ValueChanged<String> onRemovePrompt;
  final void Function(int oldIndex, int newIndex) onReorderSelected;
  final String? previewPromptName;
  final String previewPromptContent;
  final ValueChanged<String?> onPreviewChanged;
  final String? warningText;

  @override
  Widget build(BuildContext context) {
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
          onRemovePrompt: onRemovePrompt,
          onReorderSelected: onReorderSelected,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: previewPromptName,
          decoration: const InputDecoration(
            labelText: 'Prompt-Vorschau',
            border: OutlineInputBorder(),
          ),
          items: {...selectedPrompts, ...availablePrompts}
              .map((p) => DropdownMenuItem(value: p, child: Text(p)))
              .toList(),
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
