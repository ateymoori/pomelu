import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/config/app_config.dart';
import '../../../core/config/legal_config.dart';
import '../../../core/platform/platform_info.dart';
import '../../../core/utils/app_logger.dart';
import 'link_opener.dart';

part 'reply_report.g.dart';

/// Why a reply is reported; [name] goes in the mail.
enum ReportReason { harmful, hateful, sexual, misleading, other }

@Riverpod(keepAlive: true)
ReplyReporter replyReporter(Ref ref) => ReplyReporter(
  ref.watch(linkLauncherProvider),
  platform: ref.watch(platformInfoProvider).platform,
  version: () async => (await PackageInfo.fromPlatform()).version,
);

/// Reports an agent's reply to Royan AB by email: the user's mail app opens
/// with the reason, the reply's text, the app version and the platform.
/// Nothing about the gateway goes with it, and nothing leaves the phone
/// unless the user sends the mail.
class ReplyReporter {
  ReplyReporter(
    this._launch, {
    required this._platform,
    required this._version,
  });

  final LinkLauncher _launch;
  final AppPlatform _platform;
  final Future<String> Function() _version;

  /// False when no mail app took the report.
  Future<bool> send(ReportReason reason, String reply) async {
    String version;
    try {
      version = await _version();
    } on Object catch (e) {
      log.w('app version unknown for a report', error: e);
      version = '';
    }
    final excerpt = reply.length > AppConfig.reportExcerptChars
        ? reply.substring(0, AppConfig.reportExcerptChars)
        : reply;
    // Encoded by hand: a query map would turn spaces into "+", which mail
    // apps show as is.
    final fields = {
      'subject': 'Pomelu report: ${reason.name}',
      'body':
          'Reason: ${reason.name}\n'
          'App: Pomelu $version, ${_platform.name}\n\n'
          'Reported reply:\n$excerpt',
    };
    try {
      return await _launch(
        Uri(
          scheme: 'mailto',
          path: LegalConfig.reportEmail,
          query: [
            for (final MapEntry(:key, :value) in fields.entries)
              '$key=${Uri.encodeComponent(value)}',
          ].join('&'),
        ),
      );
    } on Object catch (e) {
      log.w('no mail app took a report', error: e);
      return false;
    }
  }
}
