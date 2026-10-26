import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/app/routes.dart';
import 'package:hermes/features/chat/domain/chat_target.dart';
import 'package:hermes/features/share/data/share_intake_service.dart';
import 'package:hermes/features/share/domain/incoming_share.dart';
import 'package:hermes/features/share/presentation/composer_seeds_provider.dart';
import 'package:hermes/features/share/presentation/incoming_share_provider.dart';
import 'package:hermes/hermes/models/local_attachment.dart';

/// What the OS hands the app, as the test says.
class _Intake extends Fake implements ShareIntakeService {
  IncomingShare? launch;
  final StreamController<IncomingShare> controller =
      StreamController<IncomingShare>.broadcast();

  @override
  Stream<IncomingShare> get shares => controller.stream;

  @override
  Future<IncomingShare?> initial() async => launch;

  @override
  Future<void> dispose() => controller.close();
}

const _target = ChatTarget.bot('atlas');

LocalAttachment _file(String name) => LocalAttachment(
  id: name,
  path: '/cache/$name',
  name: name,
  mimeType: 'text/plain',
  sizeBytes: 3,
);

void main() {
  late _Intake intake;
  late ProviderContainer container;

  ProviderContainer boot() {
    final c = ProviderContainer(
      overrides: [shareIntakeServiceProvider.overrideWithValue(intake)],
    );
    // The share lives while someone watches it, as the shell and the picker do.
    c.listen(pendingShareProvider, (_, _) {});
    addTearDown(c.dispose);
    return c;
  }

  setUp(() {
    intake = _Intake();
    addTearDown(intake.dispose);
  });

  group('what is kept', () {
    test('the share that launched the app', () async {
      intake.launch = const IncomingShare(id: 'launch', text: 'opened with');
      container = boot();
      await pumpEventQueue();

      expect(container.read(pendingShareProvider)?.id, 'launch');
    });

    test('a share that arrives later replaces the one waiting', () async {
      intake.launch = const IncomingShare(id: 'one', text: 'first');
      container = boot();
      await pumpEventQueue();

      intake.controller.add(const IncomingShare(id: 'two', text: 'second'));
      await pumpEventQueue();

      expect(container.read(pendingShareProvider)?.id, 'two');
    });

    test('a share with nothing in it is not kept', () async {
      container = boot();
      await pumpEventQueue();

      intake.controller.add(const IncomingShare(id: 'blank', text: '  '));
      await pumpEventQueue();

      expect(container.read(pendingShareProvider), isNull);
    });

    test('a link that only names a bot is kept: it says where to go', () async {
      container = boot();
      await pumpEventQueue();

      intake.controller.add(const IncomingShare(id: 'link', profile: 'nova'));
      await pumpEventQueue();

      expect(container.read(pendingShareProvider)?.profile, 'nova');
    });

    test(
      'a share whose files were all left out is kept: the user is told',
      () async {
        container = boot();
        await pumpEventQueue();

        intake.controller.add(const IncomingShare(id: 'big', skipped: 2));
        await pumpEventQueue();

        final kept = container.read(pendingShareProvider);
        expect(kept?.skipped, 2);
        expect(kept?.isEmpty, isTrue);
      },
    );
  });

  group('settling it', () {
    test('dismiss forgets that share, and only that one', () async {
      intake.launch = const IncomingShare(id: 'a', text: 'x');
      container = boot();
      await pumpEventQueue();
      final notifier = container.read(pendingShareProvider.notifier);

      notifier.dismiss('older');
      expect(container.read(pendingShareProvider)?.id, 'a');

      notifier.dismiss('a');
      expect(container.read(pendingShareProvider), isNull);
    });
  });

  group('routeTo', () {
    test('seeds the chat with the words and the files, then settles', () async {
      final share = IncomingShare(
        id: 'a',
        text: 'look',
        files: [_file('a.txt')],
      );
      intake.launch = share;
      container = boot();
      await pumpEventQueue();

      final route = container
          .read(pendingShareProvider.notifier)
          .routeTo(_target, share);

      expect(route, Routes.chatPath('atlas'));
      expect(container.read(pendingShareProvider), isNull);
      final seed = container.read(composerSeedsProvider)[_target.key];
      expect(seed?.text, 'look');
      expect(seed?.attachments.map((f) => f.name), ['a.txt']);
    });
  });
}
