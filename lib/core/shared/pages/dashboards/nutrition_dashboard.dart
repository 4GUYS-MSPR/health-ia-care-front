
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../features/health/domain/entities/nutrition_food.dart';
import '../../../../features/health/presentation/blocs/foods_bloc.dart';
import '../../utils/nutrition_utils.dart';
import '../../widgets/dashboard/graph_card.dart';
import '../../widgets/dashboard/legend_item.dart';
import '../../widgets/dashboard/generic_pie_chart.dart';
import '../../widgets/dashboard/generic_bar_chart.dart';
import '../../../extensions/l10n_extension.dart';

class NutritionDashboard extends StatelessWidget {
  const NutritionDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<FoodsBloc>()..add(const LoadFoodsRequested()),

      child: BlocBuilder<FoodsBloc, FoodsState>(
        builder: (context, state) {
          if (state is FoodsInitial || state is FoodsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is FoodsError) {
            debugPrint('FoodsError in NutritionDashboard: ${state.failure.debugMessage ?? 'no debug message'}');
            return Center(child: Text(context.l10n.foodsErrorLoading));
          }
          final foods = state is FoodsLoaded ? state.foods : <NutritionFood>[];
          return _NutritionContent(foods: foods);
        },
      ),
    );
  }
}


class _NutritionContent extends StatelessWidget {
  const _NutritionContent({required this.foods});

  final List<NutritionFood> foods;

  // Couleurs utilisées pour les graphiques (catégories, types de repas, etc.)
  static const _couleurs = [
    Colors.orange, Colors.green, Colors.red,
    Colors.blue, Colors.brown, Colors.purple, Colors.teal,
  ];



