import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/extensions/l10n_extension.dart';
import 'core/service_locator/service_locator.dart';
import 'core/shared/cubits/locale_cubit/locale_cubit.dart';
import 'l10n/generated/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initServiceLocator();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<LocaleCubit>(),
        ),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    Locale? selectedLocale = context.watch<LocaleCubit>().state;
    return MaterialApp(
      onGenerateTitle: (context) => context.l10n.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: selectedLocale,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(context.l10n.helloWorld),
      ),
    );
  }
}
