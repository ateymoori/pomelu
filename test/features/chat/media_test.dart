import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:hermes/core/config/app_config.dart';
import 'package:hermes/features/chat/data/attachments.dart';
import 'package:hermes/features/chat/data/location.dart';
import 'package:hermes/features/chat/data/media_cache.dart';
import 'package:hermes/features/chat/domain/chat_message.dart';
import 'package:hermes/features/chat/presentation/widgets/location_picker.dart';
import 'package:hermes/features/chat/presentation/widgets/media_attachment.dart';
import 'package:hermes/features/chat/presentation/widgets/media_strip.dart';
import 'package:hermes/features/chat/presentation/widgets/mic_button.dart';
import 'package:hermes/features/chat/presentation/widgets/picture_actions.dart';
import 'package:hermes/features/connection/presentation/connection_providers.dart';
import 'package:hermes/hermes/api/hermes_api.dart';
import 'package:hermes/hermes/client/hermes_client.dart';
import 'package:hermes/hermes/hermes_constants.dart';
import 'package:hermes/hermes/hermes_failure.dart';
import 'package:hermes/hermes/models/local_attachment.dart';
import 'package:hermes/hermes/transport/hermes_http.dart';
import 'package:record/record.dart';

import '../../support/app_host.dart';

LocalAttachment file(String name, int bytes, AttachmentKind kind) =>
    LocalAttachment(
      id: name,
      path: '/tmp/$name',
      name: name,
      mimeType: 'application/octet-stream',
      sizeBytes: bytes,
      kind: kind,
    );

/// Writes a small file on stop, as the platform recorder does.
class _FakeRecorder implements AudioRecorder {
  String? _path;
  bool cancelled = false;

  /// The microphone is taken: a start throws.
  bool busy = false;

  @override
  Future<bool> hasPermission({bool request = true}) async => true;

  @override
  Future<void> start(RecordConfig config, {required String path}) async {
    if (busy) throw StateError('the microphone is in use');
    _path = path;
  }

  @override
  Future<String?> stop() async {
    await File(_path!).writeAsBytes([1, 2, 3]);
    return _path;
  }

  @override
  Future<void> cancel() async => cancelled = true;

  @override
  Future<void> dispose() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A gateway whose files are all 26 KB.
class _SizedFiles extends Fake implements HermesApi {
  @override
  Future<int?> mediaSize(String path) async => 26 * 1024;
}

/// A gateway with one file, whose bytes the test changes.
class _OneFile extends Fake implements HermesApi, HermesClient, HermesHttp {
  String content = 'first';
  bool reachable = true;
  int downloads = 0;

  @override
  HermesHttp get http => this;

  @override
  Uri mediaDownloadUrl(String path) => Uri.parse('http://gw/files?path=$path');

  @override
  Future<int?> mediaSize(String path) async {
    if (!reachable) throw const NetworkFailure('out of reach');
    return content.length;
  }

  @override
  Future<void> download(
    Uri uri,
    String savePath, {
    void Function(int received, int total)? onProgress,
    Object? cancelToken,
  }) async {
    downloads++;
    await File(savePath).writeAsString(content);
  }
}

class _Geo extends GeolocatorPlatform {
  Position? last;
  int streams = 0;
  int currentAsks = 0;
  // ignore: close_sinks, the test drops it with the fake.
  final StreamController<Position> fixes = StreamController.broadcast();

  @override
  Future<bool> isLocationServiceEnabled() async => true;

  @override
  Future<LocationPermission> checkPermission() async =>
      LocationPermission.whileInUse;

  @override
  Future<Position?> getLastKnownPosition({
    bool forceLocationManager = false,
  }) async => last;

  @override
  Future<Position> getCurrentPosition({LocationSettings? locationSettings}) {
    currentAsks++;
    throw UnimplementedError();
  }

  @override
  Stream<Position> getPositionStream({LocationSettings? locationSettings}) {
    streams++;
    return fixes.stream;
  }
}

class _NoTiles extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      MemoryImage(
        Uint8List.fromList(const [
          0x47, 0x49, 0x46, 0x38, 0x39, 0x61, 0x01, 0x00, 0x01, 0x00, 0x80, //
          0x00, 0x00, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x21, 0xF9, 0x04,
          0x01, 0x00, 0x00, 0x00, 0x00, 0x2C, 0x00, 0x00, 0x00, 0x00, 0x01,
          0x00, 0x01, 0x00, 0x00, 0x02, 0x02, 0x44, 0x01, 0x00, 0x3B,
        ]),
      );
}

