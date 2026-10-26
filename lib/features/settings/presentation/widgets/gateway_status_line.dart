import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../hermes/hermes_constants.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../connection/domain/connection_probe.dart';
import '../../domain/settings_form_state.dart';
import 'settings_section.dart';

/// One line under the URL field telling the user what the gateway is and
/// whether it wants a sign-in, or that it is too old for this app.
class GatewayStatusLine extends StatelessWidget {
  const GatewayStatusLine({required this.state, super.key});

  final SettingsFormState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final spacing = context.spacing;
    final style = Theme.of(context).textTheme.bodySmall;

    if (state.probing) {
      return Row(
        children: [
          ShimmerLine(width: spacing.xl, height: spacing.md),
          SizedBox(width: spacing.sm),
          Text(l10n.settingsAuthDetecting, style: style),
        ],
      );
    }

    final probe = state.probe;
    if (probe == null) return const SizedBox.shrink();

    if (!probe.reachable) {
      return Text(
        l10n.errorNetwork,
        style: style?.copyWith(color: colors.danger),
      );
    }

    if (state.gatewayTooOld) {
      return Text(
        l10n.settingsGatewayTooOld(
          probe.status?.version ?? '',
          HermesProtocol.minGatewayVersion,
        ),
        style: style?.copyWith(color: colors.warning),
      );
    }

    if (!probe.gated) {
      return SettingsStatus(kind: StatusKind.ok, label: l10n.settingsAuthNone);
    }

    if (state.authUnsupported) {
      return Text(
        l10n.settingsAuthUnsupported(_providerNames(l10n, probe)),
        style: style?.copyWith(color: colors.warning),
      );
    }

    return SettingsStatus(kind: StatusKind.warn, label: l10n.settingsAuthBasic);
  }

  static String _providerNames(AppLocalizations l10n, ProbeResult probe) {
    final separator = l10n.settingsAuthProviderSeparator;
    final names = probe.providers
        .map((p) => p.displayName.isEmpty ? p.name : p.displayName)
        .where((n) => n.isNotEmpty);
    if (names.isNotEmpty) return names.join(separator);
    return probe.status?.authProviders?.join(separator) ?? '';
  }
}

/// "Not encrypted" under a plain `http://` address of a host on the
/// internet: it stays while the address does, so nobody misses it.
class InsecureLinkNotice extends StatelessWidget {
  const InsecureLinkNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final style = Theme.of(context).textTheme.bodySmall;
    return Semantics(
      container: true,
      liveRegion: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            CupertinoIcons.lock_open,
            size: spacing.lg,
            color: colors.warning,
          ),
          SizedBox(width: spacing.sm),
          Expanded(
            child: Text(
              context.l10n.settingsNotEncrypted,
              style: style?.copyWith(color: colors.warning),
            ),
          ),
        ],
      ),
    );
  }
}
