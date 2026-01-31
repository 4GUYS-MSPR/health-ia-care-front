import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../../core/logging/logger_mixin.dart';

part 'login_form_state.dart';

/// Cubit for managing login form UI state (password visibility).
class LoginFormCubit extends Cubit<LoginFormState> with LoggerMixin {
  LoginFormCubit() : super(const LoginFormState()) {
    logger.finest('LoginFormCubit initialized');
    logger.fine('Initial isObscured=${state.isObscured}');
  }

  @override
  String get loggerName => 'Authentication.Presentation.LoginFormCubit';

  void togglePasswordVisibility() {
    logger.finest('togglePasswordVisibility called');
    final newValue = !state.isObscured;
    emit(
      state.copyWith(
        isObscured: newValue,
      ),
    );
    logger.fine('Password visibility set to ${newValue ? 'obscured' : 'visible'}');
  }

  /// Request a submit signal. The UI listener will use the form key and
  /// controllers to validate and actually trigger the login process.
  void requestSubmit() {
    logger.finest('requestSubmit called');
    emit(state.copyWith(submitRequested: true));
  }

  /// Clear the submit flag after it has been handled by the UI.
  void clearSubmission() {
    emit(state.copyWith(submitRequested: false));
  }
}
