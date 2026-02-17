import 'dart:convert';
import 'dart:io';

import 'package:excel/excel.dart' as xls;
import 'package:path/path.dart' as p;

import '../core/utils/batch_helpers.dart';
import '../data/models/batch_config.dart';
import '../data/models/batch_stats.dart';
import '../data/models/log_entry.dart';

class GeneratedReports {
  const GeneratedReports({
    required this.excelPath,
    required this.markdownPath,
    required this.htmlPath,
  });

  final String excelPath;
  final String markdownPath;
  final String htmlPath;
}

class ReportGeneratorService {
  Future<GeneratedReports> generateReports({
    required String projectPath,
    required String batchId,
    required BatchConfig config,
    required BatchStats stats,
    required List<Map<String, dynamic>> results,
    required List<LogEntry> logs,
    required Map<String, String> promptContents,
    double inputPricePerMillion = 0.0,
    double outputPricePerMillion = 0.0,
  }) async {
    final runAt = stats.startedAt ?? DateTime.now();
    final outputDir = _resolveAvailableOutputDir(
      Directory(
        _outputDir(
          projectPath,
          batchId: batchId,
          batchName: config.name,
          runAt: runAt,
        ),
      ),
    );
    if (!outputDir.existsSync()) {
      outputDir.createSync(recursive: true);
    }

    final mergedResults = _mergeResultsByItemId(results);

    try {
      final excelPath = await _generateExcel(outputDir.path, mergedResults);
      final markdownPath = await _generateMarkdown(
        outputDir.path,
        config: config,
        stats: stats,
        logs: logs,
        promptContents: promptContents,
        inputPricePerMillion: inputPricePerMillion,
        outputPricePerMillion: outputPricePerMillion,
      );
      final htmlPath = await _generateHtml(
        outputDir.path,
        config: config,
        stats: stats,
        results: mergedResults,
        logs: logs,
      );

      return GeneratedReports(
        excelPath: excelPath,
        markdownPath: markdownPath,
        htmlPath: htmlPath,
      );
    } on FileSystemException catch (e) {
      throw Exception(
        'Failed to write report files to ${outputDir.path}: ${e.message}',
      );
    }
  }

  String _outputDir(
    String projectPath, {
    required String batchId,
    required String batchName,
    required DateTime runAt,
  }) {
    final folderName = generateBatchRunFolderName(
      batchName: batchName,
      batchId: batchId,
      runAt: runAt,
    );
    return p.join(projectPath, 'results', folderName);
  }

  Directory _resolveAvailableOutputDir(Directory desiredDir) {
    if (!desiredDir.existsSync()) {
      return desiredDir;
    }

    var suffix = 2;
    while (true) {
      final candidate = Directory('${desiredDir.path}_$suffix');
      if (!candidate.existsSync()) {
        return candidate;
      }
      suffix++;
    }
  }

  Future<String> _generateExcel(
    String outputDir,
    List<Map<String, dynamic>> results,
  ) async {
    final workbook = xls.Excel.createExcel();
    final sheet = workbook['results'];

    final headers = _collectHeaders(results);
    if (headers.isNotEmpty) {
      sheet.appendRow(
        headers.map((h) => xls.TextCellValue(h)).toList(growable: false),
      );
    }

    for (final result in results) {
      final row = headers
          .map((key) => xls.TextCellValue(_stringify(result[key])))
          .toList(growable: false);
      sheet.appendRow(row);
    }

    final bytes = workbook.encode();
    if (bytes == null) {
      throw StateError('Excel encoding failed.');
    }

    final path = p.join(outputDir, 'results.xlsx');
    final file = File(path);
    await file.writeAsBytes(bytes, flush: true);
    return path;
  }

