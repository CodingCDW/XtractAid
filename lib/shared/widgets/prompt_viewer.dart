import 'package:flutter/material.dart';

class PromptViewer extends StatelessWidget {
  const PromptViewer({
    super.key,
    required this.text,
    required this.placeholder,
  });

  final String text;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.textTheme.bodyMedium ?? const TextStyle();
    final highlight = base.copyWith(
      color: Colors.blue.shade700,
      fontWeight: FontWeight.bold,
    );

    final spans = <InlineSpan>[];
    if (text.isEmpty) {
      spans.add(TextSpan(text: '-', style: base));
    } else {
      var start = 0;
      while (true) {
        final idx = text.indexOf(placeholder, start);
        if (idx < 0) {
          spans.add(TextSpan(text: text.substring(start), style: base));
          break;
        }
        if (idx > start) {
          spans.add(TextSpan(text: text.substring(start, idx), style: base));
        }
        spans.add(TextSpan(text: placeholder, style: highlight));
        start = idx + placeholder.length;
      }
    }

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 120),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SelectableText.rich(TextSpan(children: spans)),
    );
  }
}