  @override
  Widget build(BuildContext context) {
    // Affiche le dashboard nutrition : KPIs, graphiques, etc.
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre principal
          Text(context.l10n.nutritionDashboardTitle, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          // Affiche le nombre d'aliments chargés
          Text('${foods.length} ${context.l10n.nutritionDashboardFoodsLoaded}', style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          // Affiche les indicateurs clés (KPI)
          _buildKpiCards(context),
          const SizedBox(height: 32),
          // Affiche les graphiques de catégories et types de repas
          _buildResponsiveRow(context, _buildCategoriesCamembert(context), _buildTypeRepasBarres(context)),
          const SizedBox(height: 16),
          // Affiche les graphiques de macronutriments et micronutriments
          _buildResponsiveRow(context, _buildMacronutrimentsCamembert(context), _buildMicronutrimentsCamembert(context)),
        ],
      ),
    );
  }

  Widget _buildResponsiveRow(BuildContext context, Widget gauche, Widget droite) => LayoutBuilder(
    builder: (layoutContext, contraintes) => contraintes.maxWidth > 700
        ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: gauche), const SizedBox(width: 16), Expanded(child: droite),
          ])
        : Column(children: [gauche, const SizedBox(height: 16), droite]),
  );


  Widget _buildKpiCards(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(child: _kpiCard(Icons.restaurant_menu,       context.l10n.nutritionDashboardKpiTotalFoods,  '${foods.length}', Colors.blue)),
      const SizedBox(width: 32),
      Expanded(child: _kpiCard(Icons.local_fire_department, context.l10n.nutritionDashboardKpiAvgCalories,   '${moyenne(foods, (aliment) => aliment.calories.toDouble()).toStringAsFixed(0)} kcal', Colors.orange)),
      const SizedBox(width: 32),
      Expanded(child: _kpiCard(Icons.egg_outlined,          context.l10n.nutritionDashboardKpiAvgProtein,  '${moyenne(foods, (aliment) => aliment.protein).toStringAsFixed(1)}g', Colors.red)),
      const SizedBox(width: 32),
      Expanded(child: _kpiCard(Icons.grain,                 context.l10n.nutritionDashboardKpiAvgCarbs,   '${moyenne(foods, (aliment) => aliment.carbohydrates).toStringAsFixed(1)}g', Colors.amber)),
      const SizedBox(width: 32),
      Expanded(child: _kpiCard(Icons.opacity_outlined,      context.l10n.nutritionDashboardKpiAvgFat,    '${moyenne(foods, (aliment) => aliment.fat).toStringAsFixed(1)}g', Colors.indigo)),
    ],
  );

  Widget _kpiCard(IconData icone, String label, String valeur, Color couleur) => Card(
    // Carte KPI : affiche une icône, un label et une valeur
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(backgroundColor: couleur.withOpacity(0.15), child: Icon(icone, color: couleur)),
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


  Widget _buildCategoriesCamembert(BuildContext context) {
    // Graphique camembert par catégorie d'aliments
    final parCategorie = compterParGroupe(foods, (aliment) => aliment.category).entries.toList();
    final values = parCategorie.map((e) => e.value.toDouble()).toList();
    final labels = parCategorie.map((e) => e.key).toList();
    return GraphCard(
      title: context.l10n.nutritionDashboardPieCategoryTitle,
      child: foods.isEmpty
          ? Center(child: Text(context.l10n.nutritionDashboardPieCategoryNoData))
          : Row(children: [
              Expanded(child: GenericPieChart(values: values, labels: labels, colors: _couleurs)),
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
            ]),
    );
  }

  Widget _buildTypeRepasBarres(BuildContext context) {
    // Graphique barres par type de repas
    final parTypeRepas = compterParGroupe(foods, (aliment) => aliment.mealType).entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final values = parTypeRepas.map((e) => e.value.toDouble()).toList();
    final labels = parTypeRepas.map((e) => e.key).toList();
    return GraphCard(
      title: context.l10n.nutritionDashboardPieMealTypeTitle,
      child: foods.isEmpty
          ? Center(child: Text(context.l10n.nutritionDashboardPieCategoryNoData))
          : GenericBarChart(labels: labels, values: values, colors: _couleurs),
    );
  }

  Widget _buildMacronutrimentsCamembert(BuildContext context) {
    // Graphique camembert pour la répartition des macronutriments
    double totalProteines = 0, totalGlucides = 0, totalLipides = 0;
    for (final aliment in foods) {
      totalProteines += aliment.protein;
      totalGlucides  += aliment.carbohydrates;
      totalLipides   += aliment.fat;
    }
    final values = [totalProteines, totalGlucides, totalLipides];
    final labels = ['Protéines', 'Glucides', 'Lipides'];
    final colors = [Colors.red, Colors.amber, Colors.indigo];
    return GraphCard(
      title: context.l10n.nutritionDashboardPieMacrosTitle,
      subtitle: context.l10n.nutritionDashboardPieMacrosSubtitle,
      child: foods.isEmpty
          ? Center(child: Text(context.l10n.nutritionDashboardPieCategoryNoData))
          : Row(children: [
              Expanded(child: GenericPieChart(values: values, labels: labels, colors: colors)),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LegendItem(colors[0], '${context.l10n.nutritionDashboardPieMacrosLegendProtein} : ${totalProteines.toStringAsFixed(0)}g'),
                  const SizedBox(height: 6),
                  LegendItem(colors[1], '${context.l10n.nutritionDashboardPieMacrosLegendCarbs} : ${totalGlucides.toStringAsFixed(0)}g'),
                  const SizedBox(height: 6),
                  LegendItem(colors[2], '${context.l10n.nutritionDashboardPieMacrosLegendFat} : ${totalLipides.toStringAsFixed(0)}g'),
                ],
              ),
            ]),
    );
  }

  Widget _buildMicronutrimentsCamembert(BuildContext context) {
    // Graphique camembert pour la répartition des micronutriments
    double totalFibres = 0, totalSucres = 0, totalSodium = 0, totalCholesterol = 0, totalEau = 0;
    for (final aliment in foods) {
      totalFibres     += aliment.fiber;
      totalSucres     += aliment.sugars;
      totalSodium     += aliment.sodium.toDouble();
      totalCholesterol+= aliment.cholesterol.toDouble();
      totalEau        += aliment.waterIntake.toDouble();
    }
    final values = [totalFibres, totalSucres, totalSodium, totalCholesterol, totalEau];
    final labels = ['Fibres', 'Sucres', 'Sodium', 'Cholestérol', 'Eau'];
    final colors = [Colors.brown, Colors.pink, Colors.blueGrey, Colors.deepPurple, Colors.cyan];
    return GraphCard(
      title: context.l10n.nutritionDashboardPieMicrosTitle,
      subtitle: context.l10n.nutritionDashboardPieMicrosSubtitle,
      child: foods.isEmpty || values.reduce((a, b) => a + b) == 0
          ? Center(child: Text(context.l10n.nutritionDashboardPieCategoryNoData))
          : Row(children: [
              Expanded(child: GenericPieChart(values: values, labels: labels, colors: colors)),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LegendItem(colors[0], '${context.l10n.nutritionDashboardPieMicrosLegendFiber} : ${totalFibres.toStringAsFixed(0)}'),
                  const SizedBox(height: 6),
                  LegendItem(colors[1], '${context.l10n.nutritionDashboardPieMicrosLegendSugars} : ${totalSucres.toStringAsFixed(0)}'),
                  const SizedBox(height: 6),
                  LegendItem(colors[2], '${context.l10n.nutritionDashboardPieMicrosLegendSodium} : ${totalSodium.toStringAsFixed(0)}'),
                  const SizedBox(height: 6),
                  LegendItem(colors[3], '${context.l10n.nutritionDashboardPieMicrosLegendCholesterol} : ${totalCholesterol.toStringAsFixed(0)}'),
                  const SizedBox(height: 6),
                  LegendItem(colors[4], '${context.l10n.nutritionDashboardPieMicrosLegendWater} : ${totalEau.toStringAsFixed(0)}'),
                ],
              ),
            ]),
    );
  }
}