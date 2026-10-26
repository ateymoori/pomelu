import 'dart:async';

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/tokens.dart';
import '../../../../core/ui/ui.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../domain/settings_form_state.dart';
import '../settings_controller.dart';
import 'settings_section.dart';

/// Sign-in affordances under the URL: password login for a gated gateway,
/// or a token field when an un-gated one hides its process token.
class GatewayAuthBlock extends ConsumerStatefulWidget {
  const GatewayAuthBlock({super.key});

  @override
  ConsumerState<GatewayAuthBlock> createState() => _GatewayAuthBlockState();
}

class _GatewayAuthBlockState extends ConsumerState<GatewayAuthBlock> {
  late final TextEditingController _username;
  late final TextEditingController _password;
  late final TextEditingController _token;

  @override
  void initState() {
    super.initState();
    final state = ref.read(settingsControllerProvider);
    _username = TextEditingController(text: state.username);
    _password = TextEditingController(text: state.password);
    _token = TextEditingController(text: state.token);
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _token.dispose();
    super.dispose();
  }

  void _sync(TextEditingController field, String value) {
    if (field.text == value) return;
    field.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settingsControllerProvider);
    ref.listen(settingsControllerProvider, (_, next) {
      _sync(_username, next.username);
      _sync(_password, next.password);
      _sync(_token, next.token);
    });

    final signIn = state.gated && !state.authUnsupported;
    final identified = state.credentialKind != CredentialKind.none;

    final rows = [
      if (signIn && identified)
        _SignedInRow(state: state)
      else if (signIn)
        ..._credentialFields(state),
      if (state.needsManualToken) _tokenField(),
    ];
    if (rows.isEmpty) return const SizedBox.shrink();
    // A card of its own under the gateway's, as iOS groups a sign-in.
    return Padding(
      padding: EdgeInsets.only(top: context.spacing.xl),
      child: FormSection(
        header: context.l10n.settingsSignInSection,
        children: rows,
      ),
    );
  }

  /// The captions are the fields' accessible names: no hints.
  List<Widget> _credentialFields(SettingsFormState state) {
    final l10n = context.l10n;
    final controller = ref.read(settingsControllerProvider.notifier);
    final ready = state.username.trim().isNotEmpty && state.password.isNotEmpty;

    return [
      SettingsField(
        label: l10n.settingsUsername,
        child: TextField(
          controller: _username,
          keyboardType: TextInputType.text,
          autocorrect: false,
          enableSuggestions: false,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.username],
          onChanged: controller.setUsername,
        ),
      ),
      SettingsField(
        label: l10n.settingsPassword,
        child: _SecretField(
          controller: _password,
          showLabel: l10n.settingsPasswordShow,
          hideLabel: l10n.settingsPasswordHide,
          autofillHints: const [AutofillHints.password],
          onChanged: controller.setPassword,
          onSubmitted: () => unawaited(_signIn()),
        ),
      ),
      FormButtonRow(
        label: state.signingIn ? l10n.settingsSigningIn : l10n.settingsSignIn,
        onPressed: ready && !state.busy ? () => unawaited(_signIn()) : null,
      ),
    ];
  }

  /// Signs in; over plain `http://` to a host on the internet the password
  /// would cross it readable, so the user confirms first.
  Future<void> _signIn() async {
    final controller = ref.read(settingsControllerProvider.notifier);
    if (ref.read(settingsControllerProvider).insecure) {
      final l10n = context.l10n;
      final go = await showConfirmDialog(
        context,
        title: l10n.settingsNotEncryptedConfirmTitle,
        body: l10n.settingsNotEncryptedConfirmBody,
        confirmLabel: l10n.settingsNotEncryptedConfirmAction,
        icon: CupertinoIcons.lock_open,
      );
      if (!go || !mounted) return;
    }
    await controller.signIn();
  }

  Widget _tokenField() {
    final l10n = context.l10n;
    final controller = ref.read(settingsControllerProvider.notifier);
    return SettingsField(
      label: l10n.settingsToken,
      child: _SecretField(
        controller: _token,
        showLabel: l10n.settingsTokenShow,
        hideLabel: l10n.settingsTokenHide,
        hintText: l10n.settingsTokenHint,
        onChanged: controller.setToken,
        onSubmitted: controller.useToken,
        action: AppIconButton(
          icon: CupertinoIcons.checkmark,
          tooltip: l10n.settingsTokenUse,
          onPressed: controller.useToken,
        ),
      ),
    );
  }
}

/// A masked text field with an eye that reveals it, and an optional
/// [action] after the eye.
class _SecretField extends StatefulWidget {
  const _SecretField({
    required this.controller,
    required this.showLabel,
    required this.hideLabel,
    required this.onChanged,
    required this.onSubmitted,
    this.autofillHints,
    this.hintText,
    this.action,
  });

  final TextEditingController controller;
  final String showLabel;
  final String hideLabel;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;
  final Iterable<String>? autofillHints;
  final String? hintText;
  final Widget? action;

  @override
  State<_SecretField> createState() => _SecretFieldState();
}

class _SecretFieldState extends State<_SecretField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    final reveal = _RevealButton(
      hidden: _hidden,
      showLabel: widget.showLabel,
      hideLabel: widget.hideLabel,
      onPressed: () => setState(() => _hidden = !_hidden),
    );
    final action = widget.action;
    return TextField(
      controller: widget.controller,
      obscureText: _hidden,
      autocorrect: false,
      enableSuggestions: false,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done,
      autofillHints: widget.autofillHints,
      onChanged: widget.onChanged,
      onSubmitted: (_) => widget.onSubmitted(),
      decoration: InputDecoration(
        hintText: widget.hintText,
        suffixIcon: action == null
            ? reveal
            : Row(mainAxisSize: MainAxisSize.min, children: [reveal, action]),
      ),
    );
  }
}

/// The eye that reveals or masks a secret field.
class _RevealButton extends StatelessWidget {
  const _RevealButton({
    required this.hidden,
    required this.showLabel,
    required this.hideLabel,
    required this.onPressed,
  });

  final bool hidden;
  final String showLabel;
  final String hideLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => AppIconButton(
    icon: hidden ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
    tooltip: hidden ? showLabel : hideLabel,
    onPressed: onPressed,
  );
}

/// "Signed in as X" (or "Session token") and sign-out.
class _SignedInRow extends ConsumerWidget {
  const _SignedInRow({required this.state});

  final SettingsFormState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final who = state.signedInAs;
    final label = who == null
        ? l10n.settingsAuthToken
        : l10n.settingsSignedInAs(who);

    return Row(
      children: [
        Expanded(
          child: SettingsInset(
            child: SettingsStatus(kind: StatusKind.ok, label: label),
          ),
        ),
        SizedBox(width: context.spacing.sm),
        TextButton(
          onPressed: state.busy
              ? null
              : () => unawaited(
                  ref.read(settingsControllerProvider.notifier).signOut(),
                ),
          child: Text(l10n.settingsSignOut),
        ),
      ],
    );
  }
}
