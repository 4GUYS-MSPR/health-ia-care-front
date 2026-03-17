import '../../../health/domain/entities/import_action_classnames.dart';
import '../../../health/presentation/pages/food_import_export_page.dart';

class MemberImportExportPage extends FoodImportExportPage {
  const MemberImportExportPage({super.key})
      : super(
          title: 'Import / Export Members',
          classname: ImportActionClassnames.member,
          entityLabel: 'members',
          enableExport: true,
        );
}
