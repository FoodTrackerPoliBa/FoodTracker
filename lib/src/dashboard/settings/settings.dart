import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:food_traker/setup.dart';
import 'package:food_traker/src/backend/backend.dart';
import 'package:food_traker/src/backend/gemini_manager.dart';
import 'package:food_traker/src/backend/user_data.dart';
import 'package:food_traker/src/dashboard/create_new_meal/create_new_meal.dart';
import 'package:food_traker/src/dashboard/settings/ingredients_view.dart';
import 'package:food_traker/src/dashboard/settings/preview_activity_level.dart';
import 'package:food_traker/src/dashboard/settings/preview_gender.dart';
import 'package:food_traker/src/dashboard/settings/preview_height.dart';
import 'package:food_traker/src/dashboard/settings/preview_weight.dart';
import 'package:food_traker/src/dashboard/settings/recipes_view.dart';
import 'package:food_traker/src/utils.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Future<void> previewGender(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return const PreviewGender();
        });
  }

  Future<void> previewHeight(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return const PreviewHeight();
        });
  }

  Future<void> previewWeight(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return const PreviewWeight();
        });
  }

  Future<void> previewActivityLevel(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return const PreviewActivityLevel();
        });
  }

  Future<void> previewGeminiApiKey() async {
    final TextEditingController controller = TextEditingController(
      text: await backend.getGeminiApiKey(),
    );
    if (mounted) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Gemini API Key'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Enter your Gemini API Key',
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Utils.pop(
                      context: context,
                      currentRouteName: 'settings_preview_gemini_api_key');
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  await backend.setGeminiApiKey(controller.text);
                  if (context.mounted) {
                    Utils.pop(
                        context: context,
                        currentRouteName: 'settings_preview_gemini_api_key');
                  }
                  setState(() {});
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<bool> askSureEraseDatabase() async {
    final TextEditingController controller = TextEditingController();
    final bool result = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Delete all data!"),
              content: SizedBox(
                width: 150,
                height: 60,
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                      hintText: "DELETE", border: OutlineInputBorder()),
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: const Text("Annulla")),
                FilledButton(
                    onPressed: () {
                      if (controller.text == "DELETE") {
                        Navigator.pop(context, true);
                      }
                    },
                    child: const Text("Conferma"))
              ],
            );
          },
        ) ??
        false;
    return result;
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Gender'),
            subtitle: const Text('Select your gender'),
            onTap: () async {
              await previewGender(context);
              setState(() {});
            },
            trailing: Text(UserData.gender!.value),
          ),
          ListTile(
            leading: const Icon(Icons.height),
            title: const Text('Height (cm)'),
            subtitle: const Text('Enter your height in centimeters'),
            onTap: () async {
              await previewHeight(context);
              setState(() {});
            },
            trailing: Text('${UserData.height} cm'),
          ),
          ListTile(
              leading: const Icon(Icons.scale),
              title: const Text('Weight (kg)'),
              subtitle: const Text('Enter your weight in kilograms'),
              onTap: () async {
                await previewWeight(context);
                setState(() {});
              },
              trailing: Text('${UserData.weight} kg')),
          ListTile(
            leading: const Icon(Icons.cake),
            title: const Text('Birthday'),
            subtitle: const Text('Select your birthday'),
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: UserData.birthday,
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                await UserData.setBirthday(picked);
                setState(() {});
              }
            },
            trailing: Text(DateFormat('dd/MM/yyyy').format(UserData.birthday!)),
          ),
          ListTile(
            leading: const Icon(Icons.directions_run),
            title: const Text('Activity Level'),
            subtitle: const Text('Select your activity level'),
            onTap: () async {
              await previewActivityLevel(context);
              setState(() {});
            },
            trailing: Text(UserData.activityLevel!.value),
          ),
          ListTile(
            leading: const Icon(Icons.fastfood),
            title: const Text('Ingredients'),
            subtitle: const Text('View and manage your ingredients'),
            onTap: () {
              Utils.push(
                      context: context,
                      routeName: 'ingredients_view',
                      page: const IngredientsView())
                  .then((_) {
                setState(() {});
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text('Recipes'),
            subtitle: const Text('View and manage your recipes'),
            onTap: () {
              Utils.push(
                  context: context,
                  routeName: 'recipes_view',
                  page: RecipesSelector(
                    title: "List of recipes",
                    showEmptyRecipe: false,
                    onRecipePressed: (recipe) {
                      Utils.push(
                        context: context,
                        routeName: 'create_new_meal',
                        page: CreateNewMeal(
                          meal: recipe,
                        ),
                      );
                    },
                  )).then((_) {
                setState(() {});
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.vpn_key),
            title: const Text('Gemini API Key'),
            subtitle: const Text('Configure your Gemini API Key'),
            onTap: () async {
              await previewGeminiApiKey();
              await geminiManager.init(raiseError: false);
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Export All Data'),
            subtitle: const Text('Export your data as a file'),
            onTap: () async {
              final data = await backend.exportDatabase();
              final tempDir = await getTemporaryDirectory();
              final file = File('${tempDir.path}/exported_data.txt');
              await file.writeAsString(data);

              Share.shareXFiles([XFile(file.path)],
                  text: 'Here is my exported data.');
            },
          ),
          ListTile(
              leading: const Icon(Icons.food_bank),
              title: const Text('Export Ingredients and Recipes'),
              subtitle:
                  const Text('Export your ingredients and recipes as a file'),
              onTap: () async {
                final String data = await backend.exportIngredientsAndRecipes();
                final tempDir = await getTemporaryDirectory();
                final file = File(
                    '${tempDir.path}/exported_ingredients_and_recipes.txt');
                await file.writeAsString(data);
                Share.shareXFiles([XFile(file.path)],
                    text: 'Here is my ingredients and recipes data.');
              }),
          ListTile(
            leading: const Icon(Icons.file_upload),
            title: const Text('Import All Data'),
            subtitle: const Text('Import your all data from a backup file'),
            onTap: () async {
              await Utils.importBackup();
              setState(() {});
            },
          ),
          ListTile(
              leading: const Icon(Icons.menu_book),
              title: const Text('Import Ingredients and Recipes'),
              subtitle: const Text(
                  'Import your ingredients and recipes from a backup file'),
              onTap: () async {
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['txt'],
                );
                if (result != null && result.files.single.path != null) {
                  final file = File(result.files.single.path!);
                  final data = await file.readAsString();
                  await backend.importIngredientsAndRecipes(data);
                  setState(() {});
                }
              }),
          ListTile(
              tileColor: Theme.of(context).colorScheme.error,
              textColor: Theme.of(context).colorScheme.onError,
              iconColor: Theme.of(context).colorScheme.onError,
              leading: const Icon(Icons.menu_book),
              title: const Text('Delete all data'),
              subtitle: const Text('WARNING! All data will be erased'),
              onTap: () async {
                if (await askSureEraseDatabase()) {
                  await backend.eraseDatabase();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const Setup(),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  }
                }
              })
        ],
      ),
    );
  }
}
