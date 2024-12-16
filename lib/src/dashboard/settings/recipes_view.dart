import 'package:flutter/material.dart';
import 'package:food_traker/src/backend/backend.dart';
import 'package:food_traker/src/backend/types/recipe.dart';
import 'package:food_traker/src/dashboard/add_meal_intake/add_meal_intake.dart';
import 'package:food_traker/src/dashboard/create_new_meal/create_new_meal.dart';
import 'package:food_traker/src/utils.dart';

class RecipesView extends StatefulWidget {
  const RecipesView({super.key});

  @override
  State<RecipesView> createState() => _RecipesViewState();
}

class _RecipesViewState extends State<RecipesView> {
  final TextEditingController _searchController = TextEditingController();

  Future<void> deleteRecipe(BuildContext context, Recipe recipe) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete recipe"),
          content: Text(
              "Are you sure you want to delete the recipe ${recipe.name}?"),
          actions: [
            TextButton(
              onPressed: () {
                Utils.pop(context: context, currentRouteName: 'recipes_view');
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await backend.deleteRecipe(recipe.id);
                if (context.mounted) {
                  Utils.pop(context: context, currentRouteName: 'recipes_view');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Deleted ${recipe.name}"),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Utils.push(
                  context: context,
                  routeName: 'create_new_meal',
                  page: const CreateNewMeal());
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
                  borderSide: BorderSide.none,
                ),
                fillColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.12),
                filled: true,
                hintText: 'Search for recipes',
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (_) {
                setState(() {}); // Update the UI when the search text changes
              },
            ),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: Listenable.merge([backend, _searchController]),
              builder: (context, child) {
                return FutureBuilder<List<Recipe>>(
                  future: backend.getRecipes(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                          child:
                              Text('Error loading recipes: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    final List<Recipe> recipes = snapshot.data!
                        .where((recipe) => recipe.name
                            .toLowerCase()
                            .contains(_searchController.text.toLowerCase()))
                        .toList();
                    return ListView.builder(
                      itemCount: recipes.length,
                      itemBuilder: (context, index) {
                        final Recipe meal = recipes[index];
                        return InkWell(
                          onTap: () {
                            Utils.push(
                              context: context,
                              routeName: 'create_new_meal',
                              page: CreateNewMeal(
                                meal: meal,
                              ),
                            );
                          },
                          onLongPress: () async {
                            await deleteRecipe(context, meal);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      height: 80,
                                      width: 80,
                                      child: FoodPreview(
                                        key: Key(meal.id.toString()),
                                        meal: meal,
                                      ),
                                    ),
                                    const SizedBox(width: 8.0),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(meal.name.capitalize(),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            meal.description,
                                            overflow: TextOverflow.ellipsis,
                                          )
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8.0),
                                    FutureBuilder<int>(
                                      future: meal.totalCalories,
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          return const Text("...");
                                        }
                                        if (snapshot.hasError) {
                                          return const Text(
                                            "Error loading calories",
                                            style: TextStyle(fontSize: 12),
                                          );
                                        }
                                        return Text(
                                          "${snapshot.data} kcal",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                              ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
