import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';

import '../core/constants/app_constants.dart';

final _log = Logger('ProjectFileService');

/// Manages project folder structure and the project.xtractaid.json file.
class ProjectFileService {
  /// Create a new project folder structure.
  Future<void> createProject({
    required String path,
    required String name,
    required String projectId,
  }) async {
    final dir = Directory(path);
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }

    // Create subdirectories
    for (final subdir in AppConstants.projectSubdirs) {
      await Directory('$path/$subdir').create(recursive: true);
    }

    // Create project file
    final projectFile = File('$path/${AppConstants.projectFileName}');
    final projectData = {
      'id': projectId,
      'name': name,
      'version': '1.0',
      'created_at': DateTime.now().toIso8601String(),
    };
    await projectFile.writeAsString(
      const JsonEncoder.withIndent('  ').convert(projectData),
    );

    _log.info('Created project "$name" at $path');
  }

  /// Validate a project folder by checking for project.xtractaid.json.
  Future<Map<String, dynamic>?> validateProject(String path) async {
    final projectFile = File('$path/${AppConstants.projectFileName}');
    if (!projectFile.existsSync()) return null;

    try {
      final content = await projectFile.readAsString();
      return json.decode(content) as Map<String, dynamic>;
    } catch (e) {
      _log.warning('Invalid project file at $path: $e');
      return null;
    }
  }

  /// Delete a project folder recursively from disk.
  Future<void> deleteProjectFolder(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) {
      return;
    }
    await dir.delete(recursive: true);
    _log.info('Deleted project folder at $path');
  }

  /// Get the prompts directory path for a project.
  String promptsDir(String projectPath) => '$projectPath/prompts';

  /// Get the input directory path for a project.
  String inputDir(String projectPath) => '$projectPath/input';

  /// Get the results directory path for a project.
  String resultsDir(String projectPath) => '$projectPath/results';
}
