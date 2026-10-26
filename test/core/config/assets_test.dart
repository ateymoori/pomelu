import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/core/config/assets.dart';

void main() {
  test('every asset the code names is on disk and declared in pubspec', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final paths = [
      Assets.logo,
      Assets.botScreenPage,
      for (final f in Assets.bundledLicenses) f.asset,
    ];

    for (final path in paths) {
      expect(File(path).existsSync(), isTrue, reason: '$path is missing');
      final folder = '${path.substring(0, path.lastIndexOf('/'))}/';
      expect(
        pubspec.contains('- $path') || pubspec.contains('- $folder'),
        isTrue,
        reason: '$path is not in pubspec.yaml',
      );
    }
  });

  test('the bundled licenses name the fonts and scripts the app ships', () {
    expect(Assets.bundledLicenses.map((f) => f.name), [
      'Inter',
      'JetBrains Mono',
      'noVNC',
      'pako',
    ]);
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('family: Inter'));
    expect(pubspec, contains('family: JetBrainsMono'));
  });
}
