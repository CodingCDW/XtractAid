import 'package:flutter/material.dart';

class PromptSelector extends StatelessWidget {
  const PromptSelector({
    super.key,
    required this.availablePrompts,
    required this.selectedPrompts,
    required this.onAddPrompt,
    required this.onRemovePrompt,
    required this.onReorderSelected,
  });

  final List<String> availablePrompts;
  final List<String> selectedPrompts;
  final ValueChanged<String> onAddPrompt;
  final ValueChanged<String> onRemovePrompt;
  final void Function(int oldIndex, int newIndex) onReorderSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _PromptList(
            title: 'Verfuegbar',
            prompts: availablePrompts,
            onTap: onAddPrompt,
            icon: Icons.arrow_forward,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SelectedPromptList(
            prompts: selectedPrompts,
            onTap: onRemovePrompt,
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
  });

  final String title;
  final List<String> prompts;
  final ValueChanged<String> onTap;
  final IconData icon;

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
    required this.prompts,
    required this.onTap,
    required this.onReorder,
  });

  final List<String> prompts;
  final ValueChanged<String> onTap;
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
          Text('Ausgewaehlt', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Expanded(
            child: ReorderableListView.builder(
              itemCount: prompts.length,
              onReorder: onReorder,
              itemBuilder: (context, index) {
                final prompt = prompts[index];
                return ListTile(
                  key: ValueKey(prompt),
                  dense: true,
                  title: Text(prompt),
                  trailing: const Icon(Icons.arrow_back),
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
