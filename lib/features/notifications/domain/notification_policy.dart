import 'package:flutter/foundation.dart';

import '../../../app/routes.dart';
import '../../../hermes/events/event_payloads.dart';
import '../../../hermes/hermes_constants.dart';
import '../../../hermes/requests/server_request.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'app_notification.dart';

/// What the user looks at: the app in front, and the bot whose chat is open.
@immutable
class ActiveView {
  const ActiveView({this.isForeground = false, this.profile = ''});

  /// Nothing on screen: the app is away.
  static const ActiveView background = ActiveView();

  final bool isForeground;

  /// The bot of the open chat; empty off a chat.
  final String profile;

  /// The chat of [ref] is on screen. Each bot has one chat, so the bot is
  /// the conversation; a session whose bot is not known yet never is.
  bool isWatching(SessionRef? ref) =>
      isForeground &&
      ref != null &&
      profile.isNotEmpty &&
      ref.profile == profile;
}

/// Whether a gateway signal becomes a system notification, and what it says.
/// Pure: no I/O.
class NotificationPolicy {
  const NotificationPolicy({
    required this.enabled,
    required this.permissionGranted,
    required this.l10n,
  });

  /// The Settings toggle.
  final bool enabled;

  /// `POST_NOTIFICATIONS` granted.
  final bool permissionGranted;
  final AppLocalizations l10n;

  bool get canNotify => enabled && permissionGranted;

  /// A `notification.show` notice. Quiet for the chat on screen, and for a
  /// transient toast (`ttl_ms`) in the foreground: that one is for the app.
  AppNotification? forNotice(
    GatewayNotice notice, {
    required ActiveView view,
    SessionRef? ref,
  }) {
    if (!canNotify || view.isWatching(ref)) return null;
    if (view.isForeground && notice.ttlMs != null && !notice.isError) {
      return null;
    }
    return AppNotification(
      id: AppNotification.idFor(notice.dedupeKey),
      title: switch (notice.level) {
        GatewayNotice.levelError => l10n.notificationErrorTitle,
        GatewayNotice.levelWarning => l10n.notificationWarningTitle,
        _ => l10n.notificationNoticeTitle,
      },
      body: notice.text,
      channelId: NotificationChannels.alerts,
      deepLink: deepLinkFor(ref),
      tag: notice.dedupeKey,
    );
  }

  /// A delegated run that finished (`background.complete`).
  AppNotification? forBackground(
    BackgroundResult result, {
    required ActiveView view,
    SessionRef? ref,
  }) {
    if (!canNotify || result.text.isEmpty || view.isWatching(ref)) {
      return null;
    }
    return AppNotification(
      id: AppNotification.idFor('bg/${result.sessionId}/${result.taskId}'),
      title: result.isError
          ? l10n.notificationBackgroundFailedTitle
          : l10n.notificationBackgroundTitle,
      body: _summarize(result.text),
      channelId: NotificationChannels.alerts,
      deepLink: deepLinkFor(ref),
      tag: 'bg/${result.taskId}',
    );
  }

  /// A question the agent is blocked on. Says what is asked, never an answer
  /// or a value.
  AppNotification? forRequest(
    ServerRequest request, {
    required ActiveView view,
    SessionRef? ref,
  }) {
    if (!canNotify || view.isWatching(ref)) return null;
    final (title, body) = switch (request) {
      ClarifyRequest(:final questions) => (
        l10n.notificationQuestionTitle,
        questions
            .map((q) => q.question)
            .join(l10n.notificationQuestionSeparator),
      ),
      ApprovalRequest(:final command, :final description) => (
        l10n.notificationApprovalTitle,
        command.isNotEmpty ? command : description,
      ),
      InputRequest(:final prompt, :final subject) => (
        l10n.notificationInputTitle,
        prompt.isNotEmpty ? prompt : subject,
      ),
    };
    return AppNotification(
      id: AppNotification.idFor(requestTag(request.id)),
      title: title,
      body: _summarize(body),
      channelId: NotificationChannels.alerts,
      deepLink: deepLinkFor(ref),
      tag: requestTag(request.id),
    );
  }

  /// The newest of the messages bot [profile] wrote while the app was away.
  /// One row per bot: a later message replaces it, as in a messenger.
  AppNotification? forMessage({
    required String profile,
    required String botTitle,
    required String text,
  }) {
    if (!canNotify || text.trim().isEmpty) return null;
    // A file arrives as a `MEDIA:` line with a path on the gateway's disk.
    final words = text
        .split('\n')
        .where((l) => !l.trimLeft().startsWith(HermesProtocol.mediaLinePrefix))
        .join('\n');
    return AppNotification(
      id: AppNotification.idFor(messageTag(profile)),
      title: botTitle,
      body: words.trim().isEmpty
          ? l10n.notificationMessageAttachment
          : _summarize(words),
      channelId: NotificationChannels.messages,
      deepLink: Routes.chatPath(profile),
      tag: messageTag(profile),
    );
  }

  /// The tag of request [id]'s notification, retracted once it is answered.
  static String requestTag(String id) => 'request/$id';

  /// The tag of bot [profile]'s message row, retracted when its chat opens.
  static String messageTag(String profile) => 'message/$profile';

  /// The bot's chat, or home when the bot is not known.
  static String deepLinkFor(SessionRef? ref) => ref == null || !ref.canDeepLink
      ? Routes.home
      : Routes.chatPath(ref.profile);

  /// The shade shows two lines: a long answer is cut so they are useful.
  static String _summarize(String text, {int limit = 240}) {
    final flat = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (flat.length <= limit) return flat;
    return '${flat.substring(0, limit).trimRight()}…';
  }
}
