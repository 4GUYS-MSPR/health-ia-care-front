import 'package:flutter/material.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/theme_extension.dart';

class ExerciseDeleteDialog extends StatelessWidget {
  const ExerciseDeleteDialog({super.key});

  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const ExerciseDeleteDialog(),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AlertDialog(
      icon: Icon(Icons.warning_amber_rounded, color: context.colorScheme.error, size: 48),
      title: Text(l10n.exerciseDeleteDialogTitle),
      content: Text(l10n.exerciseDeleteDialogContent),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.exerciseDeleteDialogCancelButton),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: context.colorScheme.error,
            foregroundColor: context.colorScheme.onError,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.exerciseDeleteDialogConfirmButton),
        ),
      ],
    );
  }
}
