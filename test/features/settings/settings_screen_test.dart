import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hermes/app/routes.dart';
import 'package:hermes/core/platform/platform_info.dart';
import 'package:hermes/core/storage/key_value_store.dart';
import 'package:hermes/core/storage/secret_store.dart';
import 'package:hermes/core/theme/app_theme.dart';
import 'package:hermes/core/ui/ui.dart';
import 'package:hermes/features/connection/domain/connection_probe.dart';
import 'package:hermes/features/connection/presentation/connection_providers.dart';
import 'package:hermes/features/notifications/data/notification_gateway.dart';
import 'package:hermes/features/notifications/presentation/notification_providers.dart';
import 'package:hermes/features/settings/domain/preference_keys.dart';
import 'package:hermes/features/settings/presentation/connect_guide_page.dart';
import 'package:hermes/features/settings/presentation/settings_controller.dart';
import 'package:hermes/features/settings/presentation/settings_screen.dart';
import 'package:hermes/features/settings/presentation/widgets/settings_about_section.dart';
import 'package:hermes/hermes/auth/auth_credential.dart';
import 'package:hermes/hermes/auth/hermes_auth.dart';
import 'package:hermes/hermes/hermes_failure.dart';
import 'package:hermes/hermes/models/gateway_status.dart';
import 'package:hermes/l10n/generated/app_localizations.dart';

import '../../support/app_host.dart';
import '../../support/memory_stores.dart';
import 'settings_harness.dart';

const _phone = Size(360, 800);
const _fold = Size(840, 900);
const _url = 'http://gw.lan:9119';

/// What the OS says about notifications, and what the user did about it.
class _Notifications extends Fake implements NotificationGateway {
  bool granted = true;
  int settingsOpened = 0;
  int requests = 0;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> hasPermission() async => granted;

  @override
  Future<bool> requestPermission() async {
    requests++;
    return granted;
  }

  @override
  Future<bool> openSettings() async {
    settingsOpened++;
    return true;
  }
}

