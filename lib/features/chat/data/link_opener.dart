import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_config.dart';

part 'link_opener.g.dart';

/// Hands a link to the system; true when something took it.
typedef LinkLauncher = Future<bool> Function(Uri uri);

/// The system's link handler, out of the app. Tests put their own.
@Riverpod(keepAlive: true)
LinkLauncher linkLauncher(Ref ref) =>
    (uri) => launchUrl(uri, mode: LaunchMode.externalApplication);

/// Whether a link the agent wrote may open ([AppConfig.openableLinkSchemes]).
bool canOpenLink(Uri uri) =>
    AppConfig.openableLinkSchemes.contains(uri.scheme.toLowerCase());
