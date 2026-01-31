import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:health_ia_care_app/app/router/app_routes.dart';
import 'package:health_ia_care_app/features/authentication/presentation/layouts/login_large_layout.dart';

import '../../../../app/service_locator/service_locator.dart';
import '../../../../core/shared/layouts/responsive_layout_builder.dart';
import '../blocs/auth_bloc/auth_bloc.dart';
import '../cubits/login_form_cubit/login_form_cubit.dart';
import '../cubits/login_process_cubit/login_process_cubit.dart';
import '../layouts/login_compact_layout.dart';
import '../layouts/login_medium_layout.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Keys
  final _formKey = GlobalKey<FormState>();
  final _emailFormFieldKey = GlobalKey();
  final _passwordFormFieldKey = GlobalKey();

  // Controllers
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    // Init controllers
    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    // Dispose controllers
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<LoginProcessCubit>()),
        BlocProvider(create: (_) => sl<LoginFormCubit>()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthAuthenticatedState) {
                context.goNamed(AppRoutes.home);
              }
            },
          ),
          // When login succeeds, notify AuthBloc
          BlocListener<LoginProcessCubit, LoginProcessState>(
            listener: (context, state) {
              if (state is LoginProcessSuccessState) {
                context.read<AuthBloc>().add(
                  AuthSetAuthenticatedEvent(user: state.user),
                );
              }
            },
          ),
          // When the form cubit requests a submit, validate using the
          // form key + controllers and trigger the login process.
          BlocListener<LoginFormCubit, LoginFormState>(
            listener: (context, state) {
              if (state.submitRequested) {
                if (_formKey.currentState!.validate()) {
                  context.read<LoginProcessCubit>().login(
                    email: _emailController.text,
                    password: _passwordController.text,
                  );
                }
                // Clear the flag so it doesn't retrigger
                context.read<LoginFormCubit>().clearSubmission();
              }
            },
          ),
        ],
        child: ResponsiveLayoutBuilder(
          compact: LoginCompactLayout(
            formKey: _formKey,
            emailController: _emailController,
            passwordController: _passwordController,
            emailFormFieldKey: _emailFormFieldKey,
            passwordFormFieldKey: _passwordFormFieldKey,
          ),
          medium: LoginMediumLayout(
            formKey: _formKey,
            emailController: _emailController,
            passwordController: _passwordController,
            emailFormFieldKey: _emailFormFieldKey,
            passwordFormFieldKey: _passwordFormFieldKey,
          ),
          large: LoginLargeLayout(
            formKey: _formKey,
            emailController: _emailController,
            passwordController: _passwordController,
            emailFormFieldKey: _emailFormFieldKey,
            passwordFormFieldKey: _passwordFormFieldKey,
          ),
        ),
      ),
    );
  }
}
