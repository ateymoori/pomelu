import 'package:uuid/uuid.dart';

/// A fresh random id: of a turn, a command row, a file.
String newId() => const Uuid().v4();
