import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/config/app_config.dart';
import '../../../hermes/models/local_attachment.dart';
import 'chat_message.dart';

part 'outbox.freezed.dart';
part 'outbox.g.dart';

/// Life of a turn the gateway has not acknowledged.
///
/// `sending` is the upload step: nothing reached the agent, so a restart may
/// queue it again. `submitted` means `prompt.submit` went out: the agent may
/// run it, so it is settled against the gateway, never sent blindly again.
/// `failed` waits for the user.
enum OutboxStatus { queued, sending, submitted, failed }

/// Why a turn was put back in line or waits for the user.
enum OutboxFailure {
  /// Stop was pressed while its files went up: nothing reached the agent.
  stopped,

  /// The gateway may have got it but does not hold it.
  unconfirmed,

  /// The frame never left: no connection.
  network,

  /// The gateway refused it.
  refused,

  /// It could not be read or sent on the phone (a file gone, a fault).
  local,
}

/// One outgoing turn, persisted the moment the user sends it. Its id is also
/// the id of its transcript row.
@freezed
abstract class OutboxEntry with _$OutboxEntry {
  const OutboxEntry._();

  const factory OutboxEntry({
    required String id,
    required DateTime createdAt,
    @Default('') String text,
    @Default(<LocalAttachment>[]) List<LocalAttachment> attachments,
    @Default(OutboxStatus.queued) OutboxStatus status,

    /// An unknown reason (an older app's text) reads as [OutboxFailure.local].
    @JsonKey(unknownEnumValue: OutboxFailure.local) OutboxFailure? error,
    @Default(0) int attempts,

    /// The prompt that went out with `prompt.submit`, so a turn of files alone
    /// can be found in the history again.
    String? sentText,
  }) = _OutboxEntry;

  factory OutboxEntry.fromJson(Map<String, dynamic> json) =>
      _$OutboxEntryFromJson(json);

  bool get isQueued => status == OutboxStatus.queued;
  bool get isSending => status == OutboxStatus.sending;
  bool get isSubmitted => status == OutboxStatus.submitted;
  bool get isFailed => status == OutboxStatus.failed;

  /// The user may still resend, edit or discard it. Once it is going out, or
  /// went out unanswered, a resend could run it twice.
  bool get isAmendable => isQueued || isFailed;

  bool get isEmpty => text.trim().isEmpty && attachments.isEmpty;
}

/// Pure transitions of the send queue, oldest first.
abstract final class Outbox {
  /// A full queue takes no new turn; nothing in it is ever dropped.
  static const int maxEntries = 50;

  /// Automatic attempts before an entry waits for the user.
  static const int maxAutoAttempts = 5;

  static OutboxEntry? find(List<OutboxEntry> q, String id) =>
      q.where((e) => e.id == id).firstOrNull;

  static List<OutboxEntry> enqueue(List<OutboxEntry> q, OutboxEntry e) =>
      e.isEmpty || q.length >= maxEntries ? q : List.unmodifiable([...q, e]);

  static List<OutboxEntry> remove(List<OutboxEntry> q, String id) =>
      List.unmodifiable(q.where((e) => e.id != id));

  static List<OutboxEntry> update(
    List<OutboxEntry> q,
    String id,
    OutboxEntry Function(OutboxEntry e) change,
  ) => List.unmodifiable([
    for (final e in q)
      if (e.id == id) change(e) else e,
  ]);

  static OutboxEntry sending(OutboxEntry e) => e.copyWith(
    status: OutboxStatus.sending,
    attempts: e.attempts + 1,
    error: null,
  );

  /// Back in line after a network miss; failed once the budget is spent.
  static OutboxEntry requeued(OutboxEntry e) => e.copyWith(
    status: e.attempts >= maxAutoAttempts
        ? OutboxStatus.failed
        : OutboxStatus.queued,
    error: OutboxFailure.network,
  );

  static OutboxEntry failed(OutboxEntry e, OutboxFailure error) =>
      e.copyWith(status: OutboxStatus.failed, error: error);

  /// A fresh start (manual retry, edit): new budget, no stale error.
  static OutboxEntry fresh(OutboxEntry e, {String? text}) => e.copyWith(
    text: text ?? e.text,
    status: OutboxStatus.queued,
    attempts: 0,
    error: null,
    sentText: null,
  );

  /// The next entry that may go out, or null. Order is part of the
  /// conversation: anything not waiting its turn holds the ones behind it.
  static OutboxEntry? next(List<OutboxEntry> q) =>
      q.firstOrNull?.isQueued ?? false ? q.first : null;

  /// Something to deliver or settle without the user.
  static bool hasWork(List<OutboxEntry> q) =>
      next(q) != null || q.any((e) => e.isSending || e.isSubmitted);

  /// After process death: an upload that was cut goes back in line; a
  /// submitted entry stays for settling.
  static List<OutboxEntry> rehydrate(List<OutboxEntry> q) => List.unmodifiable([
    for (final e in q)
      if (e.isSending) e.copyWith(status: OutboxStatus.queued) else e,
  ]);

  static DeliveryState delivery(OutboxStatus s) => switch (s) {
    OutboxStatus.queued => DeliveryState.queued,
    OutboxStatus.sending || OutboxStatus.submitted => DeliveryState.sending,
    OutboxStatus.failed => DeliveryState.failed,
  };

  /// [rows] with the queue drawn on them: a row in the queue takes the
  /// entry's state, a pending row whose entry is gone is delivered, and an
  /// entry with no row (after a cold start or a reload) gets one.
  static List<ChatMessage> project(
    List<ChatMessage> rows,
    List<OutboxEntry> q,
  ) {
    final byId = {for (final e in q) e.id: e};
    final out = <ChatMessage>[
      for (final row in rows)
        if (byId.remove(row.id) case final e?)
          row.copyWith(
            text: e.text,
            attachments: e.attachments,
            delivery: delivery(e.status),
          )
        else if (row.isUser && row.isPending)
          row.copyWith(delivery: DeliveryState.sent, error: null)
        else
          row,
    ];
    for (final e in byId.values) {
      out.add(
        ChatMessage(
          id: e.id,
          role: ChatRole.user,
          text: e.text,
          attachments: e.attachments,
          timestamp: e.createdAt,
          delivery: delivery(e.status),
        ),
      );
    }
    return List.unmodifiable(out);
  }

  /// Ids of the [entries] the gateway holds, by the user rows it reported
  /// ([evidence], oldest first). One row settles one entry.
  static Set<String> delivered(
    Iterable<OutboxEntry> entries,
    List<ChatMessage> evidence,
  ) {
    final rows = evidence.length > AppConfig.outboxLookback
        ? evidence.sublist(evidence.length - AppConfig.outboxLookback)
        : evidence;
    final used = <int>{};
    final out = <String>{};
    for (final e in entries) {
      final oldest = e.createdAt.subtract(AppConfig.outboxClockSkew);
      for (var i = 0; i < rows.length; i++) {
        final row = rows[i];
        if (used.contains(i) || !row.isUser) continue;
        if (row.timestamp?.isBefore(oldest) ?? false) continue;
        if (!_matches(e, row.text.trim())) continue;
        used.add(i);
        out.add(e.id);
        break;
      }
    }
    return out;
  }

  static bool _matches(OutboxEntry e, String text) {
    final words = e.text.trim();
    if (words.isEmpty) {
      final sent = e.sentText?.trim() ?? '';
      return sent.isNotEmpty && text == sent;
    }
    return e.attachments.isEmpty ? text == words : text.endsWith(words);
  }
}
