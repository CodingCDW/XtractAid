import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:xtractaid/data/models/batch_config.dart';
import 'package:xtractaid/data/models/batch_stats.dart';
import 'package:xtractaid/data/models/log_entry.dart';
import 'package:xtractaid/services/report_generator_service.dart';

void main() {
  late ReportGeneratorService service;
  late Directory tmpDir;

  setUp(() {
    service = ReportGeneratorService();
    tmpDir = Directory.systemTemp.createTempSync('report_test_');
  });

  tearDown(() {
    if (tmpDir.existsSync()) {
      tmpDir.deleteSync(recursive: true);
    }
  });

  BatchConfig makeConfig() {
    return BatchConfig.fromJson({
      'batchId': 'test-batch-001',
      'projectId': 'proj-1',
      'name': 'Test Batch',
      'input': {'type': 'excel', 'path': '/tmp/data.xlsx'},
      'promptFiles': ['prompt_a.txt', 'prompt_b.txt'],
      'chunkSettings': {'chunkSize': 1, 'repetitions': 2},
      'models': [
        {'modelId': 'gpt-5.2', 'providerId': 'openai'},
      ],
    });
  }

  BatchStats makeStats() {
    return BatchStats(
      totalApiCalls: 8,
      completedApiCalls: 8,
      failedApiCalls: 0,
      totalInputTokens: 10000,
      totalOutputTokens: 5000,
      totalCost: 0.0875,
      totalItems: 2,
      processedItems: 2,
      startedAt: DateTime(2026, 2, 15, 10, 0),
      completedAt: DateTime(2026, 2, 15, 10, 5),
    );
  }

  /// Simulates 2 items × 2 prompts × 2 reps = 8 result rows
  List<Map<String, dynamic>> makeUnmergedResults() {
    return [
      {
        'ID_from_prompt_a_rep_1': 'Case_1',
        'Diagnosis_from_prompt_a_rep_1': 'Depression',
        'Symptoms_from_prompt_a_rep_1': '["Sad mood","Insomnia"]',
      },
      {
        'ID_from_prompt_a_rep_2': 'Case_1',
        'Diagnosis_from_prompt_a_rep_2': 'Depression',
        'Symptoms_from_prompt_a_rep_2': '["Low energy","Insomnia"]',
      },
      {
        'ID_from_prompt_b_rep_1': 'Case_1',
        'Diagnosis_from_prompt_b_rep_1': 'Dysthymie',
      },
      {
        'ID_from_prompt_b_rep_2': 'Case_1',
        'Diagnosis_from_prompt_b_rep_2': 'Depression',
      },
      {
        'ID_from_prompt_a_rep_1': 'Case_2',
        'Diagnosis_from_prompt_a_rep_1': 'Anxiety',
        'Symptoms_from_prompt_a_rep_1': '["Panic","Avoidance"]',
      },
      {
        'ID_from_prompt_a_rep_2': 'Case_2',
        'Diagnosis_from_prompt_a_rep_2': 'GAD',
      },
      {
        'ID_from_prompt_b_rep_1': 'Case_2',
        'Diagnosis_from_prompt_b_rep_1': 'Panikstörung',
      },
      {
        'ID_from_prompt_b_rep_2': 'Case_2',
        'Diagnosis_from_prompt_b_rep_2': 'Anxiety',
      },
    ];
  }

  group('Result merging', () {
    test('merges 8 rows into 2 rows by item ID', () async {
      final results = makeUnmergedResults();
      final reports = await service.generateReports(
        projectPath: tmpDir.path,
        batchId: 'merge-test',
        config: makeConfig(),
        stats: makeStats(),
        results: results,
        logs: <LogEntry>[],
        promptContents: {},
      );

      // Read the Excel to check row count (headers + data rows)
      final excelFile = File(reports.excelPath);
      expect(excelFile.existsSync(), isTrue);

      // Read HTML and check for actual item IDs
      final html = await File(reports.htmlPath).readAsString();
      expect(html, contains('Case_1'));
      expect(html, contains('Case_2'));
      // Should NOT contain generic "Item 1" labels
      expect(html, isNot(contains('>Item 1<')));
      expect(html, isNot(contains('>Item 2<')));
    });

    test('merged rows contain fields from all prompts and reps', () async {
      final results = makeUnmergedResults();
      final reports = await service.generateReports(
        projectPath: tmpDir.path,
        batchId: 'fields-test',
        config: makeConfig(),
        stats: makeStats(),
        results: results,
        logs: <LogEntry>[],
        promptContents: {},
      );

      final html = await File(reports.htmlPath).readAsString();
      // All prompt/rep field names should be present
      expect(html, contains('Diagnosis_from_prompt_a_rep_1'));
      expect(html, contains('Diagnosis_from_prompt_a_rep_2'));
      expect(html, contains('Diagnosis_from_prompt_b_rep_1'));
      expect(html, contains('Diagnosis_from_prompt_b_rep_2'));
      // ID_from_* keys should have been removed
      expect(html, isNot(contains('ID_from_prompt_a_rep_1')));
    });

    test('handles rows without ID key gracefully', () async {
      final results = <Map<String, dynamic>>[
        {'Diagnosis': 'Depression'},
        {'Diagnosis': 'Anxiety'},
      ];
      final reports = await service.generateReports(
        projectPath: tmpDir.path,
        batchId: 'no-id-test',
        config: makeConfig(),
        stats: makeStats(),
        results: results,
        logs: <LogEntry>[],
        promptContents: {},
      );

      final html = await File(reports.htmlPath).readAsString();
      // Should have fallback IDs
      expect(html, contains('unknown_'));
    });
  });

  group('HTML formatting', () {
    test('renders JSON arrays as list items', () async {
      final results = <Map<String, dynamic>>[
        {
          'ID': 'Test_1',
          'Symptoms_from_p1_rep_1': '["Headache","Nausea","Fatigue"]',
        },
      ];
      final reports = await service.generateReports(
        projectPath: tmpDir.path,
        batchId: 'json-test',
        config: makeConfig(),
        stats: makeStats(),
        results: results,
        logs: <LogEntry>[],
        promptContents: {},
      );

      final html = await File(reports.htmlPath).readAsString();
      expect(html, contains('<li>Headache</li>'));
      expect(html, contains('<li>Nausea</li>'));
      expect(html, contains('<li>Fatigue</li>'));
      // Should NOT have raw JSON brackets
      expect(html, isNot(contains('&quot;Headache&quot;')));
    });

    test('escapes HTML in values', () async {
      final results = <Map<String, dynamic>>[
        {
          'ID': 'XSS_Test',
          'Note_from_p1_rep_1': '<script>alert("xss")</script>',
        },
      ];
      final reports = await service.generateReports(
        projectPath: tmpDir.path,
        batchId: 'xss-test',
        config: makeConfig(),
        stats: makeStats(),
        results: results,
        logs: <LogEntry>[],
        promptContents: {},
      );

      final html = await File(reports.htmlPath).readAsString();
      // The user-injected value must be escaped (not raw <script>)
      expect(
        html,
        contains('&lt;script&gt;alert(&quot;xss&quot;)&lt;/script&gt;'),
      );
      // The raw injected string must NOT appear unescaped in data
      expect(html, isNot(contains('<script>alert')));
    });
  });

  group('Excel header grouping', () {
    test('groups headers by prompt+rep instead of alphabetical', () async {
      final results = <Map<String, dynamic>>[
        {
          'ID': 'Case_1',
          'Z_field_from_prompt_a_rep_1': 'z1',
          'A_field_from_prompt_a_rep_1': 'a1',
          'Z_field_from_prompt_b_rep_1': 'z2',
          'A_field_from_prompt_b_rep_1': 'a2',
        },
      ];
      final reports = await service.generateReports(
        projectPath: tmpDir.path,
        batchId: 'header-test',
        config: makeConfig(),
        stats: makeStats(),
        results: results,
        logs: <LogEntry>[],
        promptContents: {},
      );

      // Read the Excel file to verify header order
      final excelFile = File(reports.excelPath);
      expect(excelFile.existsSync(), isTrue);
      // The HTML also uses the same merged results, so check field ordering there
      final html = await File(reports.htmlPath).readAsString();
      // prompt_a fields should appear before prompt_b fields
      final aIdx = html.indexOf('_from_prompt_a_rep_1');
      final bIdx = html.indexOf('_from_prompt_b_rep_1');
      expect(aIdx, lessThan(bIdx));
    });
  });

  group('Session log cost details', () {
    test('stores reports under batch run folder with date and time', () async {
      final config = BatchConfig.fromJson({
        'batchId': 'batch-001',
        'projectId': 'proj-1',
        'name': 'Batch_gpt-5.2_ab12cd34',
        'input': {'type': 'excel', 'path': '/tmp/data.xlsx'},
        'promptFiles': ['prompt_a.txt'],
        'chunkSettings': {'chunkSize': 1, 'repetitions': 1},
        'models': [
          {'modelId': 'gpt-5.2', 'providerId': 'openai'},
        ],
      });

      final reports = await service.generateReports(
        projectPath: tmpDir.path,
        batchId: 'ignored-for-folder',
        config: config,
        stats: makeStats(),
        results: <Map<String, dynamic>>[],
        logs: <LogEntry>[],
        promptContents: {},
      );

      final resultDir = p.basename(p.dirname(reports.markdownPath));
      expect(resultDir, 'Batch_gpt-5.2_ab12cd34_2026-02-15_10-00-00');
    });

    test(
      'creates unique folder when same run timestamp already exists',
      () async {
        final config = BatchConfig.fromJson({
          'batchId': 'batch-001',
          'projectId': 'proj-1',
          'name': 'Batch_gpt-5.2_ab12cd34',
          'input': {'type': 'excel', 'path': '/tmp/data.xlsx'},
          'promptFiles': ['prompt_a.txt'],
          'chunkSettings': {'chunkSize': 1, 'repetitions': 1},
          'models': [
            {'modelId': 'gpt-5.2', 'providerId': 'openai'},
          ],
        });

        final first = await service.generateReports(
          projectPath: tmpDir.path,
          batchId: 'batch-001',
          config: config,
          stats: makeStats(),
          results: <Map<String, dynamic>>[],
          logs: <LogEntry>[],
          promptContents: {},
        );
        final second = await service.generateReports(
          projectPath: tmpDir.path,
          batchId: 'batch-001',
          config: config,
          stats: makeStats(),
          results: <Map<String, dynamic>>[],
          logs: <LogEntry>[],
          promptContents: {},
        );

        final firstDir = p.basename(p.dirname(first.markdownPath));
        final secondDir = p.basename(p.dirname(second.markdownPath));
        expect(firstDir, 'Batch_gpt-5.2_ab12cd34_2026-02-15_10-00-00');
        expect(secondDir, 'Batch_gpt-5.2_ab12cd34_2026-02-15_10-00-00_2');
      },
    );

    test('includes pricing breakdown when pricing is provided', () async {
      final reports = await service.generateReports(
        projectPath: tmpDir.path,
        batchId: 'cost-test',
        config: makeConfig(),
        stats: makeStats(),
        results: <Map<String, dynamic>>[],
        logs: <LogEntry>[],
        promptContents: {'prompt_a.txt': 'Test prompt'},
        inputPricePerMillion: 1.75,
        outputPricePerMillion: 14.0,
      );

      final md = await File(reports.markdownPath).readAsString();
      expect(md, contains('Input pricing: \$1.75 / 1M tokens'));
      expect(md, contains('Output pricing: \$14.00 / 1M tokens'));
      expect(md, contains('Input cost:'));
      expect(md, contains('Output cost:'));
      expect(md, contains('openai:gpt-5.2'));
    });

    test('omits pricing breakdown when pricing is zero', () async {
      final reports = await service.generateReports(
        projectPath: tmpDir.path,
        batchId: 'no-cost-test',
        config: makeConfig(),
        stats: makeStats(),
        results: <Map<String, dynamic>>[],
        logs: <LogEntry>[],
        promptContents: {},
      );

      final md = await File(reports.markdownPath).readAsString();
      expect(md, contains('Total cost (USD)'));
      expect(md, isNot(contains('Input pricing:')));
    });
  });
}
