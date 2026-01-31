import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/extensions/l10n_extension.dart';
import 'logout_dialog.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    void showLogoutDialog() {
      showDialog(
        context: context,
        builder: (context) => LogoutDialog(),
      );
    }

    return IconButton(
      onPressed: showLogoutDialog,
      icon: Icon(Symbols.logout),
      tooltip: context.l10n.authLogoutIconButtonTooltip,
    );
  }
}
