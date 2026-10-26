import 'package:flutter/material.dart';
import 'package:re_highlight/languages/bash.dart';
import 'package:re_highlight/languages/c.dart';
import 'package:re_highlight/languages/cpp.dart';
import 'package:re_highlight/languages/csharp.dart';
import 'package:re_highlight/languages/css.dart';
import 'package:re_highlight/languages/dart.dart';
import 'package:re_highlight/languages/diff.dart';
import 'package:re_highlight/languages/dockerfile.dart';
import 'package:re_highlight/languages/go.dart';
import 'package:re_highlight/languages/graphql.dart';
import 'package:re_highlight/languages/http.dart';
import 'package:re_highlight/languages/ini.dart';
import 'package:re_highlight/languages/java.dart';
import 'package:re_highlight/languages/javascript.dart';
import 'package:re_highlight/languages/json.dart';
import 'package:re_highlight/languages/kotlin.dart';
import 'package:re_highlight/languages/lua.dart';
import 'package:re_highlight/languages/makefile.dart';
import 'package:re_highlight/languages/markdown.dart';
import 'package:re_highlight/languages/nginx.dart';
import 'package:re_highlight/languages/objectivec.dart';
import 'package:re_highlight/languages/php.dart';
import 'package:re_highlight/languages/plaintext.dart';
import 'package:re_highlight/languages/powershell.dart';
import 'package:re_highlight/languages/protobuf.dart';
import 'package:re_highlight/languages/python.dart';
import 'package:re_highlight/languages/ruby.dart';
import 'package:re_highlight/languages/rust.dart';
import 'package:re_highlight/languages/scala.dart';
import 'package:re_highlight/languages/shell.dart';
import 'package:re_highlight/languages/sql.dart';
import 'package:re_highlight/languages/swift.dart';
import 'package:re_highlight/languages/typescript.dart';
import 'package:re_highlight/languages/xml.dart';
import 'package:re_highlight/languages/yaml.dart';
import 'package:re_highlight/re_highlight.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/utils/app_logger.dart';

/// Longest source we colour. Beyond this the grammar walk costs more than the
/// colour is worth on a 120 Hz panel, so the block stays plain mono text.
const int kHighlightLimit = 20000;

const int _cacheLimit = 64;

final Map<String, Mode> _languages = {
  'bash': langBash,
  'c': langC,
  'cpp': langCpp,
  'csharp': langCsharp,
  'css': langCss,
  'dart': langDart,
  'diff': langDiff,
  'dockerfile': langDockerfile,
  'go': langGo,
  'graphql': langGraphql,
  'http': langHttp,
  'ini': langIni,
  'java': langJava,
  'javascript': langJavascript,
  'json': langJson,
  'kotlin': langKotlin,
  'lua': langLua,
  'makefile': langMakefile,
  'markdown': langMarkdown,
  'nginx': langNginx,
  'objectivec': langObjectivec,
  'php': langPhp,
  'plaintext': langPlaintext,
  'powershell': langPowershell,
  'protobuf': langProtobuf,
  'python': langPython,
  'ruby': langRuby,
  'rust': langRust,
  'scala': langScala,
  'shell': langShell,
  'sql': langSql,
  'swift': langSwift,
  'typescript': langTypescript,
  'xml': langXml,
  'yaml': langYaml,
};

const Map<String, String> _extraAliases = {
  'sh': 'bash',
  'zsh': 'bash',
  'console': 'shell',
  'terminal': 'shell',
  'text': 'plaintext',
  'txt': 'plaintext',
  'toml': 'ini',
  'cfg': 'ini',
  'conf': 'ini',
  'html': 'xml',
  'svg': 'xml',
  'yml': 'yaml',
  'jsonc': 'json',
  'js': 'javascript',
  'ts': 'typescript',
  'tsx': 'typescript',
  'jsx': 'javascript',
  'py': 'python',
  'rb': 'ruby',
  'kt': 'kotlin',
  'kts': 'kotlin',
  'cs': 'csharp',
  'c++': 'cpp',
  'objc': 'objectivec',
  'patch': 'diff',
  'md': 'markdown',
  'gradle': 'kotlin',
  'docker': 'dockerfile',
  'make': 'makefile',
  'proto': 'protobuf',
  'ps1': 'powershell',
  'psql': 'sql',
  'sqlite': 'sql',
};

