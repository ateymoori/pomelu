import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/core/config/app_config.dart';
import 'package:hermes/features/bot_screen/domain/screen_view.dart';
import 'package:hermes/features/bot_screen/presentation/bot_screen_providers.dart';
import 'package:hermes/features/bot_screen/presentation/screen_session.dart';
import 'package:hermes/hermes/events/gateway_event.dart';
import 'package:hermes/hermes/hermes_constants.dart';
import 'package:hermes/hermes/models/bot_screen.dart';

import '../../support/fake_gateway.dart';
import 'screen_harness.dart';

/// One open Screen page: what it asks the gateway and shows in its web view.
class _Page {
  _Page(FakeScreenApi api) : this._(api, ScreenClient());

  _Page._(this.api, this.client)
    : container = ProviderContainer(overrides: screenOverrides(api, client)) {
    _keep = container.listen(screenSessionProvider(screenBot), (_, _) {});
  }

  final FakeScreenApi api;
  final FakeClient client;
  final ProviderContainer container;
  final FakeSurface surface = FakeSurface();
  late final ProviderSubscription<ScreenView> _keep;

  ScreenSession get session =>
      container.read(screenSessionProvider(screenBot).notifier);
  ScreenView get view => container.read(screenSessionProvider(screenBot));
  ScreenStatus get status =>
      container.read(botScreenProvider(screenBot)).value!;

  /// The page comes up: the screen read, the web view ready.
  Future<void> open() async {
    await container.read(botScreenProvider(screenBot).future);
    session.bind(surface);
    await pumpEventQueue();
  }

  /// The web view says the stream shows.
  Future<void> live() async {
    session.onStreamOpen();
    await pumpEventQueue();
  }

  Future<void> close() async {
    _keep.close();
    container.dispose();
    await pumpEventQueue();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'a running screen opens watching, a still shown while it comes up',
    () async {
      final page = _Page(FakeScreenApi());
      await page.open();

      expect(page.surface.calls, containsAll(['poster', 'attach:watch']));
      expect(page.view.stream, ScreenStream.attaching);
      await page.live();
      expect(page.view.stream, ScreenStream.live);
      await page.close();
    },
  );

  test('take over gives this page the keys; hand back returns them', () async {
    final page = _Page(FakeScreenApi());
    await page.open();
    await page.live();
    page.session.type(0, 'no', const {});
    expect(page.surface.calls, isNot(contains('type:0:no')));

    await page.session.takeOver();
    expect(page.api.calls, contains('take:viewer-1'));
    expect(
      page.status.lease.controlFor(page.view.viewerHash),
      ScreenControl.you,
    );
    expect(page.surface.calls.last, 'viewOnly:false');
    page.session.type(1, 'hi', const {});
    expect(page.surface.calls.last, 'type:1:hi');

    await page.session.handBack();
    expect(page.api.calls.last, 'back:viewer-1');
    expect(page.status.lease.holder, ScreenHolder.agent);
    expect(page.surface.calls.last, 'viewOnly:true');
    await page.close();
  });

  test('paste: onto the desktop clipboard, and typed unless long', () async {
    final page = _Page(FakeScreenApi());
    await page.open();
    await page.live();
    expect(page.session.paste('no'), isFalse);
    expect(page.surface.calls, isNot(contains('clipboard:no')));

    await page.session.takeOver();
    expect(page.session.paste('a\r\nb'), isTrue);
    expect(
      page.surface.calls,
      containsAllInOrder(['clipboard:a\nb', 'type:0:a\nb']),
    );
    final long = 'x' * (AppConfig.screenPasteMaxChars + 1);
    expect(page.session.paste(long), isFalse);
    expect(page.surface.calls.last, 'clipboard:$long');
    await page.close();
  });

  test('closing the page hands its control back', () async {
    final page = _Page(FakeScreenApi());
    await page.open();
    await page.live();
    await page.session.takeOver();

    await page.close();
    expect(page.api.calls.last, 'back:viewer-1');
    expect(page.surface.calls.last, 'detach:hand back');
  });

  test('another viewer taking control drops this page to watching', () async {
    final page = _Page(FakeScreenApi());
    await page.open();
    await page.live();
    await page.session.takeOver();

    page.api.takenElsewhere();
    page.session.onStreamClosed(HermesProtocol.screenControlTaken);
    await pumpEventQueue();
    expect(page.view.notice, ScreenNotice.controlTaken);
    expect(page.surface.calls.last, 'attach:watch');
    expect(
      page.status.lease.controlFor(page.view.viewerHash),
      ScreenControl.otherViewer,
    );
    await page.close();
  });

  test('a lost stream is opened again a few times, then Reconnect', () {
    fakeAsync((async) {
      final page = _Page(FakeScreenApi());
      unawaited(page.open());
      async.flushMicrotasks();
      final opened = page.surface.calls
          .where((c) => c.startsWith('attach'))
          .length;

      for (var i = 0; i < AppConfig.screenReattachAttempts; i++) {
        page.session.onStreamClosed(1006);
        async.elapse(AppConfig.screenReattachDelay * i);
        async.flushMicrotasks();
      }
      final attaches = page.surface.calls.where((c) => c.startsWith('attach'));
      expect(attaches.length, opened + AppConfig.screenReattachAttempts);
      page.session.onStreamClosed(1006);
      expect(page.view.stream, ScreenStream.ended);

      page.session.reconnect();
      async.flushMicrotasks();
      expect(page.view.stream, ScreenStream.attaching);
      unawaited(page.close());
      async.flushMicrotasks();
    });
  });

