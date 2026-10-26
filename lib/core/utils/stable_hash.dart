/// A 31-bit hash, the same on every run, unlike [String.hashCode]: an
/// avatar hue, a notification slot.
int stableHash(String text) {
  var hash = 0;
  for (final unit in text.codeUnits) {
    hash = (hash * 31 + unit) & 0x7fffffff;
  }
  return hash;
}
