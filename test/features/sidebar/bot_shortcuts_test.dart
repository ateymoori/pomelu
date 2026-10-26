import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hermes/app/router.dart';
import 'package:hermes/core/platform/app_shortcuts.dart';
import 'package:hermes/features/sidebar/presentation/bot_shortcuts.dart';
import 'package:hermes/features/sidebar/presentation/sidebar_providers.dart';
import 'package:hermes/hermes/models/profile.dart';

class _Shortcuts implements AppShortcuts {
  final List<List<AppShortcut>> sets = [];
  void Function(String id)? pick;

  @override
  double get iconFill => 0;

  @override
  Future<void> listen(void Function(String id) onPick) async => pick = onPick;

  @override
  Future<bool> set(List<AppShortcut> items) async {
    sets.add(items);
    return true;
  }

  @override
  Future<void> used(String id) async {}
}

class _Roster extends Profiles {
  _Roster(this.bots);

  final List<HermesProfile> bots;

  @override
  Future<List<HermesProfile>> build() async => bots;
}

class _Router extends Fake implements GoRouter {
  final List<String> went = [];

  @override
  void go(String location, {Object? extra}) => went.add(location);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'the app icon menu holds the first bots; a pick opens its chat',
    () async {
      final now = DateTime.now().toUtc();
      HermesProfile bot(
        String name,
        int minutesAgo, {
        bool isDefault = false,
      }) => HermesProfile(
        name: name,
        displayName: name.toUpperCase(),
        isDefault: isDefault,
        canonicalSession: CanonicalSession(
          lastActive: now.subtract(Duration(minutes: minutesAgo)),
        ),
      );
      final shortcuts = _Shortcuts();
      final router = _Router();
      final container = ProviderContainer(
        overrides: [
          appShortcutsProvider.overrideWithValue(shortcuts),
          appRouterProvider.overrideWithValue(router),
          profilesProvider.overrideWith(
            () => _Roster([
              bot('old', 50),
              bot('atlas', 90, isDefault: true),
              bot('nova', 1),
              bot('echo', 5),
              bot('zed', 30),
            ]),
          ),
        ],
      );
      addTearDown(container.dispose);

      container.read(botShortcutsProvider);
      await container.read(profilesProvider.future);
      await Future<void>.delayed(Duration.zero);
      final menu = shortcuts.sets.single;
      expect(
        [for (final s in menu) (s.id, s.title)],
        [
          ('atlas', 'ATLAS'),
          ('nova', 'NOVA'),
          ('echo', 'ECHO'),
          ('zed', 'ZED'),
        ],
      );
      expect(menu[1].link.toString(), 'pomelu://chat?profile=nova');

      shortcuts.pick!('nova');
      expect(router.went, ['/chat/nova']);
    },
  );
}
