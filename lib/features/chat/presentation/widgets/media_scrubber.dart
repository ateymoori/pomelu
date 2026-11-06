import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/utils/l10n_ext.dart';

/// The seek bar of a video or audio player: played and buffered track, a
/// thumb to drag, a full touch target, one control for a screen reader.
///
/// While the thumb is held it follows the finger, not the player: the
/// player reports the old position for a moment after each seek, and the
/// thumb would jump back and forth.
class MediaScrubber extends StatefulWidget {
  const MediaScrubber({
    required this.position,
    required this.duration,
    required this.onSeek,
    super.key,
    this.buffered,
    this.onScrubStart,
    this.onScrubEnd,
    this.activeColor,
    this.inactiveColor,
    this.bufferedColor,
  });

  final Duration position;
  final Duration duration;

  /// How far the stream has loaded; null draws no buffer track.
  final Duration? buffered;

  /// Seeks the player; called while the thumb moves and where it lands.
  final ValueChanged<Duration> onSeek;

  /// The finger went down on the bar, and lifted again.
  final VoidCallback? onScrubStart;
  final VoidCallback? onScrubEnd;

  /// Track colors; default to the theme's slider.
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? bufferedColor;

  @override
  State<MediaScrubber> createState() => _MediaScrubberState();
}

class _MediaScrubberState extends State<MediaScrubber> {
  double? _held;

  int get _total => widget.duration.inMilliseconds;

  double _share(Duration d) =>
      _total == 0 ? 0 : (d.inMilliseconds / _total).clamp(0.0, 1.0);

  Duration _at(double share) =>
      Duration(milliseconds: (share * _total).round());

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final l10n = context.l10n;
    final buffered = widget.buffered;
    return SizedBox(
      // A full touch target to scrub in, not the sliver the thumb gives.
      height: spacing.minTouch,
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: spacing.xs,
          overlayShape: SliderComponentShape.noOverlay,
          activeTrackColor: widget.activeColor,
          thumbColor: widget.activeColor,
          inactiveTrackColor: widget.inactiveColor,
          secondaryActiveTrackColor: widget.bufferedColor,
        ),
        // One control for a screen reader: a name, the position, and the
        // slider's own increase / decrease.
        child: MergeSemantics(
          child: Semantics(
            label: l10n.mediaSeek,
            child: Slider(
              value: _held ?? _share(widget.position),
              secondaryTrackValue: buffered == null ? null : _share(buffered),
              semanticFormatterCallback: (v) => l10n.mediaAudioTime(
                Format.duration(_at(v)),
                Format.duration(widget.duration),
              ),
              onChangeStart: _total == 0
                  ? null
                  : (v) {
                      setState(() => _held = v);
                      widget.onScrubStart?.call();
                    },
              onChanged: _total == 0
                  ? null
                  : (v) {
                      setState(() => _held = v);
                      widget.onSeek(_at(v));
                    },
              onChangeEnd: _total == 0
                  ? null
                  : (v) {
                      widget.onSeek(_at(v));
                      setState(() => _held = null);
                      widget.onScrubEnd?.call();
                    },
            ),
          ),
        ),
      ),
    );
  }
}
