part of 'food_import_bloc.dart';

/// Base class for all food import/export events.
sealed class FoodImportEvent extends Equatable {
  const FoodImportEvent();

  @override
  List<Object?> get props => [];
}

/// Event to pick and parse a file (CSV or JSON).
final class PickFileRequested extends FoodImportEvent {
  final String classname;

  const PickFileRequested({
    this.classname = ImportActionClassnames.food,
  });

  @override
  List<Object?> get props => [classname];
}

/// Event to update a specific row in the preview.
final class UpdateRowRequested extends FoodImportEvent {
  final FoodImportRow updatedRow;

  const UpdateRowRequested({required this.updatedRow});

  @override
  List<Object?> get props => [updatedRow];
}

/// Event to remove a specific row from the preview.
final class DeleteRowRequested extends FoodImportEvent {
  final int rowIndex;

  const DeleteRowRequested({required this.rowIndex});

  @override
  List<Object?> get props => [rowIndex];
}

/// Event to confirm and execute the import via the API bulk route.
final class ConfirmImportRequested extends FoodImportEvent {
  final String classname;

  const ConfirmImportRequested({
    this.classname = ImportActionClassnames.food,
  });

  @override
  List<Object?> get props => [classname];
}

/// Event to cancel the import and reset.
final class CancelImportRequested extends FoodImportEvent {
  const CancelImportRequested();
}

/// Event to export all foods to a file.
final class ExportFoodsRequested extends FoodImportEvent {
  /// 'csv' or 'json'
  final String format;
  final String classname;

  const ExportFoodsRequested({
    required this.format,
    this.classname = ImportActionClassnames.food,
  });

  @override
  List<Object?> get props => [format, classname];
}
