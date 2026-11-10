import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/features/chat/presentation/widgets/media_video.dart';
import 'package:hermes/features/chat/presentation/widgets/video_page.dart';
import 'package:hermes/features/connection/presentation/connection_providers.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

import '../../support/app_host.dart';

/// A native player that loads at once: a 30 s video, 16:9 unless [size]
/// says otherwise.
class _FakeVideos extends VideoPlayerPlatform {
  Size size = const Size(1920, 1080);
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
          size: size,
        ),
      ),
    );
    return id;
  }

  @override
  Stream<VideoEvent> videoEventsFor(int playerId) => _events[playerId]!.stream;

  /// The stream of [playerId] breaks, as when the gateway goes away.
  void fail(int playerId) => _events[playerId]!.addError(
    PlatformException(code: 'VideoError', message: 'the stream ended'),
  );

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

/// No gateway behind the rows: save and share have nothing to fetch.
Future<void> pumpVideo(
  WidgetTester tester,
  Widget child, {
  double? width,
  double? height,
}) => pumpApp(
  tester,
  child,
  width: width,
  height: height,
  overrides: [
    hermesClientProvider.overrideWithValue(null),
    hermesApiProvider.overrideWithValue(null),
  ],
);

void main() {
  late _FakeVideos videos;

  setUp(() => VideoPlayerPlatform.instance = videos = _FakeVideos());

  testWidgets('a video row opens its stream only once on screen a moment, '
      'then shows its length; a tap plays it with controls', (tester) async {
    await pumpVideo(tester, _video('reel.mp4'));
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
    await pumpVideo(tester, _video('reel.mp4'));
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

  testWidgets('a stream that breaks while it plays says so, and Retry opens '
      'it again', (tester) async {
    await pumpVideo(tester, _video('reel.mp4'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();
    await tester.tap(find.byTooltip('Play'));
    await tester.pump();

    videos.fail(0);
    await tester.pump();
    await tester.pump();
    expect(find.text('Video unavailable'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();
    await tester.pump();
    expect(videos.created, 2);
    expect(find.text('Video unavailable'), findsNothing);
  });

  testWidgets('a portrait video on a short window keeps play and full '
      'screen, with no seek bar to overflow', (tester) async {
    videos.size = const Size(1080, 1920);
    await pumpVideo(tester, _video('story.mp4'), width: 800, height: 360);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();
    await tester.tap(find.byTooltip('Play'));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byTooltip('Pause'), findsOneWidget);
    expect(find.byTooltip('Full screen'), findsOneWidget);
    expect(find.bySemanticsLabel('Seek'), findsNothing);
  });

  testWidgets('a second video that starts pauses the first', (tester) async {
    await pumpVideo(
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
