import 'dart:convert';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';

import '../../data/utils/food_csv_parser.dart';
import '../../../../core/logging/logger_mixin.dart';
import '../../domain/entities/export_format.dart';
import '../../domain/entities/food_import_row.dart';
import '../../domain/entities/import_action_classnames.dart';
import '../../domain/usecases/export_foods_usecase.dart';
import '../../domain/usecases/import_foods_usecase.dart';

part 'food_import_event.dart';
part 'food_import_state.dart';

/// Bloc responsible for food import/export workflow.
class FoodImportBloc extends Bloc<FoodImportEvent, FoodImportState> with LoggerMixin {
  final ImportFoodsUsecase importFoodsUsecase;
  final ExportFoodsUsecase exportFoodsUsecase;

  FoodImportBloc({
    required this.importFoodsUsecase,
    required this.exportFoodsUsecase,
  }) : super(const FoodImportInitial()) {
    on<PickFileRequested>(_onPickFile);
    on<UpdateRowRequested>(_onUpdateRow);
    on<DeleteRowRequested>(_onDeleteRow);
    on<ConfirmImportRequested>(_onConfirmImport);
    on<CancelImportRequested>(_onCancelImport);
    on<ExportFoodsRequested>(_onExportFoods);
  }

  @override
  String get loggerName => 'Health.Presentation.FoodImportBloc';

