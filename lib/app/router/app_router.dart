import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../../core/usecases/no_params.dart';
import '../../features/health/domain/entities/exercise.dart';
import '../../features/health/presentation/blocs/exercises_bloc.dart';
import '../../features/health/presentation/blocs/foods_bloc.dart';
import '../../features/health/presentation/blocs/diet_recommendations_bloc.dart';
import '../../features/health/presentation/blocs/sessions_bloc.dart';
import '../../features/health/presentation/pages/diet_recommendations_page.dart';
import '../../features/health/presentation/pages/exercises_page.dart';
import '../../features/health/presentation/pages/nutrition_page.dart';
import '../../features/health/presentation/pages/sessions_page.dart';
import '../../features/health/domain/entities/enum_item.dart';
import '../../features/health/domain/usecases/get_health_enums_usecase.dart';
import '../../features/health/domain/usecases/get_all_exercises_usecase.dart' as exercise_usecase;
import '../../features/members/domain/entities/member.dart';
import '../../features/members/domain/usecases/get_all_members_usecase.dart' as member_usecase;
import '../../features/members/domain/entities/objective.dart';
import '../../features/members/data/models/enum_item_model.dart' as member_enum;
import '../../features/members/presentation/bloc/members_bloc.dart';
import '../../features/members/presentation/pages/members_page.dart';

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
      GoRoute(path: '/', redirect: (context, state) => '/home'),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainLayout(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              ProtectedGoRoute(
                path: '/home',
                name: AppRoutes.home,
                builder: (context, state) => HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              ProtectedGoRoute(
                path: '/members',
                name: AppRoutes.members,
                builder: (context, state) => MembersPage(
                  createBloc: () => sl<MembersBloc>(),
                  loadObjectiveOptions: () async {
                    final result = await sl<GetHealthEnumsUsecase>()(
                      const GetHealthEnumsParams.byName('Objective'),
                    ).run();

                    final enumItems = result.match(
                      (_) => const <EnumItem>[],
                      (items) => items,
                    );

                    return enumItems
                        .map(
                          (option) => Objective(
                            id: option.id,
                            description: option.value,
                            createdAt: option.createdAt ?? DateTime.now(),
                          ),
                        )
                        .toList(growable: false);
                  },
                  loadGenderOptions: () async {
                    final result = await sl<GetHealthEnumsUsecase>()(
                      const GetHealthEnumsParams.byName('Gender'),
                    ).run();
                    return result.match(
                      (_) => const <member_enum.EnumItemModel>[],
                      (items) => items
                          .map((e) => member_enum.EnumItemModel(id: e.id, value: e.value))
                          .toList(growable: false),
                    );
                  },
                  loadLevelOptions: () async {
                    final result = await sl<GetHealthEnumsUsecase>()(
                      const GetHealthEnumsParams.byName('Level'),
                    ).run();
                    return result.match(
                      (_) => const <member_enum.EnumItemModel>[],
                      (items) => items
                          .map((e) => member_enum.EnumItemModel(id: e.id, value: e.value))
                          .toList(growable: false),
                    );
                  },
                  loadSubscriptionOptions: () async {
                    final result = await sl<GetHealthEnumsUsecase>()(
                      const GetHealthEnumsParams.byName('Subscription'),
                    ).run();
                    return result.match(
                      (_) => const <member_enum.EnumItemModel>[],
                      (items) => items
                          .map((e) => member_enum.EnumItemModel(id: e.id, value: e.value))
                          .toList(growable: false),
                    );
                  },
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              ProtectedGoRoute(
                path: '/nutrition',
                name: AppRoutes.nutrition,
                builder: (context, state) => NutritionPage(
                  createBloc: () => sl<FoodsBloc>(),
                  loadEnumByCandidates: (candidates) async {
                    final result = await sl<GetHealthEnumsUsecase>()(
                      GetHealthEnumsParams.byNames(candidates),
                    ).run();

                    return result.match(
                      (_) => const <EnumItem>[],
                      (items) => items,
                    );
                  },
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              ProtectedGoRoute(
                path: '/exercises',
                name: AppRoutes.exercises,
                builder: (context, state) => ExercisesPage(
                  createBloc: () => sl<ExercisesBloc>(),
                  loadEnumByCandidates: (candidates) async {
                    final result = await sl<GetHealthEnumsUsecase>()(
                      GetHealthEnumsParams.byNames(candidates),
                    ).run();

                    return result.match(
                      (_) => const <EnumItem>[],
                      (items) => items,
                    );
                  },
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              ProtectedGoRoute(
                path: '/diet-recommendations',
                name: AppRoutes.dietRecommendations,
                builder: (context, state) => DietRecommendationsPage(
                  createBloc: () => sl<DietRecommendationsBloc>(),
                  loadMembers: () async {
                    final result = await sl<member_usecase.GetAllMembersUsecase>()
                        .call(const member_usecase.NoParams())
                        .run();
                    return result.getOrElse((_) => const <Member>[]);
                  },
                  loadEnumByName: (name) async {
                    final result = await sl<GetHealthEnumsUsecase>()(
                      GetHealthEnumsParams.byName(name),
                    ).run();

                    return result.match(
                      (_) => const <EnumItem>[],
                      (items) => items,
                    );
                  },
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              ProtectedGoRoute(
                path: '/sessions',
                name: AppRoutes.sessions,
                builder: (context, state) => SessionsPage(
                  createBloc: () => sl<SessionsBloc>(),
                  loadMembers: () async {
                    final result = await sl<member_usecase.GetAllMembersUsecase>()
                        .call(const member_usecase.NoParams())
                        .run();
                    return result.getOrElse((_) => const <Member>[]);
                  },
                  loadExercises: () async {
                    final result = await sl<exercise_usecase.GetAllExercisesUsecase>()
                        .call(NoParams())
                        .run();
                    return result.getOrElse((_) => const <Exercise>[]);
                  },
                ),
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
