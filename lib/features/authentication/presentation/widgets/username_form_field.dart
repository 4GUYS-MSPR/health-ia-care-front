import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/extensions/l10n_extension.dart';

class UsernameFormField extends StatelessWidget {
  final TextEditingController controller;

  const UsernameFormField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final inputDecoration = InputDecoration(
      border: OutlineInputBorder(borderRadius: .circular(12)),
      labelText: context.l10n.authUsernameFormFieldLabel,
      hintText: context.l10n.authUsernameFormFieldHint,
      prefixIcon: Icon(Symbols.person),
    );

    String? validator(String? value) {
      if (value == null || value.trim().isEmpty) {
        return context.l10n.authFieldValidationPasswordRequired;
      }
      return null;
    }

    return TextFormField(
      controller: controller,
      decoration: inputDecoration,
      autofillHints: [AutofillHints.email],
      keyboardType: .emailAddress,
      autovalidateMode: .onUnfocus,
      validator: validator,
      textInputAction: .next,
    );
  }
}
