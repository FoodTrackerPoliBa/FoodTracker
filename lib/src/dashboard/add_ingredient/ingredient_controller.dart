import 'package:flutter/material.dart';
import 'package:food_traker/src/backend/types/ingredient.dart';

class IngredientController extends ChangeNotifier {
  final List<Ingredient> _ingredients;
  bool trackTextEditingControllers = false;

  Map<int, TextEditingController> textEditingControllers = {};

  void addIngredient(Ingredient ingredient) {
    if (_ingredients.contains(ingredient)) return;
    _ingredients.add(ingredient);
    textEditingControllers[ingredient.id] = TextEditingController();
    textEditingControllers[ingredient.id]!.addListener(() {
      notifyListeners();
    });
    notifyListeners();
  }

  void enableTextEditingControllers() {
    trackTextEditingControllers = true;
    // check if the ingredient is already in the list
    for (var ingredient in _ingredients) {
      if (!textEditingControllers.containsKey(ingredient.id)) {
        textEditingControllers[ingredient.id] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    for (var controller in textEditingControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void removeIngredient(Ingredient ingredient) {
    _ingredients.removeWhere((element) => element.id == ingredient.id);
    final TextEditingController? controller =
        textEditingControllers.remove(ingredient.id);
    controller?.dispose();
    notifyListeners();
  }

  void addIngredients(List<Ingredient> ingredientsL) {
    for (var ingredient in ingredientsL) {
      addIngredient(ingredient);
    }
  }

  List<Ingredient> get ingredients => _ingredients;

  IngredientController({List<Ingredient> ingredients = const []})
      : _ingredients = [...ingredients];
}
