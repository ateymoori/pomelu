import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/config/app_config.dart';
import '../../../core/utils/app_logger.dart';

part 'link_metadata.g.dart';

/// The HTTP client of the link titles. Tests put a stub.
@Riverpod(keepAlive: true)
Dio linkMetadataClient(Ref ref) => Dio(
  BaseOptions(
    connectTimeout: AppConfig.linkTitleTimeout,
    receiveTimeout: AppConfig.linkTitleTimeout,
    responseType: ResponseType.plain,
  ),
);

/// The title of a YouTube video, from its public oEmbed document [oEmbed]:
/// one small GET, no key, nothing else fetched. Null when it has none.
///
/// Kept for the life of the process; a failed one is kept for
/// [AppConfig.linkTitleRetryAfter], so a streaming reply that rebuilds its
/// card does not ask again on every token.
@riverpod
Future<String?> linkTitle(Ref ref, Uri oEmbed) async {
  final keep = ref.keepAlive();
  try {
    final body =
        (await ref.watch(linkMetadataClientProvider).getUri<String>(oEmbed))
            .data ??
        '';
    final json = body.isEmpty ? null : jsonDecode(body);
    final title = json is Map<String, dynamic> ? json['title'] : null;
    return title is String && title.trim().isNotEmpty ? title.trim() : null;
  } on Object catch (e) {
    log.d('link title lookup failed: $oEmbed', error: e);
    final retry = Timer(AppConfig.linkTitleRetryAfter, keep.close);
    ref.onDispose(retry.cancel);
    return null;
  }
}
