import 'dart:io';

import 'package:obx_lints/obx_lints.dart';
import 'package:path/path.dart' as p;

const _kUsage = '''
usage: obx_lints [--fix] [paths...]
checks nampack Obx/Rx usage of dart files under paths (default: lib).
  --fix  applies safe fixes in place, the rest is left for manual review.''';

Future<void> main(List<String> args) async {
  if (args.contains('-h') || args.contains('--help')) {
    stdout.writeln(_kUsage);
    return;
  }
  final shouldFix = args.contains('--fix');
  final paths = [
    for (final arg in args)
      if (!arg.startsWith('-')) arg,
  ];
  if (paths.isEmpty) paths.add('lib');

  final sdkPath = _findSdkPath();
  if (sdkPath == null) {
    stderr.writeln('dart sdk not found, add `dart` to PATH');
    exitCode = 2;
    return;
  }
  final dartToolDir = Directory('.dart_tool');
  final cacheDirPath = dartToolDir.existsSync() ? p.join(dartToolDir.absolute.path, 'obx_lints') : null;

  final stopwatch = Stopwatch()..start();
  final issues = await ObxLints.check(paths, cacheDirPath: cacheDirPath, sdkPath: sdkPath);
  for (final issue in issues) {
    final relativePath = p.relative(issue.path);
    final fixHint = issue.replacement == null ? '' : ' (fixable)';
    stdout.writeln('$relativePath:${issue.line}:${issue.column} - ${issue.rule.message} - ${issue.rule.code}$fixHint');
  }

  var remainingCount = issues.length;
  if (shouldFix) {
    final fixedCount = ObxLints.applyFixes(issues);
    remainingCount -= fixedCount;
    stdout.writeln('$fixedCount fixed');
  }
  stdout.writeln('${issues.length} issues found in ${stopwatch.elapsedMilliseconds}ms');
  exitCode = remainingCount == 0 ? 0 : 1;
}

/// the sdk of the running `dart`, or of the first `dart` on PATH when running as a compiled exe.
String? _findSdkPath() {
  final executableDirPath = p.dirname(Platform.resolvedExecutable);
  final runningSdkPath = p.dirname(executableDirPath);
  if (_isDartSdk(runningSdkPath)) return runningSdkPath;

  final pathVariable = Platform.environment['PATH'];
  if (pathVariable == null) return null;
  final pathSeparator = Platform.isWindows ? ';' : ':';
  for (final binDirPath in pathVariable.split(pathSeparator)) {
    final flutterDartSdkPath = p.join(binDirPath, 'cache', 'dart-sdk');
    if (_isDartSdk(flutterDartSdkPath)) return flutterDartSdkPath;
    final dartSdkPath = p.dirname(binDirPath);
    if (_isDartSdk(dartSdkPath)) return dartSdkPath;
  }
  return null;
}

bool _isDartSdk(String path) {
  final internalDirPath = p.join(path, 'lib', '_internal');
  return Directory(internalDirPath).existsSync();
}
