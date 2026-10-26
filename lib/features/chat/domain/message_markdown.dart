import '../../../hermes/models/local_attachment.dart';
import 'chat_message.dart';

/// Markdown of [m] with what the bubble swallows: reasoning worth showing,
/// tools, attachments and media.
String messageMarkdown(ChatMessage m) => [
  if (m.visibleReasoning.trim().isNotEmpty) quoteMarkdown(m.visibleReasoning),
  for (final t in m.tools)
    '`${t.context.isEmpty ? t.name : '${t.name} — ${t.context}'}`',
  if (m.text.trim().isNotEmpty) m.text.trim(),
  for (final a in m.attachments)
    '${a.isImage ? '!' : ''}[${a.name}](${a.path})',
  for (final r in m.media)
    '${r.kind == AttachmentKind.image ? '!' : ''}[${r.fileName}](${r.path})',
].join('\n\n');

/// A block quote, one `> ` per line.
String quoteMarkdown(String text) => text
    .trim()
    .split('\n')
    .map((l) => l.trimRight().isEmpty ? '>' : '> ${l.trimRight()}')
    .join('\n');
