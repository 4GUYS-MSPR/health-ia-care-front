import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/logging/logger_mixin.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/food_import_row.dart';
import '../entities/import_action_classnames.dart';
import '../errors/nutrition_failure.dart';
import '../repositories/nutrition_repository.dart';

class ImportFoodsUsecase with LoggerMixin implements Usecase<Unit, ImportFoodsUsecaseParams> {
  final NutritionRepository repository;

  ImportFoodsUsecase({required this.repository});

  @override
  String get loggerName => 'Health.Domain.ImportFoodsUsecase';

  @override
  TaskEither<Failure, Unit> call(ImportFoodsUsecaseParams params) {
    logger.finest(
      'ImportFoodsUsecase called rows=${params.rows.length}, classname=${params.classname}',
    );

    if (params.rows.isEmpty && params.jsonArrayPayloadOverride == null) {
      return TaskEither.left(
        const FoodValidationFailure(
          field: 'rows',
          debugMessage: 'No rows to import',
        ),
      );
    }

    if (
        params.classname == ImportFoodsUsecaseParams.foodActionClassname &&
        params.rows.any((row) => row.hasErrors)) {
      return TaskEither.left(
        const FoodValidationFailure(
          field: 'rows',
          debugMessage: 'Rows with errors cannot be imported',
        ),
      );
    }

    if (params.classname == ImportFoodsUsecaseParams.foodActionClassname) {
      return repository.importFoods(params.rows);
    }

    if (params.jsonArrayPayloadOverride != null) {
      return repository.importByClassname(
        classname: params.classname,
        jsonArrayPayload: params.jsonArrayPayloadOverride!,
      );
    }

    final payload = params.rows
        .map(
          (row) => {
            'label': row.label,
            'calories': row.calories,
            'protein': row.protein,
            'carbohydrates': row.carbohydrates,
            'fat': row.fat,
            'fiber': row.fiber,
            'sugars': row.sugars,
            'sodium': row.sodium,
            'cholesterol': row.cholesterol,
            'water_intake': row.waterIntake,
            'category': row.category,
            'meal_type': row.mealType,
          },
        )
        .toList();

    return repository.importByClassname(
      classname: params.classname,
      jsonArrayPayload: jsonEncode(payload),
    );
  }
}

class ImportFoodsUsecaseParams extends Equatable {
  static const foodActionClassname = ImportActionClassnames.food;

  final List<FoodImportRow> rows;
  final String classname;
  final String? jsonArrayPayloadOverride;

  const ImportFoodsUsecaseParams({
    required this.rows,
    this.classname = foodActionClassname,
    this.jsonArrayPayloadOverride,
  });

  @override
  List<Object?> get props => [rows, classname, jsonArrayPayloadOverride];
}