void main() {
  late FakeConnectionService service;
  late _Notifications notifications;
  var prompted = false;

  setUp(() {
    service = FakeConnectionService()..probeResult = gatedProbe;
    notifications = _Notifications();
    prompted = false;
  });

  var platform = const PlatformInfo(AppPlatform.android);

  List<Override> overrides(String? url, AuthCredential credential) => [
    platformInfoProvider.overrideWithValue(platform),
    keyValueStoreProvider.overrideWithValue(
      MemoryKeyValueStore({
        PreferenceKeys.gatewayUrl: ?url,
        if (prompted) PreferenceKeys.notificationsPrompted: true,
      }),
    ),
    secretStoreProvider.overrideWithValue(MemorySecretStore()),
    initialCredentialProvider.overrideWithValue(credential),
    connectionServiceProvider.overrideWithValue(service),
    connectionSupervisorProvider.overrideWith(FakeSupervisor.new),
    appVersionProvider.overrideWith((ref) async => '1.0.0'),
    notificationGatewayProvider.overrideWithValue(notifications),
    hermesClientProvider.overrideWithValue(null),
  ];

  Future<void> pumpScreen(
    WidgetTester tester, {
    Size size = _phone,
    double textScale = 1,
    String? url = _url,
    AuthCredential credential = const NoCredential(),
  }) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = size;
    addTearDown(tester.view.reset);
    // A fresh scope: one kept from an earlier pump keeps its providers.
    await tester.pumpWidget(const SizedBox());
    await pumpApp(
      tester,
      const SettingsScreen(),
      scaffold: false,
      textScale: textScale,
      overrides: overrides(url, credential),
    );
    await tester.pump(const Duration(seconds: 1));
  }

  Finder field(String hint) => find.byWidgetPredicate(
    (w) => w is TextField && (w.autofillHints?.contains(hint) ?? false),
  );

  Future<void> tapAndSettle(WidgetTester tester, Finder f) async {
    await tester.tap(f);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('lays out at 360 dp, 840 dp and twice the text size', (
    tester,
  ) async {
    for (final (size, scale) in [(_phone, 1.0), (_fold, 1.0), (_phone, 2.0)]) {
      await pumpScreen(tester, size: size, textScale: scale);
      expect(tester.takeException(), isNull);
      expect(find.text('Save and connect'), findsOneWidget);
    }
  });

  testWidgets('a fresh install shows only the hint, and a bad address says '
      'why', (tester) async {
    await pumpScreen(tester, url: null);
    final url = find.byWidgetPredicate(
      (w) => w is TextField && w.keyboardType == TextInputType.url,
    );
    final widget = tester.widget<TextField>(url);
    expect(widget.controller?.text, isEmpty);
    expect(widget.decoration?.hintText, 'https://hermes.example.com');
    await tester.enterText(url, 'http://ada:lovelace@gw.lan:9119');
    await tester.pump();
    expect(
      find.text(
        'Remove the user name and password from the address and sign in '
        'below instead',
      ),
      findsOneWidget,
    );
    await tester.enterText(url, 'not a url');
    await tester.pump();
    expect(find.text('Enter a valid http(s) URL'), findsOneWidget);
  });

  testWidgets('http to the internet warns, and a password asks first', (
    tester,
  ) async {
    await pumpScreen(tester, url: 'http://hermes.example.com');
    expect(find.textContaining('Not encrypted.'), findsOneWidget);
    await tester.enterText(field('username'), 'ada');
    await tester.enterText(field('password'), 'lovelace');
    await tester.pump();
    final signIn = find.widgetWithText(FormButtonRow, 'Sign in');
    await tapAndSettle(tester, signIn);
    expect(find.text('Send the password unencrypted?'), findsOneWidget);
    await tapAndSettle(tester, find.text('Cancel'));
    expect(service.signIns, 0, reason: 'nothing went out');
    await tapAndSettle(tester, signIn);
    await tapAndSettle(tester, find.text('Send anyway'));
    expect(service.signIns, 1);
    expect(find.text('Signed in as ada'), findsOneWidget);
  });

  testWidgets('the line under the address says what the gateway is', (
    tester,
  ) async {
    final lines = {
      'This gateway does not require sign-in': const ProbeResult(
        reachable: true,
        status: GatewayStatus(),
      ),
      'Username and password': gatedProbe,
      'Cannot reach the gateway': const ProbeResult(
        reachable: false,
        failure: NetworkFailure('refused'),
      ),
      'This gateway runs Hermes 0.20.1. This app needs Hermes 0.21.5 or '
          'newer: update Hermes.': const ProbeResult(
        reachable: true,
        status: GatewayStatus(version: '0.20.1'),
      ),
      'This gateway uses Google, which this app cannot sign in with yet':
          const ProbeResult(
            reachable: true,
            status: GatewayStatus(authRequired: true),
            providers: [AuthProvider(name: 'g', displayName: 'Google')],
          ),
    };
    for (final MapEntry(key: line, value: probe) in lines.entries) {
      service.probeResult = probe;
      await pumpScreen(tester);
      expect(find.text(line), findsOneWidget, reason: line);
    }
  });

  testWidgets('a stored sign-in shows who, and Sign out brings the form', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      credential: const BearerCredential(accessToken: 'at', username: 'ada'),
    );
    expect(find.text('Signed in as ada'), findsOneWidget);
    expect(field('password'), findsNothing);
    await tapAndSettle(tester, find.text('Sign out'));
    expect(field('password'), findsOneWidget);
  });

  testWidgets('the test result, and a token field once a test failed', (
    tester,
  ) async {
    service.probeResult = const ProbeResult(reachable: true);
    await pumpScreen(tester);
    expect(find.text('Token'), findsNothing);
    const ws = TestResult(httpOk: true, wsOk: false);
    for (final (result, text) in [
      (ws.copyWith(failure: const NetworkFailure('x')), 'WebSocket failed'),
      (ws.copyWith(detail: 'close 1011'), '(close 1011)'),
      (const TestResult(httpOk: false, wsOk: false), 'HTTP failed'),
      (ws.copyWith(wsOk: true, version: '9.9'), 'Reachable · gateway 9.9'),
    ]) {
      service.testResult = result;
      await tapAndSettle(tester, find.text('Test connection'));
      expect(find.textContaining(text), findsOneWidget, reason: text);
      expect(find.text('Token'), result.ok ? findsNothing : findsOneWidget);
    }
  });

  testWidgets('leaving with unsaved changes asks; Discard leaves', (
    tester,
  ) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = _phone;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, _) => TextButton(
            onPressed: () => unawaited(context.push<void>('/s')),
            child: const Text('open settings'),
          ),
        ),
        GoRoute(path: '/s', builder: (_, _) => const SettingsScreen()),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides(_url, const NoCredential()),
        child: MaterialApp.router(
          theme: AppTheme.light(),
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tapAndSettle(tester, find.text('open settings'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.enterText(find.widgetWithText(TextField, _url), 'gw.lan:1');
    await tester.pump();
    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Discard your changes?'), findsOneWidget);
    await tapAndSettle(tester, find.text('Cancel'));
    expect(find.byType(SettingsScreen), findsOneWidget);
    await tapAndSettle(tester, find.byType(AppCloseButton));
    await tapAndSettle(tester, find.widgetWithText(FilledButton, 'Discard'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('open settings'), findsOneWidget);
  });

  testWidgets('notifications: a refused grant says so and leads to the '
      'system settings; staying connected is on and works without it', (
    tester,
  ) async {
    notifications.granted = false;
    prompted = true;
    await pumpScreen(tester, size: const Size(360, 2400));
    expect(find.text('Blocked in system settings'), findsOneWidget);
    await tapAndSettle(tester, find.text('Open settings'));
    expect(notifications.settingsOpened, 1);
    await tapAndSettle(tester, find.text('Notify me'));
    List<bool> values() => [
      for (final s in tester.widgetList<SwitchListTile>(
        find.byType(SwitchListTile),
      ))
        s.value,
    ];
    expect(values(), [false, true], reason: 'stay connected is on at first');
    await tapAndSettle(tester, find.text('Stay connected in the background'));
    expect(values(), [false, false]);
  });

  testWidgets('before the app ever asked, a missing grant is not "Blocked"; '
      'the switch asks', (tester) async {
    notifications.granted = false;
    prompted = false;
    await pumpScreen(tester, size: const Size(360, 2400));
    expect(find.text('Blocked in system settings'), findsNothing);
    expect(find.text('Open settings'), findsNothing);
    await tapAndSettle(tester, find.text('Notify me'));
    expect(notifications.requests, 1);
  });

  testWidgets('iOS offers no "Stay connected": the system suspends the app', (
    tester,
  ) async {
    platform = const PlatformInfo(AppPlatform.ios);
    addTearDown(() => platform = const PlatformInfo(AppPlatform.android));
    await pumpScreen(tester, size: const Size(360, 2400));
    expect(find.text('Notify me'), findsOneWidget);
    expect(find.text('Stay connected in the background'), findsNothing);
  });

  testWidgets('about: versions, licenses, and a privacy row unless emptied', (
    tester,
  ) async {
    await pumpScreen(tester, size: const Size(360, 2400));
    expect(find.text('1.0.0'), findsOneWidget);
    expect(find.text('1.2.3'), findsOneWidget);
    expect(find.text('Privacy policy'), findsOneWidget);
    await tester.tap(find.text('Open-source licenses'));
    await tester.pumpAndSettle();
    expect(find.byType(LicensePage), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await pumpApp(
      tester,
      const SettingsLegalLinks(appVersion: '1.0.0', privacyPolicyUrl: ''),
    );
    expect(find.text('Privacy policy'), findsNothing);
  });

  testWidgets('"How to connect" opens the guide with the start command', (
    tester,
  ) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(360, 4000);
    addTearDown(tester.view.reset);
    final router = GoRouter(
      initialLocation: Routes.settings,
      routes: [
        GoRoute(
          path: Routes.settings,
          builder: (_, _) => const SettingsScreen(),
        ),
        GoRoute(
          path: Routes.connectGuide,
          builder: (_, _) => const ConnectGuidePage(),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides(_url, const NoCredential()),
        child: MaterialApp.router(
          theme: AppTheme.light(),
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    await tapAndSettle(tester, find.text('How to connect'));
    expect(
      find.textContaining('hermes dashboard --host 0.0.0.0'),
      findsOneWidget,
    );

    await tapAndSettle(tester, find.byType(AppCloseButton));
    expect(find.text('Settings'), findsOneWidget);
  });
}
