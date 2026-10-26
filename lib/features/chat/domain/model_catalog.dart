import 'dart:math' as math;

/// Short display form of a model id: drop the vendor prefix.
String modelDisplayName(String id) {
  final slash = id.lastIndexOf('/');
  return slash < 0 ? id : id.substring(slash + 1);
}

/// Vendor prefix of an aggregator id (`anthropic/claude-x` → `anthropic`).
/// Empty for a bare id.
String modelVendor(String id) {
  final slash = id.lastIndexOf('/');
  return slash < 0 ? '' : id.substring(0, slash);
}

/// Models whose id contains [query], ignoring case. A blank query keeps all.
List<String> filterModels(List<String> ids, String query) {
  final needle = query.trim().toLowerCase();
  if (needle.isEmpty) return ids;
  return [
    for (final id in ids)
      if (id.toLowerCase().contains(needle)) id,
  ];
}

/// [ids] newest first.
///
/// The gateway sends no release date per model, so recency is read from the
/// id: the first version number (`5.1` in `claude-fable-5.1`), then a date
/// stamp (`20241022`, `2024-10-22`). Ids that tie, or carry neither, keep the
/// gateway's own order.
List<String> sortNewestFirst(List<String> ids) {
  final ranked = [
    for (final (index, id) in ids.indexed)
      (id: id, at: index, age: _recency(id)),
  ];
  ranked.sort((a, b) {
    final newer = _compare(b.age, a.age);
    return newer != 0 ? newer : a.at.compareTo(b.at);
  });
  return [for (final r in ranked) r.id];
}

typedef _Recency = ({List<int> version, int stamp});

final RegExp _dateStamp = RegExp(r'(\d{4})-(\d{2})-(\d{2})|\d{8}');
final RegExp _versionNumber = RegExp(r'\d+(?:\.\d+)*');

_Recency _recency(String id) {
  final name = modelDisplayName(id);
  final stamp = _dateStamp.firstMatch(name);
  // A date is not a version: cut it out before looking for one.
  final rest = stamp == null
      ? name
      : name.replaceRange(stamp.start, stamp.end, ' ');
  final version = _versionNumber.firstMatch(rest)?.group(0);
  return (
    version: [
      if (version != null)
        for (final part in version.split('.')) int.tryParse(part) ?? 0,
    ],
    stamp: stamp == null
        ? 0
        : int.tryParse(stamp.group(0)!.replaceAll('-', '')) ?? 0,
  );
}

int _compare(_Recency a, _Recency b) {
  final length = math.max(a.version.length, b.version.length);
  for (var i = 0; i < length; i++) {
    final x = i < a.version.length ? a.version[i] : 0;
    final y = i < b.version.length ? b.version[i] : 0;
    if (x != y) return x.compareTo(y);
  }
  return a.stamp.compareTo(b.stamp);
}