  Future<String> _generateMarkdown(
    String outputDir, {
    required BatchConfig config,
    required BatchStats stats,
    required List<LogEntry> logs,
    required Map<String, String> promptContents,
    double inputPricePerMillion = 0.0,
    double outputPricePerMillion = 0.0,
  }) async {
    final errors = logs.where((e) => e.level == LogLevel.error).toList();
    final warnings = logs.where((e) => e.level == LogLevel.warn).toList();
    final started = stats.startedAt?.toIso8601String() ?? '-';
    final completed = stats.completedAt?.toIso8601String() ?? '-';
    final duration = (stats.startedAt != null && stats.completedAt != null)
        ? stats.completedAt!.difference(stats.startedAt!).toString()
        : '-';

    final buffer = StringBuffer()
      ..writeln('# XtractAid Batch Report')
      ..writeln()
      ..writeln('## Session')
      ..writeln('- Batch ID: `${config.batchId}`')
      ..writeln('- Name: ${config.name}')
      ..writeln('- Started: $started')
      ..writeln('- Completed: $completed')
      ..writeln('- Duration: $duration')
      ..writeln()
      ..writeln('## Configuration')
      ..writeln('- Input: ${config.input.type} (${config.input.path})')
      ..writeln('- Chunk size: ${config.chunkSettings.chunkSize}')
      ..writeln('- Repetitions: ${config.chunkSettings.repetitions}')
      ..writeln('- Prompts: ${config.promptFiles.join(', ')}')
      ..writeln(
        '- Models: ${config.models.map((m) => '${m.providerId}:${m.modelId}').join(', ')}',
      )
      ..writeln()
      ..writeln('## Token Stats')
      ..writeln('- Input tokens: ${stats.totalInputTokens}')
      ..writeln('- Output tokens: ${stats.totalOutputTokens}')
      ..writeln(
        '- Total tokens: ${stats.totalInputTokens + stats.totalOutputTokens}',
      )
      ..writeln()
      ..writeln('## Cost')
      ..writeln('- Total cost (USD): ${stats.totalCost.toStringAsFixed(6)}');
    if (inputPricePerMillion > 0 || outputPricePerMillion > 0) {
      final inputCost =
          stats.totalInputTokens * inputPricePerMillion / 1000000.0;
      final outputCost =
          stats.totalOutputTokens * outputPricePerMillion / 1000000.0;
      buffer
        ..writeln(
          '- Model: ${config.models.map((m) => '${m.providerId}:${m.modelId}').join(', ')}',
        )
        ..writeln(
          '- Input pricing: \$${inputPricePerMillion.toStringAsFixed(2)} / 1M tokens',
        )
        ..writeln(
          '- Output pricing: \$${outputPricePerMillion.toStringAsFixed(2)} / 1M tokens',
        )
        ..writeln(
          '- Input cost: ${stats.totalInputTokens} tokens × \$${inputPricePerMillion.toStringAsFixed(2)}/1M = \$${inputCost.toStringAsFixed(6)}',
        )
        ..writeln(
          '- Output cost: ${stats.totalOutputTokens} tokens × \$${outputPricePerMillion.toStringAsFixed(2)}/1M = \$${outputCost.toStringAsFixed(6)}',
        );
    }
    buffer
      ..writeln()
      ..writeln('## Errors')
      ..writeln('- Count: ${errors.length}')
      ..writeln('- Warnings: ${warnings.length}')
      ..writeln();

    if (errors.isNotEmpty) {
      buffer
        ..writeln('| Time | Message | Details |')
        ..writeln('|---|---|---|');
      for (final e in errors) {
        buffer.writeln(
          '| ${e.timestamp.toIso8601String()} | ${_escapeMd(e.message)} | ${_escapeMd(e.details ?? '')} |',
        );
      }
      buffer.writeln();
    }

    buffer.writeln('## Prompts');
    if (promptContents.isEmpty) {
      buffer.writeln('- No prompts available.');
    } else {
      for (final entry in promptContents.entries) {
        buffer
          ..writeln()
          ..writeln('### ${entry.key}')
          ..writeln('```text')
          ..writeln(entry.value)
          ..writeln('```');
      }
    }

    final path = p.join(outputDir, 'session_log.md');
    await File(path).writeAsString(buffer.toString(), flush: true);
    return path;
  }

