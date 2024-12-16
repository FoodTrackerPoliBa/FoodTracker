import 'package:food_traker/src/backend/types/ingredient.dart';

class MealData {
  final String name;
  final int nTotalPortions;
  final int nEatenPortions;
  final List<Ingredient> ingredients;

  const MealData({
    required this.name,
    required this.nTotalPortions,
    required this.nEatenPortions,
    required this.ingredients,
  });
}
