import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../extensions/l10n_extension.dart';
import 'package:get_it/get_it.dart';

import '../../../../features/health/domain/entities/nutrition_food.dart';
import '../../../../features/health/domain/entities/exercise.dart';
import '../../../../features/members/domain/entities/member.dart';
import '../../../../features/health/presentation/blocs/foods_bloc.dart';
import '../../../../features/health/presentation/blocs/exercises_bloc.dart';
import '../../../../features/members/presentation/bloc/members_bloc.dart';
import '../../utils/exercise_utils.dart';
import '../../widgets/dashboard/graph_card.dart';
import '../../widgets/dashboard/legend_item.dart';
import '../../widgets/dashboard/generic_pie_chart.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => GetIt.I<FoodsBloc>()..add(const LoadFoodsRequested())),
        BlocProvider(create: (_) => GetIt.I<ExercisesBloc>()..add(const LoadExercisesRequested())),
        BlocProvider(create: (_) => GetIt.I<MembersBloc>()..add(const LoadMembersRequested())),
      ],
      child: BlocBuilder<FoodsBloc, FoodsState>(
        builder: (context1, foodsState) {
          return BlocBuilder<ExercisesBloc, ExercisesState>(
            builder: (context2, exercisesState) {
              return BlocBuilder<MembersBloc, MembersState>(
                builder: (context3, membersState) {
                  final foods = foodsState is FoodsLoaded ? foodsState.foods : <NutritionFood>[];
                  final exercises = exercisesState is ExercisesLoaded ? exercisesState.items : <Exercise>[];
                  final members = membersState is MembersLoaded ? membersState.members : <Member>[];

                  return _HomeDashboardContent(foods: foods, exercises: exercises, members: members);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _HomeDashboardContent extends StatelessWidget {
  const _HomeDashboardContent({
    required this.foods,
    required this.exercises,
    required this.members,
  });

  final List<NutritionFood> foods;
  final List<Exercise> exercises;
  final List<Member> members;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dashboard', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 900;
              return isMobile
                  ? Column(
                      children: [
                        _buildClientsCard(context),
                        const SizedBox(height: 16),
                        _buildMacrosCard(context),
                        const SizedBox(height: 16),
                        _buildExercisesCard(context),
                        const SizedBox(height: 16),
                        _buildSubscriptionsCard(context),
                        const SizedBox(height: 16),
                        _buildTargetMusclesCard(context),
                        const SizedBox(height: 16),
                        _buildMealTypesCard(context),
                      ],
                    )
                  : Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildClientsCard(context)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildMacrosCard(context)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildExercisesCard(context)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildSubscriptionsCard(context)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildTargetMusclesCard(context)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildMealTypesCard(context)),
                          ],
                        ),
                      ],
                    );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildClientsCard(BuildContext context) {
    final byLevel = <String, int>{};
    for (final m in members) {
      byLevel[m.level.name] = (byLevel[m.level.name] ?? 0) + 1;
    }

    final labels = byLevel.keys.toList();
    final values = byLevel.values.map((e) => e.toDouble()).toList();

    return GraphCard(
      title: context.l10n.memberStatsLevelDistribution,
      child: members.isEmpty
          ? const Center(child: Text('Aucun client'))
          : Row(
              children: [
                Expanded(
                  child: GenericPieChart(
                    values: values,
                    labels: labels,
                    colors: [Colors.blue, Colors.green, Colors.orange, Colors.red],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < labels.length; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: LegendItem(
                          [Colors.blue, Colors.green, Colors.orange, Colors.red][i % 4],
                          '${labels[i]}: ${values[i].toStringAsFixed(0)}',
                        ),
                      ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildMacrosCard(BuildContext context) {
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;

    for (final food in foods) {
      totalProtein += food.protein;
      totalCarbs += food.carbohydrates;
      totalFat += food.fat;
    }

    final values = [totalProtein, totalCarbs, totalFat];
    final labels = ['Protéines', 'Glucides', 'Graisses'];

    return GraphCard(
      title: context.l10n.nutritionDashboardPieMacrosTitle,
      child: foods.isEmpty
          ? const Center(child: Text('Aucune donnée'))
          : Row(
              children: [
                Expanded(
                  child: GenericPieChart(
                    values: values,
                    labels: labels,
                    colors: [Colors.orange, Colors.green, Colors.red],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LegendItem(Colors.orange, '${totalProtein.toStringAsFixed(0)}g'),
                    const SizedBox(height: 8),
                    LegendItem(Colors.green, '${totalCarbs.toStringAsFixed(0)}g'),
                    const SizedBox(height: 8),
                    LegendItem(Colors.red, '${totalFat.toStringAsFixed(0)}g'),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildExercisesCard(BuildContext context) {
    final byCategory = ExerciseUtils.countByCategory(exercises);
    final labels = byCategory.keys.toList();
    final values = byCategory.values.map((e) => e.toDouble()).toList();

    return GraphCard(
      title: context.l10n.exerciseDashboardPieCategoryTitle,
      child: exercises.isEmpty
          ? const Center(child: Text('Aucun exercice'))
          : Row(
              children: [
                Expanded(
                  child: GenericPieChart(
                    values: values,
                    labels: labels,
                    colors: [Colors.blue, Colors.red, Colors.purple, Colors.brown],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < labels.length; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: LegendItem(
                          [Colors.blue, Colors.red, Colors.purple, Colors.brown][i % 4],
                          '${labels[i]}: ${values[i].toStringAsFixed(0)}',
                        ),
                      ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildSubscriptionsCard(BuildContext context) {
    final bySub = <String, int>{};
    for (final m in members) {
      final subName = m.subscription.name;
      bySub[subName] = (bySub[subName] ?? 0) + 1;
    }

    final labels = bySub.keys.toList();
    final values = bySub.values.map((e) => e.toDouble()).toList();

    return GraphCard(
      title: context.l10n.memberStatsSubscriptionDistribution,
      child: members.isEmpty
          ? const Center(child: Text('Aucun client'))
          : Row(
              children: [
                Expanded(
                  child: GenericPieChart(
                    values: values,
                    labels: labels,
                    colors: [Colors.green, Colors.blue, Colors.orange],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < labels.length; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: LegendItem(
                          [Colors.green, Colors.blue, Colors.orange][i % 3],
                          '${labels[i]}: ${values[i].toStringAsFixed(0)}',
                        ),
                      ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildTargetMusclesCard(BuildContext context) {
    final byMuscle = ExerciseUtils.countTargetMuscles(exercises);
    final labels = byMuscle.keys.toList();
    final values = byMuscle.values.map((e) => e.toDouble()).toList();

    return GraphCard(
      title: context.l10n.exerciseDashboardBarTargetMusclesTitle,
      child: exercises.isEmpty
          ? const Center(child: Text('Aucun exercice'))
          : Row(
              children: [
                Expanded(
                  child: GenericPieChart(
                    values: values,
                    labels: labels,
                    colors: [Colors.red, Colors.purple, Colors.orange, Colors.pink],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < labels.length; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: LegendItem(
                          [Colors.red, Colors.purple, Colors.orange, Colors.pink][i % 4],
                          '${labels[i]}: ${values[i].toStringAsFixed(0)}',
                        ),
                      ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildMealTypesCard(BuildContext context) {
    final byMealType = <String, int>{};
    for (final food in foods) {
      byMealType[food.mealType] = (byMealType[food.mealType] ?? 0) + 1;
    }

    final labels = byMealType.keys.toList();
    final values = byMealType.values.map((e) => e.toDouble()).toList();

    return GraphCard(
      title: context.l10n.nutritionDashboardPieMealTypeTitle,
      child: foods.isEmpty
          ? const Center(child: Text('Aucun aliment'))
          : Row(
              children: [
                Expanded(
                  child: GenericPieChart(
                    values: values,
                    labels: labels,
                    colors: [Colors.blue, Colors.green, Colors.orange, Colors.purple],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < labels.length; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: LegendItem(
                          [Colors.blue, Colors.green, Colors.orange, Colors.purple][i % 4],
                          '${labels[i]}: ${values[i].toStringAsFixed(0)}',
                        ),
                      ),
                  ],
                ),
              ],
            ),
    );
  }
}
