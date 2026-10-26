import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/navigation/leave_page.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/ui/ui.dart';
import '../../../core/utils/l10n_ext.dart';
import 'settings_controller.dart';
import 'widgets/settings_about_section.dart';
import 'widgets/settings_appearance_section.dart';
import 'widgets/settings_connection_actions.dart';
import 'widgets/settings_gateway_section.dart';
import 'widgets/settings_notifications_section.dart';

/// Gateway connection + appearance. The only settings surface in the app.
///
/// Leaving with gateway changes that were not saved (back, the close button,
/// the system gesture) asks first. A sign-in, a test or a save in flight
/// keeps the page open; a probe does not (it only reads, and closing the page
/// drops its answer).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final dirty = ref.watch(settingsDirtyProvider);
    final busy = ref.watch(
      settingsControllerProvider.select((s) => s.blocksLeaving),
    );

    return PopScope(
      canPop: !dirty && !busy,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !busy) unawaited(_confirmDiscard(context));
      },
      child: Scaffold(
        backgroundColor: context.surfaces.grouped,
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: true,
        appBar: readingAppBar(
          context,
          title: l10n.settingsTitle,
          onClose: () => unawaited(requestLeavePage(context)),
        ),
        body: const _Body(),
      ),
    );
  }

  /// Asks before dropping unsaved changes; closes the page on a yes.
  Future<void> _confirmDiscard(BuildContext context) async {
    final discard = await confirmDiscard(
      context,
      body: context.l10n.settingsDiscardBody,
    );
    if (discard && context.mounted) leavePage(context);
  }
}

/// Scrollable content that runs under the glass bar; rides above the
/// keyboard.
class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.only(
          // Under the glass bar: start below it, scroll on beneath it.
          top: MediaQuery.paddingOf(context).top + spacing.sm,
          bottom: spacing.xxl + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: const ReadingColumn(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SettingsGatewaySection(),
              _SectionGap(),
              SettingsConnectionActions(),
              _SectionGap(),
              SettingsAppearanceSection(),
              _SectionGap(),
              SettingsNotificationsSection(),
              _SectionGap(),
              SettingsAboutSection(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Vertical rhythm between cards.
class _SectionGap extends StatelessWidget {
  const _SectionGap();

  @override
  Widget build(BuildContext context) => SizedBox(height: context.spacing.xl);
}
