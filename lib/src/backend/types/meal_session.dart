import 'package:food_traker/src/backend/types/ingredient.dart';
import 'package:food_traker/src/backend/types/meal_type.dart';

class MealSession {
  final int id;
  final String name;
  final MealType mealType;
  final DateTime timestamp;
  final int nTotalPortions;
  final int nEatenPortions;
  final double? price;

  final List<Ingredient> ingredients;

  int get calories {
    int total = 0;
    for (final Ingredient ingredient in ingredients) {
      total += ((((ingredient.amount ?? 0) / nTotalPortions) * nEatenPortions) /
              100 *
              ingredient.calories)
          .round();
    }
    return total;
  }

  MealSession({
    required this.id,
    required this.name,
    required this.mealType,
    required this.timestamp,
    required this.ingredients,
    required this.nTotalPortions,
    required this.nEatenPortions,
    required this.price
  });
}
