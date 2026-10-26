import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/ui.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../data/link_opener.dart';

/// Links in the agent's replies. The agent writes them, so only http, https
/// and mailto open: an `intent:`, `file:` or app scheme must not start
/// something on the phone. Any other link is copied, and the user is told.
abstract final class MarkdownLinks {
  /// Opens [url] when [canOpenLink] allows it, else copies it and says so. A
  /// link with no scheme does nothing.
  static void open(BuildContext context, String url) {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || !uri.hasScheme) return;
    if (canOpenLink(uri)) {
      final launch = ProviderScope.containerOf(
        context,
        listen: false,
      ).read(linkLauncherProvider);
      unawaited(_launchQuietly(launch, uri, url));
      return;
    }
    unawaited(AppSnacks.of(context).copy(url, context.l10n.chatLinkCopied));
  }

  static Future<void> _launchQuietly(
    LinkLauncher launch,
    Uri uri,
    String url,
  ) async {
    try {
      await launch(uri);
    } on Object catch (e) {
      log.w('link launch failed: $url', error: e);
    }
  }
}
