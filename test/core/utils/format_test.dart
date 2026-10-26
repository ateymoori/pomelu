import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/core/utils/format.dart';
import 'package:hermes/l10n/generated/app_localizations.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  group('Format.bytes', () {
    test('a size under a kilobyte is whole bytes, with no separator', () {
      expect(Format.bytes(l10n, 0), '0 B');
      expect(Format.bytes(l10n, 512), '512 B');
      expect(Format.bytes(l10n, 1023), '1023 B');
    });

    test('under ten of a unit has one decimal, from ten up none', () {
      expect(Format.bytes(l10n, 1024), '1.0 KB');
      expect(Format.bytes(l10n, 1536), '1.5 KB');
      expect(Format.bytes(l10n, 10 * 1024), '10 KB');
      expect(Format.bytes(l10n, 5 * 1024 * 1024), '5.0 MB');
      expect(Format.bytes(l10n, 50 * 1024 * 1024), '50 MB');
    });
  });
}
