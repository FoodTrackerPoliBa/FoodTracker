import 'package:flutter/material.dart';
import 'package:food_traker/src/backend/backend.dart';
import 'package:food_traker/src/backend/types/ingredient.dart';
import 'package:food_traker/src/dashboard/common_widgets/ingredient_tile.dart';
import 'package:food_traker/src/dashboard/create_new_ingredient/create_new_ingredient.dart';
import 'package:food_traker/src/utils.dart';

class IngredientsView extends StatefulWidget {
  const IngredientsView({super.key});

  @override
  State<IngredientsView> createState() => _IngredientsViewState();
}

class _IngredientsViewState extends State<IngredientsView> {
  final TextEditingController _searchController = TextEditingController();

  Future<void> confirmDeleteFood(
      BuildContext context, Ingredient ingredient) async {
    List<String> recipes =
        await backend.getRecipesContainingIngredient(ingredient.id);
    if (recipes.isNotEmpty && context.mounted) {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Delete ingredient"),
            content: Text(
                "The ingredient ${ingredient.name} is used in the following recipes: ${recipes.join(", ")}\n\nAre you sure you want to delete it?"),
            actions: [
              TextButton(
                onPressed: () {
                  Utils.pop(
                      context: context, currentRouteName: 'ingredient_view');
                },
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  await backend.deleteIngredient(ingredient.id);
                  if (context.mounted) {
                    Utils.pop(
                        context: context, currentRouteName: 'ingredient_view');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Deleted ${ingredient.name}"),
                      ),
                    );
                  }
                },
                child: const Text("Delete"),
              ),
            ],
          );
        },
      );
    } else {
      await backend.deleteIngredient(ingredient.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Deleted ${ingredient.name}"),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredients'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Utils.push(
                context: context,
                routeName: 'create_new_ingredient',
                page: const CreateNewIngredient(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none),
                fillColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.12),
                filled: true,
                hintText: 'Search for ingredients',
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: Listenable.merge([backend, _searchController]),
              builder: (context, child) => FutureBuilder<List<Ingredient>>(
                future: backend.getFoods(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final List<Ingredient> ingredients = snapshot.data!
                      .where((ingredient) => ingredient.name
                          .toLowerCase()
                          .contains(_searchController.text.toLowerCase()))
                      .toList();
                  return ListView.builder(
                    itemCount: ingredients.length,
                    itemBuilder: (context, index) {
                      final Ingredient ingredient = ingredients[index];
                      return IngredientTile(
                        key: ValueKey(
                          ingredient.barcode ?? ingredient.name,
                        ),
                        ingredient: ingredient,
                        trailing: IconButton(
                            onPressed: () async {
                              await confirmDeleteFood(context, ingredient);
                            },
                            icon: const Icon(Icons.delete)),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
