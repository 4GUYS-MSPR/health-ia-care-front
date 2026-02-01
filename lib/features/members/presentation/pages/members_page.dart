import 'package:flutter/material.dart';
import 'package:health_ia_care_app/core/extensions/l10n_extension.dart';
import 'package:health_ia_care_app/core/extensions/theme_extension.dart';

class MembersPage extends StatelessWidget {
  const MembersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          margin: .zero,
          child: Center(
            child: Text(
              context.l10n.navigationDestinationMembers,
              style: context.textTheme.displayLarge?.copyWith(
                fontWeight: .bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
