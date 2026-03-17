import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/errors/network_failures.dart';
import '../../../../core/logging/logger_mixin.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/export_format.dart';
import '../../domain/entities/food_import_row.dart';
import '../../domain/entities/nutrition_food.dart';
import '../../domain/errors/nutrition_failure.dart';
import '../../domain/repositories/nutrition_repository.dart';
import '../datasources/nutrition_remote_data_source.dart';
import '../models/nutrition_food_model.dart';
import '../utils/food_csv_parser.dart';

/// Repository implementation for nutrition food operations.
///
/// Coordinates network checks and remote datasource calls.
class NutritionRepositoryImpl with LoggerMixin implements NutritionRepository {
  final NutritionRemoteDataSource remoteDatasources;
  final NetworkInfo networkInfo;

  NutritionRepositoryImpl({
    required this.remoteDatasources,
    required this.networkInfo,
  });

  @override
  String get loggerName => 'Health.Data.NutritionRepository';

  /// Checks for internet connectivity.
  TaskEither<Failure, Unit> _checkInternetConnection() {
    return TaskEither.tryCatch(
      () async {
        final isConnected = await networkInfo.isConnected;
        if (!isConnected) {
          logger.warning('No internet connection');
          throw const NoInternetConnectionFailure();
        }
        return unit;
      },
      (error, _) {
        if (error is Failure) return error;
        return const NoInternetConnectionFailure();
      },
    );
  }

  @override
  TaskEither<Failure, NutritionFood> createFood(NutritionFood food) {
    logger.finest('createFood called');

    return _checkInternetConnection().flatMap(
      (_) => TaskEither.tryCatch(
        () async {
          final data = NutritionFoodModel.fromEntity(food).toMap();
          final createdFood = await remoteDatasources.createFood(
            label: data['label'],
            calories: data['calories'],
            protein: data['protein'],
            carbohydrates: data['carbohydrates'],
            fat: data['fat'],
            fiber: data['fiber'],
            sugars: data['sugars'],
            sodium: data['sodium'],
            cholesterol: data['cholesterol'],
            waterIntake: data['water_intake'],
            categoryId: data['category'],
            mealTypeId: data['meal_type'],
          );
          logger.fine('Food created with id=${createdFood.id}');
          return createdFood;
        },
        (error, stackTrace) {
          logger.severe('Failed to create food', error, stackTrace);
          if (error is Failure) return error;
          return const FoodCreationFailure(debugMessage: 'Unexpected error');
        },
      ),
    );
  }

  @override
  TaskEither<Failure, Unit> deleteFood(int id) {
    logger.finest('deleteFood called for id=$id');

    return _checkInternetConnection().flatMap(
      (_) => TaskEither.tryCatch(
        () async {
          await remoteDatasources.deleteFood(id);
          logger.fine('Food $id deleted');
          return unit;
        },
        (error, stackTrace) {
          logger.severe('Failed to delete food $id', error, stackTrace);
          if (error is Failure) return error;
          return FoodDeleteFailure(
            foodId: id,
            debugMessage: 'Unexpected error',
          );
        },
      ),
    );
  }

  @override
  TaskEither<Failure, List<NutritionFood>> getAllFoods() {
    logger.finest('getAllFoods called');

    return _checkInternetConnection().flatMap(
      (_) => TaskEither.tryCatch(
        () async {
          final foods = await remoteDatasources.getFoods();
          logger.fine('Retrieved ${foods.length} foods');
          return foods;
        },
        (error, stackTrace) {
          logger.severe('Failed to fetch foods', error, stackTrace);
          if (error is Failure) return error;
          return const FoodsFetchFailure(debugMessage: 'Unexpected error');
        },
      ),
    );
  }

  @override
  TaskEither<Failure, NutritionFood> getFood(int id) {
    logger.finest('getFood called for id=$id');

    return _checkInternetConnection().flatMap(
      (_) => TaskEither.tryCatch(
        () async {
          final food = await remoteDatasources.getFood(id);
          logger.fine('Retrieved food $id');
          return food;
        },
        (error, stackTrace) {
          logger.severe('Failed to fetch food $id', error, stackTrace);
          if (error is Failure) return error;
          return FoodNotFoundException(
            foodId: id,
            debugMessage: 'Unexpected error',
          );
        },
      ),
    );
  }

