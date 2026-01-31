import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/errors/network_failures.dart';
import '../../../../core/errors/server_failures.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../domain/errors/auth_failures.dart';
import '../cubits/login_process_cubit/login_process_cubit.dart';

class LoginFailureCard extends StatelessWidget {
  const LoginFailureCard({
    super.key,
    this.dense = false,
  });

  final bool dense;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<LoginProcessCubit, LoginProcessState, Failure?>(
      selector: (state) {
        if (state is LoginProcessFailureState) {
          return state.failure;
        }
        return null;
      },
      builder: (context, failure) {
        if (failure == null) {
          return Container();
        }

        final message = _mapFailureToMessage(context, failure);

        return Card(
          color: context.colorScheme.errorContainer,
          child: ListTile(
            dense: dense,
            leading: Icon(Symbols.warning),
            title: Text(message),
            textColor: context.colorScheme.onErrorContainer,
            iconColor: context.colorScheme.onErrorContainer,
          ),
        );
      },
    );
  }

  String _mapFailureToMessage(BuildContext context, Failure failure) {
    // Map known failures to localized messages
    return switch (failure) {
      AuthInvalidCredentialsFailure() => context.l10n.authErrorInvalidCredentials,
      AuthEmptyCredentialsFailure() => context.l10n.authErrorEmptyCredentials,
      NoInternetConnectionFailure() => context.l10n.authErrorNoInternet,
      ServerUnavailableFailure() => context.l10n.authErrorServerUnavailable,
      _ => context.l10n.authErrorUnknown,
    };
  }
}
