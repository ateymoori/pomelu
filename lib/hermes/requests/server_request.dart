import 'package:freezed_annotation/freezed_annotation.dart';

import '../hermes_constants.dart';
import '../models/json_converters.dart';
import 'clarify_question.dart';

part 'server_request.freezed.dart';

/// What an approval offers when the gateway lists nothing.
const List<String> defaultApprovalChoices = [
  ApprovalChoices.once,
  ApprovalChoices.deny,
];

/// What a masked-input request asks for.
enum InputKind {
  /// The password of a `sudo` command the agent is running.
  sudo,

  /// A named secret (an API key, a token) a skill or setup flow needs.
  secret,
}

/// A question the agent is blocked on, sent by the gateway as a JSON-RPC
/// *request* and answered with a response carrying the same [id]
/// (`docs/PROTOCOL.md` → Server requests).
///
/// [id] is the gateway's `srq-…` frame id; [sessionId] is the runtime id of
/// the session that asked.
@freezed
sealed class ServerRequest with _$ServerRequest {
  const ServerRequest._();

  /// The clarify tool: 1–5 questions answered together.
  const factory ServerRequest.clarify({
    required String id,
    required String sessionId,
    required List<ClarifyQuestion> questions,

    /// Answers the gateway already holds (a reconnect replay): qid → answer,
    /// null meaning skipped.
    @Default(<String, String?>{}) Map<String, String?> lockedAnswers,
  }) = ClarifyRequest;

  /// A dangerous command waiting for a decision.
  const factory ServerRequest.approval({
    required String id,
    required String sessionId,
    @Default('') String command,
    @Default('') String description,

    /// The decisions offered, in the gateway's order (`once`, `session`,
    /// `always`, `deny`). Never empty.
    @Default(defaultApprovalChoices) List<String> choices,
    @Default(false) bool smartDenied,
  }) = ApprovalRequest;

  /// A masked value: a sudo password or a named secret.
  const factory ServerRequest.input({
    required String id,
    required String sessionId,
    required InputKind kind,

    @Default('') String prompt,

    @Default('') String subject,
  }) = InputRequest;

  /// Parses the interactive request [method] sent with frame id [id], or null
  /// when it cannot be shown: a method the app has no card for, no session to
  /// attach it to, or a clarify request with no usable question.
  static ServerRequest? parse(
    Object id,
    String method,
    Map<String, dynamic> params,
  ) {
    const text = LooseString();
    final sessionId = text.fromJson(params['session_id']);
    if (sessionId.isEmpty) return null;
    final frameId = '$id';

    switch (method) {
      case 'clarify':
        final raw = params['questions'];
        final questions = [
          if (raw is List)
            for (final entry in raw)
              if (entry is Map<String, dynamic>)
                ?ClarifyQuestion.fromJson(entry).normalized(),
        ];
        if (questions.isEmpty) return null;
        final answers = params['answers'];
        return ServerRequest.clarify(
          id: frameId,
          sessionId: sessionId,
          questions: questions,
          lockedAnswers: {
            if (answers is Map)
              for (final e in answers.entries)
                if (e.key is String && (e.value == null || e.value is String))
                  e.key as String: e.value as String?,
          },
        );
      case 'approval':
        final listed = const LooseStringList().fromJson(params['choices']);
        // `allow_permanent: false` (a security warning forbids it) hides
        // "always"; the gateway omits the field otherwise.
        final choices = [
          for (final c in listed ?? const <String>[])
            if (c.isNotEmpty &&
                !(c == ApprovalChoices.always &&
                    params['allow_permanent'] == false))
              c,
        ];
        return ServerRequest.approval(
          id: frameId,
          sessionId: sessionId,
          command: text.fromJson(params['command']),
          description: text.fromJson(params['description']),
          choices: choices.isEmpty ? defaultApprovalChoices : choices,
          smartDenied: const LooseBool().fromJson(params['smart_denied']),
        );
      case 'sudo':
        return ServerRequest.input(
          id: frameId,
          sessionId: sessionId,
          kind: InputKind.sudo,
          subject: text.fromJson(params['command']),
        );
      case 'secret':
        return ServerRequest.input(
          id: frameId,
          sessionId: sessionId,
          kind: InputKind.secret,
          prompt: text.fromJson(params['prompt']),
          subject: text.fromJson(params['env_var']),
        );
    }
    return null;
  }
}