  test(
    'after a reconnect it watches as a new viewer and keeps its control',
    () async {
      final page = _Page(FakeScreenApi());
      await page.open();
      await page.live();
      await page.session.takeOver();

      page.api.newSocket();
      page.client
        ..goOffline()
        ..goOnline();
      await pumpEventQueue();
      expect(
        page.api.calls,
        containsAllInOrder(['observe:viewer-1', 'take:viewer-2']),
      );
      expect(page.surface.calls.last, 'attach:control');
      expect(
        page.status.lease.controlFor(page.view.viewerHash),
        ScreenControl.you,
      );
      await page.close();
    },
  );

  test('hand back of control held on a lost socket forces it', () async {
    final page = _Page(FakeScreenApi());
    await page.open();
    await page.live();
    await page.session.takeOver();

    page.api.newSocket();
    await page.session.handBack();
    expect(page.api.calls, containsAllInOrder(['back:viewer-1', 'back:force']));
    expect(page.status.lease.holder, ScreenHolder.agent);
    expect(page.view.failure, isNull);
    await page.close();
  });

  test('away, control is kept a while, then handed back', () {
    fakeAsync((async) {
      final binding = WidgetsBinding.instance;
      final page = _Page(FakeScreenApi());
      unawaited(page.open());
      async.flushMicrotasks();
      unawaited(page.live());
      unawaited(page.session.takeOver());
      async.flushMicrotasks();

      binding
        ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
        ..handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      async.flushMicrotasks();
      expect(page.surface.calls.last, 'detach:keep');
      expect(page.status.lease.humanHolds, isTrue);

      async.elapse(AppConfig.screenAwayHandBack);
      expect(page.api.calls.last, 'back:viewer-1');
      expect(page.status.lease.holder, ScreenHolder.agent);

      binding
        ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
        ..handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      async.flushMicrotasks();
      expect(page.surface.calls.last, 'attach:watch');
      unawaited(page.close());
      async.flushMicrotasks();
    });
  });

  test('away, a viewer that took over meanwhile keeps control', () {
    fakeAsync((async) {
      final binding = WidgetsBinding.instance;
      final page = _Page(FakeScreenApi());
      unawaited(page.open());
      async.flushMicrotasks();
      unawaited(page.live());
      unawaited(page.session.takeOver());
      async.flushMicrotasks();

      binding
        ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
        ..handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      async.flushMicrotasks();
      // The phone's socket drops; a desktop viewer takes over.
      page.api
        ..newSocket()
        ..takenElsewhere();

      async.elapse(AppConfig.screenAwayHandBack);
      expect(page.api.calls, isNot(contains('back:force')));
      expect(page.api.lease.viewerHash, 'feedfeedfeed');
      unawaited(page.close());
      async.flushMicrotasks();
    });
  });

  test('a screen that is off opens nothing until it starts', () async {
    final page = _Page(FakeScreenApi(running: false));
    await page.open();
    expect(page.surface.calls, isEmpty);

    await page.session.start();
    await pumpEventQueue();
    expect(page.api.calls, contains('start'));
    expect(page.surface.calls.last, 'attach:watch');
    await page.close();
  });

  test(
    "this bot's events move status and control; others and older do not",
    () async {
      final page = _Page(FakeScreenApi());
      await page.open();
      GatewayEvent lease(String key, int epoch) => GatewayEvent(
        type: EventNames.displayLease,
        sessionId: '',
        payload: {
          'profile_key': key,
          'lease': {
            'holder': 'human',
            'viewer_hash': 'feedfeedfeed',
            'epoch': epoch,
          },
        },
      );

      page.client.emit(lease('/home/a/.hermes', 9));
      await pumpEventQueue();
      expect(page.status.lease.humanHolds, isFalse);

      page.client.emit(lease(screenKey, 9));
      await pumpEventQueue();
      expect(page.status.lease.epoch, 9);

      page.client.emit(
        const GatewayEvent(
          type: EventNames.displayLease,
          sessionId: '',
          payload: {
            'profile_key': screenKey,
            'lease': {'holder': 'agent', 'epoch': 8},
          },
        ),
      );
      page.client.emit(
        GatewayEvent(
          type: EventNames.displayStatus,
          sessionId: '',
          payload: {...page.status.toJsonForTest(), 'running': false},
        ),
      );
      await pumpEventQueue();
      expect(page.status.lease.humanHolds, isTrue);
      expect(page.status.running, isFalse);
      expect(page.surface.calls.last, 'detach:hand back');
      await page.close();
    },
  );
}

extension on ScreenStatus {
  /// The wire form of this status, as an event carries it.
  Map<String, Object?> toJsonForTest() => {
    'supported': supported,
    'installed': installed,
    'running': running,
    'profile_key': profileKey,
    'lease': {
      'holder': lease.holder.name,
      'viewer_hash': lease.viewerHash,
      'epoch': lease.epoch,
    },
  };
}
