import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../cubits/theme_cubit/theme_cubit.dart';

class ThemeToggleWidget extends StatelessWidget {
  const ThemeToggleWidget({super.key});

  Brightness _getPlatformBrightness(BuildContext context) =>
      context.watch<ThemeCubit>().systemBrightness;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => context.read<ThemeCubit>().toggleThemeMode(),
      icon: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          var iconDark = Icon(Symbols.dark_mode, fill: 1);
          var iconLight = Icon(Symbols.light_mode, fill: 1);

          switch (themeMode) {
            case ThemeMode.system:
              switch (_getPlatformBrightness(context)) {
                case Brightness.dark:
                  return iconLight;
                case Brightness.light:
                  return iconDark;
              }
            case ThemeMode.light:
              return iconDark;
            case ThemeMode.dark:
              return iconLight;
          }
        },
      ),
    );
  }
}
