import 'dart:async';

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/config/legal_config.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/failure_text.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../hermes/hermes_failure.dart';
import '../../../share/presentation/composer_seeds_provider.dart';
import '../../data/media_cache.dart';
import '../../data/reply_report.dart';
import '../../domain/chat_message.dart';
import '../../domain/chat_target.dart';
import '../../domain/message_markdown.dart';
import '../../domain/transcript.dart';
import '../chat_controller.dart';
import '../read_aloud.dart';

/// The long-press menu as a named action, for a screen reader or a switch,
/// on a node of its own around children that keep their semantics.
class MessageActionsSemantics extends StatelessWidget {
  const MessageActionsSemantics({
    required this.onActions,
    required this.child,
    super.key,
  });

  final VoidCallback onActions;
  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    explicitChildNodes: true,
    customSemanticsActions: {
      CustomSemanticsAction(label: context.l10n.chatMessageActionsLabel):
          onActions,
    },
    child: child,
  );
}

enum _Action {
  copy,
  copyMarkdown,
  quote,
  share,
  readAloud,
  resend,
  edit,
  discard,
  hide,
  deleteFrom,
  deleteNote,
  report,
}

/// The long-press menu of a row. Unsent turns can be sent again, edited or
/// discarded (the queue is the only place they live); saved rows hidden on
/// this phone or deleted from there on (the gateway cannot cut one message
/// out of the middle); command rows, which live here only, removed; a
/// finished reply of the agent reported to the developer. A right-click
/// opens it at the [pointer].
Future<void> showMessageActions(
  BuildContext context,
  WidgetRef ref,
  ChatTarget target,
  ChatMessage message, {
  Offset? pointer,
}) async {
  final markdown = messageMarkdown(message);
  if (markdown.trim().isEmpty) return;
  if (message.isCommand && message.delivery == DeliveryState.sending) return;
  // A long press answers with a vibration and the click sound.
  if (pointer == null) Feedback.forLongPress(context).ignore();
  // The row may be rebuilt or gone when the menu closes: read now, and
  // open later dialogs on the navigator, which outlives it.
  final snacks = AppSnacks.of(context);
  final l10n = context.l10n;
  final navigator = Navigator.of(context);
  final seeds = ref.read(composerSeedsProvider.notifier);
  final controller = ref.read(chatControllerProvider(target).notifier);
  final chat = ref.read(chatControllerProvider(target));
  // Queued or failed only: one going out could otherwise run twice.
  final unsent = message.isUser && controller.canAmend(message.id);
  final at = chat.messages.indexWhere((m) => m.id == message.id);
  final saved =
      at >= 0 && !message.isCommand && !message.isPending && !message.streaming;
  final start = saved ? Transcript.turnStart(chat.messages, at) : null;
  final idle = chat.isReady && !chat.running && chat.outbox.isEmpty;
  final reportable =
      !message.isUser && !message.isCommand && !message.streaming;
  final reporter = ref.read(replyReporterProvider);
  final reader = ref.read(readAloudProvider.notifier);
  final speakable = reportable && message.text.trim().isNotEmpty;
  final reading = ref.read(readAloudProvider)?.messageId == message.id;

  AppMenuItem<_Action> item(
    _Action action,
    IconData icon,
    String label, {
    String? hint,
    bool danger = false,
    bool enabled = true,
  }) => AppMenuItem(
    value: action,
    label: label,
    icon: icon,
    hint: hint,
    destructive: danger,
    enabled: enabled,
  );

  final action = await showAppMenu<_Action>(
    context,
    at: pointer,
    items: [
      if (unsent) ...[
        item(_Action.resend, CupertinoIcons.arrow_up, l10n.chatResend),
        item(_Action.edit, CupertinoIcons.pencil, l10n.chatEditResend),
      ],
      item(_Action.copy, CupertinoIcons.doc_on_doc, l10n.chatCopy),
      item(
        _Action.copyMarkdown,
        CupertinoIcons.chevron_left_slash_chevron_right,
        l10n.chatCopyMarkdown,
      ),
      item(_Action.quote, CupertinoIcons.quote_bubble, l10n.chatQuoteReply),
      item(_Action.share, CupertinoIcons.square_arrow_up, l10n.chatShare),
      if (speakable)
        item(
          _Action.readAloud,
          reading ? CupertinoIcons.stop_circle : CupertinoIcons.speaker_2,
          reading ? l10n.chatStopReading : l10n.chatReadAloud,
        ),
      if (saved)
        item(
          _Action.hide,
          CupertinoIcons.eye_slash,
          l10n.chatHide,
          hint: l10n.chatHideHint,
        ),
      if (start != null)
        item(
          _Action.deleteFrom,
          CupertinoIcons.trash,
          l10n.chatDeleteFrom,
          hint: idle ? l10n.chatDeleteFromHint : l10n.chatDeleteBusy,
          danger: true,
          enabled: idle,
        ),
      if (message.isCommand)
        item(
          _Action.deleteNote,
          CupertinoIcons.trash,
          l10n.chatDeleteAction,
          danger: true,
        ),
      if (reportable)
        item(
          _Action.report,
          CupertinoIcons.flag,
          l10n.chatReport,
          hint: l10n.chatReportHint,
        ),
      if (unsent)
        item(
          _Action.discard,
          CupertinoIcons.trash,
          l10n.actionDiscard,
          danger: true,
        ),
    ],
  );

  switch (action) {
    case _Action.copy || _Action.copyMarkdown:
      await snacks.copy(
        action == _Action.copy ? message.text : markdown,
        l10n.chatCopied,
      );
    case _Action.share:
      await MediaCache.shareText(markdown);
    case _Action.readAloud:
      // As the menu said: a reading that ended meanwhile is not started again.
      if (reading) return reader.stop();
      // Up while the speech is made and played; Stop there too.
      final bar = snacks.show(
        l10n.chatReadingAloud,
        duration: AppConfig.readAloudBar,
        action: SnackBarAction(
          label: l10n.chatStopReading,
          onPressed: () => unawaited(reader.stop()),
        ),
      );
      HermesFailure? failed;
      try {
        await reader.read(
          messageId: message.id,
          text: message.text,
          profile: target.profile,
        );
      } on HermesFailure catch (e) {
        failed = e;
      } finally {
        bar?.close();
      }
      if (failed != null) snacks.show(failureTextFor(l10n, failed));
    case _Action.quote:
      // Through the seed channel the share sheet uses: the composer stays
      // the one owner of its text.
      seeds.put(
        target.key,
        ComposerSeed(text: '${quoteMarkdown(markdown)}\n\n'),
      );
    case _Action.resend:
      if (!await controller.retry(message.id)) {
        snacks.show(l10n.chatAlreadySending);
      }
    case _Action.edit:
      if (!navigator.mounted) return;
      final edited = await AppSheet.show<String>(
        navigator.context,
        builder: (sheet) => TextEntrySheet(
          title: l10n.chatEditMessage,
          initial: controller.draftOf(message.id),
          submitLabel: sheet.l10n.chatResend,
          maxLines: AppConfig.maxComposerLines,
        ),
      );
      // The turn may have gone out while the sheet was open.
      if (edited != null &&
          !await controller.editAndResend(message.id, edited)) {
        snacks.show(l10n.chatAlreadySending);
      }
    case _Action.discard:
      final discarded = await controller.discard(message.id);
      snacks.show(discarded ? l10n.chatDiscarded : l10n.chatAlreadySending);
    case _Action.hide:
      final hidden = await controller.hide(message.id);
      if (hidden == null) {
        snacks.show(l10n.chatDeleteUnsaved);
        return;
      }
      snacks.show(
        l10n.chatHidden,
        action: SnackBarAction(
          label: l10n.chatUndo,
          onPressed: () => controller.show(hidden),
        ),
      );
    case _Action.deleteFrom:
      if (!navigator.mounted) return;
      final later = Transcript.turnsFrom(chat.messages, start!) - 1;
      final confirmed = await showConfirmDialog(
        navigator.context,
        title: l10n.chatDeleteFromTitle,
        body: l10n.chatDeleteFromBody(later),
        confirmLabel: l10n.chatDeleteAction,
      );
      if (!confirmed) return;
      snacks.show(switch (await controller.deleteFrom(message.id)) {
        DeleteOutcome.removed => l10n.chatDeleted,
        DeleteOutcome.busy => l10n.chatDeleteBusy,
        DeleteOutcome.unsaved => l10n.chatDeleteUnsaved,
        DeleteOutcome.failed => l10n.chatDeleteFailed,
      });
    case _Action.deleteNote:
      controller.deleteNote(message.id);
      snacks.show(l10n.chatDeleted);
    case _Action.report:
      final anchor = context.mounted ? context : navigator.context;
      if (!anchor.mounted) return;
      final reason = await showAppMenu<ReportReason>(
        anchor,
        title: l10n.chatReportTitle,
        items: [
          for (final (reason, icon, label) in [
            (
              ReportReason.harmful,
              CupertinoIcons.exclamationmark_triangle,
              l10n.chatReportHarmful,
            ),
            (
              ReportReason.hateful,
              CupertinoIcons.hand_raised,
              l10n.chatReportHateful,
            ),
            (
              ReportReason.sexual,
              CupertinoIcons.eye_slash,
              l10n.chatReportSexual,
            ),
            (
              ReportReason.misleading,
              CupertinoIcons.question_circle,
              l10n.chatReportMisleading,
            ),
            (
              ReportReason.other,
              CupertinoIcons.ellipsis_circle,
              l10n.chatReportOther,
            ),
          ])
            AppMenuItem(value: reason, label: label, icon: icon),
        ],
      );
      if (reason == null) return;
      if (!await reporter.send(reason, markdown)) {
        snacks.show(l10n.chatReportFailed(LegalConfig.reportEmail));
      }
    case null:
      break;
  }
}
