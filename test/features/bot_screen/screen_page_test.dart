import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hermes/app/routes.dart';
import 'package:hermes/core/config/app_config.dart';
import 'package:hermes/core/theme/app_theme.dart';
import 'package:hermes/features/bot_screen/domain/remote_input.dart';
import 'package:hermes/features/bot_screen/presentation/bot_screen_page.dart';
import 'package:hermes/features/bot_screen/presentation/widgets/screen_action.dart';
import 'package:hermes/l10n/generated/app_localizations.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import '../../support/app_host.dart';
import '../../support/fake_web_view.dart';
import 'screen_harness.dart';

late FakeWebViewPlatform _web;

FakeWebView get _view => _web.views.single;

/// The page over [api], at [size].
Future<void> _open(
  WidgetTester tester,
  FakeScreenApi api, {
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await pumpApp(
    tester,
    const BotScreenPage(profile: screenBot),
    scaffold: false,
    overrides: screenOverrides(api, ScreenClient()),
  );
  await tester.pump();
  await tester.pump();
}

/// The page's viewer comes up and the stream shows.
Future<void> _live(WidgetTester tester) async {
  _view.send({'type': 'ready'});
  await tester.pump();
  await tester.pump();
  _view.send({'type': 'connect'});
  await tester.pump();
}

bool _ran(String call) =>
    _view.scripts.any((s) => s.startsWith('pomelu.$call'));

Future<void> _tap(WidgetTester tester, String text) async {
  await tester.tap(find.text(text));
  await tester.pump();
  await tester.pump();
}

void main() {
  setUp(() => WebViewPlatform.instance = _web = FakeWebViewPlatform());

  testWidgets('the chat header offers the screen only for a bot with one; its '
      'dot is lit while a person drives it', (tester) async {
    Future<void> header(FakeScreenApi api) async {
      await pumpApp(
        tester,
        const ScreenAction(profile: screenBot),
        overrides: screenOverrides(api, ScreenClient()),
      );
      await tester.pump();
    }

    await header(
      FakeScreenApi()
        ..status = FakeScreenApi().status.copyWith(installed: false),
    );
    expect(find.byKey(const Key('chat-top-screen')), findsNothing);

    await header(FakeScreenApi());
    expect(find.byTooltip('Screen'), findsOneWidget);

    await header(FakeScreenApi()..takenElsewhere());
    expect(find.byTooltip('Screen: a person has control'), findsOneWidget);
  });

  testWidgets('closing the screen does not raise the keyboard again', (
    tester,
  ) async {
    final composer = FocusNode();
    addTearDown(composer.dispose);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: Routes.home,
          builder: (_, _) => Scaffold(
            body: Column(
              children: [
                TextField(focusNode: composer),
                const ScreenAction(profile: screenBot),
              ],
            ),
          ),
        ),
        GoRoute(
          path: Routes.screen,
          builder: (_, _) => const Scaffold(body: Text('screen')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: screenOverrides(FakeScreenApi(), ScreenClient()),
        child: MaterialApp.router(
          theme: AppTheme.light(),
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(composer.hasFocus, isTrue);

    await tester.tap(find.byTooltip('Screen'));
    await tester.pumpAndSettle();
    expect(find.text('screen'), findsOneWidget);
    router.pop();
    await tester.pumpAndSettle();

    expect(composer.hasFocus, isFalse);
  });

  testWidgets('a screen that is off offers Start, then comes up watching', (
    tester,
  ) async {
    final api = FakeScreenApi(running: false);
    await _open(tester, api);
    expect(find.text('Screen is off'), findsWidgets);
    expect(_web.views, isEmpty);

    await _tap(tester, 'Start screen');
    expect(api.calls, contains('start'));
    // The page comes off the asset bundle, decoded on another isolate.
    for (var i = 0; i < 100 && _view.html == null; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }
    // The viewer loads under the gateway's origin, for its socket's Origin.
    expect(_view.baseUrl, 'http://gw.lan:9119');
    expect(_view.html, contains('pomelu'));

    await _live(tester);
    expect(_ran('layout'), isTrue);
    expect(_ran('poster'), isTrue);
    expect(
      _view.scripts,
      contains(
        startsWith(
          'pomelu.attach("ws://gw/api/display/ws?display_ticket=t1",true,4100)',
        ),
      ),
    );
    expect(find.text('Bot in control'), findsOneWidget);
    expect(find.text('Take over'), findsOneWidget);
  });

  testWidgets('in control: keys typed and held go to the desktop; Hand back '
      'returns to watching', (tester) async {
    final api = FakeScreenApi();
    await _open(tester, api);
    await _live(tester);

    await _tap(tester, 'Take over');
    expect(api.calls, contains('take:viewer-1'));
    expect(find.text('You are in control'), findsOneWidget);
    expect(_view.scripts, contains('pomelu.viewOnly(false)'));

    await tester.tap(find.byTooltip('Keyboard'));
    await tester.pump();
    final field = find.byKey(const Key('screen-typing'));
    await tester.enterText(field, '${RemoteTyping.filler}a');
    expect(_view.scripts.last, 'pomelu.type(0,"a",[])');
    await tester.tap(find.text('Ctrl'));
    await tester.pump();
    await tester.enterText(field, '${RemoteTyping.filler}ac');
    expect(_view.scripts.last, 'pomelu.type(0,"c",["ctrl"])');
    await tester.tap(find.byTooltip('Tab'));
    expect(_view.scripts.last, 'pomelu.press("tab",[])');
    // A hardware keyboard's arrows and Escape go to the desktop too.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    expect(_view.scripts.last, 'pomelu.press("left",[])');
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    expect(_view.scripts.last, 'pomelu.press("escape",[])');

    await _tap(tester, 'Hand back');
    expect(api.calls.last, 'back:viewer-1');
    expect(find.text('Bot in control'), findsOneWidget);
    expect(find.byKey(const Key('screen-typing')), findsNothing);
  });

  testWidgets('in control: Drag picks up on one tap and drops on the next, '
      'and can be cancelled between', (tester) async {
    await _open(tester, FakeScreenApi());
    await _live(tester);
    await _tap(tester, 'Take over');

    await tester.tap(find.byTooltip('Drag and drop'));
    expect(_view.scripts.last, 'pomelu.drag(true)');
    _view.send({'type': 'drag', 'state': 'pick'});
    await tester.pump();
    expect(find.text('Tap what to drag'), findsOneWidget);
    _view.send({'type': 'drag', 'state': 'drop'});
    await tester.pump();
    expect(find.text('Tap where to drop it'), findsOneWidget);

    await tester.tap(find.byTooltip('Cancel drag'));
    expect(_view.scripts.last, 'pomelu.drag(false)');
    _view.send({'type': 'drag', 'state': 'off'});
    await tester.pump();
    expect(find.text('You are in control'), findsOneWidget);
  });

  testWidgets('over the soft keyboard only the key row stays, with Paste', (
    tester,
  ) async {
    await _open(tester, FakeScreenApi());
    await _live(tester);
    await _tap(tester, 'Take over');
    await tester.tap(find.byTooltip('Keyboard'));
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pump();

    expect(find.byTooltip('Hide keyboard'), findsOneWidget);
    expect(find.byTooltip('Paste'), findsOneWidget);
    expect(find.text('Hand back'), findsNothing);
  });

  testWidgets('another viewer in control: Take over asks first, and ⋯ can give '
      'control to the bot', (tester) async {
    final api = FakeScreenApi()..takenElsewhere();
    await _open(tester, api);
    await _live(tester);
    expect(find.text('Another viewer in control'), findsOneWidget);

    await _tap(tester, 'Take over');
    expect(find.text('Take over from the other viewer?'), findsOneWidget);
    await tester.tap(
      find.descendant(of: find.byType(Dialog), matching: find.text('Cancel')),
    );
    await tester.pumpAndSettle();
    expect(api.calls, isNot(contains('take:viewer-1')));

    await tester.tap(find.byKey(const Key('screen-more')));
    await tester.pumpAndSettle();
    await _tap(tester, 'Give control to $screenBot');
    await tester.tap(
      find.descendant(
        of: find.byType(Dialog),
        matching: find.text('Give control to $screenBot'),
      ),
    );
    await tester.pumpAndSettle();
    expect(api.calls.last, 'back:force');
    expect(find.text('Bot in control'), findsOneWidget);
  });

  testWidgets('a stream lost for good offers Reconnect', (tester) async {
    await _open(tester, FakeScreenApi());
    await _live(tester);
    for (var i = 0; i <= AppConfig.screenReattachAttempts; i++) {
      _view.send({'type': 'disconnect', 'code': 1006});
      await tester.pump(AppConfig.screenReattachDelay * i);
      await tester.pump();
    }
    expect(find.text('Stream ended'), findsWidgets);

    await _tap(tester, 'Reconnect');
    expect(find.text('Connecting…'), findsOneWidget);
  });

  for (final size in const [Size(360, 640), Size(640, 360)]) {
    testWidgets('in control, it fits a small phone at twice the text size, '
        '${size.width.round()} wide', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await pumpApp(
        tester,
        const BotScreenPage(profile: screenBot),
        scaffold: false,
        textScale: 2,
        overrides: screenOverrides(FakeScreenApi(), ScreenClient()),
      );
      await tester.pump();
      await tester.pump();
      await _live(tester);
      await _tap(tester, 'Take over');
      await tester.tap(find.byTooltip('Keyboard'));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text('Hand back'), findsOneWidget);
    });
  }

  for (final (name, size) in [
    ('a phone', const Size(360, 740)),
    ('a phone on its side', const Size(740, 360)),
    ('a tablet', const Size(1024, 1366)),
  ]) {
    testWidgets('the controls fit $name', (tester) async {
      await _open(tester, FakeScreenApi(), size: size);
      await _live(tester);
      final takeOver = tester.getRect(find.text('Take over'));
      expect(tester.takeException(), isNull);
      expect((Offset.zero & size).contains(takeOver.center), isTrue);
      // Too short for two rows: the controls join the top one.
      final short = size.height < 480;
      expect(takeOver.center.dy < size.height / 2, short);
      // The desktop fits between the chrome.
      final layout = _view.scripts.lastWhere(
        (s) => s.startsWith('pomelu.layout'),
      );
      expect(layout, contains('"top":'));
    });
  }
}
