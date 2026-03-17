import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/logging/logger_mixin.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/export_format.dart';
import '../entities/import_action_classnames.dart';
import '../repositories/nutrition_repository.dart';

class ExportFoodsUsecase with LoggerMixin implements Usecase<String, ExportFoodsUsecaseParams> {
  final NutritionRepository repository;

  ExportFoodsUsecase({required this.repository});

  @override
  String get loggerName => 'Health.Domain.ExportFoodsUsecase';

  @override
  TaskEither<Failure, String> call(ExportFoodsUsecaseParams params) {
    logger.finest(
      'ExportFoodsUsecase called format=${params.format.name}, classname=${params.classname}',
    );
    if (params.classname == ImportActionClassnames.food) {
      return repository.exportFoods(params.format);
    }
    return repository.exportByClassname(
      classname: params.classname,
      format: params.format,
    );
  }
}

class ExportFoodsUsecaseParams extends Equatable {
  final ExportFormat format;
  final String classname;

  const ExportFoodsUsecaseParams({
    required this.format,
    this.classname = ImportActionClassnames.food,
  });

  @override
  List<Object?> get props => [format, classname];
}
