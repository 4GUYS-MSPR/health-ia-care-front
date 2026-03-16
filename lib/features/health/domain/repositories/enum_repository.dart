import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/enum_item.dart';

abstract class EnumRepository {
  /// Fetches a list of enum items by model [name].
  TaskEither<Failure, List<EnumItem>> getEnumValues(String name);

  /// Tries several model names and returns the first successful non-empty list.
  TaskEither<Failure, List<EnumItem>> getFirstAvailableEnumValues(List<String> modelNames);
}
