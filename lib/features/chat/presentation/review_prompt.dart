import 'dart:async';

import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/config/app_config.dart';
import '../../../core/platform/app_visibility.dart';
import '../../../core/platform/store_review.dart';
import '../../../core/storage/key_value_store.dart';
import '../../../core/utils/app_logger.dart';
import '../../../hermes/client/connection_state.dart';
import '../../connection/presentation/connection_providers.dart';
import '../../settings/domain/preference_keys.dart';

part 'review_prompt.g.dart';

/// Asks the store for its review prompt once, after real use: enough finished
/// replies on enough different days. The app adds no question of its own and
/// no reward, so every user can get the store's prompt, whatever they think
/// of the app. A failed or stopped turn does not count and never asks.
class ReviewPrompt {
  ReviewPrompt(this._kv, this._store, this._online);

  final KeyValueStore _kv;
  final StoreReview _store;
  final bool Function() _online;
  Timer? _pending;

  /// A turn ended well. Asks after a pause, when nothing else has started.
  Future<void> replyFinished() async {
    if (_kv.getBool(PreferenceKeys.reviewAsked) ?? false) return;
    final replies = _replies + 1;
    final days = {..._days, _today()};
    await _kv.setString(PreferenceKeys.reviewReplies, '$replies');
    await _kv.setString(PreferenceKeys.reviewDays, days.join(','));
    if (replies < AppConfig.reviewMinReplies ||
        days.length < AppConfig.reviewMinDays) {
      return;
    }
    _pending?.cancel();
    _pending = Timer(AppConfig.reviewAskDelay, () => unawaited(_ask()));
  }

  /// A turn runs, or the turn ended badly: this is no moment to ask.
  void notNow() {
    _pending?.cancel();
    _pending = null;
  }

  void dispose() => notNow();

  Future<void> _ask() async {
    // Away, offline or typing the next message: the next finished reply asks.
    if (!appIsVisible || !_online() || _typing) return;
    await _kv.setBool(PreferenceKeys.reviewAsked, true);
    try {
      await _store.request();
    } on PlatformException catch (e) {
      log.w('store review failed', error: e);
    }
  }

  bool get _typing =>
      FocusManager.instance.primaryFocus?.context
          ?.findAncestorWidgetOfExactType<EditableText>() !=
      null;

  int get _replies =>
      int.tryParse(_kv.getString(PreferenceKeys.reviewReplies) ?? '') ?? 0;

  Set<String> get _days => {
    ...?_kv.getString(PreferenceKeys.reviewDays)?.split(','),
  };

  static String _today() => DateTime.now().toIso8601String().substring(0, 10);
}

@Riverpod(keepAlive: true)
ReviewPrompt reviewPrompt(Ref ref) {
  final prompt = ReviewPrompt(
    ref.watch(keyValueStoreProvider),
    ref.watch(storeReviewProvider),
    () => ref.read(hermesClientProvider)?.state is Connected,
  );
  ref.onDispose(prompt.dispose);
  return prompt;
}
