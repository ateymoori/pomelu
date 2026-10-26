import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/features/notifications/domain/notification_policy.dart';
import 'package:hermes/features/notifications/presentation/active_view_provider.dart';
import 'package:hermes/hermes/events/event_payloads.dart';
import 'package:hermes/hermes/requests/clarify_question.dart';
import 'package:hermes/hermes/requests/server_request.dart';
import 'package:hermes/l10n/generated/app_localizations.dart';

final l10n = lookupAppLocalizations(const Locale('en'));

NotificationPolicy policyWith({bool enabled = true, bool granted = true}) =>
    NotificationPolicy(
      enabled: enabled,
      permissionGranted: granted,
      l10n: l10n,
    );

const ref = SessionRef(runtimeId: 'rt-1', storedId: 's-1', profile: 'atlas');
const away = ActiveView.background;
const onAtlas = ActiveView(isForeground: true, profile: 'atlas');
const onOther = ActiveView(isForeground: true, profile: 'other');

GatewayNotice notice({String level = 'info', int? ttlMs}) => GatewayNotice(
  sessionId: 'rt-1',
  text: 'Something happened',
  level: level,
  key: 'k',
  ttlMs: ttlMs,
);

const clarify = ServerRequest.clarify(
  id: 'srq-1',
  sessionId: 'rt-1',
  questions: [
    ClarifyQuestion(qid: 'q0', question: 'Which branch?'),
    ClarifyQuestion(qid: 'q1', question: 'Which remote?'),
  ],
);

void main() {
  test('nothing is posted with the toggle off or without the grant', () {
    for (final p in [policyWith(enabled: false), policyWith(granted: false)]) {
      expect(p.forNotice(notice(), view: away, ref: ref), isNull);
      expect(p.forRequest(clarify, view: away, ref: ref), isNull);
    }
  });

  test('nothing rings for the chat on screen, only for the others', () {
    final p = policyWith();
    expect(p.forNotice(notice(), view: onAtlas, ref: ref), isNull);
    expect(p.forRequest(clarify, view: onAtlas, ref: ref), isNull);
    expect(p.forNotice(notice(), view: onOther, ref: ref), isNotNull);
    // Away, or with the bot not known yet, the app cannot be watching it.
    expect(
      p.forNotice(
        notice(),
        view: const ActiveView(profile: 'atlas'),
        ref: ref,
      ),
      isNotNull,
    );
    expect(p.forNotice(notice(), view: onAtlas), isNotNull);
  });

  test('the open chat comes from the route; nothing is watched elsewhere', () {
    final chat = activeViewFromLocation('/chat/100%25', isForeground: true);
    expect(chat.profile, '100%');
    expect(
      activeViewFromLocation('/settings', isForeground: true).profile,
      isEmpty,
    );
  });

  test('a notice: titled by level, a toast stays in the app', () {
    final p = policyWith();
    String? title(String level) => p
        .forNotice(
          notice(level: level),
          view: away,
          ref: ref,
        )
        ?.title;
    expect(title('info'), l10n.notificationNoticeTitle);
    expect(title('warning'), l10n.notificationWarningTitle);
    expect(title('error'), l10n.notificationErrorTitle);

    expect(p.forNotice(notice(ttlMs: 3000), view: onOther, ref: ref), isNull);
    expect(p.forNotice(notice(ttlMs: 3000), view: away, ref: ref), isNotNull);
    expect(
      p.forNotice(
        notice(ttlMs: 3000, level: 'error'),
        view: onOther,
        ref: ref,
      ),
      isNotNull,
    );
  });

  test('a tap opens the bot chat, or home when the bot is unknown', () {
    final p = policyWith();
    final linked = p.forNotice(notice(), view: away, ref: ref)!;
    expect(linked.deepLink, '/chat/atlas');
    expect(p.forNotice(notice(), view: away)!.deepLink, '/');
    // Same key, same slot: a repeat replaces the row.
    expect(p.forNotice(notice(level: 'error'), view: away)!.id, linked.id);
  });

  test('a background result: titled by outcome, cut for the shade', () {
    final p = policyWith();
    BackgroundResult result(String text) =>
        BackgroundResult(sessionId: 'rt-1', taskId: 't1', text: text);

    final done = p.forBackground(result('42'), view: away, ref: ref)!;
    expect(done.title, l10n.notificationBackgroundTitle);
    expect(
      p.forBackground(result('error: boom'), view: away, ref: ref)!.title,
      l10n.notificationBackgroundFailedTitle,
    );
    final long = p.forBackground(
      result('line one\n\n   two ${'x' * 400}'),
      view: away,
      ref: ref,
    )!;
    expect(long.body, startsWith('line one two'));
    expect(long.body, endsWith('…'));
    expect(long.body.length, lessThanOrEqualTo(241));
    expect(p.forBackground(result(''), view: away, ref: ref), isNull);
  });

  test('a bot message: one row per bot, a file in words, never a path', () {
    final p = policyWith();
    final n = p.forMessage(
      profile: 'atlas',
      botTitle: 'Atlas',
      text: 'Report ready\nMEDIA:/home/me/report.pdf',
    )!;
    expect(
      (n.title, n.body, n.deepLink),
      ('Atlas', 'Report ready', '/chat/atlas'),
    );
    expect(n.tag, NotificationPolicy.messageTag('atlas'));
    expect(
      p
          .forMessage(
            profile: 'atlas',
            botTitle: 'Atlas',
            text: 'MEDIA:/a.png',
          )!
          .body,
      l10n.notificationMessageAttachment,
    );
    expect(
      policyWith(granted: false)
          .forMessage(profile: 'atlas', botTitle: 'Atlas', text: 'hi'),
      isNull,
    );
  });

  test('a question says what is asked, never a value', () {
    final p = policyWith();
    final asked = p.forRequest(clarify, view: away, ref: ref)!;
    expect(asked.title, l10n.notificationQuestionTitle);
    expect(asked.body, 'Which branch? · Which remote?');
    expect(asked.tag, NotificationPolicy.requestTag('srq-1'));

    expect(
      p
          .forRequest(
            const ApprovalRequest(
              id: 'srq-2',
              sessionId: 'rt-1',
              description: 'Clean the build folder',
            ),
            view: away,
          )!
          .body,
      'Clean the build folder',
    );
    final secret = p.forRequest(
      const InputRequest(
        id: 'srq-4',
        sessionId: 'rt-1',
        kind: InputKind.secret,
        prompt: 'Paste your API key',
        subject: 'OPENAI_API_KEY',
      ),
      view: away,
    )!;
    expect(secret.title, l10n.notificationInputTitle);
    expect(secret.body, 'Paste your API key');
  });
}
