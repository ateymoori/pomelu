import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/features/notifications/domain/background_redial_budget.dart';

void main() {
  const budget = Duration(minutes: 10);
  late List<String> calls;
  late BackgroundRedialBudget subject;

  setUp(() {
    calls = [];
    subject = BackgroundRedialBudget(
      budget: budget,
      park: () async => calls.add('park'),
      wake: () async => calls.add('wake'),
    );
  });

  tearDown(() => subject.dispose());

  test('unreachable in the background for the budget: redialling stops', () {
    fakeAsync((async) {
      subject
        ..foreground(visible: false)
        ..connection(unreachable: true);

      async.elapse(budget - const Duration(seconds: 1));
      expect(calls, isEmpty);
      async.elapse(const Duration(seconds: 1));

      expect(calls, ['park']);
      expect(subject.parked, isTrue);
    });
  });

  test('a connection in between starts the clock over', () {
    fakeAsync((async) {
      subject
        ..foreground(visible: false)
        ..connection(unreachable: true);
      async.elapse(budget ~/ 2);
      subject.connection(unreachable: false);
      async.elapse(budget ~/ 2);
      subject.connection(unreachable: true);
      async.elapse(budget ~/ 2);

      expect(calls, isEmpty);
    });
  });

  test('coming to the front wakes a parked connection', () {
    fakeAsync((async) {
      subject
        ..foreground(visible: false)
        ..connection(unreachable: true);
      async.elapse(budget);

      subject.foreground(visible: true);
      async.flushMicrotasks();

      expect(calls, ['park', 'wake']);
      expect(subject.parked, isFalse);
    });
  });

  test('a network change wakes it in the background, and the clock runs '
      'again', () {
    fakeAsync((async) {
      subject
        ..foreground(visible: false)
        ..connection(unreachable: true);
      async.elapse(budget);

      subject
        ..networkChanged()
        ..connection(unreachable: true);
      async.elapse(budget);

      expect(calls, ['park', 'wake', 'park']);
    });
  });
}
