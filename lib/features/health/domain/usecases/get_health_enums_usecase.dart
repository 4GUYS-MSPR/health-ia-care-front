import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/enum_item.dart';
import '../repositories/enum_repository.dart';

class GetHealthEnumsUsecase implements Usecase<List<EnumItem>, GetHealthEnumsParams> {
  final EnumRepository repository;

  GetHealthEnumsUsecase({required this.repository});

  @override
  TaskEither<Failure, List<EnumItem>> call(GetHealthEnumsParams params) {
    if (params.modelNames != null) {
      return repository.getFirstAvailableEnumValues(params.modelNames!);
    }
    return repository.getEnumValues(params.name!);
  }
}

class GetHealthEnumsParams {
  final String? name;
  final List<String>? modelNames;

  const GetHealthEnumsParams.byName(String this.name) : modelNames = null;
  const GetHealthEnumsParams.byNames(List<String> this.modelNames) : name = null;
}