  Future<void> _onPickFile(
    PickFileRequested event,
    Emitter<FoodImportState> emit,
  ) async {
    logger.finest('PickFileRequested received');
    emit(const FoodImportParsing());

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'json'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        logger.fine('File picking cancelled');
        emit(const FoodImportInitial());
        return;
      }

      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null) {
        logger.warning('File bytes are null');
        emit(const FoodImportError(message: 'Could not read file content'));
        return;
      }

      final content = utf8.decode(bytes, allowMalformed: true);
      final extension = file.extension?.toLowerCase() ?? '';

      if (event.classname != ImportActionClassnames.food) {
        final genericResult = extension == 'json'
          ? parseGenericJsonToJsonObjects(content, classname: event.classname)
          : parseGenericCsvToJsonObjects(content, classname: event.classname);

        if (genericResult.items.isEmpty) {
          final msg = genericResult.warnings.isNotEmpty
              ? genericResult.warnings.join('; ')
              : 'No data found in file';
          logger.warning('Generic parse resulted in 0 rows: $msg');
          emit(FoodImportError(message: msg));
          return;
        }

        final previewRows = buildGenericPreviewRows(
          genericResult.items,
          classname: event.classname,
        );
        emit(
          FoodImportPreview(
            rows: previewRows,
            fileName: file.name,
            classname: event.classname,
            jsonArrayPayload: jsonEncode(genericResult.items),
            warnings: [
              ...genericResult.warnings,
              'Preview is simplified for this import type; payload will be sent as parsed.',
            ],
            missingHeaders: genericResult.missingHeaders,
          ),
        );
        return;
      }

      CsvParseResult parseResult;
      if (extension == 'json') {
        parseResult = parseFoodJson(content);
      } else {
        parseResult = parseFoodCsv(content);
      }

      if (parseResult.rows.isEmpty) {
        final msg = parseResult.warnings.isNotEmpty
            ? parseResult.warnings.join('; ')
            : 'No data found in file';
        logger.warning('Parse resulted in 0 rows: $msg');
        emit(FoodImportError(message: msg));
        return;
      }

      logger.fine(
        'Parsed ${parseResult.rows.length} rows '
        '(${parseResult.validCount} valid, ${parseResult.errorCount} with errors)',
      );

      emit(
        FoodImportPreview(
          rows: parseResult.rows,
          fileName: file.name,
          classname: event.classname,
          warnings: parseResult.warnings,
          missingHeaders: parseResult.missingHeaders,
        ),
      );
    } catch (e, st) {
      logger.severe('Error picking/parsing file', e, st);
      emit(FoodImportError(message: 'Failed to parse file: $e'));
    }
  }

  void _onUpdateRow(
    UpdateRowRequested event,
    Emitter<FoodImportState> emit,
  ) {
    final currentState = state;
    if (currentState is! FoodImportPreview) return;

    if (currentState.classname != ImportActionClassnames.food) {
      logger.warning('Row editing is not supported for classname=${currentState.classname}');
      return;
    }

    logger.finest('UpdateRowRequested for row index=${event.updatedRow.index}');

    final revalidated = validateFoodImportRow(event.updatedRow);
    final updatedRows = currentState.rows.map((r) {
      return r.index == revalidated.index ? revalidated : r;
    }).toList();

    emit(currentState.copyWith(rows: updatedRows));
  }

  void _onDeleteRow(
    DeleteRowRequested event,
    Emitter<FoodImportState> emit,
  ) {
    final currentState = state;
    if (currentState is! FoodImportPreview) return;

    if (currentState.classname != ImportActionClassnames.food) {
      logger.warning('Row deletion is not supported for classname=${currentState.classname}');
      return;
    }

    logger.finest('DeleteRowRequested for row index=${event.rowIndex}');

    final updatedRows = currentState.rows.where((r) => r.index != event.rowIndex).toList();

    if (updatedRows.isEmpty) {
      emit(const FoodImportInitial());
      return;
    }

    emit(currentState.copyWith(rows: updatedRows));
  }

  Future<void> _onConfirmImport(
    ConfirmImportRequested event,
    Emitter<FoodImportState> emit,
  ) async {
    final currentState = state;
    if (currentState is! FoodImportPreview) return;

    final isFoodImport = currentState.classname == ImportActionClassnames.food;
    final validRows = isFoodImport
      ? currentState.rows.where((r) => r.isValid).toList()
      : currentState.rows;

    if (validRows.isEmpty) {
      logger.warning('No valid rows to import');
      emit(const FoodImportError(message: 'No valid rows to import'));
      return;
    }

    logger.fine('Starting bulk import of ${validRows.length} rows via /api/import/');
    emit(FoodImportInProgress(fileName: currentState.fileName));

    try {
      final result = await importFoodsUsecase(
        ImportFoodsUsecaseParams(
          rows: validRows,
          classname: currentState.classname,
          jsonArrayPayloadOverride: isFoodImport ? null : currentState.jsonArrayPayload,
        ),
      ).run();

      if (emit.isDone) return;

      result.fold(
        (failure) {
          emit(
            FoodImportError(
              message: failure.debugMessage ?? 'Import failed',
            ),
          );
        },
        (_) {
          logger.fine('Bulk import complete: ${validRows.length} row(s) imported');
          emit(
            FoodImportSuccess(
              successCount: validRows.length,
              failureCount: isFoodImport ? currentState.errorCount : 0,
              failedLabels: currentState.rows
                  .where((r) => isFoodImport && r.hasErrors)
                  .map((r) => r.label)
                  .toList(),
            ),
          );
        },
      );
    } catch (e, st) {
      logger.severe('Bulk import failed', e, st);
      if (emit.isDone) return;
      emit(FoodImportError(message: 'Import failed: $e'));
    }
  }

  void _onCancelImport(
    CancelImportRequested event,
    Emitter<FoodImportState> emit,
  ) {
    logger.finest('CancelImportRequested');
    emit(const FoodImportInitial());
  }

  Future<void> _onExportFoods(
    ExportFoodsRequested event,
    Emitter<FoodImportState> emit,
  ) async {
    logger.fine('ExportFoodsRequested format=${event.format}, classname=${event.classname}');
    emit(const FoodExportInProgress());

    try {
      final format = event.format == 'json' ? ExportFormat.json : ExportFormat.csv;
      final result = await exportFoodsUsecase(
        ExportFoodsUsecaseParams(format: format, classname: event.classname),
      ).run();

      if (emit.isDone) return;

      String? exportContent;
      result.fold(
        (failure) {
          emit(FoodImportError(message: failure.debugMessage ?? 'Export failed'));
        },
        (value) {
          exportContent = value;
        },
      );

      if (exportContent == null) return;

      final baseName = _exportFileBaseName(event.classname);
      final fileName = '$baseName.${event.format}';

      final bytes = Uint8List.fromList(utf8.encode(exportContent!));

      final savedPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Export ${_exportDialogLabel(event.classname)}',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: [event.format],
        bytes: bytes,
      );

      if (emit.isDone) return;

      if (savedPath != null) {
        logger.fine('Export saved to: $savedPath');
        emit(FoodExportSuccess(fileName: fileName));
      } else {
        logger.fine('Export cancelled');
        emit(const FoodImportInitial());
      }
    } catch (e, st) {
      logger.severe('Export failed', e, st);
      if (emit.isDone) return;
      emit(FoodImportError(message: 'Export failed: $e'));
    }
  }

  String _exportFileBaseName(String classname) {
    return switch (classname) {
      ImportActionClassnames.food => 'foods_export',
      ImportActionClassnames.dietRecommendation => 'diet_recommendations_export',
      ImportActionClassnames.exercise => 'exercises_export',
      ImportActionClassnames.session => 'sessions_export',
      ImportActionClassnames.member => 'members_export',
      _ => 'data_export',
    };
  }

  String _exportDialogLabel(String classname) {
    return switch (classname) {
      ImportActionClassnames.food => 'Foods',
      ImportActionClassnames.dietRecommendation => 'Diet Recommendations',
      ImportActionClassnames.exercise => 'Exercises',
      ImportActionClassnames.session => 'Sessions',
      ImportActionClassnames.member => 'Members',
      _ => 'Data',
    };
  }
}
