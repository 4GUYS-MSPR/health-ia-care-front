part of 'login_form_cubit.dart';

/// State for login form UI (password visibility).
class LoginFormState extends Equatable {
  const LoginFormState({
    this.isObscured = true,
    this.submitRequested = false,
  });

  final bool isObscured;
  final bool submitRequested;

  @override
  List<Object> get props => [isObscured, submitRequested];

  LoginFormState copyWith({
    bool? isObscured,
    bool? submitRequested,
  }) {
    return LoginFormState(
      isObscured: isObscured ?? this.isObscured,
      submitRequested: submitRequested ?? this.submitRequested,
    );
  }
}
