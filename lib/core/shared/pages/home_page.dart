import 'package:flutter/material.dart';

import '../../extensions/l10n_extension.dart';
import '../../extensions/theme_extension.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Card.outlined(
            color: context.colorScheme.surfaceContainer,
            margin: .zero,
            clipBehavior: .antiAlias,
            child: Center(
              child: Text(
                context.l10n.helloWorld,
                style: context.textTheme.displayLarge?.copyWith(
                  letterSpacing: 16,
                  fontWeight: .bold,
                  decoration: .combine([.overline, .underline]),
                  decorationColor: context.colorScheme.outline,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
