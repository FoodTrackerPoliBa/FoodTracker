import 'package:food_traker/src/backend/backend.dart';
import 'package:food_traker/src/backend/types/ingredient.dart';

/// Class containing recipe data and utils for calculating calories.
class Recipe {
  /// Unique id
  final int id;

  /// Name of the recipe
  final String name;

  /// Number of times eated
  final int count;

  final List<Ingredient> ingredients;
  String get description {
    return ingredients.map((e) => e.name).join(', ');
  }

  Future<int> get totalCalories async {
    int total = 0;
    final int totalPortions =
        await backend.estimateTotalPortionsPastMeals(name);
    final int eatenPortions =
        await backend.estimateEatenPortionsPastMeals(name);
    for (Ingredient ingredient in ingredients) {
      double amount = await backend.getAmountPastMeals(
          ingredient, name, totalPortions, eatenPortions);
      if (amount == 0) {
        amount = 100;
      }
      total +=
          ((ingredient.calories / 100 * amount) / totalPortions * eatenPortions)
              .toInt();
    }
    return total;
  }

  Recipe({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.count,
  });

  factory Recipe.empty() {
    return Recipe(
      id: -1,
      name: '',
      ingredients: [],
      count: -1,
    );
  }
}
