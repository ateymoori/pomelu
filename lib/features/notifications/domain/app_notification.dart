import 'package:flutter/foundation.dart';

import '../../../core/utils/stable_hash.dart';

/// The app's notification channels. The ids are for good: Android keeps a
/// channel's user-chosen importance, and a new id resets it.
abstract final class NotificationChannels {
  /// Notices, questions, background results: default importance.
  static const String alerts = 'hermes.alerts';

  /// A bot's messages while the app is away: high importance, as a chat.
  static const String messages = 'hermes.messages';

  /// The ongoing row of the foreground service: low importance.
  static const String connection = 'hermes.connection';

  /// The white status-bar vector (`res/drawable/ic_stat_notify.xml`).
  static const String smallIcon = 'ic_stat_notify';
}

/// A system notification to post: plain data, no plugin types.
@immutable
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.channelId,
    this.deepLink = '',
    this.tag = '',
  });

  /// Re-posting an id replaces the row.
  final int id;
  final String title;
  final String body;
  final String channelId;

  /// In-app route a tap opens; '' for none.
  final String deepLink;

  /// The handle a retraction uses (a notice `key`).
  final String tag;

  /// A stable id for [key], so a notice keeps its slot across restarts.
  /// Never 0, a common accidental default.
  static int idFor(String key) {
    final hash = stableHash(key);
    return hash == 0 ? 1 : hash;
  }
}
