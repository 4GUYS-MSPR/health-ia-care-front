import 'package:go_router/go_router.dart';

import '../../core/shared/pages/home_page.dart';
import 'app_routes.dart';

class AppRouter {
  GoRouter get router => _goRouter;

  final _goRouter = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: AppRoutes.home,
        builder: (context, state) => HomePage(),
      ),
    ],
  );
}
