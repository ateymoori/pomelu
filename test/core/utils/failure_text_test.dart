import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/core/utils/failure_text.dart';
import 'package:hermes/hermes/hermes_failure.dart';
import 'package:hermes/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('typed failures map to their sentence, a bare one to unknown', (
    tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (c) {
            context = c;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    final l10n = AppLocalizations.of(context);

    expect(
      failureText(context, NetworkFailure.notConnected),
      l10n.errorNetwork,
    );
    expect(
      failureText(context, const ServerFailure('Title already in use')),
      l10n.errorServer('Title already in use'),
    );
    expect(failureText(context, const ServerFailure('')), l10n.errorUnknown);
    expect(failureText(context, StateError('raw')), l10n.errorUnknown);
  });

  test('refusals no retry can cure say so, and offer no retry', () {
    final l10n = lookupAppLocalizations(const Locale('en'));

    expect(
      failureTextFor(l10n, const NotSupportedFailure('skills')),
      'Not supported by this gateway version',
    );
    expect(
      failureTextFor(l10n, const GatewayTooOldFailure('0.20.1', '0.21.5')),
      l10n.errorGatewayTooOld('0.20.1', '0.21.5'),
    );
    expect(
      failureTextFor(l10n, const HostRefusedFailure('guard')),
      l10n.errorHostRefused,
      reason: 'a Host guard refusal is not "this account is not allowed"',
    );
    expect(failureIsRetryable(const NotSupportedFailure('x')), isFalse);
    expect(
      failureIsRetryable(const GatewayTooOldFailure('0.1', '0.2')),
      isFalse,
    );
    expect(failureIsRetryable(const NetworkFailure('x')), isTrue);
    expect(failureIsRetryable(const HostRefusedFailure('x')), isTrue);
  });
}
