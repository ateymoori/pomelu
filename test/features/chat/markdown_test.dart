import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/features/chat/data/link_metadata.dart';
import 'package:hermes/features/chat/data/link_opener.dart';
import 'package:hermes/features/chat/domain/markdown_chunks.dart';
import 'package:hermes/features/chat/domain/markdown_segments.dart';
import 'package:hermes/features/chat/presentation/widgets/code_block.dart';
import 'package:hermes/features/chat/presentation/widgets/link_card.dart';
import 'package:hermes/features/chat/presentation/widgets/markdown_body.dart';
import 'package:hermes/features/chat/presentation/widgets/markdown_details.dart';
import 'package:hermes/features/chat/presentation/widgets/markdown_links.dart';

import '../../support/app_host.dart';

void main() {
  group('segments', () {
    test(
      'a disclosure and a lonely link get their own piece; code does not',
      () {
        final segments = MarkdownSegments.split(
          'intro\n<details open>\n<summary>More</summary>\nbody\n</details>\n'
          'https://youtu.be/dQw4w9WgXcQ\n```\nhttps://in.code\n```',
        );
        expect(segments, hasLength(4));
        final details = segments[1] as MarkdownDetailsSegment;
        expect(
          (details.summary, details.body, details.open),
          ('More', 'body', true),
        );
        final link = (segments[2] as MarkdownLinkSegment).target;
        expect(link.videoId, 'dQw4w9WgXcQ');
        expect(segments[3], isA<MarkdownTextSegment>());
      },
    );

    test('an unclosed <details> keeps its last line', () {
      final d =
          MarkdownSegments.split('<details>\n<summary>S</summary>\nlast').single
              as MarkdownDetailsSegment;
      expect(d.body, 'last');
    });

    test('task items lose their bullet, outside code only', () {
      expect(
        MarkdownSegments.normalizeTaskLists('- [x] done\n```\n- [ ] code\n```'),
        '[x] done\n```\n- [ ] code\n```',
      );
    });

    test('a link card names its host or path; a percent sign stays shown', () {
      final t = LinkTarget.parse('https://www.example.com/docs/100%25')!;
      expect(
        (t.host, t.fallbackTitle, t.isVideo),
        ('example.com', '100%', false),
      );
      expect(LinkTarget.parse('intent://x'), isNull);
    });
  });

  test('a long reply is cut between blocks only, and nothing is lost', () {
    final source = [
      for (var i = 0; i < 40; i++) 'Paragraph $i with some words in it.\n',
      '```',
      for (var i = 0; i < 40; i++) 'code line $i',
      '```',
    ].join('\n');
    final chunks = MarkdownChunks.split(source, target: 200);
    expect(chunks.length, greaterThan(3));
    expect(chunks.map((c) => c.text).join('\n'), source);
    final fenced = chunks.where((c) => c.text.contains('code line 0'));
    expect(
      fenced.single.text,
      contains('code line 39'),
      reason: 'one fence, one piece',
    );
  });

  group('links', () {
    Future<List<Uri>> tap(WidgetTester tester, String markdown) async {
      final opened = <Uri>[];
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String?;
          }
          return null;
        },
      );
      await pumpApp(
        tester,
        Builder(
          builder: (context) => TextButton(
            onPressed: () => MarkdownLinks.open(context, markdown),
            child: const Text('here'),
          ),
        ),
        overrides: [
          linkLauncherProvider.overrideWithValue((uri) async {
            opened.add(uri);
            return true;
          }),
        ],
      );
      await tester.tap(find.text('here'));
      await tester.pumpAndSettle();
      if (copied != null) opened.add(Uri.parse('copied:$copied'));
      return opened;
    }

    testWidgets('http, https and mailto open', (tester) async {
      expect(await tap(tester, 'https://example.com'), [
        Uri.parse('https://example.com'),
      ]);
    });

    testWidgets('any other scheme is copied, never launched', (tester) async {
      expect((await tap(tester, 'intent://evil')).single.scheme, 'copied');
    });
  });

  testWidgets('a table fits the column and wraps its cells; one whose words '
      'cannot fit scrolls sideways', (tester) async {
    Future<ScrollPosition> table(String rows) async {
      await pumpApp(tester, MarkdownBody(rows), width: 360);
      expect(tester.takeException(), isNull);
      return tester
          .state<ScrollableState>(
            find.ancestor(
              of: find.byType(Table),
              matching: find.byType(Scrollable),
            ),
          )
          .position;
    }

    final fits = await table(
      '| File | Size | Note |\n|---|---|---|\n'
      '| `a.md` | 26 KB | The one doc for the app, with all the steps it '
      'has, one by one |',
    );
    expect(fits.maxScrollExtent, 0);
    expect(tester.getSize(find.byType(Table)).width, lessThanOrEqualTo(360));
    // The long column wraps; the short one keeps its line.
    final size = tester.renderObject<RenderParagraph>(
      find.text('26 KB', findRichText: true),
    );
    expect(size.size.height, size.getMinIntrinsicHeight(double.infinity));

    final wide = await table(
      '| a | b | c | d |\n|---|---|---|---|\n'
      '| supercalifragilistic | antidisestablishment | '
      'floccinaucinihilipilification | pneumonoultramicroscopic |',
    );
    expect(wide.maxScrollExtent, greaterThan(0));
  });

  testWidgets('a code block shows its language and copies its source', (
    tester,
  ) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );
    await pumpApp(tester, const MarkdownBody('```dart\nvoid main() {}\n```'));
    expect(find.byType(CodeBlock), findsOneWidget);
    expect(find.text('dart'), findsOneWidget);
    await tester.tap(find.byIcon(CupertinoIcons.doc_on_doc));
    await tester.pump();
    expect(copied, 'void main() {}');
  });

  testWidgets('a disclosure the user opened stays open while the reply '
      'streams', (tester) async {
    Widget details(String summary, {required bool open}) => MarkdownDetails(
      summary: summary,
      initiallyOpen: open,
      builder: (_) => const Text('body'),
    );
    await pumpApp(tester, details('S', open: false));
    await tester.tap(find.text('S'));
    await tester.pump();
    await pumpApp(tester, details('Su', open: true));
    await pumpApp(tester, details('Sum', open: false));
    expect(find.text('body'), findsOneWidget);
  });

  testWidgets('a video card asks for its title once while the reply grows', (
    tester,
  ) async {
    var asked = 0;
    final http = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            asked++;
            handler.resolve(
              Response(requestOptions: options, data: '{"title": "A song"}'),
            );
          },
        ),
      );
    const link = 'https://youtu.be/dQw4w9WgXcQ';
    final container = ProviderContainer(
      overrides: [linkMetadataClientProvider.overrideWithValue(http)],
    );
    addTearDown(container.dispose);
    for (final reply in ['$link\n', '$link\nmore', '$link\nmore words']) {
      await pumpApp(tester, MarkdownBody(reply), container: container);
      await tester.pumpAndSettle();
    }
    expect(find.text('A song'), findsOneWidget);
    expect(asked, 1);
  });

  testWidgets('a disclosure opens on tap; a lonely link is a card', (
    tester,
  ) async {
    await pumpApp(
      tester,
      const MarkdownBody(
        '<details>\n<summary>Appendix</summary>\nhidden text\n</details>\n'
        'https://example.com/page',
      ),
    );
    expect(find.byType(MarkdownDetails), findsOneWidget);
    expect(find.byType(LinkCard), findsOneWidget);
    expect(find.textContaining('hidden text'), findsNothing);
    await tester.tap(find.text('Appendix'));
    await tester.pumpAndSettle();
    expect(find.textContaining('hidden text'), findsOneWidget);
  });
}
