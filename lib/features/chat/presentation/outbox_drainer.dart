import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../hermes/client/connection_state.dart';
import '../../connection/presentation/connection_providers.dart';
import '../data/chat_store.dart';
import '../domain/chat_target.dart';
import '../domain/outbox.dart';
import 'chat_controller.dart';

part 'outbox_drainer.g.dart';

/// Delivers the turns of chats that are not open. After a cold start nothing
/// is open: when the app starts and each time the gateway comes back, this
/// builds the chat of every target with work; the chat holds itself while it
/// delivers and lets go once done. Watched by the chat shell.
@riverpod
class OutboxDrainer extends _$OutboxDrainer {
  @override
  void build() {
    final client = ref.watch(hermesClientProvider);
    final store = ref.watch(chatStoreProvider);
    if (client == null) return;
    final up = client.states
        .where((s) => s is Connected)
        .listen((_) => _wake(store));
    ref.onDispose(() => unawaited(up.cancel()));
    // Not inside the build: waking builds other providers.
    if (client.isConnected) scheduleMicrotask(() => _wake(store));
  }

  void _wake(ChatStore store) {
    if (!ref.mounted) return;
    for (final key in store.pendingTargets()) {
      final target = ChatTarget.fromKey(key);
      if (target == null || !Outbox.hasWork(store.outbox(key))) continue;
      ref.listen(chatControllerProvider(target), (_, _) {}).close();
    }
  }
}
