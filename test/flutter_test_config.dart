import 'dart:async';

import 'package:logger/logger.dart';

/// Runs before every test file. The app logger prints a warning with a stack
/// trace for each failure a test provokes on purpose (a refused sign-in, a
/// dead socket); with the level off a green run is quiet. A test that needs
/// the output builds its own `Logger`.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  Logger.level = Level.off;
  await testMain();
}
