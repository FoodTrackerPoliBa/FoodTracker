import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_traker/src/backend/backend.dart';
import 'package:food_traker/src/backend/gemini_manager.dart';
import 'package:food_traker/src/backend/meal_data.dart';
import 'package:food_traker/src/backend/types/exceptions/recipe_already_present.dart';
import 'package:food_traker/src/backend/types/ingredient.dart';
import 'package:food_traker/src/backend/types/recipe.dart';
import 'package:food_traker/src/backend/types/meal_session.dart';
import 'package:food_traker/src/backend/types/meal_type.dart';
import 'package:food_traker/src/dashboard/add_ingredient/add_ingredient.dart';
import 'package:food_traker/src/dashboard/add_ingredient/ingredient_controller.dart';
import 'package:food_traker/src/dashboard/add_meal_details/summary_details.dart';
import 'package:food_traker/src/dashboard/chatbot/chatbox.dart';
import 'package:food_traker/src/dashboard/common_widgets/ingredient_tile.dart';
import 'package:food_traker/src/dashboard/settings/recipes_selector.dart';
import 'package:food_traker/src/globals.dart';
import 'package:food_traker/src/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class AddMealDetails extends StatefulWidget {
  final Recipe? meal;
  final MealType? mealType;
  final MealSession? mealSession;
  final DateTime? timeSelected;
  AddMealDetails(
      {super.key,
      this.meal,
      this.mealType,
      this.mealSession,
      this.timeSelected}) {
    /// Only one of meal or mealSession should be provided
    assert((meal == null) != (mealSession == null));
  }

  @override
  State<AddMealDetails> createState() => _AddMealDetailsState();
}

class _AddMealDetailsState extends State<AddMealDetails> {
  final TextEditingController nTotalPortionsController =
      TextEditingController();
  final TextEditingController nEatenPortionsController =
      TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final IngredientController ingredientController = IngredientController();
  final GlobalKey addIconButtonKey = GlobalKey();

  bool calculatePrice = true;

  DateTime get timeSelected {
    if (widget.meal != null) {
      return widget.timeSelected!;
    } else {
      return widget.mealSession!.timestamp;
    }
  }

  @override
  void initState() {
    ingredientController.enableTextEditingControllers();
    if (widget.meal != null) {
      titleController.text = widget.meal!.name;
    } else {
      titleController.text = widget.mealSession!.name;
      calculatePrice = widget.mealSession!.price != null;
    }
    nTotalPortionsController.text =
        widget.mealSession?.nTotalPortions.toString() ?? '1';
    nEatenPortionsController.text =
        widget.mealSession?.nEatenPortions.toString() ?? '1';
    if (widget.meal != null) {
      ingredientController.addIngredients(widget.meal!.ingredients);
    } else {
      ingredientController.addIngredients(widget.mealSession!.ingredients);
    }

    backend.estimateTotalPortionsPastMeals(titleController.text).then((value) {
      if (widget.mealSession == null) {
        nTotalPortionsController.text = value.toString();
      }
      for (final Ingredient ingredient in ingredientController.ingredients) {
        if (widget.mealSession == null) {
          backend
              .getAmountPastMeals(
                  ingredient,
                  titleController.text,
                  int.parse(nTotalPortionsController.text),
                  int.parse(nEatenPortionsController.text))
              .then((value) {
            ingredientController.textEditingControllers[ingredient.id]!.text =
                value.toString();
          });
        } else {
          ingredientController.textEditingControllers[ingredient.id]!.text =
              ingredient.amount.toString();
        }
      }
    });

    super.initState();
  }

