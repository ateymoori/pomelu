import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/features/bot_details/presentation/widgets/capability_async.dart';
import 'package:hermes/hermes/hermes_failure.dart';

import '../../support/app_host.dart';

void main() {
  testWidgets('a gateway without the route says so, with no retry', (
    tester,
  ) async {
    await pumpApp(
      tester,
      CapabilityAsync<void>(
        value: const AsyncError(
          NotSupportedFailure('skills'),
          StackTrace.empty,
        ),
        onRetry: () {},
        data: (_) => const SizedBox(),
      ),
    );

    expect(find.text('Not supported by this gateway version'), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
  });
}
