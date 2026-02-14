import 'package:flutter_test/flutter_test.dart';
import 'package:xtractaid/services/json_parser_service.dart';

void main() {
  late JsonParserService service;

  setUp(() {
    service = JsonParserService();
  });

  group('JsonParserService', () {
    group('Strategy 1: Direct JSON parse', () {
      test('parses JSON array directly', () {
        const response = '[{"ID": "1", "value": "a"}, {"ID": "2", "value": "b"}]';
        final result = service.parseResponse(response);

        expect(result, isNotNull);
        expect(result!.length, 2);
        expect(result[0]['ID'], '1');
        expect(result[1]['ID'], '2');
      });

      test('wraps single JSON object in list', () {
        const response = '{"ID": "1", "value": "test"}';
        final result = service.parseResponse(response);

        expect(result, isNotNull);
        expect(result!.length, 1);
        expect(result[0]['ID'], '1');
      });

      test('handles whitespace around JSON', () {
        const response = '  \n  [{"ID": "1"}]  \n  ';
        final result = service.parseResponse(response);

        expect(result, isNotNull);
        expect(result!.length, 1);
      });
    });

    group('Strategy 2: Markdown code fences', () {
      test('parses JSON inside ```json fences', () {
        const response = '''
Here is the result:

```json
[{"ID": "1", "value": "extracted"}]
```

That's the analysis.
''';
        final result = service.parseResponse(response);

        expect(result, isNotNull);
        expect(result!.length, 1);
        expect(result[0]['value'], 'extracted');
      });

      test('parses JSON inside ``` fences without language tag', () {
        const response = '''
```
[{"ID": "1"}]
```
''';
        final result = service.parseResponse(response);

        expect(result, isNotNull);
        expect(result!.length, 1);
      });
    });

    group('Strategy 3: Think tags removal', () {
      test('parses JSON after </think> tag', () {
        const response = '''
<think>
Let me analyze this carefully...
I think the answer is...
</think>
[{"ID": "1", "result": "analyzed"}]
''';
        final result = service.parseResponse(response);

        expect(result, isNotNull);
        expect(result!.length, 1);
        expect(result[0]['result'], 'analyzed');
      });

      test('handles think tags with code fences after', () {
        const response = '''
<think>reasoning here</think>
```json
[{"ID": "1"}]
```
''';
        final result = service.parseResponse(response);

        expect(result, isNotNull);
        expect(result!.length, 1);
      });
    });

    group('Strategy 4: Regex for JSON array with ID', () {
      test('finds JSON array with ID fields in mixed text', () {
        const response = '''
Sure, here are the results:
Some intro text...
[{"ID": "P001", "category": "A"}, {"ID": "P002", "category": "B"}]
And some trailing text.
''';
        final result = service.parseResponse(response);

        expect(result, isNotNull);
        expect(result!.length, 2);
        expect(result[0]['ID'], 'P001');
        expect(result[1]['ID'], 'P002');
      });
    });

    group('Strategy 5: Collect individual objects', () {
      test('collects scattered JSON objects with ID', () {
        const response = '''
Result 1: {"ID": "1", "name": "first"}
Some text between...
Result 2: {"ID": "2", "name": "second"}
''';
        final result = service.parseResponse(response);

        expect(result, isNotNull);
        expect(result!.length, 2);
        expect(result[0]['ID'], '1');
        expect(result[1]['ID'], '2');
      });
    });

    group('Failure cases', () {
      test('returns null for completely unparseable text', () {
        const response = 'This is just plain text with no JSON at all.';
        final result = service.parseResponse(response);

        expect(result, isNull);
      });

      test('returns null for empty string', () {
        final result = service.parseResponse('');
        expect(result, isNull);
      });

      test('returns null for JSON without ID fields (strategies 4-5)', () {
        // Direct parse still works for valid JSON without ID
        const response = 'some prefix [{"name": "no-id"}] some suffix';
        // Strategy 1 fails (prefix), Strategy 4-5 require "ID"
        // But code fences or think tags aren't present
        final result = service.parseResponse(response);
        expect(result, isNull);
      });
    });
  });
}
