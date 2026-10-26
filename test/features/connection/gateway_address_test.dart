import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/features/connection/domain/gateway_address.dart';
import 'package:hermes/features/connection/domain/gateway_config.dart';

void main() {
  test('classifyHost: this phone, local networks and tailnets, the rest', () {
    // dart format off
    const table = {
      HostReach.loopback: [
        'localhost', 'app.localhost', '127.9.9.9', '::1', '[::1]',
        '::ffff:127.0.0.1',
      ],
      HostReach.private: [
        '10.0.0.1', '172.16.0.1', '172.31.255.255', '192.168.1.10',
        '169.254.10.20', '100.64.0.1', '100.127.255.254', 'nas', 'nas.local',
        'NAS.Local.', 'box.tail1234.ts.net', 'router.home.arpa', 'gw.internal',
        'gw.lan', 'fd12:3456::1', 'fe80::1%wlan0', '[fd00::2]',
        '::ffff:192.168.0.5',
      ],
      HostReach.public: [
        'hermes.example.com', '8.8.8.8', '172.32.0.1', '100.128.0.1',
        '192.169.0.1', '2001:db8::1', 'ts.net.example.com', '', '::not-ip',
      ],
    };
    // dart format on
    for (final MapEntry(key: reach, value: hosts) in table.entries) {
      for (final h in hosts) {
        expect(classifyHost(h), reach, reason: h);
      }
    }
  });

  test('only plain http to the internet is sent in clear', () {
    bool clear(String u) => sendsInClearOverInternet(Uri.parse(u));
    expect(clear('http://a.example.com'), isTrue);
    expect(clear('https://a.example.com'), isFalse);
    expect(clear('http://10.1.2.3'), isFalse);
    expect(clear('http://[::1]:9119'), isFalse);
  });

  test('a missing scheme is http for a local host, https otherwise', () {
    expect(withDefaultScheme(' http://a.example.com '), 'http://a.example.com');
    expect(withDefaultScheme(''), '');
    expect(withDefaultScheme('nas.local:9119'), 'http://nas.local:9119');
    expect(withDefaultScheme('[fd00::1]:9119'), 'http://[fd00::1]:9119');
    expect(
      withDefaultScheme('hermes.example.com/x'),
      'https://hermes.example.com/x',
    );
  });

  test('GatewayConfig.uri takes http(s) with a host and nothing else', () {
    GatewayConfig c(String url) => GatewayConfig(url: url);
    expect(c(' https://gw.example.com/hermes ').uri, isNotNull);
    expect(
      c('100.101.102.103:9119').uri.toString(),
      'http://100.101.102.103:9119',
    );
    for (final bad in [
      'ftp://gw.lan',
      'http://',
      'http://:9119',
      'not a url',
    ]) {
      expect(c(bad).uri, isNull, reason: bad);
    }
    // Credentials in the address would be stored and logged in clear.
    expect(c('http://ada:lovelace@gw.lan:9119').uri, isNull);
    expect(c('https://ada@gw.lan').hasUserInfo, isTrue);
    expect(c('not a url').hasUserInfo, isFalse);
    expect(c(' http://GW.Lan:9119/ ').normalizedUrl, 'http://gw.lan:9119');
    expect(c('http://8.8.8.8:9119').insecure, isTrue);
    expect(c('http://box.tail1234.ts.net').insecure, isFalse);
  });
}
