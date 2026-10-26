import 'dart:io';

/// Where a gateway host sits, for the cleartext rule: plain `http://` to a
/// [loopback] or [private] host stays on the phone, the home network or the
/// tailnet; to a [public] host it crosses the internet unencrypted.
enum HostReach { loopback, private, public }

/// Names of hosts on a local network or a tailnet.
const List<String> _privateSuffixes = [
  '.local',
  '.ts.net',
  '.home.arpa',
  '.internal',
  '.lan',
];

/// Where [host] sits: an IP by its range (RFC 1918, link-local, CGNAT /
/// Tailscale, IPv6 ULA), a name by its suffix only (no lookup); a name
/// without a dot is local.
HostReach classifyHost(String host) {
  var h = host.trim().toLowerCase();
  if (h.startsWith('[') && h.endsWith(']')) h = h.substring(1, h.length - 1);
  if (h.endsWith('.')) h = h.substring(0, h.length - 1);
  if (h.isEmpty) return HostReach.public;
  final zone = h.indexOf('%');
  final ip = InternetAddress.tryParse(zone < 0 ? h : h.substring(0, zone));
  if (ip != null) {
    if (ip.isLoopback) return HostReach.loopback;
    var b = ip.rawAddress;
    final mapped =
        b.length == 16 &&
        b.take(10).every((x) => x == 0) &&
        b[10] == 0xff &&
        b[11] == 0xff;
    if (mapped) b = b.sublist(12);
    final private = b.length == 4
        ? b[0] == 10 ||
              (b[0] == 172 && b[1] >= 16 && b[1] <= 31) ||
              (b[0] == 192 && b[1] == 168) ||
              (b[0] == 169 && b[1] == 254) ||
              (b[0] == 100 && b[1] >= 64 && b[1] <= 127)
        : (b[0] & 0xfe) == 0xfc || (b[0] == 0xfe && (b[1] & 0xc0) == 0x80);
    if (b.length == 4 && b[0] == 127) return HostReach.loopback;
    return private ? HostReach.private : HostReach.public;
  }
  if (h.contains(':')) return HostReach.public;
  if (h == 'localhost' || h.endsWith('.localhost')) return HostReach.loopback;
  if (!h.contains('.') || _privateSuffixes.any(h.endsWith)) {
    return HostReach.private;
  }
  return HostReach.public;
}

/// Plain `http://` to a [HostReach.public] host: the page warns and asks
/// before a password goes out.
bool sendsInClearOverInternet(Uri uri) =>
    uri.scheme == 'http' && classifyHost(uri.host) == HostReach.public;

/// [input] with `http://` for a loopback or private host, `https://` for
/// any other, when it names no scheme.
String withDefaultScheme(String input) {
  final text = input.trim();
  if (text.isEmpty || text.contains('://')) return text;
  final host = Uri.tryParse('http://$text')?.host ?? '';
  final scheme = classifyHost(host) == HostReach.public ? 'https' : 'http';
  return '$scheme://$text';
}