/// Syntax colouring for fenced code, themed entirely from the design tokens.
///
/// Only the semantic token colours exist in `docs/DESIGN.md`, so the palette
/// is deliberately small: five roles instead of a twenty-colour editor theme.
/// Nothing here invents a colour.
abstract final class CodeHighlight {
  static final Highlight _highlight = Highlight()
    ..registerLanguages(_languages);

  static final Map<(String, String, Brightness), TextSpan> _cache = {};

  /// The grammar name for a fence info string, or null when we have none.
  ///
  /// `{.dart}`, `dart title="x"` and `DART` all resolve to `dart`.
  static String? resolve(String info) {
    var name = info.trim().toLowerCase();
    if (name.isEmpty) return null;
    name = name
        .split(RegExp(r'[\s,:{}]'))
        .firstWhere((part) => part.isNotEmpty, orElse: () => '');
    name = name.replaceAll(RegExp('^[.#]'), '');
    if (name.isEmpty) return null;
    final aliased = _extraAliases[name] ?? name;
    return _highlight.getLanguage(aliased) == null ? null : aliased;
  }

  /// The palette for one theme, derived from the tokens.
  ///
  /// - `accent` — keywords, types, built-ins: the one saturated colour the
  ///   design system owns.
  /// - `success` — strings and regexes.
  /// - `warning` — numbers and literals.
  /// - `textTertiary` — comments, quoted out of the way.
  /// - `codeText` — everything else, i.e. the plain block colour.
  static Map<String, TextStyle> themeOf(BuildContext context) {
    final colors = context.colors;
    // The weight of the theme's emphasised label, not a literal.
    final bold = Theme.of(context).textTheme.labelLarge?.fontWeight;
    final keyword = TextStyle(color: colors.accentText);
    final literal = TextStyle(color: colors.warning);
    final string = TextStyle(color: colors.success);
    final comment = TextStyle(
      color: colors.textTertiary,
      fontStyle: FontStyle.italic,
    );
    final title = TextStyle(color: colors.codeText, fontWeight: bold);
    final muted = TextStyle(color: colors.textSecondary);

    return {
      'keyword': keyword,
      'built_in': keyword,
      'type': keyword,
      'class': keyword,
      'literal': literal,
      'number': literal,
      'symbol': literal,
      'selector-tag': keyword,
      'selector-id': keyword,
      'selector-class': keyword,
      'string': string,
      'regexp': string,
      'char.escape': string,
      'subst': TextStyle(color: colors.codeText),
      'comment': comment,
      'quote': comment,
      'doctag': comment,
      'title': title,
      'title.function': title,
      'title.class': title,
      'section': title,
      'name': title,
      'attr': muted,
      'attribute': muted,
      'variable': muted,
      'template-variable': muted,
      'params': muted,
      'meta': muted,
      'meta.keyword': keyword,
      'meta.string': string,
      'tag': muted,
      'property': muted,
      'bullet': muted,
      'link': TextStyle(color: colors.accentText),
      'addition': TextStyle(color: colors.success),
      'deletion': TextStyle(color: colors.danger),
      'emphasis': const TextStyle(fontStyle: FontStyle.italic),
      'strong': TextStyle(fontWeight: bold),
      'operator': TextStyle(color: colors.codeText),
      'punctuation': TextStyle(color: colors.codeText),
    };
  }

  /// Colours [code] as [language], or returns null when the language is
  /// unknown, the source is oversized, or the grammar failed — every caller
  /// must be able to fall back to plain text.
  static TextSpan? spanFor(
    BuildContext context, {
    required String code,
    required String language,
    required TextStyle base,
  }) {
    if (code.length > kHighlightLimit) return null;
    final grammar = resolve(language);
    if (grammar == null || grammar == 'plaintext') return null;

    final brightness = Theme.of(context).brightness;
    final key = (code, grammar, brightness);
    final hit = _cache[key];
    if (hit != null) return TextSpan(style: base, children: [hit]);

    TextSpan? parsed;
    try {
      final result = _highlight.highlight(code: code, language: grammar);
      final renderer = TextSpanRenderer(null, themeOf(context));
      result.render(renderer);
      parsed = renderer.span;
    } on Object catch (e) {
      // A grammar that throws must never take the transcript down; the block
      // simply renders unhighlighted.
      log.w('highlighting $grammar failed', error: e);
      return null;
    }
    if (parsed == null) return null;
    if (_cache.length >= _cacheLimit) _cache.remove(_cache.keys.first);
    _cache[key] = parsed;
    return TextSpan(style: base, children: [parsed]);
  }
}
