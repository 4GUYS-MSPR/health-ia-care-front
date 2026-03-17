import '../../domain/entities/import_action_classnames.dart';
import 'food_import_export_page.dart';

class ExerciseImportExportPage extends FoodImportExportPage {
  const ExerciseImportExportPage({super.key})
      : super(
          title: 'Import / Export Exercises',
          classname: ImportActionClassnames.exercise,
          entityLabel: 'exercises',
          enableExport: true,
        );
}
