import 'package:get_it/get_it.dart';

import '../../features/authentication/di/authentication_injection.dart';
import '../../features/health/di/health_injection.dart';
import '../../features/members/di/members_injection.dart';

Future<void> registerFeatureDependencies(GetIt sl) async {
  registerAuthenticationFeature(sl);
  registerSharedHealthDatasources(sl);
  registerNutritionFeature(sl);
  registerMembersFeature(sl);
  registerDietRecommendationFeature(sl);
  registerExerciseFeature(sl);
  registerSessionFeature(sl);
}
