/// Legal links the app shows (Settings, About).
abstract final class LegalConfig {
  /// The page both store listings name; `--dart-define=PRIVACY_POLICY_URL=`
  /// overrides it (empty hides the About row).
  static const String privacyPolicyUrl = String.fromEnvironment(
    'PRIVACY_POLICY_URL',
    defaultValue: 'https://royan.se/pomelu/privacy/',
  );

  /// Where a reply report is mailed: Royan AB (the stores' generative-AI
  /// rules ask for in-app reporting).
  static const String reportEmail = String.fromEnvironment(
    'REPORT_EMAIL',
    defaultValue: 'contact@royan.se',
  );
}
