import 'package:get_it/get_it.dart';

import '../../features/authentication/di/authentication_injection.dart';

Future<void> registerFeatureDependencies(GetIt sl) async {
  registerAuthenticationFeature(sl);
}
