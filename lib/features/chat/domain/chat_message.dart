import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../hermes/hermes_constants.dart';
import '../../../hermes/models/local_attachment.dart';

part 'chat_message.freezed.dart';

enum ChatRole { user, assistant, system }

/// How far an outgoing row got. `queued` waits for a connection, `failed`
/// waits for the user.
enum DeliveryState { sent, queued, sending, failed }

enum ToolState { running, done, failed }

/// One row of the chat. Assistant rows grow from streamed events; user rows
/// are optimistic until the gateway acknowledges them.
@freezed
abstract class ChatMessage with _$ChatMessage {
  const ChatMessage._();

  const factory ChatMessage({
    required String id,
    required ChatRole role,
    @Default('') String text,
    @Default('') String reasoning,
    @Default(<ToolCall>[]) List<ToolCall> tools,
    DateTime? timestamp,

    /// The gateway's durable row id; live rows get it on the next reload.
    int? rowId,
    @Default(false) bool streaming,
    @Default(false) bool interim,
    @Default(DeliveryState.sent) DeliveryState delivery,
    String? error,
    @Default(<LocalAttachment>[]) List<LocalAttachment> attachments,
    @Default(<MediaRef>[]) List<MediaRef> media,

    /// The slash command typed, for a command row.
    String? command,

    /// The line that ends one conversation with the bot. Carries no text.
    @Default(false) bool boundary,
  }) = _ChatMessage;

  bool get isUser => role == ChatRole.user;
  bool get isAssistant => role == ChatRole.assistant;
  bool get isCommand => command != null;

  /// Not acknowledged by the gateway yet.
  bool get isPending => delivery != DeliveryState.sent;

  bool get isEmptyVisual =>
      text.trim().isEmpty &&
      reasoning.isEmpty &&
      tools.isEmpty &&
      media.isEmpty &&
      attachments.isEmpty;

  /// Reasoning worth showing. Hermes echoes the answer as reasoning for models
  /// that report none, so text that only repeats the reply is dropped.
  String get visibleReasoning {
    final r = reasoning.trim();
    final t = text.trim();
    if (r.isEmpty || t.isEmpty) return r;
    String squash(String v) => v.replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
    final rs = squash(r);
    final ts = squash(t);
    return rs == ts || ts.startsWith(rs) || rs.startsWith(ts) ? '' : r;
  }
}

/// A tool invocation shown as an activity row.
@freezed
abstract class ToolCall with _$ToolCall {
  const factory ToolCall({
    required String id,
    required String name,
    @Default('') String context,
    @Default(ToolState.running) ToolState state,
    String? resultText,
    String? inlineDiff,
    double? durationSeconds,
  }) = _ToolCall;
}

/// A file on the gateway that a message names (`MEDIA:` lines, `@image:`
/// refs, inline data URLs).
@freezed
abstract class MediaRef with _$MediaRef {
  const MediaRef._();

  const factory MediaRef({
    required String path,
    required AttachmentKind kind,
    String? dataUrl,
  }) = _MediaRef;

  String get fileName => path.split('/').last;
}

final RegExp _mediaLine = RegExp(
  '''(^|\\n)[\\t ]*[`"']?${RegExp.escape(HermesProtocol.mediaLinePrefix)}'''
  r'''\s*(`[^`\n]+`|"[^"\n]+"|'[^'\n]+'|\S+)[`"']?[\t ]*(?=\n|$)''',
);
final RegExp _imageRef = RegExp(
  '(^|\\n)[\\t ]*${RegExp.escape(HermesProtocol.imageRefPrefix)}'
  r'(\S+)[\t ]*(?=\n|$)',
);
final RegExp _inlineData = RegExp(
  'data:image/[a-zA-Z0-9.+-]+;base64,[A-Za-z0-9+/=]+',
);
final RegExp _screenshot = RegExp(r'(^|\n)[\t ]*\[screenshot\][\t ]*(?=\n|$)');
final RegExp _blankRun = RegExp(r'\n[\t ]*\n([\t ]*\n)+');

/// Lifts gateway media out of [input]: `MEDIA: <path>` lines (quoted or
/// bare), `@image:<path>` refs and inline `data:image/...` URLs. Returns the
/// text without them and the refs found.
({String text, List<MediaRef> media}) parseMedia(String input) {
  if (input.isEmpty) return (text: input, media: const []);
  final media = <MediaRef>[];
  String unquote(String s) {
    if (s.length < 2) return s;
    final a = s[0];
    return (a == '`' || a == '"' || a == "'") && a == s[s.length - 1]
        ? s.substring(1, s.length - 1)
        : s;
  }

  final text = input
      .replaceAllMapped(_mediaLine, (m) {
        final path = unquote(m.group(2)!);
        media.add(
          MediaRef(
            path: path,
            kind: LocalAttachment.kindForMime(
              LocalAttachment.mimeForPath(path),
            ),
          ),
        );
        return m.group(1) ?? '';
      })
      .replaceAllMapped(_imageRef, (m) {
        media.add(MediaRef(path: m.group(2)!, kind: AttachmentKind.image));
        return m.group(1) ?? '';
      })
      .replaceAllMapped(_inlineData, (m) {
        media.add(
          MediaRef(path: '', kind: AttachmentKind.image, dataUrl: m.group(0)),
        );
        return '';
      })
      .replaceAll(_screenshot, '')
      .replaceAll(_blankRun, '\n\n');
  return (text: text.trim(), media: media);
}
