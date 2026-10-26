import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/platform/reduce_transparency.dart';
import '../core/theme/app_chrome.dart';
import '../core/theme/app_theme.dart';
import '../features/connection/presentation/connection_providers.dart';
import '../features/notifications/presentation/notification_center.dart';
import '../features/settings/presentation/theme_mode_provider.dart';
import '../features/sidebar/presentation/bot_shortcuts.dart';
import '../l10n/generated/app_localizations.dart';
import 'router.dart';

/// Root widget.
class HermesApp extends ConsumerWidget {
  const HermesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Alive for the whole app: the supervisor reconnects and signs in again
    // when the gateway rotates its token; the center posts notifications;
    // the app icon's menu follows the bots.
    ref.watch(connectionSupervisorProvider);
    ref.watch(notificationCenterProvider);
    ref.watch(botShortcutsProvider);
    final mode = ref.watch(themeModeSettingProvider);
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      highContrastTheme: AppTheme.lightContrast(),
      highContrastDarkTheme: AppTheme.darkContrast(),
      themeMode: mode,
      routerConfig: router,
      // The open pages come back after a process death.
      restorationScopeId: 'app',
      builder: (context, child) => AppChrome(
        solidGlass: ref.watch(reduceTransparencyProvider).value ?? false,
        child: child ?? const SizedBox.shrink(),
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
    );
  }
}
