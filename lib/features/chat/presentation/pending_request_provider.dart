import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../hermes/requests/server_request.dart';
import '../../connection/presentation/connection_providers.dart';

part 'pending_request_provider.g.dart';

/// The question the agent is waiting on in the session [runtimeId], or null.
///
/// The router is the source of truth, not the chat state: it parks a question
/// while no chat is open and drops it when it is answered, withdrawn, or no
/// longer listed after a reconnect. Watching this rebuilds only the card.
@riverpod
Stream<ServerRequest?> pendingRequest(Ref ref, String runtimeId) {
  final router = ref.watch(serverRequestRouterProvider);
  if (router == null || runtimeId.isEmpty) return Stream.value(null);
  return router.watch(runtimeId);
}
