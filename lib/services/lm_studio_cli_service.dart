import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

final _log = Logger('LmStudioCliService');

/// Manages LM Studio CLI operations (model loading, server readiness).
class LmStudioCliService {
  final Dio _dio;

  LmStudioCliService({Dio? dio}) : _dio = dio ?? Dio();

  /// Load a model in LM Studio via CLI.
  ///
  /// Runs: `lms unload --all` then `lms load {modelId}`
  Future<bool> loadModel(
    String modelId, {
    void Function(String line)? onProgress,
  }) async {
    try {
      // Unload all models first
      _log.info('Unloading all models...');
      final unloadResult = await Process.run('lms', ['unload', '--all']);
      if (unloadResult.exitCode != 0) {
        _log.warning('lms unload failed: ${unloadResult.stderr}');
      }

      // Load the requested model
      _log.info('Loading model: $modelId');
      final process = await Process.start('lms', ['load', modelId]);

      process.stdout
          .transform(const SystemEncoding().decoder)
          .listen((line) {
        onProgress?.call(line.trim());
        _log.fine('lms load: $line');
      });

      process.stderr
          .transform(const SystemEncoding().decoder)
          .listen((line) {
        _log.warning('lms load stderr: $line');
      });

      final exitCode = await process.exitCode;
      return exitCode == 0;
    } on ProcessException catch (e) {
      _log.severe('LM Studio CLI not found: $e');
      return false;
    }
  }

  /// Wait for the LM Studio server to be ready.
  ///
  /// Polls the /v1/models endpoint until it responds or timeout.
  Future<bool> waitForServer({
    String baseUrl = 'http://localhost:1234/v1',
    Duration timeout = const Duration(seconds: 60),
    Duration pollInterval = const Duration(seconds: 2),
  }) async {
    final deadline = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(deadline)) {
      try {
        final response = await _dio.get(
          '$baseUrl/models',
          options: Options(receiveTimeout: const Duration(seconds: 3)),
        );
        if (response.statusCode == 200) {
          final data = response.data as Map<String, dynamic>?;
          final models = data?['data'] as List?;
          if (models != null && models.isNotEmpty) {
            _log.info('LM Studio server ready with ${models.length} model(s).');
            return true;
          }
        }
      } catch (_) {
        // Server not ready yet
      }
      await Future.delayed(pollInterval);
    }

    _log.warning('LM Studio server did not become ready within $timeout.');
    return false;
  }

  /// Check if the LM Studio CLI is available.
  Future<bool> isCliAvailable() async {
    try {
      final result = await Process.run('lms', ['--version']);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }
}
