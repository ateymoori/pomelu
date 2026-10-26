import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/utils/app_logger.dart';
import '../../../hermes/hermes_failure.dart';
import '../../connection/presentation/connection_providers.dart';

part 'media_size.g.dart';

/// Bytes in the gateway file [path]; null when the gateway does not say. A
/// size once known is kept: a file the bot sent does not change.
@riverpod
Future<int?> mediaSize(Ref ref, String path) async {
  final api = ref.watch(hermesApiProvider);
  if (api == null) return null;
  try {
    final size = await api.mediaSize(path);
    ref.keepAlive();
    return size;
  } on HermesFailure catch (e) {
    log.w('size of $path unknown', error: e);
    return null;
  }
}
