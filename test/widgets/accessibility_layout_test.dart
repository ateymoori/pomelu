import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/core/theme/app_theme.dart';
import 'package:hermes/core/theme/tokens.dart' show Spacing;
import 'package:hermes/core/ui/ui.dart';
import 'package:hermes/features/chat/domain/chat_message.dart';
import 'package:hermes/features/chat/domain/chat_target.dart';
import 'package:hermes/features/chat/presentation/widgets/attachment_thumb.dart';
import 'package:hermes/features/chat/presentation/widgets/markdown_details.dart';
import 'package:hermes/features/chat/presentation/widgets/reasoning_chip.dart';
import 'package:hermes/features/chat/presentation/widgets/tool_card.dart';
import 'package:hermes/features/chat/presentation/widgets/user_message.dart';
import 'package:hermes/features/connection/presentation/connection_providers.dart';
import 'package:hermes/features/settings/presentation/widgets/settings_section.dart';
import 'package:hermes/features/sidebar/presentation/widgets/avatar.dart';
import 'package:hermes/hermes/models/local_attachment.dart';
import 'package:hermes/l10n/generated/app_localizations.dart';

const _spacing = Spacing();

/// [child] in the app theme on a screen [width] dp wide at [scale] text.
Widget _host(
  Widget child, {
  double width = 344,
  double scale = 1,
  bool reduceMotion = false,
}) => ProviderScope(
  overrides: [hermesApiProvider.overrideWithValue(null)],
  child: MaterialApp(
    theme: AppTheme.light(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          size: Size(width, 800),
          textScaler: TextScaler.linear(scale),
          disableAnimations: reduceMotion,
        ),
        child: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(width: width, child: child),
          ),
        ),
      ),
    ),
  ),
);

