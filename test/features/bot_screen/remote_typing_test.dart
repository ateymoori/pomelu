import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/features/bot_screen/domain/remote_input.dart';

void main() {
  final f = RemoteTyping.filler;

  test('typing, a backspace and an autocorrected word become keys', () {
    expect(RemoteTyping.diff(f, '${f}h'), (backspaces: 0, text: 'h'));
    expect(RemoteTyping.diff('${f}hi', '${f}h'), (backspaces: 1, text: ''));
    // The keyboard swaps "teh" for "the ": back to the "t", then the rest.
    expect(RemoteTyping.diff('${f}teh', '${f}the '), (
      backspaces: 2,
      text: 'he ',
    ));
    expect(RemoteTyping.diff(f, '$f\n'), (backspaces: 0, text: '\n'));
  });

  test('an emoji is one character either way', () {
    expect(RemoteTyping.diff(f, '$f😀'), (backspaces: 0, text: '😀'));
    expect(RemoteTyping.diff('$f😀', f), (backspaces: 1, text: ''));
  });

  test('the field refills once emptied or long', () {
    expect(RemoteTyping.spent(''), isTrue);
    expect(RemoteTyping.spent(f), isFalse);
    expect(RemoteTyping.spent(f * 3), isTrue);
  });
}
