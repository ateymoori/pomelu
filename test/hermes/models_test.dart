import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/hermes/auth/hermes_auth.dart';
import 'package:hermes/hermes/events/gateway_event.dart';
import 'package:hermes/hermes/hermes_constants.dart';
import 'package:hermes/hermes/hermes_failure.dart';
import 'package:hermes/hermes/models/bot_cron_job.dart';
import 'package:hermes/hermes/models/bot_skill.dart';
import 'package:hermes/hermes/models/bot_soul.dart';
import 'package:hermes/hermes/models/bot_toolset.dart';
import 'package:hermes/hermes/models/compress_result.dart';
import 'package:hermes/hermes/models/gateway_action.dart';
import 'package:hermes/hermes/models/gateway_status.dart';
import 'package:hermes/hermes/models/json_parse.dart';
import 'package:hermes/hermes/models/profile.dart';
import 'package:hermes/hermes/models/session_message.dart';
import 'package:hermes/hermes/models/session_resume.dart';
import 'package:hermes/hermes/models/session_summary.dart';

import '../support/fixtures.dart';

Map<String, dynamic> _result(String name) =>
    fixtureMap(name)['result'] as Map<String, dynamic>;

List<T> _rows<T>(Object? raw, T Function(Map<String, dynamic>) from) =>
    parseRows(raw, from);

/// Recorded gateway answers parse into the models, and malformed ones cost
/// a row, never the whole answer.
void main() {
  test('recorded answers parse', () {
    final profiles = _rows(
      _result('profiles_list.json')['profiles'],
      HermesProfile.fromJson,
    );
    final def = profiles.firstWhere((p) => p.name == 'default');
    expect(profiles, hasLength(6));
    expect((def.isDefault, def.title), (true, 'General'));
    expect(def.canonicalSession?.title, HermesProtocol.botChatTitle);
    expect(def.botMeta?.color, startsWith('hsl'));
    expect(def.lastActivity, isNotNull);

    final rest = _rows(
      fixtureMap('rest_profiles_sessions.json')['sessions'],
      SessionSummary.fromJson,
    );
    expect(rest.first.id, '20260902_113205_0a4055fb');
    expect(rest.first.lastActive, isNotNull);

    final listed = _rows(
      _result('session_list_default.json')['sessions'],
      SessionSummary.fromJson,
    );
    expect((listed.first.id.isNotEmpty, listed.first.lastActive), (true, null));

    final resume = SessionResume.fromJson(_result('session_resume.json'));
    expect(resume.sessionId, '5691ff8d');
    expect(resume.storedId, '20260901_214133_b63848');
    expect(resume.hydrating, isTrue);

    final history = _rows(
      _result('session_history.json')['messages'],
      SessionMessage.fromJson,
    );
    expect(history.map((m) => (m.isUser, m.durableId)), [
      (true, 65),
      (false, 66),
    ]);

    expect(
      fixtureList('skills.json', BotSkill.fromJson).any((s) => !s.enabled),
      isTrue,
    );
    expect(fixtureList('toolsets.json', BotToolset.fromJson).first.toolNames, [
      'web_extract',
      'web_search',
    ]);
    expect(
      BotSoul.fromJson(fixtureMap('soul.json')).content,
      startsWith('# Atlas'),
    );
    final jobs = fixtureList('cron_jobs.json', BotCronJob.fromJson);
    expect(jobs.first.schedule?.expr, '0 8 * * *');
    expect(jobs.first.nextRunAt, isNotNull);

    final ready = GatewayEvent.fromParams(
      fixtureMap('gateway_ready.json')['params'] as Map<String, dynamic>,
    )!;
    expect((ready.type, ready.seq), (EventNames.gatewayReady, null));
    expect(ready.text('replay_epoch'), isNotEmpty);
  });

  group('a malformed answer', () {
    test('costs only its bad rows', () {
      final logs = <String>[];
      final rows = parseRows(
        [
          {'name': 'a'},
          'junk',
          {'name': 'b', 'enabled': 'yes', 'description': 3},
        ],
        BotSkill.fromJson,
        log: (m, [_]) => logs.add(m),
      );
      expect(rows.map((s) => s.name), ['a', 'b']);
      expect(logs, hasLength(1));
      expect(parseRows('not a list', BotSkill.fromJson), isEmpty);
    });

    test('of the wrong shape is a protocol failure, not a TypeError', () {
      expect(
        () => parseObject([1], GatewayStatus.fromJson),
        throwsA(isA<ProtocolFailure>()),
      );
      expect(
        () => parseObject({'x': 1}, (_) => throw TypeError()),
        throwsA(isA<ProtocolFailure>()),
      );
    });

    test('loose types read as the nearest sane value', () {
      final p = HermesProfile.fromJson({
        'name': 42,
        'is_default': 1,
        'ui_meta': 'not an object',
        'last_session': {'last_active': double.infinity, 'message_count': '3'},
      });
      expect((p.name, p.isDefault, p.botMeta), ('42', true, null));
      expect(p.lastSession?.lastActive, isNull);
      expect(p.lastSession?.messageCount, 3);

      final m = SessionMessage.fromJson({
        'role': 'assistant',
        'content': [
          {'type': 'text', 'text': 'hi'},
          {'type': 'image_url'},
        ],
        'timestamp': 'yesterday',
        'row_id': '9',
      });
      expect((m.body, m.timestamp, m.durableId), ('hi\n[image]', null, 9));

      final status = GatewayStatus.fromJson({
        'version': 0.22,
        'auth_required': 'true',
        'auth_providers': ['basic', 3],
      });
      expect((status.version, status.authRequired), ('0.22', true));
      expect(status.authProviders, ['basic']);
      expect(
        TokenRefresh.fromJson({'access_token': 'a', 'refresh_token': 7})
            .refreshToken,
        '7',
      );
      expect(
        GatewayEvent.fromParams({'type': 'x', 'seq': double.nan})?.seq,
        isNull,
      );
    });
  });

  test('the derived values the screens show', () {
    expect(
      const BotCronJob(id: 'j1', prompt: '\n Send the digest.\nmore').title,
      'Send the digest.',
    );
    expect(
      const BotCronJob(
        id: 'j',
        lastStatus: 'delivery_failed',
        lastError: 'run',
        lastDeliveryError: 'no chat',
      ).lastDetail,
      'no chat',
    );
    expect(
      const CompressResult(
        summary: CompressSummary(headline: 'Compressed', tokenLine: '10 → 2'),
      ).text,
      'Compressed\n10 → 2',
    );
    expect(
      const ActionStatus(
        name: 'hermes-update',
        exitCode: 0,
        lines: ['old run', '=== hermes-update started now ===', 'pulled'],
      ).log,
      'pulled',
    );
    expect(const SessionSummary(id: 'a', resolvedId: 'b').openId, 'b');
    final now = DateTime.utc(2026);
    final working = HermesProfile(
      name: 'n',
      workerSession: WorkerSession(
        lastActive: now.subtract(const Duration(seconds: 5)),
      ),
    );
    expect(working.isWorking(now, const Duration(seconds: 90)), isTrue);
    expect(working.isWorking(now, const Duration(seconds: 1)), isFalse);
  });
}
