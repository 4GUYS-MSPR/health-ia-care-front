import 'package:go_router/go_router.dart';

import '../../features/authentication/presentation/blocs/auth_bloc/auth_bloc.dart';
import '../service_locator/service_locator.dart';

class ProtectedGoRoute extends GoRoute {
  ProtectedGoRoute({
    required super.path,
    super.name,
    super.builder,
    super.pageBuilder,
    super.parentNavigatorKey,
    super.onExit,
    super.caseSensitive,
    super.routes,
  }) : super(
         redirect: (context, state) {
           // Check Auth State
           final authBloc = sl<AuthBloc>();
           final isAuthenticated = authBloc.state is AuthAuthenticatedState;

           // If not authenticated, redirect to login
           if (!isAuthenticated) {
             return '/login';
           }

           // If authenticated, do not redirect
           return null;
         },
       );
}
