import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'platform_channels.dart';
import 'platform_info.dart';

part 'reduce_transparency.g.dart';

/// iOS's Reduce Transparency setting, which Flutter does not expose; false
/// elsewhere. Liquid Glass turns solid while it is on.
@Riverpod(keepAlive: true)
Stream<bool> reduceTransparency(Ref ref) {
  if (!ref.watch(platformInfoProvider).isIOS) return Stream.value(false);
  return const EventChannel(PlatformChannels.reduceTransparency)
      .receiveBroadcastStream()
      .map((on) => on == true);
}
