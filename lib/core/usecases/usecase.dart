import 'package:fpdart/fpdart.dart';

import '../errors/failures.dart';

abstract interface class Usecase<ReturnType, Params> {
  TaskEither<Failure, ReturnType> call(Params params);
}
