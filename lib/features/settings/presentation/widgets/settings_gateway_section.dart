import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';

import '../../../../core/ui/ui.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../settings_controller.dart';
import 'gateway_auth_block.dart';
import 'gateway_status_line.dart';
import 'settings_section.dart';

/// Gateway URL, what the probe found, a link to the setup guide, whether the
/// link is encrypted, and sign-in.
class SettingsGatewaySection extends ConsumerStatefulWidget {
  const SettingsGatewaySection({super.key});

  @override
  ConsumerState<SettingsGatewaySection> createState() =>
      _SettingsGatewaySectionState();
}

class _SettingsGatewaySectionState
    extends ConsumerState<SettingsGatewaySection> {
  late final TextEditingController _url;

  @override
  void initState() {
    super.initState();
    final state = ref.read(settingsControllerProvider);
    _url = TextEditingController(text: state.url);
  }

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    final urlInvalid = state.url.trim().isNotEmpty && !state.urlValid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FormSection(
          header: l10n.settingsGatewaySection,
          children: [
            SettingsField(
              label: l10n.settingsGatewayUrl,
              child: TextField(
                controller: _url,
                keyboardType: TextInputType.url,
                autocorrect: false,
                enableSuggestions: false,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.url],
                onChanged: controller.setUrl,
                decoration: InputDecoration(
                  hintText: l10n.settingsGatewayUrlHint,
                  errorText: !urlInvalid
                      ? null
                      : state.config.hasUserInfo
                      ? l10n.settingsGatewayUrlUserInfo
                      : l10n.settingsGatewayUrlInvalid,
                ),
              ),
            ),
            SettingsInset(child: GatewayStatusLine(state: state)),
            if (state.insecure)
              const SettingsInset(child: InsecureLinkNotice()),
            FormRow(
              title: l10n.connectGuideTitle,
              navigates: true,
              onTap: () => unawaited(context.push<void>(Routes.connectGuide)),
            ),
          ],
        ),
        const GatewayAuthBlock(),
      ],
    );
  }
}
