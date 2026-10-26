import '../../../core/config/app_config.dart';
import '../../../hermes/api/hermes_api.dart';
import '../../../hermes/models/profile.dart';
import '../../../hermes/models/session_message.dart';
import '../domain/notification_policy.dart';
import 'away_store.dart';
import 'notification_gateway.dart';

/// Posts what each bot wrote in its Bot Chat while the app was away: a cron
/// job's report, a background task's result, a reply that finished after
/// the app left the screen. The newest message per bot, each one once. The
/// app runs it on its socket's `sessions.changed`, the background check on
/// its own; both share [store].
Future<void> checkMessages({
  required HermesApi api,
  required AwayStore store,
  required NotificationGateway gateway,
  required NotificationPolicy policy,
  required String account,
}) async {
  if (!policy.canNotify) return;
  final away = await store.awaySince();
  if (away == null) return;
  final marks = await store.marks(account);
  var marked = false;
  for (final bot in await api.listProfiles()) {
    final chat = bot.canonicalSession;
    if (bot.isHidden || chat == null) continue;
    final mark = marks[bot.name];
    final moved = mark == null
        ? chat.lastActive?.isAfter(away) ?? false
        : chat.messageCount != mark.count;
    if (!moved) continue;
    final since = mark != null && mark.at.isAfter(away) ? mark.at : away;
    final rows = await api.storedMessages(
      storedId: chat.openId,
      profile: bot.name,
      limit: AppConfig.messageCheckRows,
    );
    final newest = rows.lastOrNull?.timestamp;
    marks[bot.name] = ChatMark(
      newest != null && newest.isAfter(since) ? newest : since,
      chat.messageCount,
    );
    marked = true;
    final reply = _newestReply(rows, since);
    if (reply == null) continue;
    final n = policy.forMessage(
      profile: bot.name,
      botTitle: bot.title,
      text: reply.body,
    );
    if (n != null) await gateway.show(n);
  }
  if (marked) await store.saveMarks(account, marks);
}

/// What the app has seen of [bots] at [at]: taken as it leaves the screen,
/// so a reply to a turn sent just before still counts as new.
Map<String, ChatMark> marksOf(List<HermesProfile> bots, DateTime at) => {
  for (final bot in bots)
    if (bot.canonicalSession case final chat?)
      bot.name: ChatMark(at, chat.messageCount),
};

SessionMessage? _newestReply(List<SessionMessage> rows, DateTime since) {
  for (final m in rows.reversed) {
    final at = m.timestamp;
    if (at == null || !at.isAfter(since)) return null;
    if (m.isAssistant && !m.isHidden && m.body.trim().isNotEmpty) return m;
  }
  return null;
}
