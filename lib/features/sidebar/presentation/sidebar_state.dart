import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/storage/stored_preference.dart';
import '../../settings/domain/preference_keys.dart';

part 'sidebar_state.g.dart';

/// Whether the side pane is collapsed to its rail, kept on disk.
@Riverpod(keepAlive: true)
class SidebarCollapsed extends _$SidebarCollapsed with StoredFlag {
  @override
  String get key => PreferenceKeys.sidebarCollapsed;

  @override
  bool get fallback => false;

  @override
  bool build() => load();
}
