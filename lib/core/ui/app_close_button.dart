import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

import 'app_icon_button.dart';

/// The close button of a full-screen page: an ✕ in a glass circle, floating
/// at the start of the page bar.
class AppCloseButton extends StatelessWidget {
  const AppCloseButton({required this.onPressed, super.key});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => AppIconButton(
    icon: CupertinoIcons.xmark,
    tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
    onPressed: onPressed,
    disc: true,
  );
}
