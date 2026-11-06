import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/features/chat/presentation/widgets/media_video.dart';
import 'package:hermes/features/chat/presentation/widgets/video_page.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

import '../../support/app_host.dart';

/// A native player that loads at once: a 30 s 16:9 video.
class _FakeVideos extends VideoPlayerPlatform {
  final List<String> calls = [];
  final Map<int, StreamController<VideoEvent>> _events = {};
  int _next = 0;

  int get created => calls.where((c) => c == 'create').length;

  @override
  Future<void> init() async {}

  @override
  Future<int?> createWithOptions(VideoCreationOptions options) async {
    final id = _next++;
    calls.add('create');
    // Closed in dispose.
    // ignore: close_sinks
    final events = _events[id] = StreamController<VideoEvent>();
    scheduleMicrotask(
      () => events.add(
        VideoEvent(
          eventType: VideoEventType.initialized,
          duration: const Duration(seconds: 30),
          size: const Size(1920, 1080),
        ),
      ),
    );
    return id;
  }

  @override
  Stream<VideoEvent> videoEventsFor(int playerId) => _events[playerId]!.stream;

  @override
  Future<void> play(int playerId) async => calls.add('play $playerId');

  @override
  Future<void> pause(int playerId) async => calls.add('pause $playerId');

  @override
  Future<void> dispose(int playerId) async {
    calls.add('dispose $playerId');
    await _events.remove(playerId)?.close();
  }

  @override
  Future<void> setLooping(int playerId, bool looping) async {}

  @override
  Future<void> setVolume(int playerId, double volume) async {}

  @override
  Future<void> setPlaybackSpeed(int playerId, double speed) async {}

  @override
  Future<void> seekTo(int playerId, Duration position) async {}

  @override
  Future<Duration> getPosition(int playerId) async => Duration.zero;

  @override
  Future<void> setMixWithOthers(bool mixWithOthers) async {}

  @override
  Widget buildViewWithOptions(VideoViewOptions options) => const SizedBox();
}

MediaVideo _video(String name) => MediaVideo(
  key: ValueKey(name),
  url: Uri.parse('http://gw/api/files/stream?path=/v/$name'),
  headers: const {},
  path: '/v/$name',
  name: name,
);

void main() {
  late _FakeVideos videos;

  setUp(() => VideoPlayerPlatform.instance = videos = _FakeVideos());

  testWidgets('a video row opens its stream only once on screen a moment, '
      'then shows its length; a tap plays it with controls', (tester) async {
    await pumpApp(tester, _video('reel.mp4'));
    expect(videos.created, 0);

    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();
    expect(videos.created, 1);
    expect(find.text('0:30'), findsOneWidget);

    await tester.tap(find.byTooltip('Play'));
    await tester.pump();
    expect(videos.calls, contains('play 0'));
    expect(find.byTooltip('Pause'), findsOneWidget);
    expect(find.byTooltip('Full screen'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('full screen plays on in the same player and closes back to '
      'the row', (tester) async {
    await pumpApp(tester, _video('reel.mp4'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();
    await tester.tap(find.byTooltip('Play'));
    await tester.pump();

    await tester.tap(find.byTooltip('Full screen'));
    await tester.pumpAndSettle();
    expect(find.byType(VideoPage), findsOneWidget);
    expect(find.byTooltip('Back 10 seconds'), findsOneWidget);
    expect(find.bySemanticsLabel('Close'), findsOneWidget);
    expect(find.bySemanticsLabel('Seek'), findsWidgets);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(VideoPage), findsNothing);
    expect(videos.created, 1);
    expect(videos.calls.where((c) => c.startsWith('dispose')), isEmpty);
  });

  testWidgets('a second video that starts pauses the first', (tester) async {
    await pumpApp(
      tester,
      SingleChildScrollView(
        child: Column(children: [_video('a.mp4'), _video('b.mp4')]),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    await tester.tap(find.byTooltip('Play').first);
    await tester.pump();
    await tester.tap(find.byTooltip('Play').first);
    await tester.pump();
    await tester.pump();

    final first = videos.calls.firstWhere((c) => c.startsWith('play'));
    final second = videos.calls.lastWhere((c) => c.startsWith('play'));
    expect(first, isNot(second));
    expect(videos.calls, contains('pause ${first.split(' ').last}'));
  });
}
