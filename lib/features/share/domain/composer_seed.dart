import '../../../hermes/models/local_attachment.dart';

/// What to pre-fill a chat composer with (a share, a link, a quote); taken
/// once by the chat view.
class ComposerSeed {
  const ComposerSeed({this.text = '', this.attachments = const []});

  final String text;

  final List<LocalAttachment> attachments;

  bool get isEmpty => text.isEmpty && attachments.isEmpty;
}
