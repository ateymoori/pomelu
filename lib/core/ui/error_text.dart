import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// A failure said in a line under or over what failed: small, in the danger
/// color, and announced when it appears. The caller pads it.
class ErrorText extends StatelessWidget {
  const ErrorText(this.text, {super.key, this.textAlign});

  final String text;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Text(
      text,
      textAlign: textAlign,
      style: Theme.of(context).textTheme.bodySmall
          ?.copyWith(color: context.colors.danger),
    ),
  );
}
