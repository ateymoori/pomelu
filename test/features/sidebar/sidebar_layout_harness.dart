import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hermes/app/routes.dart';
import 'package:hermes/core/storage/key_value_store.dart';
import 'package:hermes/core/storage/secret_store.dart';
import 'package:hermes/core/theme/app_theme.dart';
import 'package:hermes/features/chat/domain/chat_target.dart';
import 'package:hermes/features/connection/presentation/connection_providers.dart';
import 'package:hermes/features/settings/domain/preference_keys.dart';
import 'package:hermes/features/sidebar/domain/bot_group.dart';
import 'package:hermes/features/sidebar/presentation/sidebar_providers.dart';
import 'package:hermes/hermes/client/connection_state.dart';
import 'package:hermes/hermes/models/profile.dart';
import 'package:hermes/l10n/generated/app_localizations.dart';

import '../../support/memory_stores.dart';

const _atlas = BotGroup(
  profile: HermesProfile(
    name: 'atlas',
    model: 'sonnet',
    description: 'Research',
  ),
);
const _hermes = BotGroup(
  profile: HermesProfile(name: 'hermes', model: 'haiku'),
);

/// A roster that counts its builds instead of calling a gateway.
class FakeProfiles extends Profiles {
  static int builds = 0;

  @override
  Future<List<HermesProfile>> build() async {
    builds++;
    return const [];
  }

  @override
  Future<void> refresh() async {}
}

Widget app(
  Widget Function(BuildContext) build, {
  AsyncValue<List<BotGroup>> groups = const AsyncData([_atlas, _hermes]),
  bool configured = true,
  ThemeData? theme,
  double textScale = 1,
}) {
  final router = GoRouter(
    initialLocation: Routes.home,
    routes: [
      GoRoute(
        path: Routes.home,
        builder: (context, state) => Scaffold(body: build(context)),
        routes: [
          GoRoute(
            path: 'chat/:${Routes.profileParam}',
            builder: (context, state) => const Scaffold(body: Text('chat')),
          ),
        ],
      ),
      GoRoute(
        path: Routes.settings,
        builder: (context, state) => const Scaffold(body: Text('settings')),
      ),
    ],
  );
  return ProviderScope(
    overrides: [
      keyValueStoreProvider.overrideWithValue(
        MemoryKeyValueStore({
          if (configured) PreferenceKeys.gatewayUrl: 'http://gw.test:9119',
        }),
      ),
      secretStoreProvider.overrideWithValue(MemorySecretStore()),
      sidebarGroupsProvider.overrideWithValue(groups),
      profilesProvider.overrideWith(FakeProfiles.new),
      connectionStateProvider.overrideWith(
        (ref) => Stream<HermesConnectionState>.value(
          const Connected(replayEpoch: 'x'),
        ),
      ),
      profileAvatarProvider.overrideWith((ref, name) => null),
    ],
    child: MaterialApp.router(
      theme: theme ?? AppTheme.light(),
      routerConfig: router,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}

const open = ChatTarget.bot('atlas');

/// How often the roster was built, reading it first: a Retry that starts it
/// afresh shows as one more build.
int rosterBuilds(WidgetTester tester) {
  ProviderScope.containerOf(tester.element(find.byType(Scaffold).first))
      .read(profilesProvider);
  return FakeProfiles.builds;
}