void _useWidth(WidgetTester tester, double width) {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  group('confirm dialog', () {
    for (final width in [344.0, 840.0]) {
      testWidgets('fits at $width dp and 2x text', (tester) async {
        _useWidth(tester, width);
        await tester.pumpWidget(
          _host(
            Builder(
              builder: (context) => TextButton(
                onPressed: () => showConfirmDialog(
                  context,
                  title: 'Delete this conversation?',
                  body: 'It is removed from the gateway for good.',
                  confirmLabel: 'Delete conversation',
                ),
                child: const Text('open'),
              ),
            ),
            width: width,
            scale: 2,
          ),
        );
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Delete this conversation?'), findsOneWidget);
        expect(find.text('Delete conversation'), findsOneWidget);
      });
    }
  });

  group('user bubble', () {
    for (final width in [344.0, 840.0]) {
      testWidgets('caps at 80 % of the column at $width dp', (tester) async {
        _useWidth(tester, width);
        await tester.pumpWidget(
          _host(
            // The transcript scrolls; only the width is under test here.
            SingleChildScrollView(
              child: UserMessage(
                target: const ChatTarget.bot('atlas'),
                message: ChatMessage(
                  id: 'u1',
                  role: ChatRole.user,
                  text: 'word ' * 24,
                  timestamp: DateTime(2026, 10, 3, 12),
                ),
              ),
            ),
            width: width,
            scale: 2,
          ),
        );

        expect(tester.takeException(), isNull);
        final bubble = tester.getSize(find.byType(AppSurface).first);
        expect(bubble.width, lessThanOrEqualTo(width * 0.8 + 0.5));
        expect(bubble.width, greaterThan(width * 0.7));
      });
    }
  });

  testWidgets('a letter avatar does not grow with the text scale', (
    tester,
  ) async {
    await tester.pumpWidget(_host(const HermesAvatar(name: 'Atlas'), scale: 2));

    final text = tester.widget<Text>(find.text('A'));
    expect(text.textScaler, TextScaler.noScaling);
    final letter = tester.getSize(find.text('A'));
    expect(letter.height, lessThanOrEqualTo(_spacing.avatar));
    expect(tester.takeException(), isNull);
  });

  group('remove badge', () {
    testWidgets('a file pill offers a labelled 48 dp remove target', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      var removed = 0;
      await tester.pumpWidget(
        _host(
          Center(
            child: AttachmentThumb(
              attachment: const LocalAttachment(
                id: 'a1',
                path: '/tmp/report.pdf',
                name: 'report.pdf',
                mimeType: 'application/pdf',
                sizeBytes: 2048,
              ),
              onRemove: () => removed++,
            ),
          ),
          scale: 2,
        ),
      );

      expect(tester.takeException(), isNull);
      final badge = find.byType(RemoveBadge);
      expect(tester.getSize(badge), Size.square(_spacing.minTouch));
      expect(find.bySemanticsLabel('Remove'), findsOneWidget);
      // The whole square is inside the pill, so all of it takes the tap.
      final pill = tester.getRect(find.byType(AttachmentThumb));
      final target = tester.getRect(badge);
      expect(pill.contains(target.topRight - const Offset(1, -1)), isTrue);
      await tester.tapAt(target.bottomLeft + const Offset(2, -2));
      expect(removed, 1);
      handle.dispose();
    });
  });

  group('disclosures', () {
    testWidgets(
      'the Thinking toggle is a full-width row button that says if open',
      (tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          _host(const ReasoningChip(reasoning: 'Let me check the logs.')),
        );

        final toggle = find.bySemanticsLabel('Thinking');
        expect(toggle, findsOneWidget);
        expect(
          tester.getSemantics(toggle),
          matchesSemantics(
            label: 'Thinking',
            isButton: true,
            hasExpandedState: true,
            hasTapAction: true,
            hasFocusAction: true,
            isFocusable: true,
          ),
        );
        // A text-height row across the column: short, but wide to hit.
        final row = tester.getSize(find.byType(InkWell));
        expect(row.height, greaterThanOrEqualTo(_spacing.inlineRow));
        expect(row.width, greaterThanOrEqualTo(_spacing.minTouch * 4));

        await tester.tap(find.byType(InkWell));
        await tester.pump();
        expect(
          tester.getSemantics(toggle),
          matchesSemantics(
            label: 'Thinking',
            isButton: true,
            hasExpandedState: true,
            isExpanded: true,
            hasTapAction: true,
            hasFocusAction: true,
            isFocusable: true,
          ),
        );
        handle.dispose();
      },
    );

    testWidgets('a tool row with output toggles as a row; done is read out', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          const ToolCard(
            call: ToolCall(
              id: 't1',
              name: 'grep',
              state: ToolState.done,
              resultText: 'three matches',
            ),
          ),
        ),
      );

      // A text-height row across the column: short, but wide to hit.
      final row = tester.getSize(find.byType(InkWell));
      expect(row.height, greaterThanOrEqualTo(_spacing.inlineRow));
      expect(row.width, greaterThanOrEqualTo(_spacing.minTouch * 4));
      expect(find.bySemanticsLabel(RegExp('Done')), findsOneWidget);
      handle.dispose();
    });
  });

  testWidgets('a <details> summary can be activated by a screen reader', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(
        MarkdownDetails(
          summary: 'Appendix',
          builder: (_) => const Text('body'),
        ),
      ),
    );

    expect(
      tester.getSemantics(find.bySemanticsLabel('Appendix')),
      matchesSemantics(
        label: 'Appendix',
        isButton: true,
        hasExpandedState: true,
        hasTapAction: true,
        hasFocusAction: true,
        isFocusable: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('the spinner stands still when motion is reduced', (
    tester,
  ) async {
    await tester.pumpWidget(_host(const AppSpinner(), reduceMotion: true));
    final ring = tester.widget<CircularProgressIndicator>(
      find.byType(CircularProgressIndicator),
    );
    expect(ring.value, isNotNull);
  });

  testWidgets('a settings caption names its field', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(
        const SettingsField(
          label: 'Gateway URL',
          child: TextField(
            decoration: InputDecoration(hintText: 'http://homelab.lan'),
          ),
        ),
      ),
    );

    final field = tester.getSemantics(find.byType(TextField));
    expect(field.label, contains('Gateway URL'));
    handle.dispose();
  });
}
