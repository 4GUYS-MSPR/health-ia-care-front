import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/extensions/l10n_extension.dart';
import '../core/shared/cubits/locale_cubit/locale_cubit.dart';
import '../core/shared/cubits/theme_cubit/theme_cubit.dart';
import '../core/theme/app_theme.dart';
import '../features/authentication/presentation/blocs/auth_bloc/auth_bloc.dart';
import '../l10n/generated/app_localizations.dart';
import 'router/app_router.dart';
import 'service_locator/service_locator.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<ThemeCubit>()),
        BlocProvider(create: (_) => sl<LocaleCubit>()),
        BlocProvider(create: (_) => sl<AuthBloc>()),
      ],
      child: Builder(
        builder: (context) {
          final themeMode = context.watch<ThemeCubit>().state;
          final selectedLocale = context.watch<LocaleCubit>().state;
          final appRouter = sl<AppRouter>();

          return MaterialApp.router(
            // App title
            onGenerateTitle: (context) => context.l10n.appTitle,

            // Theme related
            theme: AppTheme.lightMediumContrast,
            darkTheme: AppTheme.dark,
            highContrastTheme: AppTheme.lightHighContrast,
            highContrastDarkTheme: AppTheme.darkHighContrast,
            themeMode: themeMode,

            // l10n related
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: selectedLocale,

            // Router related
            routerConfig: appRouter.router,
          );
        },
      ),
    );
  }
}
