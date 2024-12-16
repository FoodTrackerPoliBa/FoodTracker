import 'package:flutter/material.dart';
import 'package:food_traker/src/backend/backend.dart';
import 'package:food_traker/src/backend/types/ingredient.dart';
import 'package:food_traker/src/dashboard/add_ingredient/ingredient_controller.dart';
import 'package:food_traker/src/dashboard/barcode_scanner/barcode_scanner.dart';
import 'package:food_traker/src/dashboard/common_widgets/ingredient_tile.dart';
import 'package:food_traker/src/dashboard/create_new_ingredient/create_new_ingredient.dart';
import 'package:food_traker/src/utils.dart';

class AddIngredient extends StatefulWidget {
  final IngredientController ingredientController;
  const AddIngredient({super.key, required this.ingredientController});

  @override
  State<AddIngredient> createState() => _AddIngredientState();
}

class _AddIngredientState extends State<AddIngredient> {
  List<Ingredient> get ingredients => widget.ingredientController.ingredients;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Add ingredients'),
          actions: [
            FilledButton(
                onPressed: () {
                  Navigator.of(context).pop(ingredients);
                },
                child: const Text('Save')),
          ],
        ),
        body: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none),
                          fillColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.12),
                          filled: true,
                          hintText: 'Search for ingredients',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: IconButton(
                              onPressed: () async {
                                final String? scannedBarcode = await Utils.push(
                                    context: context,
                                    routeName: 'barcodescanner',
                                    page: const BarcodeScannerWithOverlay());

                                _searchController.text = scannedBarcode ?? '';
                              },
                              icon: const Icon(Icons.barcode_reader))),
                    ),
                  ),
                ),
                IconButton(
                    icon: Icon(
                      Icons.add,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary),
                    onPressed: () {
                      Utils.push(
                          context: context,
                          routeName: 'create_new_ingredient',
                          page: const CreateNewIngredient());
                    })
              ],
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        child: Text('Ingredients to add',
                            style: Theme.of(context).textTheme.bodyMedium),
                      ),
                      Expanded(
                        child: AnimatedBuilder(
                          animation: Listenable.merge([
                            backend,
                            widget.ingredientController,
                            _searchController
                          ]),
                          builder: (context, child) {
                            return FutureBuilder<List<Ingredient>>(
                              future: backend.getFoods(),
                              initialData: ingredients,
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                if (snapshot.hasError) {
                                  return const Center(child: Text('Error'));
                                }
                                // ignore: no_leading_underscores_for_local_identifiers
                                List<Ingredient> _ingredients =
                                    snapshot.data!.toList();
                                _ingredients.removeWhere((ingredient) =>
                                    ingredients
                                        .map((e) => e.id)
                                        .contains(ingredient.id));
                                _ingredients = _ingredients.where((ingredient) {
                                  return ingredient.name.toLowerCase().contains(
                                          _searchController.text
                                              .toLowerCase()) ||
                                      (ingredient.barcode ?? "")
                                          .toLowerCase()
                                          .contains(_searchController.text
                                              .toLowerCase());
                                }).toList();
                                return ListView.builder(
                                    itemCount: _ingredients.length,
                                    itemBuilder: (context, index) {
                                      return IngredientTile(
                                          key: ValueKey<String>(
                                              _ingredients[index].barcode ??
                                                  _ingredients[index].name),
                                          ingredient: _ingredients[index],
                                          trailing: IconButton(
                                              onPressed: () {
                                                widget.ingredientController
                                                    .addIngredient(
                                                        _ingredients[index]);
                                              },
                                              icon: const Icon(Icons.add)));
                                    });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        child: Text('Ingredients added',
                            style: Theme.of(context).textTheme.bodyMedium),
                      ),
                      Expanded(
                        child: AnimatedBuilder(
                          animation: widget.ingredientController,
                          builder: (context, child) => ListView.builder(
                              itemCount: ingredients.length,
                              itemBuilder: (context, index) {
                                return IngredientTile(
                                    key: ValueKey<String>(
                                        ingredients[index].barcode ??
                                            ingredients[index].name),
                                    ingredient: ingredients[index],
                                    trailing: IconButton(
                                        onPressed: () {
                                          widget.ingredientController
                                              .removeIngredient(
                                                  ingredients[index]);
                                        },
                                        icon: const Icon(Icons.delete)));
                              }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
