import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/hermes/hermes_constants.dart';
import 'package:hermes/hermes/requests/clarify_question.dart';
import 'package:hermes/hermes/requests/server_request.dart';
import 'package:hermes/hermes/requests/server_request_router.dart';
import 'package:hermes/hermes/rpc/json_rpc_client.dart';

import '../support/fake_channel.dart';
import '../support/fixtures.dart';

final Map<String, dynamic> _fx = fixtureMap('server_requests.json');

Map<String, dynamic> _frame(String name) =>
    (_fx['frames'] as Map<String, dynamic>)[name] as Map<String, dynamic>;

ServerRequest? _parse(String name) {
  final f = _frame(name);
  return ServerRequest.parse(
    f['id'] as Object,
    f['method'] as String,
    f['params'] as Map<String, dynamic>,
  );
}

const _session = 'a1b2c3d4';
const _clarifyId = 'srq-3f9a1c2b7d10';
const _approvalId = 'srq-aa11bb22cc33';

void main() {
  group('parsing', () {
    test('clarify, approval, sudo and secret take their wire shapes', () {
      final clarify = _parse('clarify')! as ClarifyRequest;
      expect(clarify.questions.map((q) => q.qid), ['q0', 'q1', 'q2']);
      expect(clarify.questions[1].multiSelect, isTrue);
      expect(clarify.questions[2].hasChoices, isFalse);

      final approval = _parse('approval')! as ApprovalRequest;
      expect(approval.command, 'rm -rf /tmp/hermes-test-dir');
      expect(approval.choices, ['once', 'session', 'always', 'deny']);
      expect(
        (_parse('approvalNoPermanent')! as ApprovalRequest).choices,
        isNot(contains('always')),
        reason: 'allow_permanent: false hides "always"',
      );
      expect((_parse('approvalEmpty')! as ApprovalRequest).choices, [
        'once',
        'deny',
      ]);

      final sudo = _parse('sudo')! as InputRequest;
      expect(
        (sudo.kind, sudo.subject),
        (InputKind.sudo, 'sudo apt-get update'),
      );
      final secret = _parse('secret')! as InputRequest;
      expect(
        (secret.kind, secret.subject, secret.prompt),
        (InputKind.secret, 'OPENAI_API_KEY', 'Paste your OpenAI API key'),
      );
    });

    test('a clarify question drops blank and over-long choices', () {
      final q = ClarifyQuestion(
        qid: ' q ',
        question: 'Which?',
        choices: ['a', '  ', 'x' * (HermesLimits.maxChoiceChars + 1)],
        multiSelect: true,
      ).normalized()!;
      expect(q.qid, 'q');
      expect(q.choices, ['a']);
      expect(
        const ClarifyQuestion(
          qid: 'q',
          question: 'Q',
          choices: [' '],
          multiSelect: true,
        ).normalized()!.multiSelect,
        isFalse,
      );
      expect(const ClarifyQuestion(question: 'Q').normalized(), isNull);
    });
  });

  group('the router', () {
    late FakeChannel channel;
    late JsonRpcClient rpc;
    late ServerRequestRouter router;

    setUp(() {
      channel = FakeChannel();
      rpc = JsonRpcClient(channel);
      router = ServerRequestRouter()..attach(rpc);
    });

    tearDown(() async {
      await router.dispose();
      await rpc.close();
    });

    Future<void> receive(Map<String, dynamic> frame) async {
      channel.receive(frame);
      await pumpEventQueue();
    }

    Object? errorCode() => (channel.sent.last['error'] as Map)['code'];

    test('parks a question for its session and announces it once', () async {
      final arrived = <String>[];
      final sub = router.arrivals.listen((r) => arrived.add(r.id));

      await receive(_frame('clarify'));
      await receive(_frame('clarify'));
      await receive(_frame('approval'));

      expect(router.pendingFor(_session)!.id, _clarifyId, reason: 'oldest');
      expect(router.pendingFor('other'), isNull);
      expect(arrived, [_clarifyId, _approvalId]);
      expect(channel.sent, isEmpty);
      await sub.cancel();
    });

    test('answers what it does not show at once', () async {
      await receive(_frame('vaultCode'));
      expect(channel.sent.last['result'], {'value': ''});

      await receive(_frame('previewAct'));
      expect(errorCode(), HermesProtocol.errNotShown);

      await receive({
        'jsonrpc': '2.0',
        'id': 'x',
        'method': 'clarify',
        'params': {'session_id': _session, 'questions': <Object?>[]},
      });
      expect(errorCode(), -32602);
      expect(router.pendingFor(_session), isNull);
    });

    test('answers under the wire id, once, and closes the request', () async {
      final closed = <String>[];
      final sub = router.closed.listen(closed.add);
      await receive({
        'jsonrpc': '2.0',
        'id': 7,
        'method': 'approval',
        'params': {'session_id': _session, 'command': 'ls'},
      });

      expect(router.answerApproval('7', 'once'), isTrue);
      expect(router.answerApproval('7', 'once'), isTrue);

      expect(channel.sent.single, {
        'jsonrpc': '2.0',
        'id': 7,
        'result': {'choice': 'once'},
      });
      expect(router.pendingFor(_session), isNull);
      await pumpEventQueue();
      expect(closed, ['7']);
      await sub.cancel();
    });

    test('each kind answers in its own shape', () async {
      await receive(_frame('clarify'));
      router.answerClarify(_clarifyId, {'q0': 'Stress', 'q2': null});
      expect(channel.sent.last['result'], {
        'answers': {'q0': 'Stress', 'q2': null},
      });

      await receive(_frame('singleClarify'));
      router.cancelClarify('srq-1111aaaa2222');
      expect(channel.sent.last['result'], isEmpty);

      await receive(_frame('secret'));
      router.answerInput('srq-7777ffff8888', '');
      expect(channel.sent.last['result'], {'value': ''});
    });

    test('an answer on a dead socket fails and leaves it open', () async {
      await receive(_frame('approval'));
      channel.down = true;

      expect(router.answerApproval(_approvalId, 'deny'), isFalse);
      expect(router.pendingFor(_session)!.id, _approvalId);
    });

    test(
      'a withdrawn request is gone, and a late answer sends nothing',
      () async {
        await receive(_frame('clarify'));
        router
          ..cancel(_clarifyId)
          ..cancel('unknown');

        expect(router.pendingFor(_session), isNull);
        expect(router.answerClarify(_clarifyId, const {}), isTrue);
        expect(channel.sent, isEmpty);
      },
    );

    test('watch emits the current request, then each change', () async {
      await receive(_frame('clarify'));
      final seen = <String?>[];
      final sub = router.watch(_session).listen((r) => seen.add(r?.id));
      await pumpEventQueue();

      await receive(_frame('approval'));
      router.cancel(_clarifyId);
      router.cancel(_approvalId);
      await pumpEventQueue();

      expect(seen, [_clarifyId, _approvalId, null]);
      await sub.cancel();
    });

    test('a reconnect snapshot opens, replaces and drops quietly', () async {
      final arrived = <String>[];
      final sub = router.arrivals.listen((r) => arrived.add(r.id));
      await receive(_frame('sudo'));

      router.replay(_session, [
        ..._fx['openRequests'] as List,
        'junk',
        {'id': null, 'method': 'clarify'},
      ]);
      await pumpEventQueue();

      final clarify = router.pendingFor(_session)! as ClarifyRequest;
      expect(clarify.id, _clarifyId);
      expect(clarify.lockedAnswers, {'q0': 'Caffeine timing', 'q2': null});
      expect(arrived, ['srq-5555eeee6666'], reason: 'replays are no arrivals');

      router.replay(_session, null);
      expect(router.pendingFor(_session), isNull);
      await sub.cancel();
    });

    test('retainSessions forgets requests of other sessions', () async {
      await receive(_frame('approval'));
      router.retainSessions({'another'});
      expect(router.pendingFor(_session), isNull);
    });
  });
}
