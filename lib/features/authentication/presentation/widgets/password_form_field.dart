import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../cubits/login_form_cubit/login_form_cubit.dart';

class PasswordFormField extends StatelessWidget {
  const PasswordFormField({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final isObscured = context.select(
      (LoginFormCubit cubit) => cubit.state.isObscured,
    );

    final inputDecoration = InputDecoration(
      border: OutlineInputBorder(borderRadius: .circular(12)),
      labelText: context.l10n.authPasswordFormFieldLabel,
      hintText: context.l10n.authPasswordFormFieldHint,
      prefixIcon: Icon(Symbols.password),
      suffixIcon: _ToggleVisibilityButton(),
    );

    String? validator(String? value) {
      if (value == null || value.trim().isEmpty) {
        return context.l10n.authFieldValidationPasswordRequired;
      }
      return null;
    }

    void onSubmit(_) {
      if (Form.of(context).validate()) {
        context.read<LoginFormCubit>().requestSubmit();
      }
    }

    return TextFormField(
      controller: controller,
      decoration: inputDecoration,
      obscureText: isObscured,
      autofillHints: [AutofillHints.password],
      keyboardType: .visiblePassword,
      autovalidateMode: .onUnfocus,
      validator: validator,
      textInputAction: .done,
      onFieldSubmitted: onSubmit,
    );
  }
}

class _ToggleVisibilityButton extends StatelessWidget {
  const _ToggleVisibilityButton();

  @override
  Widget build(BuildContext context) {
    final isObscured = context.select(
      (LoginFormCubit cubit) => cubit.state.isObscured,
    );

    void togglePasswordVisibility() {
      context.read<LoginFormCubit>().togglePasswordVisibility();
    }

    return Padding(
      padding: const .only(right: 4.0),
      child: IconButton(
        onPressed: togglePasswordVisibility,
        icon: Icon(
          isObscured ? Symbols.visibility : Symbols.visibility_off,
        ),
      ),
    );
  }
}
