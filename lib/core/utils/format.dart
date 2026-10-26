import 'package:intl/intl.dart';

import '../../l10n/generated/app_localizations.dart';

abstract final class Format {
  /// `512 B`, `1.5 KB`, `12 MB`: one decimal under 10, in [l10n]'s locale.
  static String bytes(AppLocalizations l10n, int b) {
    final locale = l10n.localeName;
    if (b < _unit) return l10n.fileSizeB(NumberFormat('0', locale).format(b));
    final units = [l10n.fileSizeKB, l10n.fileSizeMB, l10n.fileSizeGB];
    var v = b / _unit;
    var i = 0;
    while (v >= _unit && i < units.length - 1) {
      v /= _unit;
      i++;
    }
    // No thousands separator: `1000 KB` reads better than `1,000 KB`.
    return units[i](NumberFormat(v >= 10 ? '0' : '0.0', locale).format(v));
  }

  static const int _unit = 1024;

  /// Local calendar days from [from] to [to], counted on dates: across DST
  /// two midnights are 23 or 25 hours apart.
  static int calendarDays(DateTime from, DateTime to) {
    final a = from.toLocal();
    final b = to.toLocal();
    return DateTime.utc(
      b.year,
      b.month,
      b.day,
    ).difference(DateTime.utc(a.year, a.month, a.day)).inDays;
  }

  static String duration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
