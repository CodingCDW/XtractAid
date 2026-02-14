import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';

import '../core/constants/app_constants.dart';
import '../data/models/item.dart';

final _log = Logger('PromptService');

/// Manages prompt templates: loading, validation, and item injection.
class PromptService {
  /// Load all prompt files (.txt, .md) from a directory.
  Future<Map<String, String>> loadPrompts(String promptsDir) async {
    final dir = Directory(promptsDir);
    if (!dir.existsSync()) {
      _log.warning('Prompts directory does not exist: $promptsDir');
      return {};
    }

    final prompts = <String, String>{};
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) {
          final ext = f.path.toLowerCase();
          return ext.endsWith('.txt') || ext.endsWith('.md');
        });

    for (final file in files) {
      try {
        final content = await file.readAsString(encoding: utf8);
        final name = file.uri.pathSegments.last;
        prompts[name] = content;
      } catch (e) {
        _log.warning('Failed to read prompt file ${file.path}: $e');
      }
    }

    _log.info('Loaded ${prompts.length} prompt(s) from $promptsDir');
    return prompts;
  }

  /// Check if a prompt template contains the item placeholder.
  bool hasPlaceholder(String promptText) {
    return promptText.contains(AppConstants.itemPlaceholder);
  }

  /// Inject items into a prompt template, replacing the placeholder.
  ///
  /// Items are formatted as JSON-LD lines:
  /// ```
  /// {"ID": "P001", "Item": "Patient report text..."}
  /// {"ID": "P002", "Item": "Another text..."}
  /// ```
  String injectItems(String promptTemplate, List<Item> items) {
    final itemLines = items.map((item) {
      return json.encode({'ID': item.id, 'Item': item.text});
    }).join('\n');

    if (hasPlaceholder(promptTemplate)) {
      return promptTemplate.replaceAll(
        AppConstants.itemPlaceholder,
        itemLines,
      );
    }

    // If no placeholder, append items at the end
    _log.warning('Prompt has no placeholder. Appending items at the end.');
    return '$promptTemplate\n\n$itemLines';
  }

  /// Validate a prompt template.
  List<String> validatePrompt(String promptText) {
    final warnings = <String>[];

    if (promptText.trim().isEmpty) {
      warnings.add('Prompt is empty.');
    }

    if (!hasPlaceholder(promptText)) {
      warnings.add(
        'Prompt does not contain the placeholder "${AppConstants.itemPlaceholder}". '
        'Items will be appended at the end.',
      );
    }

    if (promptText.length > 50000) {
      warnings.add(
        'Prompt is very long (${promptText.length} characters). '
        'This may use excessive tokens.',
      );
    }

    return warnings;
  }

  /// Split items into chunks of the given size.
  List<List<Item>> createChunks(List<Item> items, int chunkSize) {
    final chunks = <List<Item>>[];
    for (var i = 0; i < items.length; i += chunkSize) {
      final end = (i + chunkSize < items.length) ? i + chunkSize : items.length;
      chunks.add(items.sublist(i, end));
    }
    return chunks;
  }
}
