import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/features/bot_details/domain/profile_id.dart';

void main() {
  test('a new bot gets a free profile id Hermes accepts', () {
    expect(profileIdFor('  My Work! ', {}), 'my-work');
    expect(profileIdFor('My Work', {'my-work', 'my-work-2'}), 'my-work-3');
    // Another script keeps its title as the name; the id is plain.
    expect(profileIdFor('دستیار', {}), 'bot');
    expect(profileIdFor('Default', {}), 'default-2', reason: 'reserved');
  });
}
