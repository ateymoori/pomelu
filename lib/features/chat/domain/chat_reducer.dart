import '../../../hermes/events/gateway_event.dart';
import '../../../hermes/events/turn_payloads.dart';
import '../../../hermes/hermes_failure.dart';
import 'chat_message.dart';
import 'chat_state.dart';

/// Pure transitions from live gateway events to [ChatState].
abstract final class ChatReducer {
  /// Applies one live event; unknown events change nothing.
  static ChatState apply(ChatState state, GatewayEvent ev, DateTime now) {
    final next = _apply(state, ev, now);
    // The plan is the running turn's: a finished turn's would linger.
    return state.running && !next.running ? next.copyWith(plan: null) : next;
  }

  static ChatState _apply(ChatState state, GatewayEvent ev, DateTime now) {
    switch (ev.type) {
      case EventNames.messageStart:
        // A stop is on its way: a late start must not revive the turn.
        if (state.stopRequested) return state;
        return _stream(state, now).copyWith(
          running: true,
          error: null,
          statusLine: '',
          plan: state.running ? state.plan : null,
        );
      case EventNames.todoUpdated:
        final plan = ev.todoPlan;
        final old = state.plan;
        if (old != null && plan.revision < old.revision) return state;
        return state.copyWith(plan: plan.items.isEmpty ? null : plan);
      case EventNames.messageDelta:
        return delta(state, ev.text(), now);
      case EventNames.reasoningDelta:
        return _edit(
          state,
          now,
          (m) => m.copyWith(reasoning: m.reasoning + ev.text()),
        ).copyWith(running: true);
      case EventNames.reasoningAvailable:
        final t = ev.text();
        return _edit(
          state,
          now,
          (m) => t.isEmpty ? m : m.copyWith(reasoning: t),
        );
      case EventNames.thinkingDelta:
        return state.copyWith(thinkingLabel: ev.text(), running: true);
      case EventNames.toolGenerating:
        return state.copyWith(thinkingLabel: ev.generatingTool, running: true);
      case EventNames.messageInterim:
        final interim = ev.interim;
        if (interim.alreadyStreamed) return state;
        final parsed = parseMedia(interim.text);
        return _edit(
          state,
          now,
          (m) => m.copyWith(
            text: m.text.isEmpty ? parsed.text : '${m.text}\n\n${parsed.text}',
            media: [...m.media, ...parsed.media],
            streaming: false,
            interim: true,
          ),
        );
      case EventNames.toolStart || EventNames.toolProgress:
        return _tool(_stream(state, now), ev.tool, done: false);
      case EventNames.toolComplete:
        return _tool(_stream(state, now), ev.tool, done: true);
      case EventNames.messageComplete:
        return complete(state, ev.turnComplete, now);
      case EventNames.error:
        return seal(state).copyWith(
          running: false,
          stopRequested: false,
          thinkingLabel: '',
          error: ServerFailure(ev.errorMessage),
        );
      case EventNames.statusUpdate:
        return state.copyWith(statusLine: ev.text());
      case EventNames.sessionInfo:
        final info = ev.sessionInfo;
        String or(String fresh, String old) => fresh.isNotEmpty ? fresh : old;
        var s = state.copyWith(
          model: or(info.model, state.model),
          effort: or(info.reasoningEffort, state.effort),
          provider: or(info.provider, state.provider),
        );
        final running = info.running;
        if (running ?? false) s = s.copyWith(running: true);
        if (running == false) {
          s = seal(s).copyWith(
            running: false,
            stopRequested: false,
            thinkingLabel: '',
            statusLine: '',
          );
        }
        return s;
      default:
        return state;
    }
  }

  /// Adds [text] to the streaming reply.
  static ChatState delta(ChatState state, String text, DateTime now) => _edit(
    state,
    now,
    (m) => m.copyWith(text: m.text + text),
  ).copyWith(running: true, thinkingLabel: '');

  /// Ends the turn with [c]: its whole text, reasoning and status.
  static ChatState complete(ChatState s, TurnComplete c, DateTime now) {
    final st = _edit(s, now, (m) {
      // The complete frame carries the whole text.
      if (c.text.isNotEmpty) {
        final parsed = parseMedia(c.text);
        m = m.copyWith(text: parsed.text, media: [...m.media, ...parsed.media]);
      }
      if (c.reasoning.isNotEmpty && m.reasoning.isEmpty) {
        m = m.copyWith(reasoning: c.reasoning);
      }
      return m.copyWith(
        streaming: false,
        error: c.status == TurnStatus.error ? c.error : m.error,
      );
    });
    return st.copyWith(
      running: false,
      stopRequested: false,
      thinkingLabel: '',
      statusLine: c.status == TurnStatus.interrupted ? c.status : '',
    );
  }

  /// Ends the streaming reply, dropping it when it showed nothing.
  static ChatState seal(ChatState s) {
    final m = s.streamingMessage;
    if (m == null) return s;
    return _put(s, m.copyWith(streaming: false));
  }

  static ChatState _stream(ChatState s, DateTime now) =>
      s.streamingMessage != null
      ? s
      : s.copyWith(
          messages: [
            ...s.messages,
            ChatMessage(
              id: 'live-${now.microsecondsSinceEpoch}-${s.messages.length}',
              role: ChatRole.assistant,
              streaming: true,
              timestamp: now,
            ),
          ],
        );

  static ChatState _edit(
    ChatState s,
    DateTime now,
    ChatMessage Function(ChatMessage m) change,
  ) {
    final st = _stream(s, now);
    return _put(st, change(st.streamingMessage!));
  }

  static ChatState _put(ChatState s, ChatMessage m) => s.copyWith(
    messages: [
      for (final x in s.messages)
        if (x.id != m.id)
          x
        else if (m.streaming || !m.isEmptyVisual || m.error != null)
          m,
    ],
  );

  static ChatState _tool(ChatState s, ToolEvent ev, {required bool done}) {
    final m = s.streamingMessage!;
    final id = _toolId(ev, m);
    final at = m.tools.indexWhere((t) => t.id == id);
    final prev = at < 0 ? null : m.tools[at];
    String? pick(String fresh, String? old) => fresh.isNotEmpty ? fresh : old;
    final tool = ToolCall(
      id: id,
      name: ev.name.isNotEmpty ? ev.name : (prev?.name ?? 'tool'),
      context: pick(ev.context, prev?.context) ?? '',
      state: !done
          ? ToolState.running
          : (ev.failed ? ToolState.failed : ToolState.done),
      resultText: done ? ev.resultText : prev?.resultText,
      inlineDiff: pick(ev.inlineDiff, prev?.inlineDiff),
      durationSeconds: ev.durationSeconds ?? prev?.durationSeconds,
    );
    final tools = [...m.tools];
    if (at < 0) {
      tools.add(tool);
    } else {
      tools[at] = tool;
    }
    return _put(
      s,
      m.copyWith(tools: tools),
    ).copyWith(running: true, thinkingLabel: done ? '' : s.thinkingLabel);
  }

  static String _toolId(ToolEvent ev, ChatMessage m) {
    if (ev.id.isNotEmpty) return ev.id;
    final running = m.tools.reversed.where(
      (t) => t.state == ToolState.running && t.name == ev.name,
    );
    return running.firstOrNull?.id ?? 'live-tool-${ev.name}-${m.tools.length}';
  }
}
