import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_traker/src/backend/backend.dart';
import 'package:food_traker/src/backend/types/exceptions/food_already_present.dart';
import 'package:food_traker/src/backend/types/ingredient.dart';
import 'package:food_traker/src/backend/types/exceptions/no_gemini_api_found.dart';
import 'package:food_traker/src/dashboard/barcode_scanner/barcode_scanner.dart';
import 'package:food_traker/src/globals.dart';
import 'package:food_traker/src/utils.dart';

class CreateNewIngredient extends StatefulWidget {
  const CreateNewIngredient({super.key, this.ingredientId});
  final int? ingredientId;
  @override
  State<CreateNewIngredient> createState() => _CreateNewIngredientState();
}

class _CreateNewIngredientState extends State<CreateNewIngredient> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  String? imageUrl;
  String? barcode;
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  final TextEditingController _satFatController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();
  final TextEditingController _sugarController = TextEditingController();
  final TextEditingController _fiberController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  Ingredient? ingredient;

  Future<void> showAlertNoNameConfigured() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('No name configured'),
            content: const Text('Please enter a name for the ingredient'),
            actions: [
              FilledButton(
                onPressed: () {
                  Utils.pop(
                      context: context,
                      currentRouteName: 'create_new_ingredient');
                },
                child: const Text('Ok'),
              ),
            ],
          );
        });
  }

  Future<void> showNoApiKeyConfigured() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('No API Key Configured'),
            content: const Text('Please configure an API Key in the settings'),
            actions: [
              FilledButton(
                onPressed: () {
                  Utils.pop(
                      context: context,
                      currentRouteName: 'create_new_ingredient');
                },
                child: const Text('Ok'),
              ),
            ],
          );
        });
  }

  Future<void> showGenericError(Exception e) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(
                'Unable to retrive the nutrient values, try again later or try to change the name of the food\n\n${e.toString()}'),
            actions: [
              FilledButton(
                onPressed: () {
                  Utils.pop(
                      context: context,
                      currentRouteName: 'create_new_ingredient');
                },
                child: const Text('Ok'),
              ),
            ],
          );
        });
  }

  bool isLoading = false;

  Future<void> showLoadingScreen() async {
    isLoading = true;
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Loading...'),
            content: const SizedBox(
                height: 40,
                width: 40,
                child: Center(child: CircularProgressIndicator())),
            actions: [
              TextButton(
                onPressed: () {
                  isLoading = false;
                  Utils.pop(
                      context: context,
                      currentRouteName: 'create_new_ingredient');
                },
                child: const Text('Cancel'),
              ),
            ],
          );
        });
    isLoading = false;
  }

  Future<void> aiIngredientSuggestions() async {
    try {
      if (_nameController.text.isEmpty) {
        await showAlertNoNameConfigured();
        return;
      }
      final Ingredient ingredient =
          await backend.getGeminiEstimatedFood(_nameController.text);
      _caloriesController.text = ingredient.calories.toString();
      _fatController.text = (ingredient.fat ?? 0).toString();
      _satFatController.text = (ingredient.saturedFat ?? 0).toString();
      _carbsController.text = (ingredient.carbohydrates ?? 0).toString();
      _sugarController.text = (ingredient.sugar ?? 0).toString();
      _fiberController.text = (ingredient.fiber ?? 0).toString();
      _proteinController.text = (ingredient.protein ?? 0).toString();
    } on NoGeminiApiFound {
      await showNoApiKeyConfigured();
    } on Exception catch (e) {
      await showGenericError(e);
    }
  }

  @override
  void initState() {
    if (widget.ingredientId != null) {
      backend.getFood(id: widget.ingredientId!).then((value) {
        ingredient = value;
        _nameController.text = ingredient!.name;
        _caloriesController.text = ingredient!.calories.toString();
        _fatController.text = (ingredient!.fat ?? 0).toString();
        _satFatController.text = (ingredient!.saturedFat ?? 0).toString();
        _carbsController.text = (ingredient!.carbohydrates ?? 0).toString();
        _sugarController.text = (ingredient!.sugar ?? 0).toString();
        _fiberController.text = (ingredient!.fiber ?? 0).toString();
        _proteinController.text = (ingredient!.protein ?? 0).toString();
        _priceController.text = (ingredient!.price ?? 0).toString();
        barcode = ingredient!.barcode;
        backend.getFoodImageUrl(ingredient!).then((value) {
          imageUrl = value;
          setState(() {});
        });
      });
    }
    if (trackPrices) {
      _priceController.text = '0';
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Add Ingredient'),
          actions: [
            IconButton(
              icon: const Icon(Icons.auto_fix_high),
              onPressed: () async {
                showLoadingScreen();
                await aiIngredientSuggestions();
                if (isLoading && context.mounted) Navigator.pop(context);
              },
            ),
            IconButton(
              icon: const Icon(Icons.camera_alt),
              onPressed: () async {
                final String? scannedBarcode = await Utils.push(
                    context: context,
                    routeName: 'barcode_scanner_without_overlay',
                    page: const BarcodeScannerWithOverlay());

                showLoadingScreen();
                barcode = scannedBarcode;
                if (barcode != null) {
                  try {
                    final Ingredient? ingredient =
                        await backend.getFoodFromBarcode(barcode!);
                    if (ingredient != null) {
                      _nameController.text = ingredient.name;
                      _caloriesController.text = ingredient.calories.toString();
                      _fatController.text = (ingredient.fat ?? '').toString();
                      _satFatController.text =
                          (ingredient.saturedFat ?? '').toString();
                      _carbsController.text =
                          (ingredient.carbohydrates ?? '').toString();
                      _sugarController.text =
                          (ingredient.sugar ?? '').toString();
                      _fiberController.text =
                          (ingredient.fiber ?? '').toString();
                      _proteinController.text =
                          (ingredient.protein ?? '').toString();
                      setState(() {
                        imageUrl = ingredient.imageUrl;
                      });
                    }
                    if (isLoading && context.mounted) Navigator.pop(context);
                  } on Exception catch (e) {
                    if (isLoading && context.mounted) Navigator.pop(context);
                    await showGenericError(e);
                  }
                }
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                imageUrl == null
                    ? const DefaultMealImage()
                    : Image(
                        image: CachedNetworkImageProvider(imageUrl!),
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _caloriesController,
                  decoration: const InputDecoration(
                    labelText: 'Calories (kcal per 100g)',
                    border: OutlineInputBorder(),
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a number';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _fatController,
                  decoration: const InputDecoration(
                    labelText: 'Fat (g per 100g)',
                    border: OutlineInputBorder(),
                  ),
                  inputFormatters: CustomTextInputFormatter.doubleOnly(),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a number';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _satFatController,
                  decoration: const InputDecoration(
                    labelText: 'Saturated Fat (g per 100g)',
                    border: OutlineInputBorder(),
                  ),
                  inputFormatters: CustomTextInputFormatter.doubleOnly(),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a number';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _carbsController,
                  decoration: const InputDecoration(
                    labelText: 'Carbohydrates (g per 100g)',
                    border: OutlineInputBorder(),
                  ),
                  inputFormatters: CustomTextInputFormatter.doubleOnly(),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a number';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _sugarController,
                  decoration: const InputDecoration(
                    labelText: 'Sugar (g per 100g)',
                    border: OutlineInputBorder(),
                  ),
                  inputFormatters: CustomTextInputFormatter.doubleOnly(),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a number';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _fiberController,
                  decoration: const InputDecoration(
                    labelText: 'Fiber (g per 100g)',
                    border: OutlineInputBorder(),
                  ),
                  inputFormatters: CustomTextInputFormatter.doubleOnly(),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a number';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _proteinController,
                  decoration: const InputDecoration(
                    labelText: 'Protein (g per 100g)',
                    border: OutlineInputBorder(),
                  ),
                  inputFormatters: CustomTextInputFormatter.doubleOnly(),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a number';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                if (trackPrices) ...[
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price (€ per 100g)',
                      border: OutlineInputBorder(),
                    ),
                    inputFormatters: CustomTextInputFormatter.doubleOnly(),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return null;
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (!_formKey.currentState!.validate()) {
              return;
            }
            final ingredient = Ingredient(
              id: this.ingredient?.id ?? -1,
              name: _nameController.text,
              barcode: barcode,
              count: 0,
              calories: int.parse(_caloriesController.text),
              fat: double.parse(_fatController.text),
              saturedFat: double.parse(_satFatController.text),
              carbohydrates: double.parse(_carbsController.text),
              sugar: double.parse(_sugarController.text),
              fiber: double.parse(_fiberController.text),
              protein: double.parse(_proteinController.text),
              price: double.parse(_priceController.text),
              imageUrl: imageUrl,
            );
            try {
              await backend.addFood(ingredient,
                  foodEditing: !(widget.ingredientId ==
                      null)); // if we doesn't have the ingredient id, it is a new ingredient, so we are not editing the food
              if (context.mounted) Navigator.pop(context);
            } on FoodAlreadyPresent {
              if (context.mounted) {
                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Food Already Present'),
                      content: Text(
                          'The food "${ingredient.name}" is already present in your list.'),
                      actions: [
                        FilledButton(
                          onPressed: () {
                            Utils.pop(
                                context: context,
                                currentRouteName: 'create_new_ingredient');
                          },
                          child: const Text('Ok'),
                        ),
                      ],
                    );
                  },
                );
              }
            } on Exception catch (e) {
              await showGenericError(e);
            }
          },
          child: const Icon(Icons.save),
        ));
  }
}

class DefaultMealImage extends StatelessWidget {
  const DefaultMealImage({super.key});

  @override
  Widget build(BuildContext context) => Container(
        height: 120,
        width: 120,
        color: Theme.of(context).colorScheme.secondaryContainer,
        child: Icon(
          Icons.restaurant_outlined,
          size: 48,
          color: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
      );
}
