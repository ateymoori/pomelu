import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/features/notifications/data/message_check.dart';
import 'package:hermes/features/notifications/domain/notification_policy.dart';
import 'package:hermes/hermes/api/hermes_api.dart';
import 'package:hermes/hermes/hermes_constants.dart';
import 'package:hermes/hermes/models/profile.dart';
import 'package:hermes/hermes/models/session_message.dart';
import 'package:hermes/l10n/generated/app_localizations.dart';

import '../../support/memory_stores.dart';
import 'notification_center_harness.dart' show FakeGateway;

DateTime at(int minute) => DateTime.utc(2026, 10, 23, 18, minute);

class _Api extends Fake implements HermesApi {
  List<HermesProfile> bots = [];
  Map<String, List<SessionMessage>> rows = {};
  final reads = <String>[];

  @override
  Future<List<HermesProfile>> listProfiles() async => bots;

  @override
  Future<List<SessionMessage>> storedMessages({
    required String storedId,
    required String profile,
    int limit = HermesLimits.storedMessagesPage,
  }) async {
    reads.add(storedId);
    return rows[storedId] ?? const [];
  }
}

HermesProfile bot(
  String name, {
  required int count,
  DateTime? last,
  bool hidden = false,
}) => HermesProfile(
  name: name,
  canonicalSession: CanonicalSession(
    id: 'chat-$name',
    resolvedId: 'tip-$name',
    lastActive: last ?? at(0),
    messageCount: count,
  ),
  uiMeta: {
    HermesProtocol.botsMetaKey: {'title': name.toUpperCase(), 'hidden': hidden},
  },
);

SessionMessage said(String role, String text, int minute) =>
    SessionMessage(role: role, text: text, timestamp: at(minute));

void main() {
  late _Api api;
  late MemoryAwayStore store;
  late FakeGateway gateway;
  final policy = NotificationPolicy(
    enabled: true,
    permissionGranted: true,
    l10n: lookupAppLocalizations(const Locale('en')),
  );

  Future<void> check() => checkMessages(
    api: api,
    store: store,
    gateway: gateway,
    policy: policy,
    account: 'gw#me',
  );

  setUp(() {
    api = _Api();
    store = MemoryAwayStore();
    gateway = FakeGateway();
  });

  test('a reply that lands after the app left rings once, even when the turn '
      'began before', () async {
    // Left at :10 right after asking; Hermes keeps last_active at the
    // question, so only the count shows the reply.
    store.away = at(10);
    api.bots = [
      bot('atlas', count: 2, last: at(9)),
      bot('quiet', count: 4),
      bot('ghost', count: 1, hidden: true),
    ];
    await store.saveMarks('gw#me', marksOf(api.bots, at(10)));
    api.rows['tip-atlas'] = [
      said('assistant', 'old answer', 4),
      said('user', 'and the weather?', 9),
    ];

    api.bots[0] = bot('atlas', count: 3, last: at(9));
    api.rows['tip-atlas'] = [
      ...api.rows['tip-atlas']!,
      const SessionMessage(role: 'tool', name: 'search'),
    ];
    await check();
    expect(gateway.shown, isEmpty, reason: 'no reply yet');

    api.bots[0] = bot('atlas', count: 4, last: at(9));
    api.rows['tip-atlas'] = [
      said('user', 'and the weather?', 9),
      said('assistant', 'Rain until noon.', 12),
    ];
    await check();
    await check();
    expect(gateway.shown.map((n) => (n.title, n.body)), [
      ('ATLAS', 'Rain until noon.'),
    ]);
    expect(api.reads, ['tip-atlas', 'tip-atlas']);
  });

  test('nothing is read while the app is in front', () async {
    api.bots = [bot('atlas', count: 3, last: at(14))];
    await check();
    expect(api.reads, isEmpty);
    expect(gateway.shown, isEmpty);
  });
}
