import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/storage/stored_preference.dart';
import '../domain/preference_keys.dart';

part 'theme_mode_provider.g.dart';

/// Persisted theme mode. Default is [ThemeMode.system].
@Riverpod(keepAlive: true)
class ThemeModeSetting extends _$ThemeModeSetting with StoredChoice<ThemeMode> {
  @override
  String get key => PreferenceKeys.themeMode;

  @override
  List<ThemeMode> get choices => ThemeMode.values;

  @override
  ThemeMode get fallback => ThemeMode.system;

  @override
  ThemeMode build() => load();
}
