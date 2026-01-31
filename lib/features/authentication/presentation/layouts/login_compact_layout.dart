import 'package:flutter/material.dart';
import 'package:health_ia_care_app/core/extensions/theme_extension.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../widgets/username_form_field.dart';
import '../widgets/login_button.dart';
import '../widgets/login_progress_indicator.dart';
import '../widgets/login_failure_card.dart';
import '../widgets/password_form_field.dart';

class LoginCompactLayout extends StatelessWidget {
  const LoginCompactLayout({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.emailFormFieldKey,
    required this.passwordFormFieldKey,
  });

  // Keys
  final GlobalKey<FormState> formKey;
  final GlobalKey emailFormFieldKey;
  final GlobalKey passwordFormFieldKey;

  // Controllers
  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          LoginProgressIndicator(),
          Expanded(
            child: _AuthContainer(
              formKey: formKey,
              emailController: emailController,
              passwordController: passwordController,
              emailFormFieldKey: emailFormFieldKey,
              passwordFormFieldKey: passwordFormFieldKey,
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthContainer extends StatelessWidget {
  const _AuthContainer({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.emailFormFieldKey,
    required this.passwordFormFieldKey,
  });

  // Keys
  final GlobalKey<FormState> formKey;
  final GlobalKey emailFormFieldKey;
  final GlobalKey passwordFormFieldKey;

  // Controllers
  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: .all(16),
        child: Column(
          children: [
            _AuthContainerHeader(),
            const SizedBox(height: 16),
            LoginFailureCard(dense: true),
            const SizedBox(height: 16),
            _AuthForm(
              formKey: formKey,
              emailController: emailController,
              passwordController: passwordController,
              emailFormFieldKey: emailFormFieldKey,
              passwordFormFieldKey: passwordFormFieldKey,
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthContainerHeader extends StatelessWidget {
  const _AuthContainerHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      spacing: 8,
      children: [
        Text(
          context.l10n.authLoginPageTitle,
          style: context.textTheme.displayLarge?.copyWith(
            fontWeight: .bold,
          ),
        ),
        Text(
          context.l10n.authLoginPageDescription,
          style: context.textTheme.labelLarge?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _AuthForm extends StatelessWidget {
  const _AuthForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.emailFormFieldKey,
    required this.passwordFormFieldKey,
  });

  // Keys
  final GlobalKey<FormState> formKey;
  final GlobalKey emailFormFieldKey;
  final GlobalKey passwordFormFieldKey;

  // Controllers
  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: .end,
          children: [
            UsernameFormField(
              key: emailFormFieldKey,
              controller: emailController,
            ),
            SizedBox(height: 12),
            PasswordFormField(
              key: passwordFormFieldKey,
              controller: passwordController,
            ),
            SizedBox(height: 24),
            LoginButton(),
          ],
        ),
      ),
    );
  }
}
