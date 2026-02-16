import 'package:flutter/material.dart';

import '../../core/l10n/generated/app_localizations.dart';

class PromptSelector extends StatelessWidget {
  const PromptSelector({
    super.key,
    required this.availablePrompts,
    required this.selectedPrompts,
    required this.onAddPrompt,
    required this.onRemovePromptAt,
    required this.onReorderSelected,
    this.onImport,
  });

  final List<String> availablePrompts;
  final List<String> selectedPrompts;
  final ValueChanged<String> onAddPrompt;
  final ValueChanged<int> onRemovePromptAt;
  final void Function(int oldIndex, int newIndex) onReorderSelected;
  final VoidCallback? onImport;

  @override
  Widget build(BuildContext context) {
    final t = S.of(context)!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _PromptList(
            title: t.promptSelectorAvailable,
            prompts: availablePrompts,
            onTap: onAddPrompt,
            icon: Icons.arrow_forward,
            onImport: onImport,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SelectedPromptList(
            title: t.promptSelectorSelected,
            prompts: selectedPrompts,
            onTapIndex: onRemovePromptAt,
            onReorder: onReorderSelected,
          ),
        ),
      ],
    );
  }
}

class _PromptList extends StatelessWidget {
  const _PromptList({
    required this.title,
    required this.prompts,
    required this.onTap,
    required this.icon,
    this.onImport,
  });

  final String title;
  final List<String> prompts;
  final ValueChanged<String> onTap;
  final IconData icon;
  final VoidCallback? onImport;

  @override
  Widget build(BuildContext context) {
    final t = S.of(context)!;
    return Container(
      height: 220,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              const Spacer(),
              if (onImport != null)
                TextButton.icon(
                  onPressed: onImport,
                  icon: const Icon(Icons.file_open, size: 16),
                  label: Text(t.promptImport),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: prompts.length,
              itemBuilder: (context, index) {
                final prompt = prompts[index];
                return ListTile(
                  dense: true,
                  title: Text(prompt),
                  trailing: Icon(icon),
                  onTap: () => onTap(prompt),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedPromptList extends StatelessWidget {
  const _SelectedPromptList({
    required this.title,
    required this.prompts,
    required this.onTapIndex,
    required this.onReorder,
  });

  final String title;
  final List<String> prompts;
  final ValueChanged<int> onTapIndex;
  final void Function(int oldIndex, int newIndex) onReorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Expanded(
            child: ReorderableListView.builder(
              itemCount: prompts.length,
              onReorder: onReorder,
              itemBuilder: (context, index) {
                final prompt = prompts[index];
                return ListTile(
                  key: ValueKey('selected_prompt_$index:$prompt'),
                  dense: true,
                  title: Text(prompt),
                  trailing: const Icon(Icons.arrow_back),
                  onTap: () => onTapIndex(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
