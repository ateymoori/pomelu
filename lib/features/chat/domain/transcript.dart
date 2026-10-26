import '../../../hermes/events/gateway_event.dart';
import '../../../hermes/events/turn_payloads.dart';
import '../../../hermes/models/session_message.dart';
import '../../../hermes/models/session_resume.dart';
import 'chat_message.dart';
import 'chat_reducer.dart';
import 'chat_state.dart';

/// Pure reads and rebuilds of the transcript rows.
abstract final class Transcript {
  /// Rows from a saved transcript. One agent turn is saved as an assistant
  /// row per tool call; they fold into one row, as the turn read live.
  static List<ChatMessage> fromHistory(List<SessionMessage> rows) {
    final out = <ChatMessage>[];
    var i = 0;
    for (final r in rows) {
      if (r.isHidden) continue;
      i++;
      final last = out.lastOrNull;
      if (r.isTool) {
        final tool = ToolCall(
          id: 'h-tool-$i',
          name: r.toolName ?? 'tool',
          context: r.context,
          state: ToolState.done,
        );
        if (last != null && last.isAssistant) {
          out.last = last.copyWith(tools: [...last.tools, tool]);
        } else {
          out.add(
            ChatMessage(
              id: 'h-$i',
              role: ChatRole.assistant,
              tools: [tool],
              timestamp: r.timestamp,
            ),
          );
        }
        continue;
      }
      final role = switch (r.role) {
        'user' => ChatRole.user,
        'system' => ChatRole.system,
        _ => ChatRole.assistant,
      };
      final parsed = parseMedia(r.body);
      final row = ChatMessage(
        id: r.durableId != null ? 'row-${r.durableId}' : 'h-$i',
        role: role,
        text: parsed.text,
        media: parsed.media,
        reasoning: r.reasoningText ?? '',
        timestamp: r.timestamp,
        rowId: r.durableId,
      );
      if (role == ChatRole.assistant && last != null && last.isAssistant) {
        if (row.isEmptyVisual) continue;
        if (last.text.trim().isEmpty && last.media.isEmpty) {
          out.last = row.copyWith(
            tools: last.tools,
            reasoning: [
              last.reasoning,
              row.reasoning,
            ].where((t) => t.isNotEmpty).join('\n\n'),
          );
          continue;
        }
      }
      out.add(row);
    }
    return out;
  }

  /// The same user and assistant words in the same order: a loaded
  /// transcript that matches what live events drew.
  static bool sameConversation(List<ChatMessage> a, List<ChatMessage> b) {
    List<(ChatRole, String)> words(List<ChatMessage> rows) => [
      for (final m in rows)
        if (!m.isCommand &&
            (m.isUser || m.isAssistant) &&
            m.text.trim().isNotEmpty)
          (m.role, m.text.trim()),
    ];
    final x = words(a);
    final y = words(b);
    if (x.length != y.length) return false;
    for (var i = 0; i < x.length; i++) {
      if (x[i] != y[i]) return false;
    }
    return true;
  }

  /// Index of the user row that opens the turn of row [index], or null (a
  /// greeting or a cron run has no turn to undo).
  static int? turnStart(List<ChatMessage> rows, int index) {
    for (var i = index; i >= 0; i--) {
      if (rows[i].isUser && !rows[i].isCommand) return i;
    }
    return null;
  }

  /// Saved user turns from [start] to the end.
  static int turnsFrom(List<ChatMessage> rows, int start) => rows
      .skip(start)
      .where((m) => m.isUser && !m.isCommand && !m.isPending)
      .length;

  /// The row of [after] (a fresh load) that is [row] of [before]: same role
  /// and text, counted from the end so repeated rows pair up.
  static ChatMessage? matchReloaded(
    ChatMessage row,
    List<ChatMessage> before,
    List<ChatMessage> after,
  ) {
    bool same(ChatMessage m) =>
        !m.isCommand && m.role == row.role && m.text.trim() == row.text.trim();
    final from = before.indexWhere((m) => m.id == row.id);
    if (from < 0) return null;
    final laterTwins = before.skip(from + 1).where(same).length;
    final twins = after.where(same).toList();
    final at = twins.length - 1 - laterTwins;
    return at < 0 ? null : twins[at];
  }

  /// [history] with the command rows of [current] put back, each before the
  /// first row stamped after it. The gateway never stores them.
  static List<ChatMessage> withCommands(
    List<ChatMessage> history,
    List<ChatMessage> current,
  ) {
    final notes = current.where((m) => m.isCommand).toList();
    if (notes.isEmpty) return history;
    final out = <ChatMessage>[];
    var n = 0;
    for (final row in history) {
      final at = row.timestamp;
      while (at != null &&
          n < notes.length &&
          (notes[n].timestamp?.isBefore(at) ?? false)) {
        out.add(notes[n++]);
      }
      out.add(row);
    }
    return [...out, ...notes.skip(n)];
  }

  /// Rows of conversation [storedId] as read-only earlier rows: unique ids,
  /// no gateway row id, sealed, closed by a boundary.
  static List<ChatMessage> asEarlier(String storedId, List<ChatMessage> rows) =>
      [
        for (final m in rows)
          if (!m.isPending)
            m.copyWith(id: '$storedId/${m.id}', rowId: null, streaming: false),
        ChatMessage(
          id: 'boundary/$storedId',
          role: ChatRole.system,
          boundary: true,
        ),
      ];

  static const String _inflight = 'inflight-user/';
  static const String _queued = 'queued-user/';

  /// [s] with what the resumed session [r] is in the middle of: the running
  /// turn (its words, the reply so far, its error) and the prompt queued
  /// behind it. Rows of an earlier restore give way, so nothing is doubled.
  static ChatState restoreInflight(ChatState s, SessionResume r, DateTime now) {
    final inflight = r.inflight;
    final queued = r.queued?.user ?? '';
    if (inflight == null && queued.isEmpty) return s;
    ChatMessage user(String prefix, String text) => ChatMessage(
      id: '$prefix${r.sessionId}',
      role: ChatRole.user,
      text: text,
      timestamp: now,
    );
    var st = s.copyWith(
      messages: [
        for (final m in s.messages)
          if (!m.id.startsWith(_inflight) &&
              !m.id.startsWith(_queued) &&
              !(m.isAssistant && m.streaming))
            m,
      ],
    );
    if (inflight != null) {
      if (inflight.user.isNotEmpty &&
          st.messages.lastOrNull?.text != inflight.user) {
        st = st.copyWith(
          messages: [...st.messages, user(_inflight, inflight.user)],
        );
      }
      if (inflight.assistant.isNotEmpty) {
        st = ChatReducer.delta(st, inflight.assistant, now);
      }
      if (inflight.error case final error?) {
        st = ChatReducer.complete(
          st,
          TurnComplete(
            status: TurnStatus.error,
            error: error,
            text: inflight.assistant,
          ),
          now,
        );
      }
    }
    if (queued.isNotEmpty) {
      st = st.copyWith(messages: [...st.messages, user(_queued, queued)]);
    }
    return st.copyWith(running: r.running || st.running);
  }
}
