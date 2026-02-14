import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

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
  }) async {
    final outputDir = Directory(_outputDir(projectPath, batchId));
    if (!outputDir.existsSync()) {
      outputDir.createSync(recursive: true);
    }

    final excelPath = await _generateExcel(
      outputDir.path,
      results,
    );
    final markdownPath = await _generateMarkdown(
      outputDir.path,
      config: config,
      stats: stats,
      logs: logs,
      promptContents: promptContents,
    );
    final htmlPath = await _generateHtml(
      outputDir.path,
      config: config,
      stats: stats,
      results: results,
      logs: logs,
    );

    return GeneratedReports(
      excelPath: excelPath,
      markdownPath: markdownPath,
      htmlPath: htmlPath,
    );
  }

  String _outputDir(String projectPath, String batchId) {
    return p.join(projectPath, 'results', batchId);
  }

  Future<String> _generateExcel(
    String outputDir,
    List<Map<String, dynamic>> results,
  ) async {
    final workbook = Workbook();
    final sheet = workbook.worksheets[0];
    sheet.name = 'results';

    final headers = _collectHeaders(results);
    for (var col = 0; col < headers.length; col++) {
      sheet.getRangeByIndex(1, col + 1).setText(headers[col]);
    }

    for (var row = 0; row < results.length; row++) {
      final result = results[row];
      for (var col = 0; col < headers.length; col++) {
        final key = headers[col];
        final value = result[key];
        sheet.getRangeByIndex(row + 2, col + 1).setText(_stringify(value));
      }
    }

    if (headers.isNotEmpty) {
      for (var i = 1; i <= headers.length; i++) {
        sheet.autoFitColumn(i);
      }
    }

    final bytes = workbook.saveAsStream();
    workbook.dispose();

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
      ..writeln('- Models: ${config.models.map((m) => '${m.providerId}:${m.modelId}').join(', ')}')
      ..writeln()
      ..writeln('## Token Stats')
      ..writeln('- Input tokens: ${stats.totalInputTokens}')
      ..writeln('- Output tokens: ${stats.totalOutputTokens}')
      ..writeln('- Total tokens: ${stats.totalInputTokens + stats.totalOutputTokens}')
      ..writeln()
      ..writeln('## Cost')
      ..writeln('- Total cost (USD): ${stats.totalCost.toStringAsFixed(6)}')
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

    final itemsHtml = results.asMap().entries.map((entry) {
      final i = entry.key + 1;
      final map = entry.value;
      final fields = map.entries
          .map(
            (e) => '<dt>${_escapeHtml(e.key)}</dt><dd>${_escapeHtml(_stringify(e.value))}</dd>',
          )
          .join();
      return '<section class="item"><h3>Item $i</h3><dl>$fields</dl></section>';
    }).join('\n');

    final html = '''
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
    dl { display: grid; grid-template-columns: minmax(120px, 220px) 1fr; gap: 6px 10px; margin: 0; }
    dt { font-weight: 600; color: #374151; }
    dd { margin: 0; white-space: pre-wrap; }
    input { width: 100%; box-sizing: border-box; padding: 8px; border: 1px solid #cbd5e1; border-radius: 8px; margin-bottom: 10px; }
    ul { list-style: none; margin: 0; padding: 0; }
    li { padding: 6px 8px; border-radius: 6px; cursor: pointer; }
    li:hover { background: #eef2ff; }
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
    final keys = <String>{'ID'};
    for (final row in results) {
      keys.addAll(row.keys);
    }
    final headers = keys.toList();
    headers.sort();
    if (headers.remove('ID')) {
      headers.insert(0, 'ID');
    }
    return headers;
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
    return value.replaceAll('|', '\\|').replaceAll('\n', ' ');
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
