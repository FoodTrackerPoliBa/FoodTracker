class DailyOverviewData {
  final int supplied;
  final int burned;
  final NutrientValues actual;
  final NutrientValues target;
  final double price;

  DailyOverviewData({
    required this.supplied,
    required this.burned,
    required this.target,
    required this.actual,
    required this.price
  });

  factory DailyOverviewData.empty() {
    return DailyOverviewData(
      supplied: 0,
      burned: 0,
      target: NutrientValues(carbs: 0, protein: 0, fat: 0, kcalories: 0, sugar: 0),
      actual: NutrientValues(carbs: 0, protein: 0, fat: 0, kcalories: 0, sugar: 0),
      price: 0
    );
  }
}

class NutrientValues {
  final int carbs;
  final int protein;
  final int fat;
  final int sugar;
  final int kcalories;
  NutrientValues(
      {required this.carbs,
      required this.protein,
      required this.fat,
      required this.sugar,
      required this.kcalories});
}
