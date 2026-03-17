import '../../domain/entities/import_action_classnames.dart';
import 'food_import_export_page.dart';

class DietImportExportPage extends FoodImportExportPage {
  const DietImportExportPage({super.key})
      : super(
          title: 'Import / Export Diet Recommendations',
          classname: ImportActionClassnames.dietRecommendation,
          entityLabel: 'diet recommendations',
          enableExport: true,
        );
}
