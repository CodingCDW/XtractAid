import 'dart:io';

void main() {
  final lockFile = File('pubspec.lock');
  if (!lockFile.existsSync()) {
    stderr.writeln('pubspec.lock not found.');
    exit(1);
  }

  final content = lockFile.readAsStringSync();
  final packageNames = _extractPackageNames(content);

  final violations = <String>[];
  for (final package in packageNames) {
    if (_isForbidden(package)) {
      violations.add(package);
    }
  }

  if (violations.isEmpty) {
    stdout.writeln('Dependency policy check passed.');
    return;
  }

  stderr.writeln('Dependency policy check failed.');
  stderr.writeln('Forbidden packages detected:');
  for (final package in violations..sort()) {
    stderr.writeln('- $package');
  }
  exit(1);
}

Set<String> _extractPackageNames(String lockContent) {
  final names = <String>{};
  final packageEntry = RegExp(r'^  ([a-z0-9_]+):$', multiLine: true);
  for (final match in packageEntry.allMatches(lockContent)) {
    names.add(match.group(1)!);
  }
  return names;
}

bool _isForbidden(String packageName) {
  if (packageName.startsWith('syncfusion_')) {
    return true;
  }
  return false;
}
