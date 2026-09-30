import 'dart:io';

import 'package:obx_lints/obx_lints.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  final fixtureDirPath = p.join('test', 'fixture');

  test('reports the `// expect:` issues of the fixture', () async {
    final samplePath = p.join(fixtureDirPath, 'sample.dart');
    final sampleLines = File(samplePath).readAsLinesSync();
    final expected = _expectedIssuesOf(sampleLines);
    final issues = await ObxLints.check([fixtureDirPath]);
    final actual = [for (final issue in issues) '${issue.line} ${issue.rule.code}'];
    expect(actual, expected);
  });

  test('fixes leave only manual issues', () async {
    final tempDir = Directory.systemTemp.createTempSync('obx_lints_');
    addTearDown(() => tempDir.deleteSync(recursive: true));
    final fixtureFiles = Directory(fixtureDirPath).listSync().whereType<File>();
    for (final file in fixtureFiles) {
      final filename = p.basename(file.path);
      file.copySync(p.join(tempDir.path, filename));
    }

    final issues = await ObxLints.check([tempDir.path]);
    final fixedCount = ObxLints.applyFixes(issues);
    final remainingIssues = await ObxLints.check([tempDir.path]);
    expect(fixedCount, greaterThan(0));
    expect(remainingIssues.length, issues.length - fixedCount);
    final hasOnlyManualIssues = remainingIssues.every((issue) => issue.replacement == null);
    expect(hasOnlyManualIssues, isTrue);
  });
}

final _expectRegex = RegExp(r'// expect: (\w+)');

List<String> _expectedIssuesOf(List<String> lines) {
  final expected = <String>[];
  for (var i = 0; i < lines.length; i++) {
    final match = _expectRegex.firstMatch(lines[i]);
    if (match == null) continue;
    expected.add('${i + 1} ${match.group(1)}');
  }
  return expected;
}
