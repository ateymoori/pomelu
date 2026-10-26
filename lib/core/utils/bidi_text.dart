import 'package:flutter/widgets.dart';
// `intl` exports its own `TextDirection`; hide it so the Flutter one wins.
import 'package:intl/intl.dart' hide TextDirection;

/// Paragraph direction of user text, from its first strong character: a
/// Persian message in the LTR app keeps its punctuation on the right side.
TextDirection directionOf(String text) =>
    Bidi.detectRtlDirectionality(text) ? TextDirection.rtl : TextDirection.ltr;

/// Wraps [child] in the direction implied by [text].
Widget withTextDirection({required String text, required Widget child}) =>
    Directionality(textDirection: directionOf(text), child: child);

/// Not prose: code, link targets, addresses, HTML tags. A Persian reply with
/// an English code block is still a Persian reply.
final RegExp _notProse = RegExp(
  r'```[\s\S]*?(?:```|$)|~~~[\s\S]*?(?:~~~|$)|`[^`\n]*`|\]\([^)\s]*\)|https?://\S+|<[^>\n]+>',
);

/// Direction of a whole Markdown reply, from its prose.
TextDirection markdownDirection(String markdown) =>
    directionOf(markdown.replaceAll(_notProse, ' '));

/// One line of user text in chrome (a row's title or preview): its own
/// direction, on the chrome's start edge.
class ContentLine extends StatelessWidget {
  const ContentLine(this.text, {super.key, this.style, this.maxLines = 1});

  final String text;
  final TextStyle? style;
  final int maxLines;

  @override
  Widget build(BuildContext context) => Text(
    text,
    maxLines: maxLines,
    overflow: TextOverflow.ellipsis,
    style: style,
    textDirection: directionOf(text),
    textAlign: Directionality.of(context) == TextDirection.rtl
        ? TextAlign.right
        : TextAlign.left,
  );
}
