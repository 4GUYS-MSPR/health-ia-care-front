import 'package:flutter/material.dart';

import '../../extensions/l10n_extension.dart';

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
