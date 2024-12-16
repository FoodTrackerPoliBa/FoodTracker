import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:food_traker/src/backend/backend.dart';
import 'package:food_traker/src/backend/types/ingredient.dart';
import 'package:food_traker/src/backend/types/recipe.dart';
import 'package:food_traker/src/backend/types/meal_type.dart';
import 'package:food_traker/src/dashboard/add_meal_details/add_meal_details.dart';
import 'package:food_traker/src/dashboard/common_widgets/ingredient_tile.dart';
import 'package:food_traker/src/dashboard/create_new_meal/create_new_meal.dart';
import 'package:food_traker/src/utils.dart';

class AddMealIntake extends StatefulWidget {
  const AddMealIntake(
      {super.key, required this.mealType, required this.timeSelected});
  final MealType mealType;
  final DateTime timeSelected;

  @override
  State<AddMealIntake> createState() => _AddMealIntakeState();
}

class _AddMealIntakeState extends State<AddMealIntake> {
  final TextEditingController _searchController = TextEditingController();
  Future<void> loadMealFromFile() async {
    final filePickerResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );
    if (filePickerResult != null) {
      final file = File(filePickerResult.files.single.path!);
      final String data = await file.readAsString();
      await backend.importMealSession(data, widget.timeSelected);
      if (mounted) {
        Utils.pop(context: context, currentRouteName: 'add_meal_intake');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mealType.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: loadMealFromFile,
          ),
          IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Utils.push(
                    context: context,
                    routeName: "create_new_meal",
                    page: const CreateNewMeal());
              }),
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
                hintText: 'Search for meals',
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: AnimatedBuilder(
                animation: Listenable.merge([backend, _searchController]),
                builder: (context, snapshot) {
                  return FutureBuilder<List<Recipe>>(
                    future: backend.getRecipes(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Center(child: Text('Error loading meals'));
                      }
                      List<Recipe> meals = snapshot.data!;
                      if (meals.isEmpty) {
                        return const Center(child: Text('No meals found'));
                      }

                      if (_searchController.text.isNotEmpty) {
                        meals = meals.where((meal) {
                          return meal.name
                              .toLowerCase()
                              .contains(_searchController.text.toLowerCase());
                        }).toList();
                      }

                      return ListView.builder(
                        itemCount: meals.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4.0, horizontal: 8.0),
                                child: InkWell(
                                  onTap: () {
                                    Utils.push(
                                      context: context,
                                      routeName: "add_meal_details",
                                      page: AddMealDetails(
                                        meal: Recipe(
                                            id: 0,
                                            name: "",
                                            ingredients: [],
                                            count: 0),
                                        mealType: widget.mealType,
                                        timeSelected: widget.timeSelected,
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.0),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.12),
                                    ),
                                    child: const Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add),
                                          SizedBox(width: 8.0),
                                          Text("Add ingredients manually"),
                                        ],
                                      ),
                                    ),
                                  ),
                                ));
                          }
                          final Recipe meal = meals[index - 1];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4.0, horizontal: 8.0),
                            child: InkWell(
                              onTap: () {
                                Utils.push(
                                  context: context,
                                  routeName: "add_meal_details",
                                  page: AddMealDetails(
                                    meal: meal,
                                    mealType: widget.mealType,
                                    timeSelected: widget.timeSelected,
                                  ),
                                );
                              },
                              child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.0),
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
                                            )),
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
                                                height: 15,
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
                                                  style:
                                                      TextStyle(fontSize: 12),
                                                );
                                              }
                                              return Text(
                                                  "${snapshot.data} kcal",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium!
                                                      .copyWith(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onSurface));
                                            }),
                                      ],
                                    ),
                                  )),
                            ),
                          );
                        },
                      );
                    },
                  );
                }),
          ),
        ],
      ),
    );
  }
}

class FoodPreview extends StatelessWidget {
  final Recipe meal;
  const FoodPreview({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: GridView.builder(
        itemCount: meal.ingredients.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: 1,
          mainAxisSpacing: 1,
          crossAxisCount: 2,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          final Ingredient ingredient = meal.ingredients[index];
          return PreviewThumbIngredient(ingredient: ingredient);
        },
      ),
    );
  }
}
