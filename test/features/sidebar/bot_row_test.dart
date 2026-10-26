import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/features/sidebar/presentation/widgets/bot_row.dart';
import 'package:hermes/l10n/generated/app_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  test('plainPreview drops markdown marks and collapses whitespace', () {
    expect(
      plainPreview('A test: **blue** and `code`\n\n# heading'),
      'A test: blue and code heading',
    );
    expect(plainPreview('see [docs](http://x) now'), 'see docs now');
    expect(plainPreview('  plain  '), 'plain');
  });

  // 2026-03-29 and 2026-10-25 are the EU daylight-saving changes: in a zone
  // that observes them, those local days are 23 and 25 hours long.
  group('calendar days across a DST change', () {
    test('relativeTime still says Yesterday the morning after', () {
      final l10n = lookupAppLocalizations(const Locale('en'));
      expect(
        relativeTime(l10n, DateTime(2026, 3, 29, 9), DateTime(2026, 3, 30, 10)),
        l10n.timeYesterday,
      );
    });
  });

  group('relativeTime', () {
    final l10n = lookupAppLocalizations(const Locale('en'));
    final now = DateTime(2026, 10, 5, 12);

    // The app's date data is loaded by the Material delegates; a unit test
    // does it by hand.
    setUpAll(() => initializeDateFormatting('en'));

    test('says now under a minute, then minutes, then hours', () {
      expect(
        relativeTime(l10n, now.subtract(const Duration(seconds: 20)), now),
        'now',
      );
      expect(
        relativeTime(l10n, now.subtract(const Duration(minutes: 5)), now),
        '5m',
      );
      expect(
        relativeTime(l10n, now.subtract(const Duration(minutes: 59)), now),
        '59m',
      );
      expect(
        relativeTime(l10n, now.subtract(const Duration(hours: 3)), now),
        '3h',
      );
    });

    test('says Yesterday for the day before, then the date', () {
      expect(
        relativeTime(l10n, DateTime(2026, 10, 4, 8), now),
        l10n.timeYesterday,
      );
      expect(relativeTime(l10n, DateTime(2026, 10, 1, 8), now), 'Oct 1');
      expect(relativeTime(l10n, DateTime(2026, 3, 28, 8), now), 'Mar 28');
    });
  });
}
