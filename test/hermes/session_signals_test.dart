import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/hermes/client/session_signals.dart';
import 'package:hermes/hermes/events/event_payloads.dart';
import 'package:hermes/hermes/events/gateway_event.dart';
import 'package:hermes/hermes/hermes_constants.dart';

GatewayEvent _e(String type, Map<String, dynamic> p, [String session = 's1']) =>
    GatewayEvent(type: type, sessionId: session, payload: p);

void main() {
  late SessionSignals signals;
  late StreamController<GatewayEvent> events;

  setUp(() {
    events = StreamController<GatewayEvent>();
    signals = SessionSignals()..attach(events.stream);
  });

  tearDown(() async {
    await signals.dispose();
    await events.close();
  });

  test('notices, their withdrawal and background results', () async {
    final notices = <GatewayNotice>[];
    final clears = <String>[];
    final results = <BackgroundResult>[];
    signals.notices.listen(notices.add);
    signals.noticeClears.listen(clears.add);
    signals.backgrounds.listen(results.add);

    events
      ..add(
        _e(EventNames.notificationShow, {
          'text': 'Credits low',
          'level': 'warning',
          'key': 'credits',
        }),
      )
      ..add(_e(EventNames.notificationShow, {'text': '  '}))
      ..add(_e(EventNames.notificationClear, {'key': 'credits'}))
      ..add(_e(EventNames.backgroundComplete, {'task_id': 't1', 'text': 'ok'}))
      ..add(
        _e(EventNames.backgroundComplete, {
          'task_id': 't2',
          'text': 'error: x',
        }),
      );
    await pumpEventQueue();

    expect(notices.single.level, GatewayNotice.levelWarning);
    expect(notices.single.dedupeKey, 's1/credits');
    expect(clears, ['s1/credits']);
    expect(results.map((r) => (r.taskId, r.isError)), [
      ('t1', false),
      ('t2', true),
    ]);
  });

  test('usage counters leave out what the gateway did not send', () {
    final usage = SessionUsage.fromEvent(
      _e(EventNames.sessionUsage, {
        'usage': {'model': 'm', 'input': 10, 'output': '5', 'total': 15},
      }),
    )!;
    expect((usage.input, usage.output, usage.total), (10, 5, 15));
    expect(usage.contextPct, isNull);
  });

  test('session refs merge, and only the newest are kept', () {
    signals
      ..handle(
        _e(EventNames.sessionInfo, {
          'stored_session_id': 'st-1',
          'profile_name': 'nova',
        }),
      )
      ..handle(_e(EventNames.sessionInfo, {'title': 'Renamed'}));
    final ref = signals.refFor('s1')!;
    expect((ref.storedId, ref.profile, ref.title), ('st-1', 'nova', 'Renamed'));
    expect(ref.canDeepLink, isTrue);

    for (var i = 0; i < HermesLimits.sessionRefCache; i++) {
      signals.handle(_e(EventNames.sessionInfo, {'title': 't'}, 'x$i'));
    }
    expect(signals.refFor('s1'), isNull);
    expect(signals.refFor('x0'), isNotNull);
  });
}