  Future<String> _generateHtml(
    String outputDir, {
    required BatchConfig config,
    required BatchStats stats,
    required List<Map<String, dynamic>> results,
    required List<LogEntry> logs,
  }) async {
    final errorCount = logs.where((e) => e.level == LogLevel.error).length;
    final successCalls = stats.completedApiCalls - stats.failedApiCalls;
    final successRate = stats.completedApiCalls == 0
        ? 0
        : (successCalls / stats.completedApiCalls) * 100;

    final itemsHtml = results
        .map((map) {
          final itemId = map['ID']?.toString() ?? 'Item';
          final fields = map.entries
              .map(
                (e) =>
                    '<dt>${_escapeHtml(e.key)}</dt><dd>${_formatHtmlValue(e.value)}</dd>',
              )
              .join();
          return '<section class="item"><h3>${_escapeHtml(itemId)}</h3><dl>$fields</dl></section>';
        })
        .join('\n');

    final html =
        '''
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>XtractAid Report ${_escapeHtml(config.batchId)}</title>
  <style>
    body { font-family: Segoe UI, Arial, sans-serif; margin: 0; background: #f7f9fb; color: #1a1d22; }
    header { background: #0f172a; color: #fff; padding: 16px 24px; }
    .layout { display: grid; grid-template-columns: 280px 1fr; min-height: calc(100vh - 64px); }
    aside { border-right: 1px solid #dbe2ea; background: #fff; padding: 12px; overflow: auto; }
    main { padding: 16px 24px; overflow: auto; }
    .summary { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 12px; margin-bottom: 16px; }
    .card { background: #fff; border: 1px solid #dbe2ea; border-radius: 10px; padding: 10px 12px; }
    .item { background: #fff; border: 1px solid #dbe2ea; border-radius: 10px; padding: 12px; margin-bottom: 12px; }
    dl { display: grid; grid-template-columns: minmax(180px, 360px) 1fr; gap: 6px 16px; margin: 0; }
    dt { font-weight: 600; color: #374151; word-break: break-word; overflow-wrap: break-word; font-size: 0.85em; }
    dd { margin: 0; white-space: pre-wrap; }
    dd ul { list-style: disc; margin: 4px 0; padding-left: 20px; }
    dd li { padding: 2px 0; border-radius: 0; cursor: default; }
    dd li:hover { background: none; }
    input { width: 100%; box-sizing: border-box; padding: 8px; border: 1px solid #cbd5e1; border-radius: 8px; margin-bottom: 10px; }
    aside ul { list-style: none; margin: 0; padding: 0; }
    aside li { padding: 6px 8px; border-radius: 6px; cursor: pointer; }
    aside li:hover { background: #eef2ff; }
  </style>
</head>
<body>
  <header><h1>XtractAid Report</h1></header>
  <div class="layout">
    <aside>
      <input id="search" placeholder="Search item..." />
      <ul id="nav"></ul>
    </aside>
    <main>
      <section class="summary">
        <div class="card"><strong>Batch</strong><div>${_escapeHtml(config.name)}</div></div>
        <div class="card"><strong>Results</strong><div>${results.length}</div></div>
        <div class="card"><strong>Success Rate</strong><div>${successRate.toStringAsFixed(2)}%</div></div>
        <div class="card"><strong>Errors</strong><div>$errorCount</div></div>
        <div class="card"><strong>Total Cost (USD)</strong><div>${stats.totalCost.toStringAsFixed(6)}</div></div>
      </section>
      <section id="items">
        $itemsHtml
      </section>
    </main>
  </div>
  <script>
    const items = Array.from(document.querySelectorAll('.item'));
    const nav = document.getElementById('nav');
    const search = document.getElementById('search');
    function renderNav(filter = '') {
      nav.innerHTML = '';
      items.forEach((item, idx) => {
        const title = item.querySelector('h3').textContent;
        const text = item.textContent.toLowerCase();
        const ok = !filter || text.includes(filter.toLowerCase());
        item.style.display = ok ? '' : 'none';
        if (!ok) return;
        const li = document.createElement('li');
        li.textContent = title;
        li.onclick = () => item.scrollIntoView({behavior:'smooth', block:'start'});
        nav.appendChild(li);
      });
    }
    search.addEventListener('input', e => renderNav(e.target.value));
    renderNav();
  </script>
</body>
</html>
''';

    final path = p.join(outputDir, 'report.html');
    await File(path).writeAsString(html, flush: true);
    return path;
  }

