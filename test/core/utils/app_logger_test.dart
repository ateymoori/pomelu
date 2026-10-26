import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/core/utils/app_logger.dart';
import 'package:logger/logger.dart';

void main() {
  test('the printer masks the error lines of an event', () {
    final printer = RedactingPrinter(SimplePrinter(colors: false));
    final lines = printer.log(
      LogEvent(
        Level.error,
        'boom',
        error: Exception('failed ws://h/api/ws?token=abc'),
      ),
    );
    expect(lines.join('\n'), isNot(contains('abc')));
    expect(lines.join('\n'), contains('token=***'));
  });

  test(
    'the app logger follows the global level, which a test can turn off',
    () {
      addTearDown(() => Logger.level = Level.off);

      initLogging();
      expect(Logger.level, appLogLevel);
      expect(log.isClosed(), isFalse);

      Logger.level = Level.off;
      expect(Logger.level, Level.off);
    },
  );
}
