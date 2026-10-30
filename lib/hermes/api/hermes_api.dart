import 'dart:convert';
import 'dart:io' show HttpHeaders;
import 'dart:typed_data';

import '../client/hermes_client.dart';
import '../hermes_constants.dart';
import '../hermes_failure.dart';
import '../models/attach_result.dart';
import '../models/bot_cron_job.dart';
import '../models/bot_screen.dart';
import '../models/bot_skill.dart';
import '../models/bot_soul.dart';
import '../models/bot_toolset.dart';
import '../models/compress_result.dart';
import '../models/context_breakdown.dart';
import '../models/gateway_action.dart';
import '../models/json_converters.dart';
import '../models/json_parse.dart';
import '../models/model_options.dart';
import '../models/profile.dart';
import '../models/push_device.dart';
import '../models/session_message.dart';
import '../models/session_resume.dart';
import '../models/session_summary.dart';
import '../rpc/json_offload.dart';

part 'dashboard_routes.dart';
part 'media_routes.dart';
part 'model_routes.dart';
part 'profile_routes.dart';
part 'push_routes.dart';
part 'screen_routes.dart';

/// Typed façade over the gateway RPCs and REST routes the app needs. A
/// malformed row of a list is left out (and logged); the rest still load.
class HermesApi
    with
        _DashboardRoutes,
        _MediaRoutes,
        _ModelRoutes,
        _ProfileRoutes,
        _PushRoutes,
        _ScreenRoutes {
  /// The API of [_client]'s gateway.
  const HermesApi(this._client);

  @override
  final HermesClient _client;

  @override
  List<T> _rows<T>(
    Object? raw,
    T Function(Map<String, dynamic>) fromJson,
    String what, [
    bool Function(T)? keep,
  ]) => parseRows(raw, fromJson, what: what, log: _client.log, keep: keep);

  // ------------------------------------------------------------- roster

  /// Every bot (profile) with its sessions; one without a name is left out.
  Future<List<HermesProfile>> listProfiles() async {
    final res = await _client.call(HermesMethods.profilesList, const {
      'include_sessions': true,
    }, HermesTimeouts.rpcStartup);
    return _rows(
      res['profiles'],
      HermesProfile.fromJson,
      'profile',
      (p) => p.name.isNotEmpty,
    );
  }

  /// A bot's avatar as a data URL, or null.
  Future<String?> profileAvatar(String name) async {
    final res = await _client.call(HermesMethods.profilesGetAsset, {
      'name': name,
      'asset': 'avatar',
    });
    final d = res['data'];
    return res['found'] == true && d is String && d.isNotEmpty ? d : null;
  }

  // ----------------------------------------------------------- sessions

  /// The session of [profile] titled exactly [title] (the "Bot Chat").
  Future<SessionSummary?> findByTitle(String profile, String title) async {
    final res = await _client.call(HermesMethods.sessionList, {
      'profile': profile,
      'title': title,
      'limit': HermesLimits.titleLookupRows,
      'include_hidden': true,
    });
    final rows = _rows(
      res['sessions'],
      (row) => SessionSummary.fromJson({...row, 'profile': profile}),
      'session',
      (s) => s.id.isNotEmpty,
    );
    return rows.firstOrNull;
  }

  /// Starts a session of [profile]. [followProfileConfig] uses the bot's
  /// model; [parentSessionId] links it to the stored session it follows.
  Future<SessionResume> createSession({
    required String profile,
    String? title,
    bool hidden = false,
    bool followProfileConfig = false,
    String? parentSessionId,
  }) async => _resumed(
    await _client.call(HermesMethods.sessionCreate, {
      'profile': profile,
      'cols': HermesLimits.terminalCols,
      'source': HermesProtocol.sourceName,
      'title': ?title,
      if (hidden) 'hidden': true,
      if (followProfileConfig) 'follow_profile_config': true,
      'parent_session_id': ?parentSessionId,
    }, HermesTimeouts.rpcStartup),
  );

  /// Brings the stored session back; with [deferHistory] the transcript is
  /// left to [history].
  Future<SessionResume> resumeSession({
    required String storedId,
    required String profile,
    bool deferHistory = true,
  }) async => _resumed(
    await _client.call(HermesMethods.sessionResume, {
      'session_id': storedId,
      'profile': profile,
      'cols': HermesLimits.terminalCols,
      'source': HermesProtocol.sourceName,
      'defer_history': deferHistory,
      'omit_messages': deferHistory,
    }, HermesTimeouts.rpcStartup),
  );

  /// Ends this app's hold on a live session; the stored chat stays and
  /// resumes later.
  Future<void> closeSession(String runtimeId) async {
    await _client.call(HermesMethods.sessionClose, {'session_id': runtimeId});
  }

  /// Drops the last user turn and all after it from an idle session;
  /// returns how many rows went.
  Future<int> undoLastTurn(String runtimeId) async {
    final res = await _client.call(HermesMethods.sessionUndo, {
      'session_id': runtimeId,
    });
    return const LooseInt().fromJson(res['removed']);
  }

  /// The transcript of a live session.
  Future<List<SessionMessage>> history(String runtimeId) async {
    final res = await _client.call(HermesMethods.sessionHistory, {
      'session_id': runtimeId,
    }, HermesTimeouts.rpcStartup);
    return _rows(res['messages'], SessionMessage.fromJson, 'message');
  }

  /// Renames a live session; throws [TitleInUseFailure] when another
  /// session holds [title].
  Future<void> setTitle(String runtimeId, String title) async {
    try {
      await _client.call(HermesMethods.sessionTitle, {
        'session_id': runtimeId,
        'title': title,
      });
    } on ServerFailure catch (e) {
      if (e.rpcCode == HermesProtocol.errTitleRejected &&
          e.message.contains(HermesProtocol.titleInUseMarker)) {
        throw TitleInUseFailure(e.message, rpcCode: e.rpcCode, data: e.data);
      }
      rethrow;
    }
  }

  /// Archives (or restores) a session and its compression lineage; the
  /// messages are kept.
  Future<void> archiveSession({
    required String sessionId,
    required String profile,
    bool archived = true,
  }) => _client.call(HermesMethods.sessionArchive, {
    'session_id': sessionId,
    'archived': archived,
    'profile': profile,
  });

  /// The stored row of [storedId], live or not.
  Future<SessionSummary> storedSession({
    required String storedId,
    required String profile,
  }) async => parseObject(
    {
      ...await _client.http.json(
        'GET',
        HermesPaths.session(storedId),
        query: {'profile': profile},
      ),
      'profile': profile,
    },
    SessionSummary.fromJson,
    what: 'stored session',
  );

  /// One page of [profile]'s visible conversations this app started, newest
  /// first; a compacted one shows as its newest part.
  Future<List<SessionSummary>> appSessions({
    required String profile,
    int offset = 0,
  }) async {
    final json = await _client.http.json(
      'GET',
      HermesPaths.sessions,
      query: {
        'profile': profile,
        'sources':
            '${HermesProtocol.sourceName},${HermesProtocol.legacySource}',
        'archived': 'include',
        'limit': '${HermesLimits.sessionListPage}',
        'offset': '$offset',
      },
    );
    return _rows(
      json['sessions'],
      (row) => SessionSummary.fromJson({...row, 'profile': profile}),
      'session',
      (s) => s.id.isNotEmpty,
    );
  }

  /// The saved transcript of [storedId]: its newest [limit] rows,
  /// compression ancestors included, images as `[image]`.
  Future<List<SessionMessage>> storedMessages({
    required String storedId,
    required String profile,
    int limit = HermesLimits.storedMessagesPage,
  }) async {
    final json = await _client.http.json(
      'GET',
      HermesPaths.sessionMessages(storedId),
      query: {
        'profile': profile,
        'limit': '$limit',
        'order': 'latest',
        'inline_images': 'false',
      },
    );
    return _rows(json['messages'], SessionMessage.fromJson, 'message');
  }

  /// Compacts a live session's context into a summary.
  Future<CompressResult> compress(String runtimeId) async => parseObject(
    await _client.call(HermesMethods.sessionCompress, {
      'session_id': runtimeId,
    }, HermesTimeouts.compress),
    CompressResult.fromJson,
    what: 'compress result',
  );

  /// What fills a live session's context window, with token estimates.
  Future<ContextBreakdown> contextBreakdown(String runtimeId) async =>
      parseObject(
        await _client.call(HermesMethods.sessionContextBreakdown, {
          'session_id': runtimeId,
        }, HermesTimeouts.rpcStartup),
        ContextBreakdown.fromJson,
        what: 'context breakdown',
      );

  // -------------------------------------------------------------- turns

  /// Sends a user turn; returns the gateway's status (`streaming`, ...).
  /// [interrupted] marks a turn sent right after a stop.
  Future<String> submitPrompt({
    required String runtimeId,
    required String profile,
    required String text,
    bool interrupted = false,
  }) async {
    try {
      final res = await _client.call(HermesMethods.promptSubmit, {
        'session_id': runtimeId,
        'profile': profile,
        'text': text,
        if (interrupted) 'interrupted': true,
      }, HermesTimeouts.rpcSubmit);
      return res['status']?.toString() ?? '';
    } on ServerFailure catch (e) {
      if (e.rpcCode != HermesProtocol.errSessionBusy) rethrow;
      final data = e.data;
      throw SessionBusyFailure(
        e.message,
        reason: data is Map ? data['reason']?.toString() : null,
        data: data,
      );
    }
  }

  /// Stops the running turn.
  Future<void> interrupt(String runtimeId) =>
      _client.call(HermesMethods.sessionInterrupt, {'session_id': runtimeId});

  static SessionResume _resumed(Map<String, dynamic> res) {
    final resume = parseObject(res, SessionResume.fromJson, what: 'session');
    if (resume.sessionId.isEmpty) {
      throw const ProtocolFailure('the gateway answered without a session id');
    }
    return resume;
  }
}

/// [op] against a REST route an older gateway may lack: its 404 is a
/// [NotSupportedFailure].
Future<T> _optionalRoute<T>(String what, Future<T> Function() op) async {
  try {
    return await op();
  } on ServerFailure catch (e) {
    if (e.httpStatus != HermesHttpStatus.notFound) rethrow;
    throw NotSupportedFailure('$what is not supported by this gateway');
  }
}
