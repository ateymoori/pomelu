import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../domain/chat_message.dart';

/// The tool calls of one turn. One call is its own [ToolCard]; more fold
/// into one row ("Running search · 4 tools") that opens to each call, so a
/// busy turn does not push its answer down the screen.
class ToolGroup extends StatelessWidget {
  const ToolGroup({required this.tools, super.key});

  final List<ToolCall> tools;

  @override
  Widget build(BuildContext context) {
    if (tools.length == 1) {
      return ToolCard(key: ValueKey(tools.single.id), call: tools.single);
    }
    final l10n = context.l10n;
    final running = tools.where((t) => t.state == ToolState.running);
    final failed = tools.where((t) => t.state == ToolState.failed).length;
    final (state, label) = running.isNotEmpty
        ? (
            ToolState.running,
            l10n.chatToolsRunning(running.last.name, tools.length),
          )
        : failed > 0
        ? (ToolState.failed, l10n.chatToolsFailed(tools.length, failed))
        : (ToolState.done, l10n.chatToolsDone(tools.length));
    return _ToolRow(
      state: state,
      label: label,
      detail: Padding(
        padding: EdgeInsetsDirectional.only(start: context.spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final tool in tools)
              ToolCard(key: ValueKey(tool.id), call: tool),
          ],
        ),
      ),
    );
  }
}

/// One tool invocation: a compact row that opens to its output and diff.
class ToolCard extends StatelessWidget {
  const ToolCard({required this.call, super.key});

  final ToolCall call;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final spacing = context.spacing;
    final mono = context.textScale.mono(color: colors.textSecondary);
    final status = switch (call.state) {
      ToolState.running => l10n.chatToolRunning(call.name),
      ToolState.done => l10n.chatToolDone(call.name),
      ToolState.failed => l10n.chatToolFailed(call.name),
    };
    final result = call.resultText?.trimRight() ?? '';
    final diff = call.inlineDiff?.trimRight() ?? '';
    Widget wide(Widget child) =>
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: child);
    return _ToolRow(
      state: call.state,
      label: call.context.isEmpty
          ? status
          : l10n.chatJoinDot(status, call.context),
      duration: call.durationSeconds == null
          ? null
          : l10n.chatToolDuration(call.durationSeconds!.toStringAsFixed(1)),
      detail: result.isEmpty && diff.isEmpty
          ? null
          : Padding(
              padding: EdgeInsets.only(top: spacing.xs, bottom: spacing.sm),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: spacing.toolOutputMaxHeight,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    spacing: spacing.sm,
                    children: [
                      // The row cuts a long path or command; here it is whole.
                      if (call.context.isNotEmpty)
                        Text(call.context, style: mono),
                      if (result.isNotEmpty)
                        Semantics(
                          label: l10n.chatToolOutput,
                          child: wide(
                            Text(result, softWrap: false, style: mono),
                          ),
                        ),
                      if (diff.isNotEmpty)
                        wide(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final line in diff.split('\n'))
                                Text(
                                  line,
                                  softWrap: false,
                                  style: mono.copyWith(
                                    color: line.startsWith('+')
                                        ? colors.success
                                        : line.startsWith('-')
                                        ? colors.danger
                                        : colors.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

/// A text-height row with the state mark, a label and, when there is
/// something to open, a chevron. Tool rows and tool groups share its height,
/// so a turn's tools read as one list.
class _ToolRow extends StatefulWidget {
  const _ToolRow({
    required this.state,
    required this.label,
    this.duration,
    this.detail,
  });

  final ToolState state;
  final String label;
  final String? duration;
  final Widget? detail;

  @override
  State<_ToolRow> createState() => _ToolRowState();
}

class _ToolRowState extends State<_ToolRow> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final mono = context.textScale.mono(color: colors.textSecondary);
    final detail = widget.detail;
    final duration = widget.duration;
    return Padding(
      padding: EdgeInsets.only(bottom: spacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          DisclosureRow(
            open: _open,
            onToggle: detail == null
                ? null
                : () => setState(() => _open = !_open),
            children: [
              _StateIcon(state: widget.state),
              SizedBox(width: spacing.sm),
              Flexible(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: mono,
                ),
              ),
              // At large text the duration gives way, not the row.
              if (duration != null) ...[
                SizedBox(width: spacing.sm),
                Flexible(
                  child: Text(
                    duration,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: mono.copyWith(color: colors.textTertiary),
                  ),
                ),
              ],
            ],
          ),
          if (_open && detail != null) detail,
        ],
      ),
    );
  }
}

/// A spinner, a check or a cross. The row says "Running" and "failed"
/// already; only a finished call needs its mark read out.
class _StateIcon extends StatelessWidget {
  const _StateIcon({required this.state});

  final ToolState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final size = context.spacing.lg;
    return switch (state) {
      ToolState.running => const ExcludeSemantics(child: AppSpinner()),
      ToolState.done => Icon(
        CupertinoIcons.checkmark,
        size: size,
        color: colors.success,
        semanticLabel: context.l10n.chatToolStateDone,
      ),
      ToolState.failed => ExcludeSemantics(
        child: Icon(CupertinoIcons.xmark, size: size, color: colors.danger),
      ),
    };
  }
}
