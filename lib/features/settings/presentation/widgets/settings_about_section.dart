import 'dart:async';

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/assets.dart';
import '../../../../core/config/legal_config.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../settings_controller.dart';

/// App version, the gateway version once a probe answered, the open-source
/// licenses, and the privacy policy when there is one.
class SettingsAboutSection extends ConsumerWidget {
  const SettingsAboutSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final spacing = context.spacing;
    final appVersion = ref.watch(appVersionProvider).value;
    final gatewayVersion =
        ref.watch(settingsControllerProvider).probe?.status?.version ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FormSection(
          header: l10n.settingsAboutSection,
          children: [
            if (appVersion == null)
              Padding(
                padding: EdgeInsets.all(spacing.lg),
                child: ShimmerLine(height: spacing.md),
              )
            else
              FormRow(title: l10n.appName, value: appVersion),
            if (gatewayVersion.isNotEmpty)
              FormRow(title: l10n.settingsGatewayLabel, value: gatewayVersion),
          ],
        ),
        SizedBox(height: spacing.xl),
        SettingsLegalLinks(appVersion: appVersion),
      ],
    );
  }
}

/// The open-source licenses and the privacy policy.
class SettingsLegalLinks extends StatelessWidget {
  /// An empty [privacyPolicyUrl] hides its row.
  const SettingsLegalLinks({
    required this.appVersion,
    super.key,
    this.privacyPolicyUrl = LegalConfig.privacyPolicyUrl,
  });

  final String? appVersion;

  final String privacyPolicyUrl;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.spacing;
    return FormSection(
      children: [
        FormRow(
          title: l10n.settingsLicenses,
          navigates: true,
          onTap: () => showLicensePage(
            context: context,
            applicationName: l10n.appName,
            applicationVersion: appVersion,
            applicationIcon: Padding(
              padding: EdgeInsets.all(spacing.md),
              child: Image.asset(
                Assets.logo,
                width: spacing.appIcon,
                height: spacing.appIcon,
              ),
            ),
          ),
        ),
        if (privacyPolicyUrl.isNotEmpty)
          FormRow(
            title: l10n.settingsPrivacyPolicy,
            trailing: Icon(
              CupertinoIcons.arrow_up_right,
              size: spacing.lg,
              color: context.colors.textTertiary,
            ),
            onTap: () => unawaited(_open(context, privacyPolicyUrl)),
          ),
      ],
    );
  }

  /// Opens [url] in the browser; says so when nothing could open it.
  static Future<void> _open(BuildContext context, String url) async {
    final snacks = AppSnacks.of(context);
    final failed = context.l10n.settingsLinkFailed;
    var opened = false;
    try {
      opened = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } on Object catch (e) {
      log.w('could not open the privacy policy', error: e);
    }
    if (!opened) snacks.show(failed);
  }
}
