import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../../core/logging/logger_mixin.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/usecases/restore_user_usecase.dart';
import '../../../domain/usecases/logout_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Bloc for managing global authentication state (authenticated/unauthenticated).
///
/// Responsibilities:
/// - Restore any cached user on creation
/// - Emit authenticated/unauthenticated states for the UI
/// - Handle logout flows
class AuthBloc extends Bloc<AuthEvent, AuthState> with LoggerMixin {
  final LogoutUsecase logoutUsecase;
  final RestoreUserUsecase restoreUserUsecase;

  AuthBloc({
    required this.logoutUsecase,
    required this.restoreUserUsecase,
  }) : super(AuthInitialState()) {
    on<AuthRestoreUserEvent>(_onRestoreUserEvent);
    on<AuthSetAuthenticatedEvent>(_onSetAuthenticatedEvent);
    on<AuthLogoutEvent>(_onLogoutEvent);

    logger.finest('AuthBloc initialized');
    logger.fine('Requesting initial user restore');
    add(AuthRestoreUserEvent());
  }

  @override
  String get loggerName => 'Authentication.Presentation.AuthBloc';

  void _onSetAuthenticatedEvent(
    AuthSetAuthenticatedEvent event,
    Emitter<AuthState> emit,
  ) {
    logger.finer('Setting authenticated state for ${event.user.email}');
    emit(AuthAuthenticatedState(user: event.user));
    logger.fine('State -> authenticated');
  }

  Future<void> _onLogoutEvent(
    AuthLogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    logger.finest('Logout requested');
    logger.fine('Calling logout usecase');

    final res = await logoutUsecase().run();

    res.fold(
      (l) {
        logger.severe('Logout failed: $l');
      },
      (r) {
        emit(AuthUnauthenticatedState());
        logger.fine('State -> unauthenticated');
      },
    );
  }

  Future<void> _onRestoreUserEvent(
    AuthRestoreUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    logger.finest('Restore user requested');
    logger.fine('Calling restoreUser usecase');

    final res = await restoreUserUsecase().run();

    res.fold(
      (l) {
        logger.severe('Failed to restore user: $l');
        emit(AuthUnauthenticatedState());
      },
      (user) {
        if (user != null) {
          emit(AuthAuthenticatedState(user: user));
          logger.fine('State -> authenticated for ${user.email}');
        } else {
          emit(AuthUnauthenticatedState());
          logger.fine('State -> unauthenticated (no user)');
        }
      },
    );
  }
}
