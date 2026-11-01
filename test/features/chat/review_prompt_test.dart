import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/core/config/app_config.dart';
import 'package:hermes/core/platform/store_review.dart';
import 'package:hermes/core/storage/key_value_store.dart';
import 'package:hermes/core/storage/memory_key_value_store.dart';
import 'package:hermes/features/chat/presentation/review_prompt.dart';
import 'package:hermes/features/settings/domain/preference_keys.dart';
import 'package:hermes/hermes/events/gateway_event.dart';

import '../../support/scripted_api.dart';
import 'chat_harness.dart';

class _Store implements StoreReview {
  int asked = 0;

  @override
  Future<void> request() async => asked++;
}

void main() {
  late _Store store;

  setUp(() => store = _Store());

  /// One reply short of the rule, on one day short of it.
  ReviewPrompt almostThere() => ReviewPrompt(
    MemoryKeyValueStore({
      PreferenceKeys.reviewReplies: '${AppConfig.reviewMinReplies - 1}',
      PreferenceKeys.reviewDays: '2020-01-01,2020-01-02',
    }),
    store,
    () => true,
  );

  testWidgets('real use asks the store, once', (tester) async {
    final prompt = almostThere();

    await prompt.replyFinished();
    await tester.pump(AppConfig.reviewAskDelay);
    await prompt.replyFinished();
    await tester.pump(AppConfig.reviewAskDelay);

    expect(store.asked, 1);
  });

  testWidgets('many replies on one day do not ask', (tester) async {
    final prompt = ReviewPrompt(MemoryKeyValueStore(), store, () => true);

    for (var i = 0; i < AppConfig.reviewMinReplies * 2; i++) {
      await prompt.replyFinished();
    }
    await tester.pump(AppConfig.reviewAskDelay);

    expect(store.asked, 0);
  });

  testWidgets('few replies on many days do not ask', (tester) async {
    final prompt = ReviewPrompt(
      MemoryKeyValueStore({
        PreferenceKeys.reviewReplies: '1',
        PreferenceKeys.reviewDays: '2020-01-01,2020-01-02,2020-01-03',
      }),
      store,
      () => true,
    );

    await prompt.replyFinished();
    await tester.pump(AppConfig.reviewAskDelay);

    expect(store.asked, 0);
  });

  testWidgets('a turn in the pause holds it until the next reply', (
    tester,
  ) async {
    final prompt = almostThere();

    await prompt.replyFinished();
    prompt.notNow();
    await tester.pump(AppConfig.reviewAskDelay);
    expect(store.asked, 0);

    await prompt.replyFinished();
    await tester.pump(AppConfig.reviewAskDelay);
    expect(store.asked, 1);
  });

  testWidgets('it waits while the user types', (tester) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: TextField(focusNode: focus, autofocus: true)),
      ),
    );
    await tester.pump();
    final prompt = almostThere();

    await prompt.replyFinished();
    await tester.pump(AppConfig.reviewAskDelay);
    expect(store.asked, 0);

    focus.unfocus();
    await tester.pump();
    await prompt.replyFinished();
    await tester.pump(AppConfig.reviewAskDelay);
    expect(store.asked, 1);
  });

  testWidgets('away from the screen it does not ask', (tester) async {
    final prompt = almostThere();

    await prompt.replyFinished();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    addTearDown(
      () => tester.binding.handleAppLifecycleStateChanged(
        AppLifecycleState.resumed,
      ),
    );
    await tester.pump(AppConfig.reviewAskDelay);

    expect(store.asked, 0);
  });

  group('from the chat', () {
    Future<ChatRig> almostThereChat(WidgetTester tester) async {
      final rig = bootChat(
        overrides: [storeReviewProvider.overrideWithValue(store)],
      );
      final kv = rig.container.read(keyValueStoreProvider);
      await kv.setString(
        PreferenceKeys.reviewReplies,
        '${AppConfig.reviewMinReplies - 1}',
      );
      await kv.setString(PreferenceKeys.reviewDays, '2020-01-01,2020-01-02');
      await tester.pump();
      return rig;
    }

    String? replies(ChatRig rig) => rig.container
        .read(keyValueStoreProvider)
        .getString(PreferenceKeys.reviewReplies);

    Future<void> turn(
      WidgetTester tester,
      ChatRig rig,
      Map<String, dynamic> end,
    ) async {
      rig.client.emit(ev(EventNames.messageStart));
      await tester.pump();
      rig.client.emit(ev(EventNames.messageComplete, end));
      await tester.pump();
    }

    testWidgets('only a good end counts', (tester) async {
      final rig = await almostThereChat(tester);
      final before = replies(rig);

      await turn(tester, rig, {'status': TurnStatus.interrupted});
      await turn(tester, rig, {'status': TurnStatus.error, 'error': 'quota'});
      expect(replies(rig), before);

      // A replayed end, with no turn running here.
      rig.client.emit(
        ev(EventNames.messageComplete, {'status': TurnStatus.complete}),
      );
      await tester.pump();
      expect(replies(rig), before);

      await tester.pump(AppConfig.reviewAskDelay);
      expect(store.asked, 0);
    });

    testWidgets('a good turn asks after the pause', (tester) async {
      final rig = await almostThereChat(tester);

      await turn(tester, rig, {'status': TurnStatus.complete});
      await tester.pump(AppConfig.reviewAskDelay);

      expect(store.asked, 1);
    });

    testWidgets('a lost connection in the pause holds it', (tester) async {
      final rig = await almostThereChat(tester);

      await turn(tester, rig, {'status': TurnStatus.complete});
      rig.client.goOffline();
      await tester.pump();
      await tester.pump(AppConfig.reviewAskDelay);

      expect(store.asked, 0);
    });

    testWidgets('an error in the pause holds it', (tester) async {
      final rig = await almostThereChat(tester);

      await turn(tester, rig, {'status': TurnStatus.complete});
      rig.client.emit(ev(EventNames.error, {'message': 'boom'}));
      await tester.pump();
      await tester.pump(AppConfig.reviewAskDelay);

      expect(store.asked, 0);
    });
  });

  testWidgets('offline when the pause ends, it does not ask', (tester) async {
    final prompt = ReviewPrompt(
      MemoryKeyValueStore({
        PreferenceKeys.reviewReplies: '${AppConfig.reviewMinReplies - 1}',
        PreferenceKeys.reviewDays: '2020-01-01,2020-01-02',
      }),
      store,
      () => false,
    );

    await prompt.replyFinished();
    await tester.pump(AppConfig.reviewAskDelay);

    expect(store.asked, 0);
  });
}
