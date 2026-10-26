import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/core/theme/app_theme.dart';
import 'package:hermes/core/theme/avatar_palette.dart';
import 'package:hermes/core/theme/tokens.dart';
import 'package:hermes/features/chat/presentation/widgets/code_highlight.dart';

/// WCAG 2.2 AA: text (1.4.3), control edges and graphics (1.4.11).
const double _text = 4.5;
const double _graphic = 3;

Color _over(Color fg, Color bg) => Color.alphaBlend(fg, bg);

double _contrast(Color fg, Color bg) {
  final a = _over(fg, bg).computeLuminance();
  final b = bg.computeLuminance();
  return ((a > b ? a : b) + 0.05) / ((a > b ? b : a) + 0.05);
}

/// Fails with every pair in [pairs] (`name: (fg, bg)`) under [min].
void _expectAll(Map<String, (Color, Color)> pairs, double min) {
  final low = [
    for (final MapEntry(:key, value: (fg, bg)) in pairs.entries)
      if (_contrast(fg, bg) < min) key,
  ];
  expect(low, isEmpty, reason: 'under $min:1');
}

void main() {
  for (final (name, t) in [
    ('light', HermesTokens.light()),
    ('dark', HermesTokens.dark()),
  ]) {
    final c = t.colors;
    final s = t.surfaces;
    final levels = {
      'backdrop': c.backdropMid,
      'surface': s.surface,
      'surfaceElevated': s.surfaceElevated,
    };
    final quiet = {
      ...levels,
      'toolSurface': c.toolSurface,
      'codeBackground': c.codeBackground,
      'userBubble': c.userBubble,
    };
    final fills = {
      ...quiet,
      'surfacePressed': s.surfacePressed,
      for (final MapEntry(:key, :value) in levels.entries) ...{
        'accentSoft on $key': _over(c.accentSoft, value),
        'dangerSoft on $key': _over(c.dangerSoft, value),
      },
    };
    Map<String, (Color, Color)> on(
      String fgName,
      Color fg,
      Map<String, Color> bgs,
    ) => {for (final e in bgs.entries) '$fgName on ${e.key}': (fg, e.value)};

    test('$name: text reads at 4.5:1 wherever it sits', () {
      _expectAll({
        ...on('textPrimary', c.textPrimary, fills),
        ...on('textSecondary', c.textSecondary, fills),
        ...on('textTertiary', c.textTertiary, fills),
        ...on('accentText', c.accentText, {
          for (final e in fills.entries)
            if (!e.key.startsWith('dangerSoft')) e.key: e.value,
        }),
        ...on('success', c.success, {...quiet, 'pressed': s.surfacePressed}),
        ...on('warning', c.warning, quiet),
        ...on('danger', c.danger, {
          for (final e in fills.entries)
            if (!e.key.startsWith('accentSoft')) e.key: e.value,
        }),
        'onAccent': (c.onAccent, c.accent),
        'onDanger': (c.onDanger, c.danger),
        'snack bar text': (c.backdropMid, c.textPrimary),
        'snack bar action': (c.inverseAccent, c.textPrimary),
        'user bubble': (c.onUserBubble, c.userBubble),
        'viewer backdrop': (c.onScrim, c.scrim.withValues(alpha: 1)),
        'code': (c.codeText, c.codeBackground),
        for (var hue = 0; hue < 360; hue++)
          'avatar hue $hue': (c.onAccent, AvatarPalette.fill(hue.toDouble())),
        for (final (i, fill) in [
          c.files.pdf,
          c.files.document,
          c.files.sheet,
          c.files.slides,
          c.files.archive,
          c.files.code,
          c.files.text,
          c.files.image,
          c.files.video,
          c.files.audio,
          c.files.other,
        ].indexed)
          'file badge $i': (c.files.label, fill),
      }, _text);
    });

    test('$name: control edges and graphics reach 3:1', () {
      final edges = {...levels, 'userBubble': c.userBubble};
      _expectAll({
        ...on('inputOutline', c.inputOutline, edges),
        ...on('accent', c.accent, edges),
        for (final (i, series) in c.chart.indexed)
          ...on('chart[$i]', series, edges),
      }, _graphic);
    });

    test('$name: tracks and the destructive fill are visible', () {
      _expectAll(on('track', c.track, levels), 1.3);
      _expectAll({
        'dangerSoft on a dialog': (
          _over(c.dangerSoft, s.surfaceElevated),
          s.surfaceElevated,
        ),
      }, 1.25);
    });
  }

  for (final (name, theme) in [
    ('light', AppTheme.light()),
    ('dark', AppTheme.dark()),
  ]) {
    testWidgets('$name: every code highlight color reads', (tester) async {
      late Map<String, TextStyle> palette;
      late HermesColors colors;
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) {
              palette = CodeHighlight.themeOf(context);
              colors = context.colors;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      _expectAll({
        for (final MapEntry(:key, :value) in palette.entries)
          if (value.color != null) key: (value.color!, colors.codeBackground),
      }, _text);
    });
  }

  test('Increase Contrast: text reads at 7:1, control edges at 4.5:1 and '
      'hairlines at 3:1 on every level', () {
    for (final t in [
      HermesTokens.lightContrast(),
      HermesTokens.darkContrast(),
    ]) {
      final c = t.colors;
      final s = t.surfaces;
      for (final bg in [c.backdropMid, s.surface, s.surfaceElevated]) {
        _expectAll({
          'textSecondary': (c.textSecondary, bg),
          'textTertiary': (c.textTertiary, bg),
          'accentText': (c.accentText, bg),
        }, 7);
        _expectAll({'inputOutline': (c.inputOutline, bg)}, _text);
        _expectAll({'outline': (s.outline, bg)}, _graphic);
      }
    }
  });
}
