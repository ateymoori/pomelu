import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/app/router.dart';
import 'package:hermes/core/platform/platform_channels.dart';
import 'package:hermes/features/share/data/share_channel.dart';
import 'package:hermes/features/share/data/share_intake_service.dart';
import 'package:hermes/features/share/domain/incoming_share.dart';
import 'package:hermes/hermes/models/local_attachment.dart';

/// The Android bridge, driven by the test.
class _Bridge implements ShareBridge {
  List<SharedItem> launch = const [];
  // ignore: close_sinks, closed by the test's tear-down.
  final controller = StreamController<List<SharedItem>>.broadcast();

  @override
  Future<List<SharedItem>> initial() async => launch;

  @override
  Stream<List<SharedItem>> stream() => controller.stream;
}

SharedItem _text(String text) => SharedItem(type: 'text', text: text);
SharedItem _skipped(int count) => SharedItem(type: 'skipped', count: count);
SharedItem _file(File file, {String? mime}) => SharedItem(
  type: 'file',
  path: file.path,
  mime: mime,
  name: file.uri.pathSegments.last,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory dir;
  late _Bridge bridge;
  late StreamController<Uri> links;
  late ShareIntakeService service;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('share_intake_test');
    addTearDown(() => dir.delete(recursive: true));
    bridge = _Bridge();
    links = StreamController<Uri>.broadcast();
    addTearDown(links.close);
    addTearDown(bridge.controller.close);
    service = ShareIntakeService(bridge: bridge, links: links.stream);
    addTearDown(service.dispose);
  });

  File write(String name, List<int> bytes) =>
      File('${dir.path}/$name')..writeAsBytesSync(bytes);

  test('a launch share is its text and the files still on disk', () async {
    final photo = write('photo.png', List<int>.filled(12, 1));
    bridge.launch = [
      _text('look at this'),
      _file(photo, mime: 'image/png'),
      _file(File('${dir.path}/gone.txt')),
      const SharedItem(type: 'hologram'),
      _text('and this'),
    ];

    final share = (await service.initial())!;

    expect(share.text, 'look at this\nand this');
    expect(share.files.single.name, 'photo.png');
    expect(share.files.single.kind, AttachmentKind.image);
    expect(share.files.single.sizeBytes, 12);
  });

  test('a share sent to a bot of the share sheet names that bot', () async {
    final photo = write('photo.png', List<int>.filled(4, 1));
    bridge.launch = [
      const SharedItem(type: 'target', profile: 'media'),
      _file(photo, mime: 'image/png'),
    ];

    final share = (await service.initial())!;

    expect(share.profile, 'media');
    expect(share.files.single.name, 'photo.png');
  });

  test(
    'files the phone left out are counted, even with nothing to send',
    () async {
      final shares = <IncomingShare>[];
      service.shares.listen(shares.add);

      bridge.controller
        ..add(const [])
        ..add([_skipped(2), _skipped(1)]);
      await pumpEventQueue();

      expect(shares.single.skipped, 3);
      expect(shares.single.isEmpty, isTrue);
      expect(shares.single.hasNotice, isTrue);
    },
  );

  test(
    'a chat link names the bot and the text; other links are none',
    () async {
      final shares = <IncomingShare>[];
      service.shares.listen(shares.add);

      links
        ..add(Uri.parse('pomelu://chat?profile=my%20bot&text=hi%20there'))
        ..add(Uri.parse('pomelu://settings'))
        ..add(Uri.parse('https://chat?profile=a'))
        ..addError(StateError('plugin'))
        ..add(Uri.parse('pomelu://chat?profile=atlas'));
      await pumpEventQueue();

      expect(shares.map((s) => (s.profile, s.text)), [
        ('my bot', 'hi there'),
        ('atlas', ''),
      ]);
    },
  );

  test('the router never navigates for a link or a shared URI', () {
    for (final link in [
      'pomelu://chat?profile=ghost',
      'content://media/external/images/1',
      '/?profile=atlas',
    ]) {
      expect(isExternalLocation(Uri.parse(link)), isTrue, reason: link);
    }
    expect(isExternalLocation(Uri.parse('/chat/atlas')), isFalse);
  });

  test(
    'the bridge parses what the platform sends, and is empty without it',
    () async {
      const methods = MethodChannel(PlatformChannels.share);
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(
        methods,
        (_) async => [
          {'type': 'text', 'text': 'hi'},
          {'type': 'skipped', 'count': 2.0},
          {'no': 'type'},
          'junk',
        ],
      );
      final items = await const ShareChannel().initial();
      expect(items.map((i) => (i.type, i.count)), [
        ('text', 0),
        ('skipped', 2),
      ]);

      messenger.setMockMethodCallHandler(methods, null);
      expect(await const ShareChannel().initial(), isEmpty);
    },
  );
}
