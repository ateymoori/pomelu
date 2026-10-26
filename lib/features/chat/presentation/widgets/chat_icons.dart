import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

import '../../domain/slash_command.dart';

/// The glyph of a slash command, in the palette and in its confirmation.
extension SlashCommandIcon on SlashCommand {
  IconData get icon => switch (this) {
    SlashCommand.newConversation => CupertinoIcons.square_pencil,
    SlashCommand.restart => CupertinoIcons.arrow_counterclockwise,
    SlashCommand.update => CupertinoIcons.arrow_down_circle,
    SlashCommand.compact => CupertinoIcons.arrow_down_right_arrow_up_left,
  };
}
