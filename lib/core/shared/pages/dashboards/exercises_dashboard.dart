import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../features/health/domain/entities/exercise.dart';
import '../../../../features/health/presentation/blocs/exercises_bloc.dart';
import '../../utils/exercise_utils.dart';
import '../../widgets/dashboard/graph_card.dart';
import '../../widgets/dashboard/legend_item.dart';
import '../../widgets/dashboard/generic_pie_chart.dart';
import '../../../extensions/l10n_extension.dart';

class ExercisesDashboard extends StatelessWidget {
  const ExercisesDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<ExercisesBloc>()..add(const LoadExercisesRequested()),
      child: BlocBuilder<ExercisesBloc, ExercisesState>(
        builder: (context, state) {
          if (state is ExercisesInitial || state is ExercisesLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ExercisesError) {
            debugPrint(
              'ExercisesError in ExercisesDashboard: ${state.failure.debugMessage ?? 'no debug message'}',
            );
            return Center(child: Text(context.l10n.exercisesErrorLoading));
          }
          final exercises = state is ExercisesLoaded ? state.items : <Exercise>[];
          return _ExerciseContent(exercises: exercises);
        },
      ),
    );
  }
}

class _ExerciseContent extends StatelessWidget {
  const _ExerciseContent({required this.exercises});

  final List<Exercise> exercises;

  // Couleurs utilisées pour les graphiques
  static const _couleurs = [
    Colors.orange,
    Colors.green,
    Colors.red,
    Colors.blue,
    Colors.brown,
    Colors.purple,
    Colors.teal,
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre principal
          Text(
            context.l10n.exerciseDashboardTitle,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          // Affiche le nombre d'exercices chargés
          Text(
            '${exercises.length} ${context.l10n.exerciseDashboardExercisesLoaded}',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          // Affiche les indicateurs clés (KPI)
          _buildKpiCards(context),
          const SizedBox(height: 32),
          // Affiche les graphiques de catégories et muscles ciblés
          _buildResponsiveRow(
            context,
            _buildCategoriesPieChart(context),
            _buildTargetMusclesPieChart(context),
          ),
          const SizedBox(height: 16),
          // Affiche le graphique d'équipements
          _buildEquipmentPieChart(context),
        ],
      ),
    );
  }

  Widget _buildResponsiveRow(BuildContext context, Widget gauche, Widget droite) => LayoutBuilder(
    builder: (layoutContext, contraintes) => contraintes.maxWidth > 700
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: gauche),
              const SizedBox(width: 16),
              Expanded(child: droite),
            ],
          )
        : Column(children: [gauche, const SizedBox(height: 16), droite]),
  );

  Widget _buildKpiCards(BuildContext context) {
    final kpiCards = [
      _kpiCard(
        Icons.fitness_center,
        context.l10n.exerciseDashboardKpiTotalExercises,
        '${exercises.length}',
        Colors.blue,
      ),
      _kpiCard(
        Icons.favorite,
        context.l10n.exerciseDashboardKpiAvgTargetMuscles,
        ExerciseUtils.averageTargetMuscles(exercises).toStringAsFixed(1),
        Colors.red,
      ),
      _kpiCard(
        Icons.hardware,
        context.l10n.exerciseDashboardKpiAvgEquipments,
        ExerciseUtils.averageEquipments(exercises).toStringAsFixed(1),
        Colors.amber,
      ),
    ];

    return LayoutBuilder(
      builder: (layoutContext, constraints) {
        const spacing = 16.0;
        final crossAxisCount = constraints.maxWidth >= 1400
            ? 4
            : constraints.maxWidth >= 1000
            ? 3
            : constraints.maxWidth >= 600
            ? 2
            : 1;
        final cardWidth = (constraints.maxWidth - (crossAxisCount - 1) * spacing) / crossAxisCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final card in kpiCards) SizedBox(width: cardWidth, child: card),
          ],
        );
      },
    );
  }

  Widget _kpiCard(IconData icone, String label, String valeur, Color couleur) => Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: couleur.withValues(alpha: 0.15),
            child: Icon(icone, color: couleur),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              Text(valeur, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _buildCategoriesPieChart(BuildContext context) {
    // Graphique camembert par catégorie d'exercices
    final byCategory = ExerciseUtils.countByCategory(exercises);
    final values = byCategory.values.map((e) => e.toDouble()).toList();
    final labels = byCategory.keys.toList();
    
    return GraphCard(
      title: context.l10n.exerciseDashboardPieCategoryTitle,
      child: byCategory.isEmpty
          ? Center(child: Text(context.l10n.exerciseDashboardPieCategoryNoData))
          : Row(
              children: [
                Expanded(
                  child: GenericPieChart(values: values, labels: labels, colors: _couleurs),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int index = 0; index < labels.length; index++)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: LegendItem(_couleurs[index % _couleurs.length], labels[index]),
                      ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildTargetMusclesPieChart(BuildContext context) {
    // Graphique camembert pour la fréquence des muscles ciblés
    final targetMuscles = ExerciseUtils.countTargetMuscles(exercises);
    final values = targetMuscles.values.map((e) => e.toDouble()).toList();
    final labels = targetMuscles.keys.toList();
    
    return GraphCard(
      title: context.l10n.exerciseDashboardBarTargetMusclesTitle,
      child: exercises.isEmpty
          ? Center(child: Text(context.l10n.exerciseDashboardPieCategoryNoData))
          : Row(
              children: [
                Expanded(
                  child: GenericPieChart(values: values, labels: labels, colors: _couleurs),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int index = 0; index < labels.length; index++)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: LegendItem(_couleurs[index % _couleurs.length], labels[index]),
                      ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildEquipmentPieChart(BuildContext context) {
    // Graphique camembert par équipement
    final byEquipment = ExerciseUtils.countEquipments(exercises);
    final values = byEquipment.values.map((e) => e.toDouble()).toList();
    final labels = byEquipment.keys.toList();
    
    return GraphCard(
      title: context.l10n.exerciseDashboardPieEquipmentTitle,
      child: exercises.isEmpty
          ? Center(child: Text(context.l10n.exerciseDashboardPieCategoryNoData))
          : Row(
              children: [
                Expanded(
                  child: GenericPieChart(values: values, labels: labels, colors: _couleurs),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int index = 0; index < labels.length; index++)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: LegendItem(_couleurs[index % _couleurs.length], labels[index]),
                      ),
                  ],
                ),
              ],
            ),
    );
  }


}
