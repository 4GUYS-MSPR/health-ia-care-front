import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/extensions/theme_extension.dart';
import '../../domain/entities/food_import_row.dart';
import '../../domain/entities/import_action_classnames.dart';
import '../blocs/food_import_bloc.dart';
import '../widgets/food_csv_row_edit_dialog.dart';

/// Full-screen page for food import (CSV/JSON) and export.
class FoodImportExportPage extends StatelessWidget {
  const FoodImportExportPage({
    super.key,
    this.title = 'Import / Export Foods',
    this.classname = 'FoodAction',
    this.entityLabel = 'foods',
    this.enableExport = true,
  });

  final String title;
  final String classname;
  final String entityLabel;
  final bool enableExport;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<FoodImportBloc>(),
      child: _FoodImportExportContent(
        title: title,
        classname: classname,
        entityLabel: entityLabel,
        enableExport: enableExport,
      ),
    );
  }
}

class _FoodImportExportContent extends StatelessWidget {
  const _FoodImportExportContent({
    required this.title,
    required this.classname,
    required this.entityLabel,
    required this.enableExport,
  });

  final String title;
  final String classname;
  final String entityLabel;
  final bool enableExport;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          BlocBuilder<FoodImportBloc, FoodImportState>(
            builder: (context, state) {
              if (state is FoodImportPreview) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton.icon(
                      onPressed: () =>
                          context.read<FoodImportBloc>().add(const CancelImportRequested()),
                      icon: const Icon(Icons.close),
                      label: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: state.validCount > 0
                          ? () => context.read<FoodImportBloc>().add(
                                ConfirmImportRequested(classname: classname),
                              )
                          : null,
                      icon: const Icon(Icons.upload),
                      label: Text('Import ${state.validCount} items'),
                    ),
                    const SizedBox(width: 16),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<FoodImportBloc, FoodImportState>(
        listener: (context, state) {
          if (state is FoodImportSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.failureCount > 0
                      ? '${state.successCount} $entityLabel imported, ${state.failureCount} skipped'
                      : '${state.successCount} $entityLabel imported successfully!',
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          if (state is FoodExportSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${_capitalize(entityLabel)} exported to ${state.fileName}'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          if (state is FoodImportError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
                backgroundColor: context.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return switch (state) {
            FoodImportInitial() => _buildInitialView(context),
            FoodImportParsing() => _buildLoadingView('Parsing file...'),
            FoodImportPreview() => _buildPreviewView(context, state),
            FoodImportInProgress() => _buildImportProgressView(context, state),
            FoodImportSuccess() => _buildSuccessView(context, state),
            FoodImportError() => _buildInitialView(context),
            FoodExportInProgress() => _buildLoadingView('Exporting $entityLabel...'),
            FoodExportSuccess() => _buildExportSuccessView(context, state),
          };
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Initial view – import + export options
  // ---------------------------------------------------------------------------

  Widget _buildInitialView(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.swap_vert,
              size: 80,
              color: context.colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: context.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              enableExport
                  ? 'Import from a CSV or JSON file, or export your data.'
                  : 'Import from a CSV or JSON file.',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),

            // Import section
            _buildSectionCard(
              context,
              icon: Icons.upload_file,
              title: 'Import',
              subtitle: 'Load ${entityLabel.toLowerCase()} data from a file (CSV or JSON)',
              children: [
                Text(
                  _expectedFieldsText(),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => context.read<FoodImportBloc>().add(
                    PickFileRequested(classname: classname),
                  ),
                  icon: const Icon(Icons.file_open),
                  label: const Text('Select File (CSV / JSON)'),
                ),
              ],
            ),
            if (enableExport) ...[
              const SizedBox(height: 24),

              // Export section
              _buildSectionCard(
                context,
                icon: Icons.download,
                title: 'Export',
                subtitle: 'Save all your data to a file',
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => context.read<FoodImportBloc>().add(
                          ExportFoodsRequested(format: 'csv', classname: classname),
                        ),
                        icon: const Icon(Icons.table_chart),
                        label: const Text('Export CSV'),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton.icon(
                        onPressed: () => context.read<FoodImportBloc>().add(
                          ExportFoodsRequested(format: 'json', classname: classname),
                        ),
                        icon: const Icon(Icons.data_object),
                        label: const Text('Export JSON'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: context.colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(icon, size: 40, color: context.colorScheme.primary),
              const SizedBox(height: 12),
              Text(title, style: context.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Loading
  // ---------------------------------------------------------------------------

  Widget _buildLoadingView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Preview
  // ---------------------------------------------------------------------------

  Widget _buildPreviewView(BuildContext context, FoodImportPreview state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Summary bar
        _buildSummaryBar(context, state),
        // Warnings
        if (state.warnings.isNotEmpty || state.missingHeaders.isNotEmpty)
          _buildWarningsBar(context, state),
        // Data table
        Expanded(
          child: _buildDataTable(context, state),
        ),
        // Bottom actions
        _buildBottomActions(context, state),
      ],
    );
  }

  Widget _buildSummaryBar(BuildContext context, FoodImportPreview state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: context.colorScheme.surfaceContainerLow,
      child: Row(
        children: [
          Icon(Icons.description, color: context.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            state.fileName,
            style: context.textTheme.titleSmall,
          ),
          const SizedBox(width: 24),
          _buildChip(
            context,
            label: '${state.totalCount} total',
            color: context.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          _buildChip(
            context,
            label: '${state.validCount} valid',
            color: Colors.green,
          ),
          if (state.errorCount > 0) ...[
            const SizedBox(width: 8),
            _buildChip(
              context,
              label: '${state.errorCount} errors',
              color: context.colorScheme.error,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, {required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: context.textTheme.labelMedium?.copyWith(color: color),
      ),
    );
  }

  Widget _buildWarningsBar(BuildContext context, FoodImportPreview state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.orange.withValues(alpha: 0.1),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: Colors.orange, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.missingHeaders.isNotEmpty)
                  Text(
                    'Missing columns: ${state.missingHeaders.join(", ")} (defaulted to 0 or empty)',
                    style: context.textTheme.bodySmall?.copyWith(color: Colors.orange.shade800),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(BuildContext context, FoodImportPreview state) {
    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 16,
          headingRowColor: WidgetStateProperty.all(
            context.colorScheme.surfaceContainerHigh,
          ),
          columns: const [
            DataColumn(label: Text('#')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Label')),
            DataColumn(label: Text('Calories'), numeric: true),
            DataColumn(label: Text('Protein'), numeric: true),
            DataColumn(label: Text('Carbs'), numeric: true),
            DataColumn(label: Text('Fat'), numeric: true),
            DataColumn(label: Text('Fiber'), numeric: true),
            DataColumn(label: Text('Sugars'), numeric: true),
            DataColumn(label: Text('Sodium'), numeric: true),
            DataColumn(label: Text('Cholesterol'), numeric: true),
            DataColumn(label: Text('Water'), numeric: true),
            DataColumn(label: Text('Category')),
            DataColumn(label: Text('Meal Type')),
            DataColumn(label: Text('Actions')),
          ],
          rows: state.rows.map((row) => _buildDataRow(context, row)).toList(),
        ),
      ),
    );
  }

  DataRow _buildDataRow(BuildContext context, FoodImportRow row) {
    final allowRowEdit = classname == ImportActionClassnames.food;
    final hasError = row.hasErrors;
    final rowColor = hasError
        ? WidgetStateProperty.all(context.colorScheme.errorContainer.withValues(alpha: 0.3))
        : null;

    return DataRow(
      color: rowColor,
      cells: [
        DataCell(Text('${row.index}')),
        DataCell(
          hasError
              ? Tooltip(
                  message: row.errors.entries.map((e) => '${e.key}: ${e.value}').join('\n'),
                  child: Icon(Icons.error, color: context.colorScheme.error, size: 20),
                )
              : Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
        ),
        _buildCell(row.label, row.errors.containsKey('label'), context),
        _buildCell('${row.calories}', row.errors.containsKey('calories'), context),
        _buildCell(row.protein.toStringAsFixed(1), row.errors.containsKey('protein'), context),
        _buildCell(
          row.carbohydrates.toStringAsFixed(1),
          row.errors.containsKey('carbohydrates'),
          context,
        ),
        _buildCell(row.fat.toStringAsFixed(1), row.errors.containsKey('fat'), context),
        _buildCell(row.fiber.toStringAsFixed(1), row.errors.containsKey('fiber'), context),
        _buildCell(row.sugars.toStringAsFixed(1), row.errors.containsKey('sugars'), context),
        _buildCell('${row.sodium}', row.errors.containsKey('sodium'), context),
        _buildCell('${row.cholesterol}', row.errors.containsKey('cholesterol'), context),
        _buildCell('${row.waterIntake}', row.errors.containsKey('water_intake'), context),
        _buildCell(row.category, row.errors.containsKey('category'), context),
        _buildCell(row.mealType, row.errors.containsKey('meal_type'), context),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                tooltip: 'Edit row',
                onPressed: allowRowEdit ? () => _editRow(context, row) : null,
              ),
              IconButton(
                icon: Icon(Icons.delete, size: 18, color: context.colorScheme.error),
                tooltip: 'Remove row',
                onPressed: allowRowEdit
                    ? () => context.read<FoodImportBloc>().add(DeleteRowRequested(rowIndex: row.index))
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  DataCell _buildCell(String value, bool hasError, BuildContext context) {
    return DataCell(
      Text(
        value,
        style: hasError
            ? TextStyle(
                color: context.colorScheme.error,
                fontWeight: FontWeight.bold,
              )
            : null,
      ),
    );
  }

  Future<void> _editRow(BuildContext context, FoodImportRow row) async {
    final updated = await FoodCsvRowEditDialog.show(context, row);
    if (updated != null && context.mounted) {
      context.read<FoodImportBloc>().add(UpdateRowRequested(updatedRow: updated));
    }
  }

  Widget _buildBottomActions(BuildContext context, FoodImportPreview state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (state.errorCount > 0)
            Text(
              '⚠ ${state.errorCount} row(s) with errors will be skipped during import.',
              style: TextStyle(color: context.colorScheme.error),
            ),
          const Spacer(),
          OutlinedButton(
            onPressed: () => context.read<FoodImportBloc>().add(
              PickFileRequested(classname: classname),
            ),
            child: const Text('Pick Another File'),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: () => context.read<FoodImportBloc>().add(const CancelImportRequested()),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: state.validCount > 0
                ? () => context.read<FoodImportBloc>().add(
                      ConfirmImportRequested(classname: classname),
                    )
                : null,
            icon: const Icon(Icons.upload),
            label: Text('Import ${state.validCount} items'),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Import progress
  // ---------------------------------------------------------------------------

  Widget _buildImportProgressView(BuildContext context, FoodImportInProgress state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Importing $entityLabel...',
            style: context.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            state.fileName,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Import success
  // ---------------------------------------------------------------------------

  Widget _buildSuccessView(BuildContext context, FoodImportSuccess state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            state.failureCount == 0 ? Icons.check_circle : Icons.warning,
            size: 80,
            color: state.failureCount == 0 ? Colors.green : Colors.orange,
          ),
          const SizedBox(height: 24),
          Text(
            'Import Complete',
            style: context.textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text(
            '${state.successCount} ${entityLabel.replaceAll('s', '')}(s) imported successfully',
            style: context.textTheme.bodyLarge?.copyWith(color: Colors.green.shade700),
          ),
          if (state.failureCount > 0) ...[
            const SizedBox(height: 8),
            Text(
              '${state.failureCount} ${entityLabel.replaceAll('s', '')}(s) had errors and were skipped',
              style: TextStyle(color: context.colorScheme.error),
            ),
            if (state.failedLabels.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Skipped: ${state.failedLabels.join(", ")}',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
          const SizedBox(height: 32),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Done'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => context.read<FoodImportBloc>().add(
              PickFileRequested(classname: classname),
            ),
            child: const Text('Import Another File'),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Export success
  // ---------------------------------------------------------------------------

  Widget _buildExportSuccessView(BuildContext context, FoodExportSuccess state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 80, color: Colors.green),
          const SizedBox(height: 24),
          Text(
            'Export Complete',
            style: context.textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text(
            '${_capitalize(entityLabel)} exported to ${state.fileName}',
            style: context.textTheme.bodyLarge?.copyWith(color: Colors.green.shade700),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => context.read<FoodImportBloc>().add(const CancelImportRequested()),
            child: const Text('Back to Import / Export'),
          ),
        ],
      ),
    );
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }

  String _expectedFieldsText() {
    if (classname == ImportActionClassnames.food) {
      return 'Expected fields: label, calories, protein, carbohydrates, fat, fiber,\n'
          'sugars, sodium, cholesterol, water_intake, category, meal_type';
    }
    if (classname == ImportActionClassnames.dietRecommendation) {
      return 'Expected fields: adherence_to_diet_plan, blood_pressure, cholesterol,\n'
          'daily_caloric_intake, dietary_nutrient_imbalance_score, glucose,\n'
          'weekly_exercise_hours (optionals accepted)';
    }
    if (classname == ImportActionClassnames.exercise) {
      return 'Expected fields: image_url (optionals: category, client, body_parts,\n'
          'equipments, secondary_muscles, target_muscles)';
    }
    if (classname == ImportActionClassnames.session) {
      return 'Expected fields: calories_burned, duration, avg_bpm, max_bpm,\n'
          'resting_bpm, water_intake, member (optional: exercices)';
    }
    if (classname == ImportActionClassnames.member) {
      return 'Expected fields: bmi, fat_percentage, height, weight, workout_frequency,\n'
          'gender, level, subscription, objectives (optional: age, client)';
    }
    return 'Expected fields depend on selected import target.';
  }
}
