import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/platform/platform_info.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../notifications/presentation/notification_providers.dart';

/// Notify me (needs the OS grant) and stay connected (a foreground service;
/// asks for the grant so its row shows, works without it). A refused grant
/// shows the way to the system settings; it is read again on resume.
class SettingsNotificationsSection extends ConsumerStatefulWidget {
  const SettingsNotificationsSection({super.key});

  @override
  ConsumerState<SettingsNotificationsSection> createState() =>
      _SettingsNotificationsSectionState();
}

class _SettingsNotificationsSectionState
    extends ConsumerState<SettingsNotificationsSection> {
  @override
  void initState() {
    super.initState();
    // The user may have flipped the permission in system settings while the
    // app was alive; the standing answer is re-read whenever this opens (and
    // on every resume, in the provider).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(ref.read(notificationPermissionProvider.notifier).refresh());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Null while the grant loads: neither "allowed" nor "blocked" yet, so the
    // card shows no "Blocked" for a moment on every visit.
    final granted = ref.watch(notificationPermissionProvider).value;
    final blocked =
        granted == false &&
        ref.read(notificationPermissionProvider.notifier).wasPrompted();
    final enabled = ref.watch(notificationsEnabledSettingProvider);
    final keepAlive = ref.watch(keepConnectionAliveSettingProvider);

    return FormSection(
      header: l10n.settingsNotifications,
      children: [
        _SwitchRow(
          title: l10n.settingsNotificationsEnabled,
          subtitle: blocked
              ? l10n.settingsNotificationsDenied
              : l10n.settingsNotificationsEnabledBody,
          value: enabled && granted != false,
          onChanged: (value) => unawaited(_setEnabled(value: value)),
        ),
        if (ref.watch(platformInfoProvider).canStayConnected)
          _SwitchRow(
            title: l10n.settingsKeepAlive,
            subtitle: l10n.settingsKeepAliveBody,
            value: keepAlive,
            onChanged: (value) => unawaited(_setKeepAlive(value: value)),
          ),
        if (blocked)
          FormButtonRow(
            label: l10n.actionOpenSettings,
            onPressed: () => unawaited(
              ref
                  .read(notificationPermissionProvider.notifier)
                  .openSystemSettings(),
            ),
          ),
      ],
    );
  }

  /// Asks for a missing grant; a refusal leaves the switch off.
  Future<bool> _ensurePermission() async {
    final permission = ref.read(notificationPermissionProvider.notifier);
    return await permission.isGranted() || await permission.request();
  }

  Future<void> _setEnabled({required bool value}) async {
    if (value && !await _ensurePermission()) return;
    if (!mounted) return;
    await ref.read(notificationsEnabledSettingProvider.notifier).set(value);
  }

  Future<void> _setKeepAlive({required bool value}) async {
    // Ask once so the ongoing row can show; a refusal does not stop the
    // service.
    if (value) await _ensurePermission();
    if (!mounted) return;
    await ref.read(keepConnectionAliveSettingProvider.notifier).set(value);
  }
}

/// A switch row; label, explanation and state read as one control.
class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      type: MaterialType.transparency,
      child: SwitchListTile.adaptive(
        title: Text(title, style: textTheme.bodyLarge),
        subtitle: Text(
          subtitle,
          style: textTheme.bodySmall?.copyWith(color: colors.textSecondary),
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
