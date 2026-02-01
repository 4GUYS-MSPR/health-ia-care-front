import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/shared/cubits/locale_cubit/locale_cubit.dart';
import '../../../../core/shared/cubits/theme_cubit/theme_cubit.dart';
import '../../../../core/utils/locale_utils.dart';
import '../../domain/entities/user.dart';
import '../blocs/auth_bloc/auth_bloc.dart';

class AccountMenuButton extends StatelessWidget {
  const AccountMenuButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AuthBloc, AuthState, User?>(
      selector: (state) {
        if (state is AuthAuthenticatedState) {
          return state.user;
        }
        return null;
      },
      builder: (context, user) {
        if (user == null) {
          return _LoggedOutAccountButton();
        }

        return _AccountMenuAnchor(user: user);
      },
    );
  }
}

class _AccountMenuAnchor extends StatelessWidget {
  const _AccountMenuAnchor({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final menuStyle = MenuStyle(
      padding: .all(.all(16)),
      side: WidgetStatePropertyAll(
        BorderSide(width: 1, color: context.colorScheme.outlineVariant),
      ),
    );

    return MenuAnchor(
      builder: (context, controller, child) {
        return _MenuAvatarButton(
          controller: controller,
          user: user,
        );
      },
      style: menuStyle,
      alignmentOffset: Offset(0, 8),
      menuChildren: [
        _MenuHeader(user: user),
        PopupMenuDivider(),
        _ThemeSubmenuButton(),
        _LocaleSubmenuButton(),
        PopupMenuDivider(),
        _LogoutButton(),
      ],
    );
  }
}

class _MenuAvatarButton extends StatelessWidget {
  const _MenuAvatarButton({
    required this.user,
    required this.controller,
  });

  final User user;
  final MenuController controller;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        if (controller.isOpen) {
          controller.close();
        } else {
          controller.open();
        }
      },
      icon: CircleAvatar(
        child: Text(user.username.substring(0, 1)),
      ),
    );
  }
}

class _MenuHeader extends StatelessWidget {
  const _MenuHeader({
    required this.user,
  });

  final User user;

  @override
  Widget build(BuildContext context) {
    return MenuItemButton(
      onPressed: null,
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(
            user.username,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: .bold,
            ),
          ),
          if (user.email.isNotEmpty)
            Text(
              user.email,
              style: context.textTheme.labelLarge,
            ),
        ],
      ),
    );
  }
}

class _ThemeSubmenuButton extends StatelessWidget {
  const _ThemeSubmenuButton();

  @override
  Widget build(BuildContext context) {
    return SubmenuButton(
      menuChildren: [
        RadioGroup<ThemeMode>(
          groupValue: context.watch<ThemeCubit>().state,
          onChanged: (value) {
            if (value != null) {
              context.read<ThemeCubit>().selectThemeMode(value);
            }
          },
          child: Column(
            children: List.generate(
              ThemeMode.values.length,
              (index) {
                final themeMode = ThemeMode.values[index];
                return MenuItemButton(
                  child: RadioListTile<ThemeMode>(
                    dense: true,
                    value: themeMode,
                    title: Text(switch (themeMode) {
                      ThemeMode.dark => context.l10n.accountMenuThemeDark,
                      ThemeMode.light => context.l10n.accountMenuThemeLight,
                      ThemeMode.system => context.l10n.accountMenuThemeSystem,
                    }),
                  ),
                );
              },
            ),
          ),
        ),
      ],
      leadingIcon: const Icon(Symbols.routine),
      child: Text(context.l10n.accountMenuThemeLabel),
    );
  }
}

class _LocaleSubmenuButton extends StatelessWidget {
  const _LocaleSubmenuButton();

  @override
  Widget build(BuildContext context) {
    return SubmenuButton(
      menuChildren: [
        RadioGroup<Locale>(
          groupValue: context.watch<LocaleCubit>().state,
          onChanged: (value) {
            if (value != null) {
              context.read<LocaleCubit>().setLocale(value);
            }
          },
          child: Column(
            children: List.generate(
              LocaleUtils.supportedLocales.length,
              (index) {
                final locale = LocaleUtils.supportedLocales[index];
                return MenuItemButton(
                  child: RadioListTile(
                    dense: true,
                    value: locale,
                    title: Text(LocaleUtils.getLanguageNativeName(locale)),
                  ),
                );
              },
            ),
          ),
        ),
      ],
      leadingIcon: const Icon(Symbols.language),
      child: Text(context.l10n.accountMenuLanguageLabel),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    return MenuItemButton(
      onPressed: () {
        authBloc.add(AuthLogoutEvent());
      },
      style: ButtonStyle(
        iconColor: WidgetStatePropertyAll(context.colorScheme.error),
        foregroundColor: WidgetStatePropertyAll(context.colorScheme.error),
      ),
      leadingIcon: const Icon(Symbols.logout),
      child: Text(context.l10n.accountMenuLogoutLabel),
    );
  }
}

class _LoggedOutAccountButton extends StatelessWidget {
  const _LoggedOutAccountButton();

  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    return IconButton(
      tooltip: context.l10n.authLogoutIconButtonTooltip,
      onPressed: () => authBloc.add(AuthLogoutEvent()),
      icon: CircleAvatar(
        child: Icon(Symbols.lock),
      ),
    );
  }
}