  List<String> _collectHeaders(List<Map<String, dynamic>> results) {
    // Collect all unique keys preserving first-seen order
    final allKeys = <String>[];
    final seen = <String>{};
    for (final row in results) {
      for (final key in row.keys) {
        if (seen.add(key)) {
          allKeys.add(key);
        }
      }
    }
    allKeys.remove('ID');

    // Group by suffix _from_<prompt>_rep_<n>
    final grouped = <String, List<String>>{};
    final ungrouped = <String>[];

    for (final key in allKeys) {
      final fromIdx = key.indexOf('_from_');
      if (fromIdx > 0) {
        final suffix = key.substring(fromIdx);
        grouped.putIfAbsent(suffix, () => []).add(key);
      } else {
        ungrouped.add(key);
      }
    }

    // Sort group keys so prompt+rep combos are in consistent order
    final sortedGroupKeys = grouped.keys.toList()..sort();

    final headers = <String>['ID'];
    for (final groupKey in sortedGroupKeys) {
      headers.addAll(grouped[groupKey]!);
    }
    headers.addAll(ungrouped);
    return headers;
  }

  List<Map<String, dynamic>> _mergeResultsByItemId(
    List<Map<String, dynamic>> results,
  ) {
    final merged = <String, Map<String, dynamic>>{};
    final idOrder = <String>[];

    for (final row in results) {
      // Find the item ID from any ID_from_* key
      String? itemId;
      for (final key in row.keys) {
        if (key.startsWith('ID_from_') || key == 'ID') {
          final val = row[key];
          if (val != null) {
            itemId = val.toString();
            break;
          }
        }
      }
      itemId ??= 'unknown_${merged.length}';

      if (!merged.containsKey(itemId)) {
        idOrder.add(itemId);
        merged[itemId] = {'ID': itemId};
      }
      merged[itemId]!.addAll(row);
    }

    // Remove redundant ID_from_* keys, keep central ID
    for (final row in merged.values) {
      row.removeWhere((key, _) => key.startsWith('ID_from_'));
    }

    return idOrder.map((id) => merged[id]!).toList();
  }

  String _formatHtmlValue(dynamic value) {
    if (value == null) return '';
    if (value is List) {
      if (value.isEmpty) return '';
      final items = value
          .map((v) => '<li>${_escapeHtml(v.toString())}</li>')
          .join();
      return '<ul>$items</ul>';
    }
    final str = _stringify(value);
    // Try parsing JSON arrays stored as strings
    if (str.startsWith('[')) {
      try {
        final list = jsonDecode(str);
        if (list is List) {
          final items = list
              .map((v) => '<li>${_escapeHtml(v.toString())}</li>')
              .join();
          return '<ul>$items</ul>';
        }
      } catch (_) {
        // Not valid JSON, fall through
      }
    }
    return _escapeHtml(str);
  }

  String _stringify(dynamic value) {
    if (value == null) {
      return '';
    }
    if (value is String) {
      return value;
    }
    if (value is num || value is bool) {
      return value.toString();
    }
    return jsonEncode(value);
  }

  String _escapeMd(String value) {
    return value
        .replaceAll('\\', '\\\\')
        .replaceAll('|', '\\|')
        .replaceAll('`', '\\`')
        .replaceAll('*', '\\*')
        .replaceAll('_', '\\_')
        .replaceAll('[', '\\[')
        .replaceAll(']', '\\]')
        .replaceAll('\n', ' ');
  }

  String _escapeHtml(String value) {
    return value
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }
}
