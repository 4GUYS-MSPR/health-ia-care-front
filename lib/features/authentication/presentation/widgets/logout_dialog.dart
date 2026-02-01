import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../blocs/auth_bloc/auth_bloc.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.authLogoutDialogTitle),
      content: Text(context.l10n.authLogoutDialogContent),
      actions: [
        _CancelButton(),
        _ConfirmButton(),
      ],
    );
  }
}

class _CancelButton extends StatelessWidget {
  const _CancelButton();

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => context.pop(),
      child: Text(context.l10n.authLogoutDialogCancelButton),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton();

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () {
        context.read<AuthBloc>().add(AuthLogoutEvent());
        context.pop();
      },
      icon: Icon(Symbols.logout),
      label: Text(context.l10n.authLogoutDialogConfirmButton),
    );
  }
}
