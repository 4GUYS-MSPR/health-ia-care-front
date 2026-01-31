import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../cubits/login_process_cubit/login_process_cubit.dart';
import '../cubits/login_form_cubit/login_form_cubit.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginProcessCubit, LoginProcessState>(
      builder: (context, state) {
        final isLoading = state is LoginProcessLoadingState;

        final buttonStyle = ButtonStyle(
          padding: WidgetStatePropertyAll(
            .symmetric(horizontal: 64, vertical: 15),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: .circular(12),
            ),
          ),
        );

        void onPressed() {
          if (Form.of(context).validate()) {
            context.read<LoginFormCubit>().requestSubmit();
          }
        }

        return FilledButton.icon(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          icon: _ButtonIcon(),
          label: _ButtonLabel(),
        );
      },
    );
  }
}

class _ButtonIcon extends StatelessWidget {
  const _ButtonIcon();

  @override
  Widget build(BuildContext context) {
    return Icon(
      Symbols.login,
      weight: 800,
    );
  }
}

class _ButtonLabel extends StatelessWidget {
  const _ButtonLabel();

  @override
  Widget build(BuildContext context) {
    return Text(
      context.l10n.authLoginButtonLabel,
      style: TextStyle(
        fontSize: 20,
        fontWeight: .bold,
      ),
    );
  }
}
