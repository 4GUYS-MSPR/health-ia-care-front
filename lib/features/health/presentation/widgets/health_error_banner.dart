import 'package:flutter/material.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/theme_extension.dart';

class HealthErrorBanner extends StatelessWidget {
  const HealthErrorBanner({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return MaterialBanner(
      content: Text(message),
      leading: Icon(
        Icons.error_outline,
        color: context.colorScheme.error,
      ),
      backgroundColor: context.colorScheme.errorContainer,
      actions: [
        TextButton(
          onPressed: onRetry,
          child: Text(context.l10n.membersRetryButton),
        ),
      ],
    );
  }
}
