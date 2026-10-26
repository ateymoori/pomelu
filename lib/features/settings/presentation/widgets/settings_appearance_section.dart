import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../theme_mode_provider.dart';

/// Theme mode: System / Light / Dark.
class SettingsAppearanceSection extends ConsumerWidget {
  const SettingsAppearanceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final mode = ref.watch(themeModeSettingProvider);

    return FormSection(
      header: l10n.settingsAppearance,
      children: [
        Padding(
          padding: EdgeInsets.all(context.spacing.md),
          child: SizedBox(
            width: double.infinity,
            child: AppSegmented<ThemeMode>(
              selected: mode,
              onChanged: (value) => unawaited(
                ref.read(themeModeSettingProvider.notifier).set(value),
              ),
              segments: {
                ThemeMode.system: l10n.settingsThemeSystem,
                ThemeMode.light: l10n.settingsThemeLight,
                ThemeMode.dark: l10n.settingsThemeDark,
              },
            ),
          ),
        ),
      ],
    );
  }
}
