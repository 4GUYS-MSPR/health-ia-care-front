import '../../domain/entities/import_action_classnames.dart';
import 'food_import_export_page.dart';

class SessionImportExportPage extends FoodImportExportPage {
  const SessionImportExportPage({super.key})
      : super(
          title: 'Import / Export Sessions',
          classname: ImportActionClassnames.session,
          entityLabel: 'sessions',
          enableExport: true,
        );
}
