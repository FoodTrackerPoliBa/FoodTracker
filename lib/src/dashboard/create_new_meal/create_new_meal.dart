import 'package:flutter/material.dart';
import 'package:food_traker/src/backend/backend.dart';
import 'package:food_traker/src/backend/types/ingredient.dart';
import 'package:food_traker/src/backend/types/recipe.dart';
import 'package:food_traker/src/dashboard/add_ingredient/add_ingredient.dart';
import 'package:food_traker/src/dashboard/add_ingredient/ingredient_controller.dart';
import 'package:food_traker/src/dashboard/common_widgets/ingredient_tile.dart';
import 'package:food_traker/src/utils.dart';

class CreateNewMeal extends StatefulWidget {
  const CreateNewMeal({super.key, this.meal});
  final Recipe? meal;
  @override
  State<CreateNewMeal> createState() => _CreateNewMealState();
}

class _CreateNewMealState extends State<CreateNewMeal> {
  final TextEditingController _nameController = TextEditingController();
  final IngredientController ingredientController = IngredientController();
  Future<void> showAlertAddMealName() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Meal Name'),
          content: const Text('Please add a name to the meal'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Utils.pop(
                    context: context, currentRouteName: 'create_new_meal');
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> showAlertAddIngredients() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Ingredients'),
          content: const Text('Please add ingredients to the meal'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Utils.pop(
                    context: context, currentRouteName: 'create_new_meal');
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    if (widget.meal != null) {
      _nameController.text = widget.meal!.name;
      ingredientController.addIngredients(widget.meal!.ingredients);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configure Recipe'),
        actions: [
          FilledButton(
              onPressed: () async {
                if (_nameController.text.isEmpty) {
                  await showAlertAddMealName();
                  return;
                }
                if (ingredientController.ingredients.isEmpty) {
                  await showAlertAddIngredients();
                  return;
                }
                await backend.addMeal(
                    _nameController.text, ingredientController.ingredients,
                    recipe: widget.meal);
                if (context.mounted) {
                  Utils.pop(
                      context: context, currentRouteName: 'create_new_meal');
                }
              },
              child: const Text('Save')),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: TextField(
            maxLength: 100,
            controller: _nameController,
            decoration: const InputDecoration(
              counterText: "",
              border: OutlineInputBorder(),
              labelText: 'Meal Name',
            ),
          ),
        ),
        Expanded(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ingredients',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          Utils.push(
                              context: context,
                              routeName: 'add_ingredient',
                              page: AddIngredient(
                                  ingredientController: ingredientController));
                        }),
                  ],
                ),
                Expanded(
                  child: AnimatedBuilder(
                    animation: ingredientController,
                    builder: (context, child) => ListView.builder(
                        itemCount: ingredientController.ingredients.length,
                        itemBuilder: (context, index) {
                          final Ingredient ingredient =
                              ingredientController.ingredients[index];
                          return IngredientTile(
                            key: ValueKey(
                              ingredient.barcode ?? ingredient.name,
                            ),
                            ingredient: ingredient,
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                ingredientController
                                    .removeIngredient(ingredient);
                              },
                            ),
                          );
                        }),
                  ),
                ),
              ],
            ),
          ),
        )),
      ]),
    );
  }
}
