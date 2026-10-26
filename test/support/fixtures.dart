import 'dart:convert';
import 'dart:io';

/// Raw text of `test/fixtures/<name>`.
String fixture(String name) => File('test/fixtures/$name').readAsStringSync();

/// `test/fixtures/<name>` decoded as JSON.
Object? fixtureJson(String name) => jsonDecode(fixture(name));

/// `test/fixtures/<name>` decoded as a JSON object.
Map<String, dynamic> fixtureMap(String name) =>
    fixtureJson(name)! as Map<String, dynamic>;

/// `test/fixtures/<name>`, a JSON array of objects, each built by [from].
List<T> fixtureList<T>(String name, T Function(Map<String, dynamic>) from) => [
  for (final item in fixtureJson(name)! as List)
    from(item as Map<String, dynamic>),
];
