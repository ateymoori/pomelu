import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/hermes/api/hermes_api.dart';
import 'package:hermes/hermes/auth/auth_credential.dart';
import 'package:hermes/hermes/client/connection_state.dart';
import 'package:hermes/hermes/client/hermes_client.dart';
import 'package:hermes/hermes/hermes_constants.dart';
import 'package:hermes/hermes/hermes_failure.dart';
import 'package:hermes/hermes/models/bot_screen.dart';
import 'package:hermes/hermes/models/gateway_action.dart';

import '../support/fixtures.dart';
import 'support/loopback_gateway.dart';

/// Wire shapes of the [HermesApi] calls against a scripted gateway: what
/// goes out, and how the answer is read.
void main() {
  late LoopbackGateway gateway;
  late HermesClient client;
  late HermesApi api;
  late List<String> logs;

  setUp(() async {
    gateway = LoopbackGateway();
    await gateway.start();
    logs = [];
    client = HermesClient(
      baseUrl: gateway.url,
      credential: () => const SessionTokenCredential('tok'),
      onCredentialRotated: (_) async {},
      log: (m, [_]) => logs.add(m),
    );
    api = HermesApi(client);
  });

  tearDown(() async {
    await client.dispose();
    await gateway.stop();
  });

  Future<Object?> caught(Future<Object?> f) =>
      f.then<Object?>((v) => v, onError: (Object e) => e);

  group('over the socket', () {
    setUp(() async {
      final ready = client.states.firstWhere((s) => s is Connected);
      await client.connect();
      await ready.timeout(const Duration(seconds: 5));
    });

    Map<String, dynamic> sent(String method) =>
        gateway.calls.lastWhere((c) => c.method == method).params;

    test('the roster: bots, avatars, the Bot Chat by title', () async {
      gateway.rpc['profiles.list'] = (_) => const RpcResult({
        'profiles': [
          {'name': 'nova'},
          {'name': ''},
          'junk',
        ],
      });
      gateway.rpc['profiles.get_asset'] = (p) => RpcResult(
        p['name'] == 'nova'
            ? {'found': true, 'data': 'data:image/png;base64,AA'}
            : {'found': false},
      );
      gateway.rpc['session.list'] = (_) => const RpcResult({
        'sessions': [
          {'id': 'a1', 'title': 'Bot Chat', 'message_count': 3},
        ],
      });

      expect((await api.listProfiles()).map((p) => p.name), ['nova']);
      expect(sent('profiles.list'), {'include_sessions': true});
      expect(await api.profileAvatar('nova'), startsWith('data:image/png'));
      expect(await api.profileAvatar('none'), isNull);
      final chat = await api.findByTitle('nova', 'Bot Chat');
      expect((chat?.id, chat?.profile), ('a1', 'nova'));
      expect(sent('session.list'), containsPair('title', 'Bot Chat'));
    });

    test('createSession sends only what was asked for', () async {
      gateway.rpc['session.create'] = (_) =>
          const RpcResult({'session_id': 'rt-1', 'stored_session_id': 's1'});

      final made = await api.createSession(profile: 'nova');
      expect((made.sessionId, made.storedId), ('rt-1', 's1'));
      expect(sent('session.create'), {
        'profile': 'nova',
        'cols': HermesLimits.terminalCols,
        'source': 'gui',
      });

      await api.createSession(
        profile: 'nova',
        title: 'Bot Chat',
        hidden: true,
        followProfileConfig: true,
        parentSessionId: 'p1',
      );
      expect(sent('session.create'), containsPair('parent_session_id', 'p1'));
      expect(
        sent('session.create'),
        containsPair('follow_profile_config', true),
      );
    });

    test(
      'resumeSession defers the history; an answer without an id fails',
      () async {
        gateway.rpc['session.resume'] = (_) =>
            RpcResult(fixtureMap('session_resume.json')['result']);

        final r = await api.resumeSession(storedId: 's1', profile: 'nova');
        expect(r.sessionId, '5691ff8d');
        expect(sent('session.resume'), containsPair('defer_history', true));
        expect(sent('session.resume'), containsPair('omit_messages', true));

        gateway.rpc['session.resume'] = (_) => const RpcResult({'status': 'x'});
        expect(
          await caught(api.resumeSession(storedId: 's1', profile: 'nova')),
          isA<ProtocolFailure>(),
        );
      },
    );

    test(
      'the live session: history, undo, title, archive, compress, context',
      () async {
        gateway.rpc['session.history'] = (_) => const RpcResult({
          'messages': [
            {'role': 'user', 'text': 'hi'},
            'junk',
          ],
        });
        gateway.rpc['session.undo'] = (_) => const RpcResult({'removed': 2});
        gateway.rpc['session.compress'] = (_) => const RpcResult({
          'status': 'compressed',
          'summary': {'headline': 'Compressed'},
        });
        gateway.rpc['session.context_breakdown'] = (_) =>
            const RpcResult({'context_max': 100, 'context_used': 40});

        expect((await api.history('r1')).single.text, 'hi');
        expect(await api.undoLastTurn('r1'), 2);
        await api.setTitle('r1', 'New');
        expect(sent('session.title'), {'session_id': 'r1', 'title': 'New'});
        await api.archiveSession(sessionId: 'r1', profile: 'nova');
        expect(sent('session.archive'), {
          'session_id': 'r1',
          'archived': true,
          'profile': 'nova',
        });
        expect((await api.compress('r1')).text, 'Compressed');
        expect((await api.contextBreakdown('r1')).fraction, 0.4);
        for (final m in [
          'session.history',
          'session.undo',
          'session.compress',
        ]) {
          expect(sent(m), {'session_id': 'r1'});
        }
      },
    );

    test('turns, model and effort', () async {
      gateway.rpc['prompt.submit'] = (_) =>
          const RpcResult({'status': 'streaming'});

      expect(
        await api.submitPrompt(runtimeId: 'r1', profile: 'nova', text: 'hi'),
        'streaming',
      );
      expect(sent('prompt.submit'), {
        'session_id': 'r1',
        'profile': 'nova',
        'text': 'hi',
      });
      await api.interrupt('r1');
      expect(sent('session.interrupt'), {'session_id': 'r1'});

      await api.switchModel(
        runtimeId: 'r1',
        model: 'openrouter/anthropic/claude-4.5:beta',
        provider: 'openrouter',
      );
      expect(
        sent('slash.exec')['command'],
        'model openrouter/anthropic/claude-4.5:beta --provider openrouter',
      );
      for (final bad in ['x; rm -rf /', '--yolo', 'a b']) {
        expect(
          await caught(api.switchModel(runtimeId: 'r1', model: bad)),
          isA<ProtocolFailure>(),
        );
      }
      await api.setReasoningEffort(runtimeId: 'r1', effort: 'high');
      expect(sent('config.set'), {
        'session_id': 'r1',
        'key': 'reasoning',
        'value': 'high',
        'scope': 'session',
      });
    });

    test(
      'attachments go out as base64; one over its cap never leaves',
      () async {
        gateway.rpc['file.attach'] = (_) =>
            const RpcResult({'attached': true, 'ref_text': '@file:a.txt'});

        final res = await api.attachFile(
          runtimeId: 'r1',
          bytes: utf8.encode('hello'),
          name: 'a.txt',
          mimeType: 'text/plain',
        );
        expect(res.refText, '@file:a.txt');
        expect(
          sent('file.attach')['data_url'],
          'data:text/plain;base64,${base64Encode(utf8.encode('hello'))}',
        );

        final calls = gateway.calls.length;
        expect(
          await caught(
            api.attachImageBytes(
              runtimeId: 'r1',
              bytes: List.filled(HermesLimits.maxImageBytes + 1, 0),
              filename: 'a.png',
            ),
          ),
          isA<ServerFailure>().having(
            (f) => f.rpcCode,
            'rpcCode',
            HermesProtocol.errImageTooLarge,
          ),
        );
        expect(
          await caught(
            api.attachFile(
              runtimeId: 'r1',
              bytes: List.filled(HermesLimits.maxFileBytes + 1, 0),
              name: 'big',
              mimeType: 'x/y',
            ),
          ),
          isA<ServerFailure>().having((f) => f.httpStatus, 'status', 413),
        );
        expect(gateway.calls.length, calls);
      },
    );

    test('a gateway error keeps its code', () async {
      gateway.rpc['session.title'] = (_) =>
          const RpcError(HermesProtocol.errSessionNotFound, 'gone');
      expect(
        await caught(api.setTitle('r1', 'x')),
        isA<ServerFailure>().having(
          (f) => f.rpcCode,
          'rpcCode',
          HermesProtocol.errSessionNotFound,
        ),
      );
    });

    test('a turn the gateway refuses (chat open elsewhere, or full) is a '
        'busy session, and says which', () async {
      gateway.rpc['prompt.submit'] = (_) => const RpcError(
        HermesProtocol.errSessionBusy,
        'This chat is open in another Hermes window/terminal.',
        data: {'reason': HermesProtocol.sessionNotOwned},
      );
      final elsewhere = await caught(
        api.submitPrompt(runtimeId: 'r1', profile: 'nova', text: 'hi'),
      );
      expect(elsewhere, isA<SessionBusyFailure>());
      expect((elsewhere! as SessionBusyFailure).openElsewhere, isTrue);

      gateway.rpc['prompt.submit'] = (_) => const RpcError(
        HermesProtocol.errSessionBusy,
        'Active session limit reached',
        data: {'reason': 'MAX_CONCURRENT_SESSIONS'},
      );
      final full = await caught(
        api.submitPrompt(runtimeId: 'r1', profile: 'nova', text: 'hi'),
      );
      expect((full! as SessionBusyFailure).openElsewhere, isFalse);
    });

    test('a title another session holds is a title conflict', () async {
      gateway.rpc['session.title'] = (p) => RpcError(
        HermesProtocol.errTitleRejected,
        "Title '${p['title']}' is already in use by session s9",
      );
      expect(
        await caught(api.setTitle('r1', 'Bot Chat')),
        isA<TitleInUseFailure>(),
      );
      gateway.rpc['session.title'] = (_) =>
          const RpcError(HermesProtocol.errTitleRejected, 'Title too long');
      expect(
        await caught(api.setTitle('r1', 'x')),
        isNot(isA<TitleInUseFailure>()),
      );
    });

    test('a bot: create, picture, and a name that keeps the rest', () async {
      gateway.rpc['profiles.create'] = (_) => const RpcResult({'ok': true});
      gateway.rpc['profiles.set_asset'] = (_) => const RpcResult({'ok': true});
      gateway.rpc['profiles.list'] = (_) => const RpcResult({
        'profiles': [
          {
            'name': 'nova',
            'ui_meta_revisions': {'hermes-bots': 2},
            'ui_meta': {
              'hermes-bots': {'color': '#f00', 'chat': 'old', 'title': 'Old'},
              'other': {'x': 1},
            },
          },
        ],
      });
      final answers = [
        {
          'applied': {
            'ui_meta': false,
            'ui_meta_conflicts': {'hermes-bots': <String, Object?>{}},
          },
        },
        {
          'applied': {'ui_meta': true},
        },
      ];
      gateway.rpc['profiles.configure'] = (_) => RpcResult(answers.removeAt(0));

      await api.createProfile('nova');
      expect(sent('profiles.create'), {'name': 'nova'});
      await api.setAvatar('nova', 'AAAA');
      expect(sent('profiles.set_asset'), {
        'name': 'nova',
        'asset': 'avatar',
        'data': 'AAAA',
      });
      await api.setAvatar('nova', null);
      expect(sent('profiles.set_asset'), containsPair('clear', true));

      // The first write lost a race: it is redone on the newer entry.
      await api.setBotTitle('nova', 'Nova');
      expect(
        gateway.calls.where((c) => c.method == 'profiles.configure'),
        hasLength(2),
      );
      expect(sent('profiles.configure'), {
        'name': 'nova',
        'ui_meta': {
          'hermes-bots': {'color': '#f00', 'title': 'Nova'},
        },
        'ui_meta_expected_revisions': {'hermes-bots': 2},
      });
    });
    test('a bot screen: status, start, a still, a way in, control both '
        'ways; an older gateway has none', () async {
      const lease = {'holder': 'agent', 'viewer_hash': null, 'epoch': 3};
      const status = {
        'profile': 'nova',
        'supported': true,
        'installed': true,
        'running': true,
        'lease': lease,
        'profile_key': '/home/a/.hermes/profiles/nova',
      };
      gateway.rpc['display.status'] = (_) => const RpcResult(status);
      gateway.rpc['display.start'] = (_) => const RpcResult(status);
      gateway.rpc['display.thumbnail'] = (_) => const RpcResult({
        'data_url': null,
        'suppressed': 'human_has_control',
      });
      gateway.rpc['display.observe'] = (_) => const RpcResult({
        ...status,
        'ticket': 't/k',
        'path': '/api/display/ws',
        'viewer_id': 'viewer-1',
      });
      gateway.rpc['display.lease.acquire'] = (_) => const RpcResult({
        'lease': {'holder': 'human', 'viewer_hash': '63a9e8a8c2d8', 'epoch': 4},
      });
      gateway.rpc['display.lease.release'] = (_) => const RpcResult({
        'lease': {'holder': 'robot', 'epoch': 5},
      });

      final screen = (await api.screenStatus('nova'))!;
      expect(sent('display.status'), {'profile': 'nova'});
      expect(
        (screen.available, screen.running, screen.lease.epoch),
        (true, true, 3),
      );
      await api.startScreen('nova');
      expect(sent('display.start'), {'profile': 'nova'});
      expect(await api.screenThumbnail('nova'), isNull);

      final way = await api.observeScreen('nova', viewerId: 'old');
      expect(sent('display.observe'), {'profile': 'nova', 'viewer_id': 'old'});
      expect(way.viewerId, 'viewer-1');
      expect(way.stream.scheme, 'ws');
      expect(way.stream.path, endsWith('/api/display/ws'));
      expect(way.stream.queryParameters, {'display_ticket': 't/k'});

      // The holder knows itself by the hash of its viewer id.
      final held = await api.takeOverScreen('nova', way.viewerId);
      expect(sent('display.lease.acquire'), {
        'profile': 'nova',
        'viewer_id': 'viewer-1',
      });
      expect(held.heldBy(screenViewerHash(way.viewerId)), isTrue);
      final back = await api.handBackScreen('nova', force: true);
      expect(sent('display.lease.release'), {'profile': 'nova', 'force': true});
      expect(back.holder, ScreenHolder.agent);

      gateway.rpc['display.status'] = (_) =>
          const RpcError(HermesProtocol.errMethodNotFound, 'method not found');
      expect(await api.screenStatus('nova'), isNull);
    });
  });

  group('over REST', () {
    SeenRequest last() => gateway.requests.last;

    test('deleting a bot is the dashboard route', () async {
      gateway.routes['DELETE /api/profiles/my%20bot'] = (_) =>
          reply({'ok': true});
      await api.deleteProfile('my bot');
      expect(last().method, 'DELETE');
    });

    test('stored sessions: one row, the newest page, escaped ids', () async {
      gateway.routes['GET /api/sessions/a%20b%2Fc'] = (_) =>
          reply({'id': 'a b/c', 'end_reason': 'compression'});
      gateway.routes['GET /api/sessions/s1/messages'] = (_) => reply({
        'messages': [
          {'role': 'user', 'content': 'hi'},
        ],
      });

      final row = await api.storedSession(storedId: 'a b/c', profile: 'nova');
      expect((row.profile, row.endReason), ('nova', 'compression'));
      final msgs = await api.storedMessages(storedId: 's1', profile: 'nova');
      expect(msgs.single.body, 'hi');
      expect(last().query, {
        'profile': 'nova',
        'limit': '${HermesLimits.storedMessagesPage}',
        'order': 'latest',
        'inline_images': 'false',
      });
      expect(
        await caught(api.storedSession(storedId: '..', profile: 'nova')),
        isA<ProtocolFailure>(),
      );
    });

    test('a bot: skills, toolsets, soul read and written', () async {
      gateway.routes['GET /api/skills'] = (_) =>
          reply(fixtureJson('skills.json'));
      gateway.routes['GET /api/tools/toolsets'] = (_) =>
          reply(fixtureJson('toolsets.json'));
      gateway.routes['GET /api/profiles/nova/soul'] = (_) =>
          reply(fixtureJson('soul.json'));
      gateway.routes['PUT /api/profiles/nova/soul'] = (_) =>
          reply({'ok': true});

      expect(await api.skills('nova'), isNotEmpty);
      expect(last().query, {'profile': 'nova'});
      expect(await api.toolsets('nova'), isNotEmpty);
      expect((await api.soul('nova')).exists, isTrue);
      await api.saveSoul('nova', '# Nova');
      expect(last().body, {'content': '# Nova'});
    });

    test('a route an older gateway lacks is not supported', () async {
      expect(await caught(api.skills('nova')), isA<NotSupportedFailure>());
      expect(await caught(api.restartGateway()), isA<NotSupportedFailure>());
      expect(
        await caught(api.transcribe(bytes: [1], mimeType: 'audio/m4a')),
        isA<NotSupportedFailure>(),
      );
    });

    test('cron jobs: list, pause, resume, run, delete, a gone one', () async {
      gateway.routes['GET /api/cron/jobs'] = (_) =>
          reply(fixtureJson('cron_jobs.json'));
      for (final a in ['pause', 'resume', 'trigger']) {
        gateway.routes['POST /api/cron/jobs/j%2F1/$a'] = (_) =>
            reply({'id': 'j/1', 'state': a});
      }
      gateway.routes['DELETE /api/cron/jobs/j%2F1'] = (_) =>
          reply({'ok': true});

      expect(await api.cronJobs('nova'), isNotEmpty);
      expect((await api.pauseCronJob('nova', 'j/1')).state, 'pause');
      expect((await api.resumeCronJob('nova', 'j/1')).state, 'resume');
      expect((await api.runCronJob('nova', 'j/1')).state, 'trigger');
      await api.deleteCronJob('nova', 'j/1');
      expect(last().method, 'DELETE');
      expect(last().query, {'profile': 'nova'});

      final gone = await caught(api.pauseCronJob('nova', 'other'));
      expect(
        gone,
        isA<ServerFailure>().having((f) => f.httpStatus, 'status', 404),
      );
    });

    test(
      'speech to text posts a data URL for the bot; too big never leaves',
      () async {
        gateway.routes['POST /api/audio/transcribe'] = (_) =>
            reply({'transcript': 'hello'});

        expect(
          await api.transcribe(
            bytes: [1, 2],
            mimeType: 'audio/m4a',
            profile: 'nova',
          ),
          'hello',
        );
        expect(last().query, {'profile': 'nova'});
        expect(last().body, {
          'data_url': 'data:audio/m4a;base64,AQI=',
          'mime_type': 'audio/m4a',
        });
        final before = gateway.requests.length;
        expect(
          await caught(
            api.transcribe(
              bytes: List.filled(HermesLimits.maxAudioBytes + 1, 0),
              mimeType: 'audio/m4a',
            ),
          ),
          isA<ServerFailure>().having((f) => f.httpStatus, 'status', 413),
        );
        expect(gateway.requests.length, before);
      },
    );

    test(
      'text to speech posts the text for the bot and reads the audio',
      () async {
        gateway.routes['POST /api/audio/speak'] = (_) =>
            reply({'ok': true, 'data_url': 'data:audio/mpeg;base64,AQI='});

        final audio = await api.speak(text: 'Hi **there**', profile: 'nova');
        expect(audio.bytes, [1, 2]);
        expect(audio.mimeType, 'audio/mpeg');
        expect(last().query, {'profile': 'nova'});
        expect(last().body, {'text': 'Hi **there**'});
      },
    );

    test('a file size is asked as its first byte only', () async {
      gateway.routes['GET /api/files/download'] = (_) => reply(
        'x',
        status: 206,
        headers: {'content-range': 'bytes 0-0/26624'},
      );

      expect(await api.mediaSize('/home/a/handoff/notes.md'), 26624);
      expect(last().headers.value('range'), 'bytes=0-0');
      expect(last().query, {'path': '/home/a/handoff/notes.md'});
    });

    test('a long recording is encoded apart and still goes out', () async {
      gateway.routes['POST /api/audio/transcribe'] = (_) =>
          reply({'transcript': 'long'});
      final bytes = List.filled(HermesLimits.offloadJsonBytes, 1);

      expect(await api.transcribe(bytes: bytes, mimeType: 'audio/m4a'), 'long');
    });

    test('restart, update and their status', () async {
      gateway.routes['POST /api/gateway/restart'] = (_) =>
          reply({'ok': true, 'name': 'gateway-restart'});
      gateway.routes['POST /api/hermes/update'] = (_) => reply({
        'ok': false,
        'error': 'update_not_in_place',
        'message': 'Run it by hand',
      });
      gateway.routes['GET /api/hermes/update/check'] = (_) =>
          reply({'behind': 3, 'update_available': true, 'can_apply': true});
      gateway.routes['GET /api/actions/hermes-update/status'] = (_) => reply({
        'name': 'hermes-update',
        'running': true,
        'lines': ['a'],
      });

      expect((await api.restartGateway()).ok, isTrue);
      expect((await api.startUpdate()).refusal, 'Run it by hand');
      final check = await api.checkUpdate();
      expect((check.updateAvailable, check.unknown), (true, false));
      expect(last().query, {'force': 'true'});
      expect((await api.actionStatus('hermes-update')).running, isTrue);
      expect(last().query, {'lines': '${HermesLimits.actionLogLines}'});
    });
  });

  group('awaitAction', () {
    const action = 'gateway-restart';
    const route = 'GET /api/actions/gateway-restart/status';
    var polls = 0;

    setUp(() => polls = 0);

    Future<void> noWait(Duration _) async {}

    /// The status route answers what [answer] says for poll number n.
    void script(HttpReply Function(int n) answer) =>
        gateway.routes[route] = (_) => answer(++polls);

    HttpReply done(int _) =>
        reply({'name': action, 'running': false, 'exit_code': 0});

    Future<Object?> wait({
      bool Function()? cancelled,
      Duration timeout = const Duration(minutes: 5),
    }) => caught(
      api.awaitAction(
        action,
        timeout: timeout,
        wait: noWait,
        cancelled: cancelled,
      ),
    );

    test('rides out a restarting dashboard, then returns the result', () async {
      script(
        (n) => switch (n) {
          1 => reply({}, status: 503),
          2 => reply({}, status: 401),
          3 => reply({'name': action, 'running': true}),
          _ => done(n),
        },
      );

      expect(
        await wait(),
        isA<ActionStatus>().having((s) => s.succeeded, 'succeeded', isTrue),
      );
      expect(polls, 4);
      expect(logs.where((l) => l.startsWith('skipped a poll')), hasLength(2));
    });

    test(
      'gives up after a long run of failures; a good poll resets it',
      () async {
        script((_) => reply({}, status: 401));
        expect(await wait(), isA<UnauthorizedFailure>());
        expect(polls, HermesLimits.actionPollMaxFailures);

        polls = 0;
        const run = HermesLimits.actionPollMaxFailures - 1;
        script(
          (n) => n == run + 1
              ? reply({'name': action, 'running': true})
              : n == 2 * run + 2
              ? done(n)
              : reply({}, status: 503),
        );
        expect(await wait(), isA<ActionStatus>());
      },
    );

    test('a failure waiting cannot cure ends it at once', () async {
      for (final (status, body, failure) in [
        (403, <String, Object?>{}, isA<ForbiddenFailure>()),
        (404, {'detail': 'Not Found'}, isA<ServerFailure>()),
        (200, <Object?>[], isA<ProtocolFailure>()),
      ]) {
        polls = 0;
        script((_) => reply(body, status: status));
        expect(await wait(), failure);
        expect(polls, 1);
      }
    });

    test(
      'a lost action is of unknown outcome; a running one is not lost',
      () async {
        script((_) => reply({'name': action, 'running': false}));
        expect(await wait(), isA<OutcomeUnknownFailure>());
        expect(polls, HermesLimits.actionNoResultPolls);

        polls = 0;
        script(
          (n) =>
              n == 60 ? done(n) : reply({'name': action, 'running': n.isEven}),
        );
        expect(await wait(), isA<ActionStatus>());
      },
    );

    test('cancel and timeout end the wait', () async {
      script((_) => reply({'name': action, 'running': true}));

      expect(await wait(cancelled: () => true), isA<CancelledFailure>());
      expect(polls, 0);
      expect(await wait(cancelled: () => polls >= 2), isA<CancelledFailure>());
      expect(polls, 2);
      expect(await wait(timeout: Duration.zero), isA<NetworkFailure>());
    });
  });
}
