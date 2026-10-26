import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show immutable, kIsWeb;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'platform_info.g.dart';

/// The operating systems the app tells apart.
enum AppPlatform { android, ios, other }

/// The platform the app runs on: the one place that asks. Providers pick a
/// platform part (share bridge, foreground service, notifications) from it;
/// any other platform gets a safe default. Tests run on the host
/// ([AppPlatform.other]) and override [platformInfoProvider] to act as one.
@immutable
class PlatformInfo {
  const PlatformInfo(this.platform);

  /// The host's platform, not Flutter's `defaultTargetPlatform` (which a
  /// widget test sets to Android).
  factory PlatformInfo.host() => PlatformInfo(
    kIsWeb
        ? AppPlatform.other
        : Platform.isAndroid
        ? AppPlatform.android
        : Platform.isIOS
        ? AppPlatform.ios
        : AppPlatform.other,
  );

  final AppPlatform platform;

  bool get isAndroid => platform == AppPlatform.android;
  bool get isIOS => platform == AppPlatform.ios;

  /// A phone OS: local notifications and the system share sheet.
  bool get isMobile => isAndroid || isIOS;

  /// The socket can stay open in the background (Android's foreground
  /// service). iOS suspends the app, so "Stay connected" is not offered.
  bool get canStayConnected => isAndroid;

  @override
  bool operator ==(Object other) =>
      other is PlatformInfo && other.platform == platform;

  @override
  int get hashCode => platform.hashCode;
}

@Riverpod(keepAlive: true)
PlatformInfo platformInfo(Ref ref) => PlatformInfo.host();
