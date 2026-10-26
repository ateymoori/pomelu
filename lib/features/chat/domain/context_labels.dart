import '../../../hermes/models/context_breakdown.dart';
import '../../../l10n/generated/app_localizations.dart';

/// The app's name for a category, else the gateway's own label.
String contextPartLabel(AppLocalizations l10n, ContextCategory c) =>
    switch (c.id) {
      ContextCategoryId.systemPrompt => l10n.contextPartSystemPrompt,
      ContextCategoryId.tools => l10n.contextPartTools,
      ContextCategoryId.rules => l10n.contextPartRules,
      ContextCategoryId.skills => l10n.contextPartSkills,
      ContextCategoryId.mcp => l10n.contextPartMcp,
      ContextCategoryId.subagents => l10n.contextPartSubagents,
      ContextCategoryId.memory => l10n.contextPartMemory,
      ContextCategoryId.conversation => l10n.contextPartConversation,
      _ => c.label.isNotEmpty ? c.label : c.id,
    };

/// Why a context file is not plainly loaded; null when it is.
String? contextFileNote(AppLocalizations l10n, ContextFile f) =>
    switch (f.status) {
      'loaded' => null,
      'truncated' => l10n.contextFileTruncated,
      'flagged' => l10n.contextFileFlagged,
      'shadowed' => l10n.contextFileShadowed,
      'blocked' => l10n.contextFileBlocked,
      'empty' => l10n.contextFileEmpty,
      'unreadable' => l10n.contextFileUnreadable,
      'suppressed' => l10n.contextFileSuppressed,
      _ => f.loaded ? null : l10n.contextFileNotLoaded,
    };

/// Share of the window as a label: "<1%" for a sliver, else whole percent.
String contextShare(AppLocalizations l10n, int tokens, int max) {
  if (max <= 0) return '';
  final share = tokens / max * 100;
  if (share > 0 && share < 1) return l10n.contextPartUnder1;
  return l10n.contextPercent(share.round());
}
