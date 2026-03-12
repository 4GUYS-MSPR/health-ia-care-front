// Fonctions utilitaires pour calculs nutritionnels
import '../../../../features/health/domain/entities/nutrition_food.dart';

// Calcule la moyenne d'une propriété nutritionnelle sur tous les aliments
double moyenne(List<NutritionFood> foods, double Function(NutritionFood aliment) propriete) {
  if (foods.isEmpty) return 0;
  return foods.fold(0.0, (somme, aliment) => somme + propriete(aliment)) / foods.length;
}

// Regroupe les aliments par une clé (catégorie ou type de repas)
Map<String, int> compterParGroupe(List<NutritionFood> foods, String Function(NutritionFood aliment) extraireGroupe) {
  final comptage = <String, int>{};
  for (final aliment in foods) {
    final nomGroupe = extraireGroupe(aliment);
    if (nomGroupe.isEmpty) continue;
    comptage[nomGroupe] = (comptage[nomGroupe] ?? 0) + 1;
  }
  return comptage;
}
