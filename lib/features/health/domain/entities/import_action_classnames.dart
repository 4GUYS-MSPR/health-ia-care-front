/// Backend classnames supported by /api/import/.
abstract final class ImportActionClassnames {
  static const dietRecommendation = 'DietRecommendationAction';
  static const exercise = 'ExerciceAction';
  static const food = 'FoodAction';
  static const member = 'MemberAction';
  static const session = 'SessionAction';

  static const all = <String>[
    dietRecommendation,
    exercise,
    food,
    member,
    session,
  ];
}