  Future<bool> askSaveAsNewRecipe() async {
    final saveNewRecipe = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Save as New Recipe'),
          content: const Text(
              'Do you want to save this combination of ingredients as a new recipe?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('No'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    return saveNewRecipe ?? false;
  }

  Future<String?> askNameOfNewRecipe() async {
    String? newRecipeName = titleController.text;
    final useMealName = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('New Recipe Name'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                  'Do you want to use the meal name as the new recipe name or assign a new one?'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      newRecipeName = titleController.text;
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('Use Meal Name'),
                  ),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text('Assign New Name'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
    if (useMealName == null) return null;

    if (!useMealName && mounted) {
      final nameController = TextEditingController();
      newRecipeName = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Enter New Recipe Name'),
            content: TextField(
                controller: nameController,
                decoration: const InputDecoration(
                    hintText: 'New Recipe Name', border: OutlineInputBorder())),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop(nameController.text);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    }
    return newRecipeName;
  }

  Future<void> saveMeal() async {
    final int? nTotalPortions = int.tryParse(nTotalPortionsController.text);
    final int? nEatenPortions = int.tryParse(nEatenPortionsController.text);
    if (nTotalPortions == null || nEatenPortions == null) {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text(
                'Please enter a valid number of portions or eaten portions'),
            actions: [
              TextButton(
                onPressed: () {
                  Utils.pop(
                      context: context, currentRouteName: 'add_meal_details');
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }
    if (nTotalPortions > 99) {
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('High Portion Number'),
            content: const Text(
                'Are you sure you want to add a high number of portions (over 99)?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('Yes'),
              ),
            ],
          );
        },
      );
      if (confirmed != true) {
        return;
      }
    }
    if (nEatenPortions > 99 && mounted) {
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('High Eaten Portion Number'),
            content: const Text(
                'Are you sure you want to eat a high number of portions (over 99)?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('Yes'),
              ),
            ],
          );
        },
      );
      if (confirmed != true) {
        return;
      }
    }
    if (titleController.text.isEmpty && mounted) {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Please enter a meal name'),
            actions: [
              TextButton(
                onPressed: () {
                  Utils.pop(
                      context: context, currentRouteName: 'add_meal_details');
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }
    for (final Ingredient ingredient in ingredientController.ingredients) {
      if (ingredientController
              .textEditingControllers[ingredient.id]!.text.isEmpty &&
          mounted) {
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('Please enter an amount for each ingredient'),
              actions: [
                TextButton(
                  onPressed: () {
                    Utils.pop(
                        context: context,
                        currentRouteName: 'add_meal_details dialog');
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        return;
      }
      final double? amount = double.tryParse(
          ingredientController.textEditingControllers[ingredient.id]!.text);
      if (amount == null && mounted) {
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content:
                  const Text('Please enter a valid number for each ingredient'),
              actions: [
                TextButton(
                  onPressed: () {
                    Utils.pop(
                        context: context,
                        currentRouteName: 'add_meal_details dialog');
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        return;
      }
      ingredient.amount = amount;
    }
    await backend.addMealDiaryEntry(
      mealType: widget.mealSession == null
          ? widget.mealType!
          : widget.mealSession!.mealType,
      timestamp: timeSelected,
      nTotalPortions: nTotalPortions,
      nEatenPortions: nEatenPortions,
      ingredients: ingredientController.ingredients,
      name: titleController.text,
      mealSession: widget.mealSession?.id,
      calculatePriceFlag: calculatePrice,
    );
    bool existsRecipe =
        await backend.existsRecipe(ingredientController.ingredients);
    if (!existsRecipe) {
      /// This is a new combination of ingredients
      /// We can ask to the user if he want to save this as a recipe
      bool response = await askSaveAsNewRecipe();
      if (response) {
        final String? mealName = await askNameOfNewRecipe();
        if (mealName != null) {
          try {
            await backend.addMeal(mealName, ingredientController.ingredients);
          } on RecipeAlreadyPresent catch (e) {
            if (mounted) await e.showAlert(context, mealName);
            return;
          }
        }
      }
    }
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Future<void> shareMeal() async {
    final String data = await backend.exportMealSession(widget.mealSession!.id);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/exported_meal.txt');
    await file.writeAsString(data);
    Share.shareXFiles([XFile(file.path)],
        text: 'Here is my meal: ${titleController.text}');
  }

  @override
  void dispose() {
    titleController.dispose();
    nTotalPortionsController.dispose();
    nEatenPortionsController.dispose();
    ingredientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meal details"),
        actions: [
          if (widget.mealSession != null)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: shareMeal,
            ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: saveMeal,
          ),
        ],
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          height: 60,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              maxLength: 100,
              controller: titleController,
              decoration: const InputDecoration(
                counterText: "",
                border: OutlineInputBorder(),
                labelText: 'Meal name',
                isDense: true,
              ),
            ),
          ),
        ),
        Row(
          children: [
            AnimatedBuilder(
                animation: nTotalPortionsController,
                builder: (context, snapshot) {
                  return Container(
                    width: 90,
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      textAlign: TextAlign.center,
                      controller: nTotalPortionsController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Portions',
                        isDense: true,
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      keyboardType: TextInputType.number,
                    ),
                  );
                }),
            Container(
              width: 90,
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                textAlign: TextAlign.center,
                controller: nEatenPortionsController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Eaten',
                  isDense: true,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number,
              ),
            ),
            if (trackPrices)
              Row(
                children: [
                  Checkbox(
                    value: calculatePrice,
                    onChanged: (value) {
                      setState(() {
                        calculatePrice = value!;
                      });
                    },
                  ),
                  const Text('Calculate\nprice'),
                ],
              ),
            const Spacer(),
            IconButton(
              key: addIconButtonKey,
              icon: const Icon(Icons.add),
              onPressed: () {
                final RenderBox renderBox = addIconButtonKey.currentContext!
                    .findRenderObject() as RenderBox;
                final position = renderBox.localToGlobal(Offset.zero);

                showMenu(
                  context: context,
                  position: RelativeRect.fromRect(
                    Rect.fromLTWH(
                        position.dx,
                        position.dy + renderBox.size.height,
                        renderBox.size.width,
                        renderBox.size.height),
                    Offset.zero & renderBox.size,
                  ),
                  items: <PopupMenuEntry>[
                    PopupMenuItem<String>(
                      value: 'add_recipe',
                      child: const Row(
                        children: [
                          Icon(Icons.receipt),
                          SizedBox(width: 8),
                          Text('Add recipe'),
                        ],
                      ),
                      onTap: () async {
                        final Recipe? recipeSelected = await Utils.push<Recipe>(
                            context: context,
                            routeName: 'add_recipes',
                            page: const RecipesSelector(
                              title: "Select recipe",
                              showEmptyRecipe: false,
                            ));
                        if (recipeSelected != null) {
                          ingredientController
                              .addIngredients(recipeSelected.ingredients);
                        }
                      },
                    ),
                    PopupMenuItem<String>(
                      value: 'add_ingredient',
                      child: const Row(
                        children: [
                          Icon(Icons.add_box),
                          SizedBox(width: 8),
                          Text('Add ingredients'),
                        ],
                      ),
                      onTap: () {
                        Utils.push(
                            context: context,
                            routeName: 'add_ingredient',
                            page: AddIngredient(
                                ingredientController: ingredientController));
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        Expanded(
          child: AnimatedBuilder(
              animation: ingredientController,
              builder: (context, snapshot) {
                return ListView.builder(
                  itemCount: ingredientController.ingredients.length,
                  itemBuilder: (context, index) {
                    final Ingredient ingredient =
                        ingredientController.ingredients[index];
                    return IngredientTile(
                        key: ValueKey<String>(
                            ingredient.barcode ?? ingredient.name),
                        ingredient: ingredient,
                        trailing: Row(children: [
                          SizedBox(
                            width: 30,
                            height: 30,
                            child: FittedBox(
                              child: IconButton(
                                  onPressed: () async {
                                    ingredientController
                                        .textEditingControllers[ingredient.id]!
                                        .text = (await backend
                                            .getAmountPastMeals(
                                                ingredient,
                                                titleController.text,
                                                int.parse(
                                                    nTotalPortionsController
                                                        .text),
                                                int.parse(
                                                    nEatenPortionsController
                                                        .text)))
                                        .toString();
                                  },
                                  icon: const Icon(Icons.autorenew)),
                            ),
                          ),
                          SizedBox(
                              width: 80,
                              child: TextField(
                                controller: ingredientController
                                    .textEditingControllers[ingredient.id],
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Amount',
                                  isDense: true,
                                  suffixText: 'g',
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters:
                                    CustomTextInputFormatter.doubleOnly(),
                                onChanged: (value) {
                                  ingredient.amount = double.tryParse(value);
                                },
                              )),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              ingredientController.removeIngredient(ingredient);
                            },
                          ),
                        ]));
                  },
                );
              }),
        ),
        SizedBox(
          height: 170,
          child: AnimatedBuilder(
              animation: Listenable.merge([
                nTotalPortionsController,
                nEatenPortionsController,
                ingredientController,
                backend
              ]),
              builder: (context, snapshot) {
                for (final Ingredient ingredient
                    in ingredientController.ingredients) {
                  if (ingredientController
                      .textEditingControllers[ingredient.id]!.text.isNotEmpty) {
                    ingredient.amount = double.tryParse(ingredientController
                        .textEditingControllers[ingredient.id]!.text);
                  }
                }
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.2),
                          width: 1),
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                    color: Theme.of(context).colorScheme.secondaryContainer,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4),
                    child: SummaryDetails(
                        ingredientsAmount: ingredientController.ingredients,
                        nTotalPortions:
                            int.tryParse(nTotalPortionsController.text) ?? 1,
                        nEatenPortions:
                            int.tryParse(nEatenPortionsController.text) ?? 1),
                  ),
                );
              }),
        )
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Utils.push(
              context: context,
              routeName: 'chat_box',
              page: ChatBox(
                controller: geminiManager.controller,
                mealData: MealData(
                  name: titleController.text,
                  nTotalPortions:
                      int.tryParse(nTotalPortionsController.text) ?? 1,
                  nEatenPortions:
                      int.tryParse(nEatenPortionsController.text) ?? 1,
                  ingredients: ingredientController.ingredients,
                ),
              ));
        },
        child: const Icon(Icons.message),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
