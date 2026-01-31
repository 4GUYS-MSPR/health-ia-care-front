import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/locale_utils.dart';
import '../../cubits/locale_cubit/locale_cubit.dart';

class LocaleDropdown extends StatelessWidget {
  const LocaleDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale?>(
      builder: (context, currentLocale) {
        return DropdownButton(
          value: currentLocale,
          items: LocaleUtils.supportedLocales
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e.languageCode.toUpperCase()),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              context.read<LocaleCubit>().setLocale(value);
            }
          },
        );
      },
    );
  }
}
