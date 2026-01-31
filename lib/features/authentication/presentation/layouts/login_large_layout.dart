import 'package:flutter/material.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/shared/widgets/locale/locale_dropdown.dart';
import '../widgets/login_button.dart';
import '../widgets/login_failure_card.dart';
import '../widgets/login_progress_indicator.dart';
import '../widgets/password_form_field.dart';
import '../widgets/username_form_field.dart';

class LoginLargeLayout extends StatelessWidget {
  const LoginLargeLayout({
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
            child: Padding(
              padding: const .all(24.0),
              child: Row(
                spacing: 24,
                children: [
                  _DecorationBox(),
                  _AuthContainer(
                    formKey: formKey,
                    emailController: emailController,
                    passwordController: passwordController,
                    emailFormFieldKey: emailFormFieldKey,
                    passwordFormFieldKey: passwordFormFieldKey,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DecorationBox extends StatelessWidget {
  const _DecorationBox();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: .infinity,
        child: Card.outlined(
          margin: .zero,
          clipBehavior: .antiAlias,
          child: Image.asset(
            "assets/images/health_ia_care_bg.png",
            fit: .cover,
          ),
        ),
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
    return SizedBox(
      width: 600,
      height: .infinity,
      child: Card.outlined(
        color: context.colorScheme.surfaceContainer,
        margin: .zero,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Align(
                  alignment: .topRight,
                  child: LocaleDropdown(),
                ),
                _AuthContainerHeader(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: LoginFailureCard(),
                ),
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
