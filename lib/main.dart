import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'core/extensions/l10n_extension.dart';
import 'core/router/app_router.dart';
import 'core/service_locator/service_locator.dart';
import 'core/shared/cubits/locale_cubit/locale_cubit.dart';
import 'core/shared/cubits/theme_cubit/theme_cubit.dart';
import 'core/theme/app_theme.dart';
import 'l10n/generated/app_localizations.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await initServiceLocator();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<LocaleCubit>(),
        ),
        BlocProvider(
          create: (context) => sl<ThemeCubit>(),
        ),
      ],
      child: const MainApp(),
    ),
  );

  FlutterNativeSplash.remove();
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeMode themeMode = context.watch<ThemeCubit>().state;
    Locale? selectedLocale = context.watch<LocaleCubit>().state;
    final appRouter = sl<AppRouter>();
    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: selectedLocale,
      theme: AppTheme.lightMediumContrast,
      darkTheme: AppTheme.dark,
      highContrastTheme: AppTheme.lightHighContrast,
      highContrastDarkTheme: AppTheme.darkHighContrast,
      themeMode: themeMode,
      routerConfig: appRouter.router,
    );
  }
}
