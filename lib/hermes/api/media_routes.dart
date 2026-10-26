part of 'hermes_api.dart';

/// Speech audio of a text: its bytes and their type (`audio/mpeg`, ...).
typedef SpeechAudio = ({Uint8List bytes, String mimeType});

/// Media both ways: attachments for the next turn, speech to and from text,
/// and the URLs the transcript's images, audio and video load from.
mixin _MediaRoutes {
  HermesClient get _client;

  /// Attaches an image to the next turn. Over [HermesLimits.maxImageBytes]
  /// it throws [HermesProtocol.errImageTooLarge] before anything is sent.
  Future<ImageAttachResult> attachImageBytes({
    required String runtimeId,
    required List<int> bytes,
    required String filename,
  }) async {
    if (bytes.length > HermesLimits.maxImageBytes) {
      throw const ServerFailure(
        'image too large',
        rpcCode: HermesProtocol.errImageTooLarge,
      );
    }
    final res = await _client.call(HermesMethods.imageAttachBytes, {
      'session_id': runtimeId,
      'filename': filename,
      'content_base64': Base64Bytes(bytes),
    }, HermesTimeouts.upload);
    return parseObject(res, ImageAttachResult.fromJson, what: 'image attach');
  }

  /// Uploads a file into the session's workspace. Over
  /// [HermesLimits.maxFileBytes] it throws a 413 before anything is sent.
  Future<FileAttachResult> attachFile({
    required String runtimeId,
    required List<int> bytes,
    required String name,
    required String mimeType,
  }) async {
    _checkSize(bytes, HermesLimits.maxFileBytes, 'file');
    final res = await _client.call(HermesMethods.fileAttach, {
      'session_id': runtimeId,
      'name': name,
      'path': name,
      'data_url': _dataUrl(mimeType, bytes),
    }, HermesTimeouts.upload);
    return parseObject(res, FileAttachResult.fromJson, what: 'file attach');
  }

  /// Speech to text with [profile]'s provider. Over
  /// [HermesLimits.maxAudioBytes] it throws a 413.
  Future<String> transcribe({
    required List<int> bytes,
    required String mimeType,
    String? profile,
  }) async {
    _checkSize(bytes, HermesLimits.maxAudioBytes, 'audio');
    final body = <String, dynamic>{
      'data_url': _dataUrl(mimeType, bytes),
      'mime_type': mimeType,
    };
    final text = encodesApart(body)
        ? await encodeJsonApart(body)
        : jsonEncode(body);
    final json = await _optionalRoute(
      'speech to text',
      () => _client.http.json(
        'POST',
        HermesPaths.audioTranscribe,
        body: text,
        query: {'profile': ?profile},
        timeout: HermesTimeouts.transcribe,
      ),
    );
    return json['transcript']?.toString() ?? '';
  }

  /// [text] spoken by [profile]'s voice (its `tts` settings; Markdown is
  /// read as plain words).
  Future<SpeechAudio> speak({required String text, String? profile}) async {
    final json = await _optionalRoute(
      'text to speech',
      () => _client.http.json(
        'POST',
        HermesPaths.audioSpeak,
        body: jsonEncode({'text': text}),
        query: {'profile': ?profile},
        timeout: HermesTimeouts.speak,
      ),
    );
    try {
      final data = UriData.parse(json['data_url']?.toString() ?? '');
      return (bytes: data.contentAsBytes(), mimeType: data.mimeType);
    } on FormatException catch (e) {
      throw ProtocolFailure('malformed speech audio', cause: e);
    }
  }

  static void _checkSize(List<int> bytes, int max, String what) {
    if (bytes.length > max) {
      throw ServerFailure(
        '$what too large',
        httpStatus: HermesHttpStatus.payloadTooLarge,
      );
    }
  }

  static Base64Bytes _dataUrl(String mimeType, List<int> bytes) =>
      Base64Bytes(bytes, prefix: 'data:$mimeType;base64,');

  /// Range-capable stream of audio or video; needs [mediaHeaders].
  Uri mediaStreamUrl(String path, {String? profile}) => _client.http.resolve(
    HermesPaths.filesStream,
    {'path': path, 'profile': ?profile},
  );

  /// Download of an image or file; needs [mediaHeaders].
  Uri mediaDownloadUrl(String path) =>
      _client.http.resolve(HermesPaths.filesDownload, {'path': path});

  /// Bytes in the gateway file [path]. Only its first byte comes down: the
  /// size is in the answer's `Content-Range`. Null when the answer has none.
  Future<int?> mediaSize(String path) async {
    final res = await _client.http.send(
      'GET',
      HermesPaths.filesDownload,
      query: {'path': path},
      headers: const {HttpHeaders.rangeHeader: 'bytes=0-0'},
      plain: true,
    );
    final range = res.headers.value(HttpHeaders.contentRangeHeader);
    return int.tryParse(range?.split('/').last ?? '');
  }

  /// Headers the media URLs need.
  Map<String, String> mediaHeaders() => _client.http.authHeaders();
}
