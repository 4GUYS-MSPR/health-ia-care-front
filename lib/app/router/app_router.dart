import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../../features/health/presentation/pages/nutrition_page.dart';

import '../../core/shared/layouts/main_layout.dart';
import '../../core/shared/pages/home_page.dart';
import '../../features/authentication/presentation/blocs/auth_bloc/auth_bloc.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../service_locator/service_locator.dart';
import 'app_routes.dart';
import 'protected_go_route.dart';

class AppRouter {
  GoRouter get router => _goRouter;

  final _goRouter = GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(sl<AuthBloc>().stream),
    redirect: (context, state) {
      final isAuthenticated = sl<AuthBloc>().state is AuthAuthenticatedState;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isAuthenticated && !isLoggingIn) {
        return '/login';
      }

      if (isAuthenticated && isLoggingIn) {
        return '/';
      }

      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainLayout(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              ProtectedGoRoute(
                path: '/',
                name: AppRoutes.home,
                builder: (context, state) => HomePage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        name: AppRoutes.login,
        builder: (context, state) => LoginPage(),
      ),
      GoRoute(
        path: '/nutrition',
        name: AppRoutes.nutrition,
        builder: (context, state) => NutritionPage(),
      ),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
