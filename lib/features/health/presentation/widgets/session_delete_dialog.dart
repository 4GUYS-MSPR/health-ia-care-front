import 'package:flutter/material.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/theme_extension.dart';

class SessionDeleteDialog extends StatelessWidget {
  const SessionDeleteDialog({super.key});

  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const SessionDeleteDialog(),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AlertDialog(
      icon: Icon(Icons.warning_amber_rounded, color: context.colorScheme.error, size: 48),
      title: Text(l10n.sessionDeleteDialogTitle),
      content: Text(l10n.sessionDeleteDialogContent),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.sessionDeleteDialogCancelButton),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: context.colorScheme.error,
            foregroundColor: context.colorScheme.onError,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.sessionDeleteDialogConfirmButton),
        ),
      ],
    );
  }
}
