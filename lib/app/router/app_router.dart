import 'package:go_router/go_router.dart';

import '../../core/shared/pages/home_page.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import 'app_routes.dart';
import 'protected_go_route.dart';

class AppRouter {
  GoRouter get router => _goRouter;

  final _goRouter = GoRouter(
    initialLocation: '/',
    routes: [
      ProtectedGoRoute(
        path: '/',
        name: AppRoutes.home,
        builder: (context, state) => HomePage(),
      ),
      GoRoute(
        path: '/login',
        name: AppRoutes.login,
        builder: (context, state) => LoginPage(),
      ),
    ],
  );
}
