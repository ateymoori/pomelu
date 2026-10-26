import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/features/sidebar/presentation/widgets/sidebar_frame.dart';

import '../../support/app_host.dart';

const _long = 'Stockholm Guide for rainy weekends, museums and food halls';

/// The width of a row's title in a side pane, with [inset] on the screen
/// edge the pane does not touch (its end edge).
Future<double> _titleWidth(
  WidgetTester tester, {
  required double inset,
  TextDirection direction = TextDirection.ltr,
}) async {
  final end = direction == TextDirection.ltr
      ? EdgeInsets.only(right: inset)
      : EdgeInsets.only(left: inset);
  await tester.pumpWidget(
    appHost(
      Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(padding: end),
          child: const SidebarFrame(
            width: 264,
            children: [
              Material(
                type: MaterialType.transparency,
                child: ListTile(title: Text(_long, maxLines: 1)),
              ),
            ],
          ),
        ),
      ),
      direction: direction,
    ),
  );
  return tester.getSize(find.text(_long)).width;
}

void main() {
  // The open iPhone Duo puts its status bar in a column on the chat's side.
  for (final direction in TextDirection.values) {
    testWidgets('a screen inset beside the chat leaves the side pane rows '
        'their width (${direction.name})', (tester) async {
      final plain = await _titleWidth(tester, inset: 0, direction: direction);
      final inset = await _titleWidth(tester, inset: 85, direction: direction);
      expect(inset, plain);
    });
  }
}
