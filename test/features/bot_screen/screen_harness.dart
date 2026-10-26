import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/features/bot_screen/domain/remote_input.dart';
import 'package:hermes/features/bot_screen/presentation/screen_surface.dart';
import 'package:hermes/features/connection/presentation/connection_providers.dart';
import 'package:hermes/hermes/api/hermes_api.dart';
import 'package:hermes/hermes/hermes_constants.dart';
import 'package:hermes/hermes/hermes_failure.dart';
import 'package:hermes/hermes/models/bot_screen.dart';
import 'package:hermes/hermes/models/profile.dart';

import '../../support/fake_gateway.dart';

const screenBot = 'nova';
const screenKey = '/home/a/.hermes/profiles/nova';

/// A gateway with a Bot Screen, as `methods_display.py` keeps it: viewer
/// ids belong to the socket that minted them ([newSocket] forgets them),
/// and every change of control moves the lease's epoch.
class FakeScreenApi extends Fake implements HermesApi {
  FakeScreenApi({bool running = true})
    : status = ScreenStatus(
        supported: true,
        installed: true,
        running: running,
        profileKey: screenKey,
      );

  ScreenStatus status;

  /// What the gateway was asked, in order, as `method:detail`.
  final List<String> calls = [];
  final Set<String> _minted = {};
  int _ids = 0;

  void newSocket() => _minted.clear();

  ScreenLease get lease => status.lease;

  /// Another viewer takes control.
  ScreenLease takenElsewhere() => _setLease(
    const ScreenLease(holder: ScreenHolder.human, viewerHash: 'feedfeedfeed'),
  );

  ScreenLease _setLease(ScreenLease next) {
    status = status.copyWith(lease: next.copyWith(epoch: lease.epoch + 1));
    return lease;
  }

  Never _mismatch() => throw const ServerFailure(
    'viewer_id was not minted for this connection',
    rpcCode: HermesProtocol.errDisplay,
    data: {'code': HermesProtocol.viewerMismatch},
  );

  @override
  Future<List<HermesProfile>> listProfiles() async => const [];

  @override
  Future<ScreenStatus?> screenStatus(String profile) async {
    calls.add('status');
    return status;
  }

  @override
  Future<ScreenStatus> startScreen(String profile) async {
    calls.add('start');
    return status = status.copyWith(running: true);
  }

  @override
  Future<String?> screenThumbnail(String profile) async =>
      'data:image/jpeg;base64,AA';

  @override
  Future<ScreenAttach> observeScreen(String profile, {String? viewerId}) async {
    calls.add('observe:$viewerId');
    final id = _minted.contains(viewerId) ? viewerId! : 'viewer-${++_ids}';
    _minted.add(id);
    return (
      status: status,
      viewerId: id,
      stream: Uri.parse('ws://gw/api/display/ws?display_ticket=t$_ids'),
    );
  }

  @override
  Future<ScreenLease> takeOverScreen(String profile, String viewerId) async {
    calls.add('take:$viewerId');
    if (!_minted.contains(viewerId)) _mismatch();
    return _setLease(
      ScreenLease(
        holder: ScreenHolder.human,
        viewerHash: screenViewerHash(viewerId),
      ),
    );
  }

  @override
  Future<ScreenLease> handBackScreen(
    String profile, {
    String? viewerId,
    bool force = false,
  }) async {
    calls.add('back:${force ? 'force' : viewerId}');
    if (!force && !_minted.contains(viewerId)) _mismatch();
    return _setLease(const ScreenLease());
  }
}

/// The web view, as the session drives it.
class FakeSurface implements ScreenSurface {
  final List<String> calls = [];

  @override
  Future<void> attach(Uri stream, {required bool viewOnly}) async =>
      calls.add('attach:${viewOnly ? 'watch' : 'control'}');

  @override
  Future<void> detach({required bool handBack}) async =>
      calls.add('detach:${handBack ? 'hand back' : 'keep'}');

  @override
  Future<void> setViewOnly({required bool viewOnly}) async =>
      calls.add('viewOnly:$viewOnly');

  @override
  Future<void> poster(String? dataUrl) async => calls.add('poster');

  @override
  Future<void> type(
    int backspaces,
    String text,
    Set<ScreenModifier> modifiers,
  ) async => calls.add('type:$backspaces:$text');

  @override
  Future<void> press(ScreenKey key, Set<ScreenModifier> modifiers) async =>
      calls.add('press:${key.name}');

  @override
  Future<void> setClipboard(String text) async => calls.add('clipboard:$text');

  @override
  Future<void> drag({required bool on}) async => calls.add('drag:$on');

  @override
  Future<void> fit() async => calls.add('fit');

  @override
  Future<void> fill() async => calls.add('fill');
}

/// A client of a gateway at an address, for the web view's origin.
class ScreenClient extends FakeClient {
  @override
  Uri get baseUrl => Uri.parse('http://gw.lan:9119');
}

List<Override> screenOverrides(FakeScreenApi api, FakeClient client) => [
  hermesApiProvider.overrideWithValue(api),
  hermesClientProvider.overrideWithValue(client),
];
