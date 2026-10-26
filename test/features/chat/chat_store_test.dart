import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/features/chat/data/chat_store.dart';
import 'package:hermes/hermes/models/local_attachment.dart';

import '../../support/memory_stores.dart';
import 'chat_harness.dart';

void main() {
  test('a gateway is its origin, host in lower case', () {
    expect(
      gatewayIdentity(Uri.parse('https://Host.example:443/api')),
      'https://host.example',
    );
    expect(gatewayIdentity(null), isEmpty);
  });

  test('the lists of one gateway are not on another', () async {
    final kv = MemoryKeyValueStore();
    final home = ChatStore(kv, 'https://home');
    final work = ChatStore(kv, 'https://work');
    await home.saveOutbox('bot:atlas', [entry('a', 'hi')]);
    await home.saveDraft('bot:atlas', const ComposerDraft(text: 'half'));
    await home.saveHidden('bot:atlas', {3});
    await home.saveLastBot('atlas');
    expect(work.outbox('bot:atlas'), isEmpty);
    expect(work.draft('bot:atlas').isEmpty, isTrue);
    expect(work.hidden('bot:atlas'), isEmpty);
    expect(work.lastBot(), isNull);
    expect(home.lastBot(), 'atlas');
    expect(home.hidden('bot:atlas'), {3});
  });

  test('the queue lists its targets while they hold entries', () async {
    final store = ChatStore(MemoryKeyValueStore(), '');
    await store.saveOutbox('bot:a', [entry('1', 'x')]);
    await store.saveOutbox('bot:b', [entry('2', 'y')]);
    expect(store.pendingTargets(), {'bot:a', 'bot:b'});
    await store.saveOutbox('bot:a', const []);
    expect(store.pendingTargets(), {'bot:b'});
  });

  test('a draft keeps its words and files; an empty one clears it', () async {
    final kv = MemoryKeyValueStore();
    final store = ChatStore(kv, '');
    const file = LocalAttachment(
      id: 'f',
      path: '/tmp/a.pdf',
      name: 'a.pdf',
      mimeType: 'application/pdf',
      sizeBytes: 3,
    );
    await store.saveDraft(
      'bot:a',
      const ComposerDraft(text: 'hello', attachments: [file]),
    );
    final draft = store.draft('bot:a');
    expect((draft.text, draft.attachments.single.name), ('hello', 'a.pdf'));
    await store.saveDraft('bot:a', const ComposerDraft());
    expect(kv.getString('chat.draft.bot:a'), isNull);
  });

  test('an unreadable blob or row costs that much only', () {
    final kv = MemoryKeyValueStore({
      'chat.outbox.bot:a':
          '[{"id":"ok","createdAt":"2026-01-01T00:00:00Z"},'
          '{"id":7},"junk"]',
      'chat.hidden.bot:a': 'not json',
    });
    final store = ChatStore(kv, '');
    expect(store.outbox('bot:a').map((e) => e.id), ['ok']);
    expect(store.hidden('bot:a'), isEmpty);
  });

  test('a queued turn stored by an earlier version reads and saves the '
      'same', () async {
    const stored =
        '[{"id":"t1","createdAt":"2026-01-01T00:00:00.000Z","text":"see",'
        '"attachments":[{"id":"v","path":"/tmp/v.m4a","name":"v.m4a",'
        '"mime_type":"audio/mp4","size_bytes":2048,"kind":"audio",'
        '"duration_ms":4500},{"id":"p","path":"/tmp/p.jpg","name":"p.jpg",'
        '"mime_type":"image/jpeg","size_bytes":10,"kind":"sticker",'
        '"thumbnail_path":"/tmp/p_t.jpg"}],"status":"queued","attempts":0}]';
    final kv = MemoryKeyValueStore({'chat.outbox.bot:a': stored});
    final store = ChatStore(kv, '');
    final [voice, picture] = store.outbox('bot:a').single.attachments;
    expect(
      (voice.kind, voice.duration, voice.sizeBytes, voice.thumbnailPath),
      (AttachmentKind.audio, const Duration(milliseconds: 4500), 2048, null),
    );
    // A kind this version does not know is sent as a plain file.
    expect(
      (picture.kind, picture.thumbnailPath),
      (AttachmentKind.file, '/tmp/p_t.jpg'),
    );

    await store.saveOutbox('bot:a', store.outbox('bot:a'));
    final again = jsonDecode(kv.getString('chat.outbox.bot:a')!) as List;
    final saved = (again.single as Map)['attachments'] as List;
    expect(saved.first, {
      'id': 'v',
      'path': '/tmp/v.m4a',
      'name': 'v.m4a',
      'mime_type': 'audio/mp4',
      'size_bytes': 2048,
      'kind': 'audio',
      'duration_ms': 4500,
    });
  });
}
