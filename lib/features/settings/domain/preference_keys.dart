/// Keys for persisted preferences. Central so nothing is duplicated.
abstract final class PreferenceKeys {
  static const String themeMode = 'settings.themeMode';
  static const String gatewayUrl = 'gateway.url';
  static const String gatewayAuthMode = 'gateway.authMode';
  static const String gatewayUsername = 'gateway.username';
  static const String lastProfile = 'nav.lastProfile';
  static const String sidebarCollapsed = 'sidebar.collapsed';
  static const String notificationsEnabled = 'notifications.enabled';
  static const String keepConnectionAlive = 'notifications.keepAlive';

  /// Set once the OS permission dialog has been shown, so the app asks at most
  /// once on its own; after that the user asks, from Settings.
  static const String notificationsPrompted = 'notifications.prompted';

  /// When the app last left the screen; gone while it is in front. Read by
  /// the background check, so stored outside the cached preferences.
  static const String awaySince = 'notifications.awaySince';

  /// Per bot, what the app has seen of its chat, with the account.
  static const String chatMarks = 'notifications.chatMarks';

  /// This phone's id for the Pomelu Hermes plugin, and the account it is
  /// registered with.
  static const String pushDeviceId = 'notifications.pushDeviceId';
  static const String pushAccount = 'notifications.pushAccount';

  /// Set once the secrets are stored readable while the phone is locked.
  static const String secretsReadableLocked = 'secrets.readableLocked';

  /// Prefixes of the chat store's per-bot keys (`ChatStore`), followed by
  /// the gateway and the bot.
  static const String chatOutboxPrefix = 'chat.outbox.';
  static const String chatPendingOutboxesPrefix = 'chat.pendingOutboxes.';
  static const String chatDraftPrefix = 'chat.draft.';
  static const String chatHiddenPrefix = 'chat.hidden.';

  // Secrets (SecretStore)
  static const String gatewayToken = 'gateway.token';
  static const String gatewayPassword = 'gateway.password';
}
