import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import '../../../core/theme/avatar_palette.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/app_logger.dart';
import 'widgets/avatar.dart';

/// Pixels of an icon's side: Android's 108 dp adaptive icon at 4x.
const double _side = 432;

/// A bot's avatar for the system (`AppShortcuts`), as a PNG: the sidebar's
/// round avatar, [picture] or the letter on its fill, across the middle
/// [fill] of the side, clear around it. Android's adaptive icon shows its
/// middle two thirds (a plain bitmap would get the launcher's white tile).
/// Null when it cannot be drawn.
Future<Uint8List?> shortcutIcon({
  required String title,
  required double fill,
  Uint8List? picture,
}) async {
  try {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final circle = Rect.fromCenter(
      center: const Offset(_side / 2, _side / 2),
      width: _side * fill,
      height: _side * fill,
    );
    canvas.clipPath(Path()..addOval(circle));
    final image = picture == null ? null : await _decode(picture);
    if (image != null) {
      final src =
          Offset.zero & Size(image.width.toDouble(), image.height.toDouble());
      final fit = applyBoxFit(BoxFit.cover, src.size, circle.size);
      canvas.drawImageRect(
        image,
        Alignment.center.inscribe(fit.source, src),
        circle,
        Paint()..filterQuality = FilterQuality.high,
      );
      image.dispose();
    } else {
      canvas.drawRect(
        circle,
        Paint()..color = AvatarPalette.fill(HermesAvatar.hueOf(title)),
      );
      final letter = TextPainter(
        text: TextSpan(
          text: HermesAvatar.letterOf(title),
          style: TextStyle(
            color: HermesColors.light().onAccent,
            fontSize: circle.height / 2,
            fontWeight: FontWeight.w600,
            height: 1,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      letter.paint(
        canvas,
        circle.center - Offset(letter.width / 2, letter.height / 2),
      );
      letter.dispose();
    }
    final drawn = await recorder.endRecording().toImage(
      _side.toInt(),
      _side.toInt(),
    );
    final png = await drawn.toByteData(format: ui.ImageByteFormat.png);
    drawn.dispose();
    return png?.buffer.asUint8List();
  } on Object catch (e) {
    log.w('shortcut icon of $title not drawn', error: e);
    return null;
  }
}

Future<ui.Image?> _decode(Uint8List bytes) async {
  try {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    codec.dispose();
    return frame.image;
  } on Object catch (e) {
    log.w('bot picture unreadable', error: e);
    return null;
  }
}
