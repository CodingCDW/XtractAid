import 'package:flutter_test/flutter_test.dart';
import 'package:xtractaid/data/models/item.dart';
import 'package:xtractaid/services/prompt_service.dart';

void main() {
  late PromptService service;

  setUp(() {
    service = PromptService();
  });

  group('PromptService', () {
    group('hasPlaceholder', () {
      test('returns true when placeholder is present', () {
        const prompt = 'Analyze the following:\n[Insert IDs and Items here]\nProvide JSON.';
        expect(service.hasPlaceholder(prompt), isTrue);
      });

      test('returns false when placeholder is absent', () {
        const prompt = 'Analyze the following data and provide JSON.';
        expect(service.hasPlaceholder(prompt), isFalse);
      });
    });

    group('injectItems', () {
      test('replaces placeholder with JSON-LD formatted items', () {
        const template = 'Analyze:\n[Insert IDs and Items here]\nReturn JSON.';
        final items = [
          const Item(id: 'P001', text: 'First item'),
          const Item(id: 'P002', text: 'Second item'),
        ];

        final result = service.injectItems(template, items);

        expect(result, contains('"ID":"P001"'));
        expect(result, contains('"Item":"First item"'));
        expect(result, contains('"ID":"P002"'));
        expect(result, contains('Analyze:'));
        expect(result, contains('Return JSON.'));
        expect(result, isNot(contains('[Insert IDs and Items here]')));
      });

      test('appends items when no placeholder exists', () {
        const template = 'Analyze the data.';
        final items = [const Item(id: '1', text: 'test')];

        final result = service.injectItems(template, items);

        expect(result, startsWith('Analyze the data.'));
        expect(result, contains('"ID":"1"'));
      });

      test('handles empty items list', () {
        const template = 'Prompt with [Insert IDs and Items here] placeholder.';
        final result = service.injectItems(template, []);

        expect(result, isNot(contains('[Insert IDs and Items here]')));
      });

      test('handles special characters in item text', () {
        const template = '[Insert IDs and Items here]';
        final items = [
          const Item(id: '1', text: 'Text with "quotes" and\nnewlines'),
        ];

        final result = service.injectItems(template, items);
        // JSON encoding should escape quotes and newlines
        expect(result, contains(r'\"quotes\"'));
      });
    });

    group('validatePrompt', () {
      test('returns no warnings for valid prompt', () {
        const prompt = 'Analyze:\n[Insert IDs and Items here]\nReturn JSON.';
        final warnings = service.validatePrompt(prompt);
        expect(warnings, isEmpty);
      });

      test('warns about empty prompt', () {
        final warnings = service.validatePrompt('');
        expect(warnings, contains(contains('empty')));
      });

      test('warns about whitespace-only prompt', () {
        final warnings = service.validatePrompt('   \n  ');
        expect(warnings, contains(contains('empty')));
      });

      test('warns about missing placeholder', () {
        const prompt = 'Analyze the data.';
        final warnings = service.validatePrompt(prompt);
        expect(warnings, contains(contains('placeholder')));
      });

      test('warns about very long prompt', () {
        final prompt = 'x' * 50001;
        final warnings = service.validatePrompt(prompt);
        expect(warnings, contains(contains('very long')));
      });
    });

    group('createChunks', () {
      final items = List.generate(
        10,
        (i) => Item(id: 'P${i.toString().padLeft(3, '0')}', text: 'Item $i'),
      );

      test('creates correct number of chunks', () {
        final chunks = service.createChunks(items, 3);
        expect(chunks.length, 4); // 10 / 3 = 3 full + 1 partial
      });

      test('last chunk has remaining items', () {
        final chunks = service.createChunks(items, 3);
        expect(chunks.last.length, 1); // 10 % 3 = 1
      });

      test('chunk size 1 gives one item per chunk', () {
        final chunks = service.createChunks(items, 1);
        expect(chunks.length, 10);
        for (final chunk in chunks) {
          expect(chunk.length, 1);
        }
      });

      test('chunk size >= items gives single chunk', () {
        final chunks = service.createChunks(items, 100);
        expect(chunks.length, 1);
        expect(chunks[0].length, 10);
      });

      test('handles empty items list', () {
        final chunks = service.createChunks([], 5);
        expect(chunks, isEmpty);
      });

      test('preserves item order', () {
        final chunks = service.createChunks(items, 4);
        expect(chunks[0][0].id, 'P000');
        expect(chunks[0][3].id, 'P003');
        expect(chunks[1][0].id, 'P004');
      });
    });
  });
}