void main() {
  test('a turn takes files while they fit, and says why one was left out', () {
    final big = file(
      'big.png',
      HermesLimits.maxImageBytes + 1,
      AttachmentKind.image,
    );
    final ok = file('ok.png', 10, AttachmentKind.image);
    final (:accepted, :refused) = Attachments.admit(const [], [big, ok]);
    expect(accepted, [ok]);
    expect(refused.single.reason, AttachRefusal.tooLarge);
    final full = Attachments.admit(
      [for (var i = 0; i < HermesLimits.maxAttachmentsPerMessage; i++) ok],
      [ok],
    );
    expect(full.refused.single.reason, AttachRefusal.tooMany);
  });

  group('a picture saved to the gallery', () {
    Future<List<Object?>> save(MediaItem item) async {
      final sunk = <Object?>[];
      await saveToGallery(
        item,
        sink: ({path, bytes, name}) async => sunk.add(path ?? bytes),
      );
      return sunk;
    }

    test('from the phone by its path, inline by its bytes', () async {
      expect(
        await save(
          const MediaItem(
            provider: AssetImage('x'),
            fileName: 'a.png',
            localPath: '/p/a.png',
          ),
        ),
        ['/p/a.png'],
      );
      final bytes = Uint8List.fromList([1, 2]);
      expect(
        await save(MediaItem(provider: MemoryImage(bytes), fileName: 'b')),
        [bytes],
      );
    });

    test('with no source it fails out loud', () async {
      await expectLater(
        save(const MediaItem(provider: AssetImage('x'), fileName: 'c')),
        throwsStateError,
      );
    });
  });

  test('a file the bot wrote again downloads again; out of reach, the copy '
      'on the phone stands', () async {
    final dir = await Directory.systemTemp.createTemp('media_cache_test');
    final before = MediaCache.root;
    MediaCache.root = () async => dir;
    addTearDown(() {
      MediaCache.root = before;
      return dir.delete(recursive: true);
    });
    final gw = _OneFile();
    Future<String> read() async => (await MediaCache.fetch(
      gw,
      gw,
      '/out/report.md',
      'report.md',
    )).readAsString();

    expect(await read(), 'first');
    expect(await read(), 'first');
    expect(gw.downloads, 1);

    gw.content = 'second, longer';
    expect(await read(), 'second, longer');
    expect(gw.downloads, 2);

    gw
      ..content = 'third'
      ..reachable = false;
    expect(await read(), 'second, longer');
    expect(gw.downloads, 2);
  });

  test('a file opens as its own type, a text format falls back to plain '
      'text, and an Android package goes to save or share', () {
    expect(MediaCache.openTypes('report.pdf'), ['application/pdf', '*/*']);
    expect(MediaCache.openTypes('notes.md'), [
      'text/markdown',
      'text/plain',
      '*/*',
    ]);
    expect(MediaCache.openTypes('app.apk'), isEmpty);
  });

  test('two gateway files of one name never share a cache file', () {
    final a = MediaCache.cacheName(
      Uri.parse('https://g/a/report.pdf'),
      'report.pdf',
    );
    final b = MediaCache.cacheName(
      Uri.parse('https://g/b/report.pdf'),
      'report.pdf',
    );
    expect(a, isNot(b));
    expect(a, endsWith('.pdf'));
  });

  testWidgets('a file from the bot shows its type and its size', (
    tester,
  ) async {
    await pumpApp(
      tester,
      const MediaAttachment(
        media: MediaRef(
          path: '/home/a/handoff/HANDOFF.md',
          kind: AttachmentKind.file,
        ),
        profile: 'nova',
      ),
      overrides: [hermesApiProvider.overrideWithValue(_SizedFiles())],
    );
    await tester.pump();

    expect(find.text('HANDOFF.md'), findsOneWidget);
    expect(find.text('MD'), findsOneWidget);
    expect(find.text('26 KB'), findsOneWidget);
  });

  test('one location request: the last fix, then the stream', () async {
    final geo = _Geo()
      ..last = Position(
        latitude: 59,
        longitude: 18,
        timestamp: DateTime.utc(2026),
        accuracy: 5,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
    GeolocatorPlatform.instance = geo;
    final seen = <double>[];
    final sub = phonePositions().listen((p) => seen.add(p!.latitude));
    await pumpEventQueue();
    expect(seen, [59]);
    expect((geo.streams, geo.currentAsks), (1, 0));
    await sub.cancel();
    expect(geo.fixes.hasListener, isFalse, reason: 'the GPS goes off');
  });

  testWidgets('the map shares the place under the pin as text', (tester) async {
    final fixes = StreamController<LocationMarkerPosition?>();
    String? shared;
    await pumpApp(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () async => shared = await Navigator.of(context).push(
            MaterialPageRoute<String>(
              builder: (_) => LocationPicker(
                lookup: (_) async => 'Main St 1, Stockholm',
                positions: fixes.stream,
                tileProvider: _NoTiles(),
              ),
            ),
          ),
          child: const Text('open'),
        ),
      ),
      scaffold: false,
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    fixes.add(
      LocationMarkerPosition(latitude: 59.5, longitude: 18.25, accuracy: 5),
    );
    await tester.pump();
    await tester.pump(AppConfig.addressLookupDebounce);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('location-share')));
    await tester.pumpAndSettle();
    expect(
      shared,
      'Location: Main St 1, Stockholm\nLatitude: 59.500000\nLongitude: 18.250000',
    );
    unawaited(fixes.close());
  });

  group('hold to talk', () {
    late _FakeRecorder recorder;
    late List<LocalAttachment> takes;
    late int tooShort;
    late int failed;

    Future<void> pumpMic(
      WidgetTester tester, {
      TextDirection? direction,
    }) async {
      recorder = _FakeRecorder();
      takes = [];
      tooShort = 0;
      failed = 0;
      await pumpApp(
        tester,
        MicButton(
          recorder: recorder,
          tempDirectory: () async => Directory.systemTemp,
          onChanged: (_) {},
          onRecorded: takes.add,
          onDenied: () {},
          onTooShort: () => tooShort++,
          onFailed: () => failed++,
        ),
        alignment: Alignment.center,
        direction: direction,
      );
    }

    /// Real file work, a step at a time.
    Future<void> settle(WidgetTester tester, bool Function() until) async {
      for (var i = 0; i < 100 && !until(); i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pump();
      }
    }

    /// Holds the mic, slides by [dx] and lets go.
    Future<void> holdAndSlide(WidgetTester tester, double dx) async {
      final finger = await tester.startGesture(
        tester.getCenter(find.byType(MicButton)),
      );
      await settle(
        tester,
        () => find.byIcon(CupertinoIcons.mic_fill).evaluate().isNotEmpty,
      );
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(seconds: 1)),
      );
      await finger.moveBy(Offset(dx, 0));
      await finger.up();
    }

    testWidgets('hold and release delivers the take', (tester) async {
      await pumpMic(tester);
      final finger = await tester.startGesture(
        tester.getCenter(find.byType(MicButton)),
      );
      await settle(
        tester,
        () => find.byIcon(CupertinoIcons.mic_fill).evaluate().isNotEmpty,
      );
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(seconds: 1)),
      );
      await finger.up();
      await settle(tester, () => takes.isNotEmpty);
      expect(takes.single.kind, AttachmentKind.audio);
      await tester.runAsync(() => File(takes.single.path).delete());
    });

    testWidgets('a tap is not a take; a slide left cancels', (tester) async {
      await pumpMic(tester);
      await tester.tap(find.byType(MicButton));
      await settle(tester, () => tooShort > 0);
      expect(takes, isEmpty);
      expect(tooShort, 1);
      await holdAndSlide(tester, -300);
      await settle(tester, () => recorder.cancelled);
      expect(takes, isEmpty);
      expect(recorder.cancelled, isTrue);
    });

    testWidgets('a recorder that does not start says so, not how to hold', (
      tester,
    ) async {
      await pumpMic(tester);
      recorder.busy = true;
      final finger = await tester.startGesture(
        tester.getCenter(find.byType(MicButton)),
      );
      await settle(tester, () => failed > 0);
      await finger.up();
      await tester.pump();
      expect(failed, 1);
      expect(tooShort, 0);
      expect(takes, isEmpty);
    });

    testWidgets('right to left, the slide that cancels goes right', (
      tester,
    ) async {
      await pumpMic(tester, direction: TextDirection.rtl);
      await holdAndSlide(tester, 300);
      await settle(tester, () => recorder.cancelled);
      expect(takes, isEmpty);
      expect(recorder.cancelled, isTrue);
    });
  });
}
