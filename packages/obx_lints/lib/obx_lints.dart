// rewritten by claude, new one is a standalone analyzer cli (no custom_lint/ide plugin) with scope-aware checks and in-place fixes

import 'dart:io';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/source/line_info.dart';
// -- the public collection has no byte store, a disk one halves warm runs by reusing linked summaries.
// ignore: implementation_imports
import 'package:analyzer/src/dart/analysis/analysis_context_collection.dart';
// ignore: implementation_imports
import 'package:analyzer/src/dart/analysis/file_byte_store.dart';
import 'package:path/path.dart' as p;

part 'src/obx_visitor.dart';

class ObxLints {
  const ObxLints._();

  static const _kCacheMaxSizeBytes = 512 * 1024 * 1024;

  /// sorted by path then offset. [sdkPath] defaults to the sdk of the running `dart`.
  static Future<List<ObxIssue>> check(List<String> paths, {String? cacheDirPath, String? sdkPath}) async {
    final includedPaths = <String>[];
    for (final path in paths) {
      final absolutePath = p.absolute(path);
      includedPaths.add(p.normalize(absolutePath));
    }
    EvictingFileByteStore? byteStore;
    if (cacheDirPath != null) {
      Directory(cacheDirPath).createSync(recursive: true);
      byteStore = EvictingFileByteStore(cacheDirPath, _kCacheMaxSizeBytes);
    }
    final collection = AnalysisContextCollectionImpl(includedPaths: includedPaths, byteStore: byteStore, sdkPath: sdkPath);
    final issues = <ObxIssue>[];
    final typeKinds = <InterfaceElement, _TypeKind>{};
    try {
      for (final context in collection.contexts) {
        final session = context.currentSession;
        final candidatePaths = <String>{};
        for (final path in context.contextRoot.analyzedFiles()) {
          if (!path.endsWith('.dart')) continue;
          final file = session.getFile(path);
          if (file is! FileResult) continue;
          // -- every issue is reported on a `.value*` access, files without one are never resolved.
          if (!file.content.contains('.value')) continue;
          candidatePaths.add(path);
        }

        final visitedPaths = <String>{};
        for (final path in candidatePaths) {
          if (visitedPaths.contains(path)) continue;
          final library = await session.getResolvedLibraryContaining(path);
          if (library is! ResolvedLibraryResult) continue;
          for (final unit in library.units) {
            final unitPath = unit.path;
            if (!candidatePaths.contains(unitPath)) continue;
            if (!visitedPaths.add(unitPath)) continue;
            final visitor = _ObxVisitor(unit, issues, typeKinds);
            unit.unit.accept(visitor);
          }
        }
      }
    } finally {
      await collection.dispose();
    }

    issues.sort((a, b) {
      final pathCompare = a.path.compareTo(b.path);
      if (pathCompare != 0) return pathCompare;
      return a.offset.compareTo(b.offset);
    });
    return issues;
  }

  /// [issues] must be sorted as returned by [check], a fix nested inside a previous one is skipped.
  static int applyFixes(List<ObxIssue> issues) {
    final issuesByPath = <String, List<ObxIssue>>{};
    for (final issue in issues) {
      if (issue.replacement == null) continue;
      (issuesByPath[issue.path] ??= []).add(issue);
    }

    var fixedCount = 0;
    for (final MapEntry(key: path, value: fileIssues) in issuesByPath.entries) {
      final file = File(path);
      final content = file.readAsStringSync();
      final buffer = StringBuffer();
      var cursor = 0;
      for (final issue in fileIssues) {
        final offset = issue.offset;
        if (offset < cursor) continue;
        final unchangedPart = content.substring(cursor, offset);
        buffer.write(unchangedPart);
        buffer.write(issue.replacement);
        cursor = offset + issue.length;
        fixedCount++;
      }
      final remainingPart = content.substring(cursor);
      buffer.write(remainingPart);
      final fixedContent = buffer.toString();
      file.writeAsStringSync(fixedContent);
    }
    return fixedCount;
  }
}

class ObxIssue {
  final String path;
  final int line;
  final int column;
  final int offset;
  final int length;
  final ObxRule rule;
  final String? replacement;

  const ObxIssue({required this.path, required this.line, required this.column, required this.offset, required this.length, required this.rule, required this.replacement});
}

enum ObxRule {
  nonReactiveValueInsideObx('non_reactive_value_inside_obx', '`value` is not reactive, use `valueR` inside `Obx` and `...R` getters/methods'),
  avoidReactiveValueOutsideObx(
    'avoid_rx_value_getter_outside_obx',
    '`valueR` is not reactive outside `Obx` and `...R` getters/methods, wrap with `Obx`, add `R` to the name or use `value`',
  ),
  nonReactiveRxInsideObx('non_reactive_rx_inside_obx', 'this Rx never notifies `Obx`, use `ObxO` or a reactive Rx'),
  preferRxToggle('prefer_rx_toggle', 'use `toggle()` instead');

  final String code;
  final String message;

  const ObxRule(this.code, this.message);
}