  @override
  TaskEither<Failure, NutritionFood> updateFood(int id, NutritionFood food) {
    logger.finest('updateFood called for id=$id');

    return _checkInternetConnection().flatMap(
      (_) => TaskEither.tryCatch(
        () async {
          final data = NutritionFoodModel.fromEntity(food).toMap();
          final updatedFood = await remoteDatasources.updateFood(
            id,
            label: data['label'],
            calories: data['calories'],
            protein: data['protein'],
            carbohydrates: data['carbohydrates'],
            fat: data['fat'],
            fiber: data['fiber'],
            sugars: data['sugars'],
            sodium: data['sodium'],
            cholesterol: data['cholesterol'],
            waterIntake: data['water_intake'],
            categoryId: data['category'],
            mealTypeId: data['meal_type'],
          );
          logger.fine('Food $id updated');
          return updatedFood;
        },
        (error, stackTrace) {
          logger.severe('Failed to update food $id', error, stackTrace);
          if (error is Failure) return error;
          return FoodUpdateFailure(
            foodId: id,
            debugMessage: 'Unexpected error',
          );
        },
      ),
    );
  }

  @override
  TaskEither<Failure, Unit> importFoods(List<FoodImportRow> rows) {
    logger.finest('importFoods called rows=${rows.length}');

    return _checkInternetConnection().flatMap(
      (_) => TaskEither.tryCatch(
        () async {
          if (rows.isEmpty) {
            throw const FoodValidationFailure(
              field: 'rows',
              debugMessage: 'No rows to import',
            );
          }

          final data = rows.map(foodRowToApiJson).toList();
          await remoteDatasources.importFoods(jsonEncode(data));
          logger.fine('Imported ${rows.length} row(s)');
          return unit;
        },
        (error, stackTrace) {
          logger.severe('Failed to import foods', error, stackTrace);
          if (error is Failure) return error;
          return const FoodImportFailure(debugMessage: 'Unexpected error during import');
        },
      ),
    );
  }

  @override
  TaskEither<Failure, Unit> importByClassname({
    required String classname,
    required String jsonArrayPayload,
  }) {
    logger.finest('importByClassname called classname=$classname');

    return _checkInternetConnection().flatMap(
      (_) => TaskEither.tryCatch(
        () async {
          await remoteDatasources.importByClassname(
            classname: classname,
            data: jsonArrayPayload,
          );
          logger.fine('Imported payload for classname=$classname');
          return unit;
        },
        (error, stackTrace) {
          logger.severe('Failed to import payload for classname=$classname', error, stackTrace);
          if (error is Failure) return error;
          return FoodImportFailure(
            debugMessage: 'Unexpected error during import for classname=$classname',
          );
        },
      ),
    );
  }

  @override
  TaskEither<Failure, String> exportFoods(ExportFormat format) {
    logger.finest('exportFoods called format=${format.name}');

    return _checkInternetConnection().flatMap(
      (_) => TaskEither.tryCatch(
        () async {
          final foods = await remoteDatasources.getFoods();
          if (foods.isEmpty) {
            throw const FoodExportFailure(debugMessage: 'No foods to export');
          }

          final content = switch (format) {
            ExportFormat.csv => foodsToCsv(foods),
            ExportFormat.json => foodsToJson(foods),
          };
          logger.fine('Export generated (${format.name}) for ${foods.length} food(s)');
          return content;
        },
        (error, stackTrace) {
          logger.severe('Failed to export foods', error, stackTrace);
          if (error is Failure) return error;
          return const FoodExportFailure(debugMessage: 'Unexpected error during export');
        },
      ),
    );
  }

  @override
  TaskEither<Failure, String> exportByClassname({
    required String classname,
    required ExportFormat format,
  }) {
    logger.finest('exportByClassname called classname=$classname format=${format.name}');

    return _checkInternetConnection().flatMap(
      (_) => TaskEither.tryCatch(
        () async {
          final objects = await remoteDatasources.fetchExportObjectsByClassname(
            classname: classname,
          );
          if (objects.isEmpty) {
            throw FoodExportFailure(debugMessage: 'No data to export for classname=$classname');
          }

          final content = switch (format) {
            ExportFormat.json => const JsonEncoder.withIndent('  ').convert(objects),
            ExportFormat.csv => _objectsToCsv(objects),
          };
          logger.fine(
            'Export generated (${format.name}) for classname=$classname, count=${objects.length}',
          );
          return content;
        },
        (error, stackTrace) {
          logger.severe(
            'Failed to export classname=$classname format=${format.name}',
            error,
            stackTrace,
          );
          if (error is Failure) return error;
          return FoodExportFailure(
            debugMessage: 'Unexpected error during export for classname=$classname',
          );
        },
      ),
    );
  }

  String _objectsToCsv(List<Map<String, dynamic>> objects) {
    final headers = <String>[];
    for (final item in objects) {
      for (final key in item.keys) {
        if (!headers.contains(key)) {
          headers.add(key);
        }
      }
    }

    String stringify(dynamic value) {
      if (value == null) return '';
      if (value is String || value is num || value is bool) return value.toString();
      return jsonEncode(value);
    }

    final rows = <List<dynamic>>[
      headers,
      ...objects.map(
        (item) => [for (final key in headers) stringify(item[key])],
      ),
    ];

    return const ListToCsvConverter().convert(rows);
  }
}
