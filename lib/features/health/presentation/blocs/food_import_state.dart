part of 'food_import_bloc.dart';

/// Base class for all food import/export states.
sealed class FoodImportState extends Equatable {
  const FoodImportState();

  @override
  List<Object?> get props => [];
}

/// Initial state, no file selected.
final class FoodImportInitial extends FoodImportState {
  const FoodImportInitial();
}

/// Parsing the file (CSV or JSON).
final class FoodImportParsing extends FoodImportState {
  const FoodImportParsing();
}

/// File parsed, showing preview of rows.
final class FoodImportPreview extends FoodImportState {
  final List<FoodImportRow> rows;
  final String fileName;
  final String classname;
  final String? jsonArrayPayload;
  final List<String> warnings;
  final List<String> missingHeaders;

  const FoodImportPreview({
    required this.rows,
    required this.fileName,
    this.classname = 'FoodAction',
    this.jsonArrayPayload,
    this.warnings = const [],
    this.missingHeaders = const [],
  });

  int get validCount => rows.where((r) => r.isValid).length;
  int get errorCount => rows.where((r) => r.hasErrors).length;
  int get totalCount => rows.length;

  FoodImportPreview copyWith({
    List<FoodImportRow>? rows,
    String? fileName,
    String? classname,
    String? jsonArrayPayload,
    List<String>? warnings,
    List<String>? missingHeaders,
  }) {
    return FoodImportPreview(
      rows: rows ?? this.rows,
      fileName: fileName ?? this.fileName,
      classname: classname ?? this.classname,
      jsonArrayPayload: jsonArrayPayload ?? this.jsonArrayPayload,
      warnings: warnings ?? this.warnings,
      missingHeaders: missingHeaders ?? this.missingHeaders,
    );
  }

  @override
  List<Object?> get props => [rows, fileName, classname, jsonArrayPayload, warnings, missingHeaders];
}

/// Import in progress (sending data to API).
final class FoodImportInProgress extends FoodImportState {
  final String fileName;

  const FoodImportInProgress({required this.fileName});

  @override
  List<Object?> get props => [fileName];
}

/// Import completed successfully.
final class FoodImportSuccess extends FoodImportState {
  final int successCount;
  final int failureCount;
  final List<String> failedLabels;

  const FoodImportSuccess({
    required this.successCount,
    required this.failureCount,
    this.failedLabels = const [],
  });

  @override
  List<Object?> get props => [successCount, failureCount, failedLabels];
}

/// Error state.
final class FoodImportError extends FoodImportState {
  final String message;

  const FoodImportError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Export in progress.
final class FoodExportInProgress extends FoodImportState {
  const FoodExportInProgress();
}

/// Export completed.
final class FoodExportSuccess extends FoodImportState {
  final String fileName;

  const FoodExportSuccess({required this.fileName});

  @override
  List<Object?> get props => [fileName];
}
