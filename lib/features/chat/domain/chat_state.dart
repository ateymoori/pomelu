import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../hermes/events/event_payloads.dart';
import '../../../hermes/hermes_failure.dart';
import '../../../hermes/models/todo_plan.dart';
import 'chat_message.dart';
import 'outbox.dart';

part 'chat_state.freezed.dart';

/// Which file of how many a send is uploading. The gateway takes whole
/// base64 frames, so there is no honest byte progress.
typedef UploadProgress = ({int done, int total, String name});

/// Snapshot of one open chat.
@freezed
abstract class ChatState with _$ChatState {
  const ChatState._();

  const factory ChatState({
    /// Bound to the socket; changes on every resume.
    @Default('') String runtimeId,

    /// Durable id, for resumes.
    @Default('') String storedId,
    @Default('') String profile,
    @Default(<ChatMessage>[]) List<ChatMessage> messages,
    @Default(false) bool loading,
    @Default(false) bool running,
    @Default(false) bool stopRequested,
    @Default('') String statusLine,
    @Default('') String thinkingLabel,
    HermesFailure? error,
    @Default('') String model,
    @Default('') String effort,
    @Default('') String provider,

    /// The agent's plan for the running turn; null when it keeps none.
    TodoPlan? plan,

    /// Token counters of the session when it opened, for the context ring.
    SessionUsage? openingUsage,

    /// Turns the gateway has not acknowledged yet, persisted.
    @Default(<OutboxEntry>[]) List<OutboxEntry> outbox,
    @Default(false) bool online,
    UploadProgress? upload,

    /// Gateway row ids hidden on this phone.
    @Default(<int>{}) Set<int> hidden,

    /// Earlier conversations, oldest first, each closed by a boundary row.
    @Default(<ChatMessage>[]) List<ChatMessage> earlier,

    /// Stored id of the oldest conversation on screen; empty means the open one.
    @Default('') String earlierCursor,
    @Default(false) bool earlierDone,

    /// The transcript could not be read; the next connection or Retry reads it.
    @Default(false) bool historyStale,
  }) = _ChatState;

  ChatMessage? get streamingMessage =>
      messages.reversed.where((m) => m.isAssistant && m.streaming).firstOrNull;

  /// Bound and loaded.
  bool get isReady => runtimeId.isNotEmpty && !loading;

  /// Weaker than [isReady] on purpose: work typed offline is queued.
  bool get canCompose => !loading;

  bool get canDeliver => isReady && online;

  /// Turns still on their way.
  int get queuedCount => outbox.where((e) => !e.isFailed).length;

  int get failedCount => outbox.where((e) => e.isFailed).length;
}
