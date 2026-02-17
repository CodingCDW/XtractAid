import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:xtractaid/services/project_file_service.dart';

void main() {
  late ProjectFileService service;
  late Directory tempDir;

  setUp(() {
    service = ProjectFileService();
    tempDir = Directory.systemTemp.createTempSync('xtractaid_test_');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('ProjectFileService', () {
    group('deleteProjectFolder', () {
      test('deletes existing folder recursively', () async {
        final subDir = Directory('${tempDir.path}/sub');
        subDir.createSync();
        File('${subDir.path}/file.txt').writeAsStringSync('data');

        await service.deleteProjectFolder(tempDir.path);

        expect(tempDir.existsSync(), false);
      });

      test('does not throw for non-existent path', () async {
        await service.deleteProjectFolder('${tempDir.path}/does_not_exist');
      });

      test('deletes folder with nested structure', () async {
        Directory('${tempDir.path}/a/b/c').createSync(recursive: true);
        File('${tempDir.path}/a/b/c/deep.txt').writeAsStringSync('deep');
        File('${tempDir.path}/root.txt').writeAsStringSync('root');

        await service.deleteProjectFolder(tempDir.path);

        expect(tempDir.existsSync(), false);
      });
    });

    group('createProject', () {
      test('creates folder with correct subdirectories', () async {
        final projectPath = '${tempDir.path}/my_project';

        await service.createProject(
          path: projectPath,
          name: 'Test Project',
          projectId: 'proj-123',
        );

        expect(Directory('$projectPath/prompts').existsSync(), true);
        expect(Directory('$projectPath/input').existsSync(), true);
        expect(Directory('$projectPath/results').existsSync(), true);
      });

      test('creates project.xtractaid.json with expected fields', () async {
        final projectPath = '${tempDir.path}/my_project';

        await service.createProject(
          path: projectPath,
          name: 'Test Project',
          projectId: 'proj-123',
        );

        final file = File('$projectPath/project.xtractaid.json');
        expect(file.existsSync(), true);

        final content =
            json.decode(file.readAsStringSync()) as Map<String, dynamic>;
        expect(content['id'], 'proj-123');
        expect(content['name'], 'Test Project');
        expect(content['version'], '1.0');
        expect(content.containsKey('created_at'), true);
      });
    });

    group('validateProject', () {
      test('returns JSON map for valid project', () async {
        final projectPath = '${tempDir.path}/valid_project';
        await service.createProject(
          path: projectPath,
          name: 'Valid',
          projectId: 'p1',
        );

        final result = await service.validateProject(projectPath);

        expect(result, isNotNull);
        expect(result!['id'], 'p1');
        expect(result['name'], 'Valid');
      });

      test('returns null when project file is missing', () async {
        final emptyDir = Directory('${tempDir.path}/empty');
        emptyDir.createSync();

        final result = await service.validateProject(emptyDir.path);

        expect(result, isNull);
      });

      test('returns null for invalid JSON', () async {
        final brokenDir = Directory('${tempDir.path}/broken');
        brokenDir.createSync();
        File('${brokenDir.path}/project.xtractaid.json')
            .writeAsStringSync('not valid json {{{');

        final result = await service.validateProject(brokenDir.path);

        expect(result, isNull);
      });
    });
  });
}
