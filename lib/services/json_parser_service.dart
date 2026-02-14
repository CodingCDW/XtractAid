import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';

final _log = Logger('JsonParserService');

/// Multi-fallback JSON parser for LLM responses.
///
/// Parsing chain:
/// 1. Direct json.decode()
/// 2. Remove markdown code fences
/// 3. Remove `<think>` tags (text after last `</think>`)
/// 4. Regex for JSON array containing "ID"
/// 5. Collect individual JSON objects with "ID"
/// 6. Fail -> null + debug file
class JsonParserService {
  /// Parse an LLM response string into a list of JSON objects.
  ///
  /// Returns null if all parsing strategies fail.
  /// If [debugDir] is provided, failed responses are saved there.
  List<Map<String, dynamic>>? parseResponse(
    String response, {
    String? debugDir,
  }) {
    // Strategy 1: Direct parse
    var result = _tryDirectParse(response);
    if (result != null) return result;

    // Strategy 2: Remove markdown code fences
    result = _tryRemoveCodeFences(response);
    if (result != null) return result;

    // Strategy 3: Remove <think> tags
    result = _tryRemoveThinkTags(response);
    if (result != null) return result;

    // Strategy 4: Regex for JSON array with "ID"
    result = _tryRegexArray(response);
    if (result != null) return result;

    // Strategy 5: Collect individual JSON objects
    result = _tryCollectObjects(response);
    if (result != null) return result;

    // Strategy 6: Failed – save debug file
    _log.warning('All JSON parsing strategies failed.');
    if (debugDir != null) {
      _saveDebugFile(response, debugDir);
    }
    return null;
  }

  /// Strategy 1: Direct json.decode.
  List<Map<String, dynamic>>? _tryDirectParse(String text) {
    try {
      final decoded = json.decode(text.trim());
      return _normalizeToList(decoded);
    } catch (_) {
      return null;
    }
  }

  /// Strategy 2: Remove markdown code fences and parse.
  List<Map<String, dynamic>>? _tryRemoveCodeFences(String text) {
    final regex = RegExp(r'```(?:json)?\s*\n?([\s\S]*?)\n?\s*```');
    final match = regex.firstMatch(text);
    if (match == null) return null;

    try {
      final decoded = json.decode(match.group(1)!.trim());
      return _normalizeToList(decoded);
    } catch (_) {
      return null;
    }
  }

  /// Strategy 3: Remove `<think>` tags and parse text after last `</think>`.
  List<Map<String, dynamic>>? _tryRemoveThinkTags(String text) {
    final thinkEndIdx = text.lastIndexOf('</think>');
    if (thinkEndIdx == -1) return null;

    final afterThink = text.substring(thinkEndIdx + '</think>'.length).trim();
    if (afterThink.isEmpty) return null;

    // Try direct parse on remaining text
    var result = _tryDirectParse(afterThink);
    if (result != null) return result;

    // Try removing code fences from remaining text
    result = _tryRemoveCodeFences(afterThink);
    if (result != null) return result;

    return null;
  }

  /// Strategy 4: Regex for JSON array containing "ID".
  List<Map<String, dynamic>>? _tryRegexArray(String text) {
    final regex = RegExp(r'\[\s*\{[^}]*?"ID"[^}]*?\}(?:\s*,\s*\{[^}]*?"ID"[^}]*?\})*\s*\]');
    final match = regex.firstMatch(text);
    if (match == null) return null;

    try {
      final decoded = json.decode(match.group(0)!);
      return _normalizeToList(decoded);
    } catch (_) {
      return null;
    }
  }

  /// Strategy 5: Collect individual JSON objects containing "ID".
  List<Map<String, dynamic>>? _tryCollectObjects(String text) {
    final regex = RegExp(r'\{[^{}]*?"ID"\s*:\s*"[^"]*"[^{}]*\}');
    final matches = regex.allMatches(text);
    if (matches.isEmpty) return null;

    final results = <Map<String, dynamic>>[];
    for (final match in matches) {
      try {
        final decoded = json.decode(match.group(0)!) as Map<String, dynamic>;
        results.add(decoded);
      } catch (_) {
        // Skip unparseable objects
      }
    }

    return results.isNotEmpty ? results : null;
  }

  /// Normalize decoded JSON to a list of maps.
  List<Map<String, dynamic>>? _normalizeToList(dynamic decoded) {
    if (decoded is List) {
      return decoded
          .whereType<Map<String, dynamic>>()
          .toList();
    }
    if (decoded is Map<String, dynamic>) {
      return [decoded];
    }
    return null;
  }

  /// Save a failed response to a debug file.
  void _saveDebugFile(String response, String debugDir) {
    try {
      final dir = Directory(debugDir);
      if (!dir.existsSync()) dir.createSync(recursive: true);

      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final file = File('${dir.path}/failed_response_$timestamp.txt');
      file.writeAsStringSync(response);
      _log.info('Saved failed response to: ${file.path}');
    } catch (e) {
      _log.warning('Failed to save debug file: $e');
    }
  }
}
