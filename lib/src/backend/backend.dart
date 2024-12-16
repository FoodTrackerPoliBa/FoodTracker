import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:food_traker/src/backend/first_start_setup.dart';
import 'package:food_traker/src/backend/gemini_manager.dart';
import 'package:food_traker/src/backend/types/activity.dart';
import 'package:food_traker/src/backend/types/activity_level.dart';
import 'package:food_traker/src/backend/types/daily_overview_data.dart';
import 'package:food_traker/src/backend/types/exceptions/food_already_present.dart';
import 'package:food_traker/src/backend/types/exceptions/insane_value.dart';
import 'package:food_traker/src/backend/types/exceptions/no_food_founded.dart';
import 'package:food_traker/src/backend/types/gender.dart';
import 'package:food_traker/src/backend/types/ingredient.dart';
import 'package:food_traker/src/backend/types/meal_session.dart';
import 'package:food_traker/src/backend/types/meal_type.dart';
import 'package:food_traker/src/backend/types/recipe.dart';
import 'package:food_traker/src/backend/user_data.dart';
import 'package:food_traker/src/globals.dart';
import 'package:openfoodfacts/openfoodfacts.dart' as off;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:http/http.dart' as http;

class Backend extends ChangeNotifier {
  Database? _db;
  String appVersion = "";
  Database get db {
    if (_db == null) {
      throw Exception('Database is not initialized');
    }
    return _db!;
  }

  bool get isInitialized => _db != null;

  Future<String> getDBPath() async {
    final DatabaseFactory databaseFactory = databaseFactoryFfi;
    final String databasesPath;
    if (Platform.isAndroid) {
      databasesPath = await getDatabasesPath();
    } else {
      databasesPath = await databaseFactory.getDatabasesPath();
    }
    return '$databasesPath${Platform.pathSeparator}food_tracker_2.db';
    // return ':memory:';
  }

  Future<void> init() async {
    /// Create the database structure as following:
    ///
    /// Table: Foods
    /// - id: the id of the food
    /// - barcode: the barcode of the food
    /// - name: the name of the food
    /// --- All values are for 100g of the food ---
    /// - energy: energy value of the food (in kcal)
    /// - fat: fat value of the food (in g)
    /// - saturated_fat: saturated fat value of the food (in g)
    /// - carbohydrates: carbohydrate value of the food (in g)
    /// - sugar: sugar value of the food (in g)
    /// - fiber: fiber value of the food (in g)
    /// - protein: protein value of the food (in g)
    /// - price: price of the food (in €/100g)
    /// - imageUrl: the image url of the food
    ///
    /// Table: Recipes
    /// - id: the id of the recipe
    /// - name: the name of the recipe
    ///
    /// Table: RecipesIngredients
    /// - food_id: the id of the food in the recipe
    /// - recipe_id: the id of the recipe
    ///
    /// Table: MealDiary
    /// - id: the id of the meal
    /// - food_id: the id of the food eaten
    /// - meal_session: the meal session
    /// - amount: amount of food in the meal (in g)
    ///
    /// Table: MealSession
    /// - id: the id of the meal session
    /// - name: the name of the meal session
    /// - timestamp: the timestamp of the meal session
    /// - meal_type: the type of the meal session
    /// - n_total_portions: the total number of portions with this ingredients
    /// - n_portions_eaten: the number of portions eaten
    /// - price: the price of the meal, the sum of all ingredients price divided by n_total_portions * n_portions_eaten
    ///
    /// - Table: Activities
    /// - id: the id of the activity
    /// - name: the name of the activity
    /// - energy: energy value of the activity (in kcal)
    /// - timestamp: timestamp of when the activity was done
    ///
    /// - Table: UserData
    /// - id: the id of the user data, it is only one row and has 1 as id
    /// - height: the height of the user in cm
    /// - weight: the weight of the user in kg
    /// - birthday: the birthday of the user in milliseconds since epoch
    /// - gender: The gender of the user, 0 if is a female, 1 if a male
    /// - activity_level: the activity level of the user, index of ActivityLevel enum

    if (isInitialized) return;
    final DatabaseFactory databaseFactory = databaseFactoryFfi;

    _db = await databaseFactory.openDatabase((await getDBPath()),
        //':memory:',
        options: OpenDatabaseOptions(
          version: 1,
          onConfigure: (db) async {
            await db.execute('PRAGMA foreign_keys = ON');
          },
          onCreate: (db, version) async {
            await db.execute('''CREATE TABLE IF NOT EXISTS Foods (
                id INTEGER PRIMARY KEY,
                barcode TEXT UNIQUE,
                name TEXT UNIQUE,
                energy INTEGER,
                fat REAL,
                saturated_fat REAL,
                carbohydrates REAL,
                sugar REAL,
                fiber REAL,
                protein REAL,
                price REAL,
                imageUrl TEXT
            )''');

            await db.execute('''CREATE TABLE IF NOT EXISTS Recipes (
              id INTEGER PRIMARY KEY,
              name TEXT UNIQUE
            )''');

            await db.execute('''CREATE TABLE IF NOT EXISTS RecipesIngredients (
                food_id INTEGER,
                recipe_id INTEGER,
                PRIMARY KEY (food_id, recipe_id),
                FOREIGN KEY (food_id) REFERENCES Foods(id) ON DELETE RESTRICT,
                FOREIGN KEY (recipe_id) REFERENCES Recipes(id) ON DELETE CASCADE
            )''');

            await db.execute('''CREATE TABLE IF NOT EXISTS MealDiary (
                id INTEGER PRIMARY KEY,
                food_id INTEGER,
                meal_session INTEGER,
                amount REAL,
                FOREIGN KEY (food_id) REFERENCES Foods(id),
                FOREIGN KEY (meal_session) REFERENCES MealSession(id) ON DELETE CASCADE
            )''');

            await db.execute('''CREATE TABLE IF NOT EXISTS MealSession (
                id INTEGER PRIMARY KEY,
                name TEXT,
                timestamp INTEGER,
                meal_type INTEGER,
                n_total_portions INTEGER,
                n_portions_eaten INTEGER,
                price REAL
            )''');

            await db.execute('''CREATE TABLE IF NOT EXISTS Activities (
                id INTEGER PRIMARY KEY,
                name TEXT,
                energy INTEGER,
                timestamp INTEGER
            )''');

            await db.execute('''CREATE TABLE IF NOT EXISTS UserData (
                id INTEGER PRIMARY KEY,
                name TEXT DEFAULT NULL,
                height REAL DEFAULT NULL,
                weight REAL DEFAULT NULL,
                birthday INTEGER DEFAULT NULL,
                gender INTEGER DEFAULT NULL,
                activity_level INTEGER DEFAULT NULL
            )''');

            /// Insert the first row if not exists with all NULL value
            await db.execute('''
              INSERT OR IGNORE INTO UserData (id) VALUES (1)
            ''');
          },
        ));
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appVersion = packageInfo.version;
  }

  Future<String> exportDatabase() async {
    Map<String, dynamic> data = {};
    final List<Map<String, Object?>> foods = await db.query('Foods');
    data['foods'] = foods;
    final List<Map<String, Object?>> recipes = await db.query('Recipes');
    data['recipes'] = recipes;
    final List<Map<String, Object?>> recipesIngredients =
        await db.query('RecipesIngredients');
    data['recipesIngredients'] = recipesIngredients;
    final List<Map<String, Object?>> mealDiary = await db.query('MealDiary');
    data['mealDiary'] = mealDiary;
    final List<Map<String, Object?>> mealSession =
        await db.query('MealSession');
    data['mealSession'] = mealSession;
    final List<Map<String, Object?>> activities = await db.query('Activities');
    data['activities'] = activities;
    final List<Map<String, Object?>> userData = await db.query('UserData');
    data['userData'] = userData;
    String json = jsonEncode(data);
    return json;
  }

  Future<String> exportIngredientsAndRecipes() async {
    final Map<String, dynamic> data = {};
    final List<Map<String, Object?>> ingredients = await db.query('Foods');
    data['ingredients'] = ingredients;
    final List<Map<String, Object?>> recipes = await db.query('Recipes');
    data['recipes'] = recipes;
    final List<Map<String, Object?>> recipesIngredients =
        await db.query('RecipesIngredients');
    data['recipesIngredients'] = recipesIngredients;
    String json = jsonEncode(data);
    return json;
  }

  Future<String> exportMealSession(int mealSessionId) async {
    final Map<String, dynamic> data = {};
    final List<Map<String, Object?>> mealSessionResult = await db
        .query('MealSession', where: 'id = ?', whereArgs: [mealSessionId]);
    if (mealSessionResult.isEmpty) {
      return '';
    }
    final List<Map<String, Object?>> mealDiary = await db.query('MealDiary',
        where: 'meal_session = ?', whereArgs: [mealSessionId]);
    final Map<String, Object?> mealSessionData = mealSessionResult.first;
    data['mealSession'] = {
      "name": mealSessionData['name'] as String,
      "meal_type": mealSessionData['meal_type'] as int,
      "n_total_portions": mealSessionData['n_total_portions'] as int,
      "n_portions_eaten": mealSessionData['n_portions_eaten'] as int,
      "price": mealSessionData['price'] as double,
    };
    data['mealDiary'] = [];
    for (final Map<String, dynamic> mealDiaryEntry in mealDiary) {
      final Ingredient food =
          await backend.getFood(id: mealDiaryEntry['food_id']);
      data['mealDiary'].add({
        "food_id": mealDiaryEntry['food_id'] as int,
        "food_data": {
          "id": mealDiaryEntry['food_id'] as int,
          "barcode": food.barcode,
          "name": food.name,
          "energy": food.calories,
          "fat": food.fat,
          "saturated_fat": food.saturedFat,
          "carbohydrates": food.carbohydrates,
          "sugar": food.sugar,
          "fiber": food.fiber,
          "protein": food.protein,
          "price": food.price,
          "imageUrl": food.imageUrl,
        },
        "amount": mealDiaryEntry['amount'] as double,
      });
    }
    String json = jsonEncode(data);
    return json;
  }

  Future<int> importMealSession(String data, DateTime timeAdd) async {
    final Map<String, dynamic> jsonData = jsonDecode(data);
    final Map<String, Object?> mealSessionData = jsonData['mealSession'];
    final List<Map<String, Object?>> mealDiaryData =
        (jsonData['mealDiary'] as List)
            .map((e) => e as Map<String, Object?>)
            .toList();
    final int mealSessionId = await db.insert(
        'MealSession',
        mealSessionData
          ..addAll({
            "timestamp": timeAdd.millisecondsSinceEpoch,
          }));
    for (final Map<String, dynamic> mealDiaryEntry in mealDiaryData) {
      Ingredient food;
      try {
        food = await backend.getFood(name: mealDiaryEntry['food_data']['name']);
        if (food != Ingredient.fromDict(mealDiaryEntry['food_data'], 0, 0)) {
          throw NoFoodFounded();
        }
      } on NoFoodFounded {
        print("No food founded, adding it to the database");
        final int foodId = await db.insert(
          'Foods',
          mealDiaryEntry['food_data'] as Map<String, Object?>,
        );
        food = await backend.getFood(id: foodId);
      }

      await db.insert('MealDiary', {
        "meal_session": mealSessionId,
        "food_id": food.id,
        "amount": mealDiaryEntry["amount"]
      });
    }
    notify();
    return mealSessionId;
  }

  Future<void> importDatabase(String data) async {
    final Map<String, dynamic> json = jsonDecode(data);
    final List<Map<String, Object?>> foods =
        (json['foods'] as List).map((e) => e as Map<String, Object?>).toList();
    final List<Map<String, Object?>> recipes = (json['recipes'] as List)
        .map((e) => e as Map<String, Object?>)
        .toList();
    final List<Map<String, Object?>> recipesIngredients =
        (json['recipesIngredients'] as List)
            .map((e) => e as Map<String, Object?>)
            .toList();
    final List<Map<String, Object?>> mealDiary = (json['mealDiary'] as List)
        .map((e) => e as Map<String, Object?>)
        .toList();
    final List<Map<String, Object?>> mealSession = (json['mealSession'] as List)
        .map((e) => e as Map<String, Object?>)
        .toList();
    final List<Map<String, Object?>> activities = (json['activities'] as List)
        .map((e) => e as Map<String, Object?>)
        .toList();
    final List<Map<String, Object?>> userData = (json['userData'] as List)
        .map((e) => e as Map<String, Object?>)
        .toList();
    await db.execute('PRAGMA foreign_keys = OFF');
    await db.transaction((txn) async {
      await txn.execute('DELETE FROM Foods');
      for (final Map<String, Object?> food in foods) {
        await txn.insert('Foods', food);
      }
      await txn.execute('DELETE FROM Recipes');
      for (final Map<String, Object?> recipe in recipes) {
        await txn.insert('Recipes', recipe);
      }
      await txn.execute('DELETE FROM RecipesIngredients');
      for (final Map<String, Object?> recipeIngredient in recipesIngredients) {
        await txn.insert('RecipesIngredients', recipeIngredient);
      }
      await txn.execute('DELETE FROM MealDiary');
      for (final Map<String, Object?> meal in mealDiary) {
        await txn.insert('MealDiary', meal);
      }
      await txn.execute('DELETE FROM MealSession');
      for (final Map<String, Object?> meal in mealSession) {
        await txn.insert('MealSession', meal);
      }
      await txn.execute('DELETE FROM Activities');
      for (final Map<String, Object?> activity in activities) {
        await txn.insert('Activities', activity);
      }
      for (final Map<String, Object?> user in userData) {
        await txn.update('UserData', user, where: 'id = 1');
      }
    });
    await db.execute('PRAGMA foreign_keys = ON');
    await UserData.init();
    notify();
  }

  Future<void> importIngredientsAndRecipes(String data) async {
    final Map<String, dynamic> json = jsonDecode(data);
    final List<Map<String, Object?>> ingredients = (json['ingredients'] as List)
        .map((e) => e as Map<String, Object?>)
        .toList();
    final List<Map<String, Object?>> recipes = (json['recipes'] as List)
        .map((e) => e as Map<String, Object?>)
        .toList();
    final List<Map<String, Object?>> recipesIngredients =
        (json['recipesIngredients'] as List)
            .map((e) => e as Map<String, Object?>)
            .toList();
    await db.transaction((txn) async {
      await txn.execute('DELETE FROM Foods');
      for (final Map<String, Object?> ingredient in ingredients) {
        await txn.insert('Foods', ingredient);
      }
      await txn.execute('DELETE FROM Recipes');
      for (final Map<String, Object?> recipe in recipes) {
        await txn.insert('Recipes', recipe);
      }
      await txn.execute('DELETE FROM RecipesIngredients');
      for (final Map<String, Object?> recipeIngredient in recipesIngredients) {
        await txn.insert('RecipesIngredients', recipeIngredient);
      }
    });
    notify();
  }

  Future<double> calculateCalories({DateTime? date}) async {
    final DateTime now = date ?? DateTime.now();
    final DateTime startOfDay = DateTime(now.year, now.month, now.day);
    final DateTime endOfDay =
        DateTime(now.year, now.month, now.day, 23, 59, 59);

    /// Since all energy are for 100g we need to divide the food amount by 100 and multiply it by the amount value
    final List<Map<String, Object?>> dailyFoodEnergy = await db.rawQuery('''
      SELECT SUM((amount/ms.n_total_portions*ms.n_portions_eaten) / 100 * energy) AS energy FROM MealDiary
      INNER JOIN Foods ON MealDiary.food_id = Foods.id INNER JOIN MealSession ms ON ms.id = MealDiary.meal_session
      WHERE timestamp >= ? AND timestamp <= ?
      ''',
        [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch]);
    return (dailyFoodEnergy[0]['energy'] as double?) ?? 0;
  }

  Future<double> calculatePrice({DateTime? date}) async {
    final DateTime now = date ?? DateTime.now();
    final DateTime startOfDay = DateTime(now.year, now.month, now.day);
    final DateTime endOfDay =
        DateTime(now.year, now.month, now.day, 23, 59, 59);

    final List<Map<String, Object?>> priceRaw = await db.rawQuery('''
SELECT SUM(price) FROM MealSession where timestamp >= ? AND timestamp <= ?
''', [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch]);
    return (priceRaw[0]['SUM(price)'] as double?) ?? 0;
  }

  Future<int> calculateCarbs({DateTime? date}) async {
    final DateTime now = date ?? DateTime.now();
    final DateTime startOfDay = DateTime(now.year, now.month, now.day);
    final DateTime endOfDay =
        DateTime(now.year, now.month, now.day, 23, 59, 59);

    final List<Map<String, Object?>> dailyFoodCarbs = await db.rawQuery('''
      SELECT SUM((amount/ms.n_total_portions*ms.n_portions_eaten) / 100 * carbohydrates) AS carbohydrates FROM MealDiary
      INNER JOIN Foods ON MealDiary.food_id = Foods.id INNER JOIN MealSession ms ON ms.id = MealDiary.meal_session
      WHERE timestamp >= ? AND timestamp <= ?
      ''',
        [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch]);
    return (dailyFoodCarbs[0]['carbohydrates'] as double?)?.round() ?? 0;
  }

  Future<int> calculateProtein({DateTime? date}) async {
    final DateTime now = date ?? DateTime.now();
    final DateTime startOfDay = DateTime(now.year, now.month, now.day);
    final DateTime endOfDay =
        DateTime(now.year, now.month, now.day, 23, 59, 59);

    final List<Map<String, Object?>> dailyFoodProtein = await db.rawQuery('''
      SELECT SUM((amount/ms.n_total_portions*ms.n_portions_eaten) / 100 * protein) AS protein FROM MealDiary
      INNER JOIN Foods ON MealDiary.food_id = Foods.id INNER JOIN MealSession ms ON ms.id = MealDiary.meal_session
      WHERE timestamp >= ? AND timestamp <= ?
      ''',
        [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch]);
    return (dailyFoodProtein[0]['protein'] as double?)?.round() ?? 0;
  }

  Future<int> calculateFat({DateTime? date}) async {
    final DateTime now = date ?? DateTime.now();
    final DateTime startOfDay = DateTime(now.year, now.month, now.day);
    final DateTime endOfDay =
        DateTime(now.year, now.month, now.day, 23, 59, 59);

    final List<Map<String, Object?>> dailyFoodFat = await db.rawQuery('''
      SELECT SUM((amount/ms.n_total_portions*ms.n_portions_eaten) / 100 * fat) AS fat FROM MealDiary
      INNER JOIN Foods ON MealDiary.food_id = Foods.id INNER JOIN MealSession ms ON ms.id = MealDiary.meal_session
      WHERE timestamp >= ? AND timestamp <= ?
      ''',
        [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch]);
    return (dailyFoodFat[0]['fat'] as double?)?.round() ?? 0;
  }

  Future<int> calculateSugar({DateTime? date}) async {
    final DateTime now = date ?? DateTime.now();
    final DateTime startOfDay = DateTime(now.year, now.month, now.day);
    final DateTime endOfDay =
        DateTime(now.year, now.month, now.day, 23, 59, 59);

    final List<Map<String, Object?>> dailyFoodSugar = await db.rawQuery('''
      SELECT SUM((amount/ms.n_total_portions*ms.n_portions_eaten) / 100 * sugar) AS sugar FROM MealDiary
      INNER JOIN Foods ON MealDiary.food_id = Foods.id INNER JOIN MealSession ms ON ms.id = MealDiary.meal_session
      WHERE timestamp >= ? AND timestamp <= ?
      ''',
        [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch]);
    return (dailyFoodSugar[0]['sugar'] as double?)?.round() ?? 0;
  }

  Future<DailyOverviewData> getDailyOverviewData(
      {required DateTime date}) async {
    final double foodEnergy = await calculateCalories(date: date);
    final int activityEnergy = await calculateTotalBurned(date: date);
    final int carbs = await calculateCarbs(date: date);
    final int protein = await calculateProtein(date: date);
    final int fat = await calculateFat(date: date);
    final int sugar = await calculateSugar(date: date);
    final double price = await calculatePrice(date: date);
    return DailyOverviewData(
        burned: activityEnergy.round(),
        supplied: foodEnergy.round(),
        price: price,
        target: NutrientValues(
            sugar: await UserData.sugarGoal(date: date),
            carbs: await UserData.carbsGoal(date: date),
            protein: await UserData.proteinGoal(date: date),
            fat: await UserData.fatGoal(date: date),
            kcalories: await UserData.dailyEnergyGoal(date: date)),
        actual: NutrientValues(
            sugar: sugar,
            carbs: carbs,
            protein: protein,
            fat: fat,
            kcalories: foodEnergy.round()));
  }

  Future<int> calculateTotalBurned({DateTime? date}) async {
    final DateTime now = date ?? DateTime.now();
    final DateTime startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);
    final DateTime endOfDay =
        DateTime(now.year, now.month, now.day, 23, 59, 59);
    final List<Map<String, Object?>> dailyActivityEnergy = await db.rawQuery('''
      SELECT SUM(energy) AS energy FROM Activities
      WHERE timestamp >= ? AND timestamp <= ?
      ''',
        [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch]);
    return (dailyActivityEnergy[0]['energy'] as int?) ?? 0;
  }

  /// *NOTE*: You shouldn't call this function from backend module, use
  /// ```dart
  /// UserData.setName instead
  Future<void> setName(String name) async {
    await db.execute('''
      UPDATE UserData SET name = ? WHERE id = 1
    ''', [name]);
    notify();
  }

  /// *NOTE*: You shouldn't call this function from backend module, use
  /// ```dart
  /// UserData.setBirthday instead
  Future<void> setBirthday(DateTime birthday) async {
    await db.execute('''
      UPDATE UserData SET birthday = ? WHERE id = 1
    ''', [birthday.millisecondsSinceEpoch]);
    notify();
  }

  /// *NOTE*: You shouldn't call this function from backend module, use
  /// ```dart
  /// UserData.setHeight instead
  Future<void> setHeight(int height) async {
    if (height > 300 || height < 50) {
      throw InsaneValueException();
    }
    await db.execute('''
      UPDATE UserData SET height = ? WHERE id = 1
    ''', [height]);
    notify();
  }

  /// *NOTE*: You shouldn't call this function from backend module, use
  /// ```dart
  /// UserData.setWeight instead
  Future<void> setWeight(double weight) async {
    if (weight > 300 || weight < 30) {
      throw InsaneValueException();
    }
    await db.execute('''
      UPDATE UserData SET weight = ? WHERE id = 1
    ''', [weight]);
    notify();
  }

  /// *NOTE*: You shouldn't call this function from backend module, use
  /// ```dart
  /// UserData.setGender instead
  Future<void> setGender(Gender gender) async {
    await db.execute('''
      UPDATE UserData SET gender = ? WHERE id = 1
    ''', [gender.index]);
    notify();
  }

  /// *NOTE*: You shouldn't call this function from backend module, use
  /// ```dart
  /// UserData.setActivityLevel instead
  Future<void> setActivityLevel(ActivityLevel activityLevel) async {
    await db.execute('''
      UPDATE UserData SET activity_level = ? WHERE id = 1
    ''', [activityLevel.index]);
    notify();
  }

  Future<void> addActivity(
      String name, int calories, DateTime timestamp) async {
    await db.insert('Activities', {
      'name': name,
      'energy': calories,
      'timestamp': timestamp.millisecondsSinceEpoch
    });
    notify();
  }

  Future<void> editActivity(int id, String name, int calories) async {
    await db.update(
        'Activities',
        {
          'name': name,
          'energy': calories,
        },
        where: 'id = ?',
        whereArgs: [id]);
  }

  Future<void> deleteActivity(int id) async {
    await db.delete('Activities', where: 'id = ?', whereArgs: [id]);
    notify();
  }

  Future<String?> getName() async {
    final result =
        await db.query('UserData', where: 'id = ?', whereArgs: [1], limit: 1);
    return result.first['name'] as String?;
  }

  Future<DateTime?> getBirthday() async {
    final result =
        await db.query('UserData', where: 'id = ?', whereArgs: [1], limit: 1);
    if (result.first['birthday'] == null) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(result.first['birthday'] as int);
  }

  Future<int?> getHeight() async {
    final result =
        await db.query('UserData', where: 'id = ?', whereArgs: [1], limit: 1);
    if (result.first['height'] == null) {
      return null;
    }
    return (result.first['height'] as double).round();
  }

  Future<double?> getWeight() async {
    final result =
        await db.query('UserData', where: 'id = ?', whereArgs: [1], limit: 1);

    return result.first['weight'] as double?;
  }

  Future<Gender?> getGender() async {
    final result =
        await db.query('UserData', where: 'id = ?', whereArgs: [1], limit: 1);
    if (result.first['gender'] == null) {
      return null;
    }
    return Gender.values[result.first['gender'] as int];
  }

  Future<ActivityLevel?> getActivityLevel() async {
    final result =
        await db.query('UserData', where: 'id = ?', whereArgs: [1], limit: 1);
    if (result.first['activity_level'] == null) {
      return null;
    }
    return ActivityLevel.values[result.first['activity_level'] as int];
  }

  Future<List<Activity>> getActivities({DateTime? start, DateTime? end}) async {
    final List<Map<String, Object?>> activities = await db.query('Activities',
        where: 'timestamp >= ? AND timestamp <= ?',
        whereArgs: [
          start?.millisecondsSinceEpoch,
          end?.millisecondsSinceEpoch
        ]);
    return activities
        .map((activity) => Activity(
            id: activity['id'] as int,
            name: activity['name'] as String,
            calories: activity['energy'] as int,
            timestamp: DateTime.fromMillisecondsSinceEpoch(
                activity['timestamp'] as int)))
        .toList();
  }

  Future<int> getIngredientCountUsage(int id) async {
    final List<Map<String, Object?>> result = await db.rawQuery(
      'SELECT COUNT(food_id) as count FROM MealDiary WHERE food_id = ?',
      [id],
    );
    return result.isNotEmpty ? result.first['count'] as int : 0;
  }

  Future<List<Recipe>> getRecipes() async {
    final List<Map<String, Object?>> recipesRaw = await db.query('Recipes');
    final List<Recipe> recipes = [];
    for (final mealRaw in recipesRaw) {
      final int recipeId = mealRaw['id'] as int;
      final String recipeName = mealRaw['name'] as String;

      final List<Map<String, Object?>> mealSessionCountRaw =
          await db.rawQuery('''
        SELECT COUNT(*) as count FROM MealSession WHERE name = ?
      ''', [recipeName]);

      final int mealSessionCount = mealSessionCountRaw.single['count'] as int;

      final List<Map<String, Object?>> ingredientsRaw = await db.query(
          'RecipesIngredients',
          where: 'recipe_id = ?',
          whereArgs: [recipeId]);
      final List<Ingredient> ingredients = [];
      for (final ingredientRaw in ingredientsRaw) {
        final foodRaw = await db.query('Foods',
            where: 'id = ?', whereArgs: [ingredientRaw['food_id']]);
        final food = foodRaw.first;
        ingredients.add(Ingredient(
          id: food['id'] as int,
          name: food['name'] as String,
          calories: food['energy'] as int,
          count: 0, // In this call we don't need the count
          fat: food['fat'] as double?,
          saturedFat: food['saturated_fat'] as double?,
          carbohydrates: food['carbohydrates'] as double?,
          sugar: food['sugar'] as double?,
          fiber: food['fiber'] as double?,
          protein: food['protein'] as double?,
          barcode: food['barcode'] as String?,
          price: food['price'] as double?,
          imageUrl: food['imageUrl'] as String?,
        ));
      }
      recipes.add(Recipe(
          id: recipeId,
          name: recipeName,
          ingredients: ingredients,
          count: mealSessionCount));
    }
    // Sort the recipes for count desc
    recipes.sort((a, b) => b.count.compareTo(a.count));
    return recipes;
  }

  Future<MealSession> getMealSession(int mealSessionId) async {
    final Map<String, Object?> mealSessionRaw = (await db
            .query('MealSession', where: 'id = ?', whereArgs: [mealSessionId]))
        .first;

    final List<Map<String, Object?>> foodsRaw = await db.rawQuery('''
        SELECT Foods.id, Foods.name, Foods.energy, Foods.fat, Foods.saturated_fat, Foods.carbohydrates, Foods.sugar, Foods.fiber, Foods.protein, MealDiary.amount, Foods.price, Foods.imageUrl
        FROM MealDiary
        INNER JOIN Foods ON MealDiary.food_id = Foods.id
        WHERE MealDiary.meal_session = ?
      ''', [mealSessionId]);
    final List<Ingredient> ingredients = [];
    for (final foodRaw in foodsRaw) {
      ingredients.add(Ingredient(
        id: foodRaw['id'] as int,
        name: foodRaw['name'] as String,
        calories: foodRaw['energy'] as int,
        count: 0, // In this call we don't need the count
        fat: foodRaw['fat'] as double?,
        saturedFat: foodRaw['saturated_fat'] as double?,
        carbohydrates: foodRaw['carbohydrates'] as double?,
        sugar: foodRaw['sugar'] as double?,
        fiber: foodRaw['fiber'] as double?,
        protein: foodRaw['protein'] as double?,
        amount: foodRaw['amount'] as double,
        price: foodRaw['price'] as double?,
        imageUrl: foodRaw['imageUrl'] as String?,
      ));
    }
    return MealSession(
        id: mealSessionRaw['id'] as int,
        name: mealSessionRaw['name'] as String,
        mealType: MealType.values[mealSessionRaw['meal_type'] as int],
        timestamp: DateTime.fromMillisecondsSinceEpoch(
            mealSessionRaw['timestamp'] as int),
        ingredients: ingredients,
        nTotalPortions: mealSessionRaw['n_total_portions'] as int,
        nEatenPortions: mealSessionRaw['n_portions_eaten'] as int,
        price: mealSessionRaw['price'] as double?);
  }

  Future<List<MealSession>> getMealSessions(
      {DateTime? start, DateTime? end}) async {
    final List<Map<String, Object?>> mealSessionsRaw = await db.query(
        'MealSession',
        where: 'timestamp >= ? AND timestamp <= ?',
        whereArgs: [
          start?.millisecondsSinceEpoch,
          end?.millisecondsSinceEpoch
        ]);
    final List<MealSession> mealSessions = [];
    for (final mealSessionRaw in mealSessionsRaw) {
      final MealSession mealSession =
          await getMealSession(mealSessionRaw['id'] as int);
      mealSessions.add(mealSession);
    }
    return mealSessions;
  }

  Future<void> addMeal(String name, List<Ingredient> ingredients,
      {Recipe? recipe}) async {
    final int mealId;
    if (recipe != null) {
      await db.update('Recipes', {'name': name},
          where: 'id = ?', whereArgs: [recipe.id]);
      mealId = recipe.id;
      await db.delete('RecipesIngredients',
          where: 'recipe_id = ?', whereArgs: [mealId]);
    } else {
      mealId = await db.insert('Recipes', {'name': name});
    }

    for (final Ingredient ingredient in ingredients) {
      await db.insert('RecipesIngredients',
          {'food_id': ingredient.id, 'recipe_id': mealId});
    }
    notify();
  }

  /// Insert food into the database, if the food already exists, update all fields
  Future<void> addFood(Ingredient ingredient,
      {bool foodEditing = false}) async {
    if (foodEditing == false) {
      /// This means it is a new food, so we need to check if already exists
      final existingFood = await db
          .query('Foods', where: 'name = ?', whereArgs: [ingredient.name]);
      if (existingFood.isNotEmpty) {
        throw FoodAlreadyPresent(
            'Food with name "${ingredient.name}" already present.');
      }
    }
    await db.rawInsert('''
      INSERT INTO Foods (${ingredient.id != -1 ? 'id, ' : ''} barcode, name, energy, fat, saturated_fat, carbohydrates, sugar, fiber, protein, price, imageUrl)
      VALUES (${ingredient.id != -1 ? '?, ' : ''} ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(id) DO UPDATE SET
      barcode = excluded.barcode,
      name = excluded.name,
      energy = excluded.energy,
      fat = excluded.fat,
      saturated_fat = excluded.saturated_fat,
      carbohydrates = excluded.carbohydrates,
      sugar = excluded.sugar,
      fiber = excluded.fiber,
      protein = excluded.protein,
      price = excluded.price,
      imageUrl = excluded.imageUrl
    ''', [
      if (ingredient.id != -1) ingredient.id,
      ingredient.barcode,
      ingredient.name,
      ingredient.calories,
      ingredient.fat,
      ingredient.saturedFat,
      ingredient.carbohydrates,
      ingredient.sugar,
      ingredient.fiber,
      ingredient.protein,
      ingredient.price,
      ingredient.imageUrl,
    ]);
    notify();
  }

  Future<List<Ingredient>> getFoods() async {
    final List<Map<String, Object?>> foodsRaw = await db.query('Foods');
    final List<Ingredient> foods = [];
    for (final foodRaw in foodsRaw) {
      foods.add(Ingredient(
        id: foodRaw['id'] as int,
        name: foodRaw['name'] as String,
        calories: foodRaw['energy'] as int,
        count: await getIngredientCountUsage(foodRaw['id'] as int),
        fat: foodRaw['fat'] as double?,
        saturedFat: foodRaw['saturated_fat'] as double?,
        carbohydrates: foodRaw['carbohydrates'] as double?,
        sugar: foodRaw['sugar'] as double?,
        fiber: foodRaw['fiber'] as double?,
        protein: foodRaw['protein'] as double?,
        price: foodRaw['price'] as double?,
        barcode: foodRaw['barcode'] as String?,
        imageUrl: foodRaw['imageUrl'] as String?,
      ));
    }
    foods.sort((a, b) => b.count.compareTo(a.count));

    return foods;
  }

  Future<Ingredient> getFood({int? id, String? name}) async {
    final List<Map<String, Object?>> foodRaw;
    if (id != null) {
      foodRaw =
          await db.query('Foods', where: 'id = ?', whereArgs: [id], limit: 1);
    } else if (name != null) {
      foodRaw = await db.query('Foods',
          where: 'name = ?', whereArgs: [name], limit: 1);
    } else {
      throw ArgumentError('Either id or name must be provided');
    }
    if (foodRaw.isEmpty) {
      throw NoFoodFounded();
    }
    final food = foodRaw.first;
    return Ingredient(
      id: food['id'] as int,
      name: food['name'] as String,
      calories: food['energy'] as int,
      count: 0,
      fat: food['fat'] as double?,
      saturedFat: food['saturated_fat'] as double?,
      carbohydrates: food['carbohydrates'] as double?,
      sugar: food['sugar'] as double?,
      fiber: food['fiber'] as double?,
      protein: food['protein'] as double?,
      price: food['price'] as double?,
      barcode: food['barcode'] as String?,
      imageUrl: food['imageUrl'] as String?,
    );
  }

  Future<String?> getFoodImageUrl(Ingredient ingredient) async {
    if (ingredient.barcode == null) {
      return null;
    }
    final off.ProductQueryConfiguration config = off.ProductQueryConfiguration(
      ingredient.barcode!,
      version: off.ProductQueryVersion.v3,
      fields: [off.ProductField.IMAGE_FRONT_SMALL_URL],
    );
    for (int attempts = 0; attempts < 3; attempts++) {
      try {
        final off.ProductResultV3 product =
            await off.OpenFoodAPIClient.getProductV3(config);
        return product.product?.imageFrontSmallUrl;
      } on off.TooManyRequestsException {
        await Future.delayed(const Duration(seconds: 5));
      }
    }
    throw const off.TooManyRequestsException();
  }

  double calculatePriceFromIngredients(
      List<Ingredient> ingredients, int nTotalPortions) {
    double price = 0;
    for (final ingredient in ingredients) {
      price += (ingredient.price ?? 0) / 100 * (ingredient.amount ?? 0);
    }
    return price / nTotalPortions;
  }

  Future<void> addMealDiaryEntry({
    required String name,
    required DateTime timestamp,
    required MealType mealType,
    required int nTotalPortions,
    required int nEatenPortions,
    required List<Ingredient> ingredients,
    required bool calculatePriceFlag,
    int? mealSession,
  }) async {
    if (mealSession != null) {
      await deleteMealSession(mealSession);
    }
    double? price;
    if (calculatePriceFlag) {
      price = calculatePriceFromIngredients(ingredients, nTotalPortions) *
          nEatenPortions;
    }
    final int mealSessionId = await db.insert('MealSession', {
      'name': name,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'meal_type': mealType.index,
      'n_total_portions': nTotalPortions,
      'n_portions_eaten': nEatenPortions,
      'price': price
    });
    for (final ingredient in ingredients) {
      await db.insert('MealDiary', {
        'food_id': ingredient.id,
        'meal_session': mealSessionId,
        'amount': ingredient.amount
      });
    }
    notify();
  }

  Future<void> deleteMealSession(int id) async {
    await db.delete('MealSession', where: 'id = ?', whereArgs: [id]);
    notify();
  }

  /// Estimate the amount of total portions for a new meal based on past meals
  Future<int> estimateTotalPortionsPastMeals(String mealName) async {
    final List<Map<String, Object?>> meals = await db.query('MealSession',
        where: 'name = ?', whereArgs: [mealName], orderBy: 'timestamp desc');
    if (meals.isEmpty) {
      return 1;
    }

    /// Calculate the more frequent amount
    final Map<int, int> mealCounts = {};
    for (final Map<String, Object?> meal in meals) {
      int nTotalPortions = meal['n_total_portions'] as int;
      if (mealCounts.containsKey(nTotalPortions)) {
        mealCounts[nTotalPortions] = mealCounts[nTotalPortions]! + 1;
      } else {
        mealCounts[nTotalPortions] = 1;
      }
    }
    final List<MapEntry<int, int>> sortedMealCounts =
        mealCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sortedMealCounts.first.key;
  }

  /// Estimate the amount of eated portions for a new meal based on past meals
  Future<int> estimateEatenPortionsPastMeals(String mealName) async {
    final List<Map<String, Object?>> meals = await db.query('MealSession',
        where: 'name = ?', whereArgs: [mealName], orderBy: 'timestamp desc');
    if (meals.isEmpty) {
      return 1;
    }

    /// Calculate the more frequent amount
    final Map<int, int> mealCounts = {};
    for (final Map<String, Object?> meal in meals) {
      int nEatenPortions = meal['n_portions_eaten'] as int;
      if (mealCounts.containsKey(nEatenPortions)) {
        mealCounts[nEatenPortions] = mealCounts[nEatenPortions]! + 1;
      } else {
        mealCounts[nEatenPortions] = 1;
      }
    }
    final List<MapEntry<int, int>> sortedMealCounts =
        mealCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sortedMealCounts.first.key;
  }

  /// Estimate the amount of grams for an ingredient based on past meals
  /// for a specific recipe
  Future<double> getAmountPastMeals(Ingredient ingredient, String mealName,
      int nTotalPortions, int nEatenPortions) async {
    final List<Map<String, Object?>> meals = await db.rawQuery('''
      SELECT amount FROM MealDiary
      INNER JOIN Foods ON MealDiary.food_id = Foods.id
      INNER JOIN MealSession ON MealDiary.meal_session = MealSession.id
      WHERE Foods.id = ? AND MealSession.name = ? AND MealSession.n_total_portions = ?
    ''', [ingredient.id, mealName, nTotalPortions]);
    if (meals.isEmpty) {
      return 0;
    }
    List<double> amounts = meals.map((e) => e['amount'] as double).toList();
    // Calculate the more frequent amount
    final Map<double, int> amountsCount = {};
    for (final amount in amounts) {
      if (amountsCount.containsKey(amount)) {
        amountsCount[amount] = amountsCount[amount]! + 1;
      } else {
        amountsCount[amount] = 1;
      }
    }
    final List<MapEntry<double, int>> sortedAmounts = amountsCount.entries
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedAmounts.first.key;
  }

  Future<Ingredient?> getFoodFromBarcode(String barcode) async {
    off.ProductQueryConfiguration config = off.ProductQueryConfiguration(
      barcode,
      version: off.ProductQueryVersion.v3,
    );
    off.ProductResultV3 product =
        await off.OpenFoodAPIClient.getProductV3(config);
    final double? sugars = product.product?.nutriments
        ?.getValue(off.Nutrient.sugars, off.PerSize.oneHundredGrams);
    final double? fiber = product.product?.nutriments
        ?.getValue(off.Nutrient.fiber, off.PerSize.oneHundredGrams);
    final double? proteins = product.product?.nutriments
        ?.getValue(off.Nutrient.proteins, off.PerSize.oneHundredGrams);
    final double? fat = product.product?.nutriments
        ?.getValue(off.Nutrient.fat, off.PerSize.oneHundredGrams);
    final double? saturatedFat = product.product?.nutriments
        ?.getValue(off.Nutrient.saturatedFat, off.PerSize.oneHundredGrams);
    final double? carbohydrates = product.product?.nutriments
        ?.getValue(off.Nutrient.carbohydrates, off.PerSize.oneHundredGrams);
    final double? energy = product.product?.nutriments
        ?.getValue(off.Nutrient.energyKCal, off.PerSize.oneHundredGrams);
    if (energy == null) {
      return null;
    }
    return Ingredient(
        id: -1,
        name: product.product?.productName ?? 'Unknown',
        barcode: barcode,
        calories: energy.round(),
        count: 0, //New ingredient so let's assume 0 times used
        fat: fat,
        saturedFat: saturatedFat,
        carbohydrates: carbohydrates,
        sugar: sugars,
        fiber: fiber,
        protein: proteins,
        imageUrl: product.product?.imageFrontSmallUrl);
  }

  Future<List<String>> getRecipesContainingIngredient(int ingredientId) async {
    final List<Map<String, Object?>> recipesRaw = await db.rawQuery('''
      SELECT Recipes.name FROM Recipes
      INNER JOIN RecipesIngredients ON Recipes.id = RecipesIngredients.recipe_id
      WHERE RecipesIngredients.food_id = ?
    ''', [ingredientId]);

    return recipesRaw.map((recipe) => recipe['name'] as String).toList();
  }

  Future<void> deleteIngredient(int id) async {
    await db.delete('Foods', where: 'id = ?', whereArgs: [id]);
    notify();
  }

  Future<void> deleteRecipe(int id) async {
    await db
        .delete('RecipesIngredients', where: 'recipe_id = ?', whereArgs: [id]);
    await db.delete('Recipes', where: 'id = ?', whereArgs: [id]);
    notify();
  }

  Future<void> setGeminiApiKey(String apiKey) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('gemini_api_key', apiKey);
  }

  Future<String?> getGeminiApiKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('gemini_api_key');
  }

  Future<Ingredient> getGeminiEstimatedFood(String foodName) async {
    final String prompt =
        "Generate in JSON format the estimated nutrition values for $foodName, the JSON must contain the following fields: energy in kcal, fat in g, saturated_fat in g, carbohydrates in g, sugar in g, fiber in g, protein in g. All the values are for 100g of the food. do not provide additional informations. The json must be parsable by python";
    final String res = await geminiManager.generateContent(prompt);

    String jsonData = res;
    // Remove the ```json and ``` from the string
    jsonData = jsonData.replaceAll('```json', '');
    jsonData = jsonData.replaceAll('```', '');
    final Map<String, dynamic> json = jsonDecode(jsonData);
    if (json['energy'] == null ||
        json['fat'] == null ||
        json['saturated_fat'] == null ||
        json['carbohydrates'] == null ||
        json['sugar'] == null ||
        json['fiber'] == null ||
        json['protein'] == null) {
      throw Exception('Missing fields in Gemini response');
    }

    return Ingredient(
        id: -1,
        name: foodName,
        calories: (json['energy'] as num).toInt(),
        count: 0, //New ingredient so let's assume it is not used
        fat: (json['fat'] as num?)?.toDouble(),
        saturedFat: (json['saturated_fat'] as num?)?.toDouble(),
        carbohydrates: (json['carbohydrates'] as num?)?.toDouble(),
        sugar: (json['sugar'] as num?)?.toDouble(),
        fiber: (json['fiber'] as num?)?.toDouble(),
        protein: (json['protein'] as num?)?.toDouble());
  }

  Future<void> updateImagesUrls() async {
    final List<Ingredient> ingredients = await getFoods();
    for (Ingredient ingredient in ingredients) {
      if (ingredient.barcode == null) {
        continue;
      }
      final String? imageUrl = await getFoodImageUrl(ingredient);
      if (imageUrl != null) {
        await db.update('Foods', {'imageUrl': imageUrl},
            where: 'id = ?', whereArgs: [ingredient.id]);
        print("Update sucessfully!");
      }
    }
  }

  Future<void> eraseDatabase() async {
    await db.close();
    final File file = File(await getDBPath());
    file.deleteSync();
    _db = null;
    await FirstStartSetup.init();
  }

  void notify() {
    notifyListeners();
  }

  Future<void> addEventToServer(
      String userId, String name, Map<String, dynamic> parameters,
      {int? millisecondsSinceEpoch}) async {
    final response = await http.post(
      Uri.parse('$analyticsServerUrl/analytics'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        "user_id": userId,
        "name": name,
        "parameters": jsonEncode(parameters),
        "timestamp":
            millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
        "appVersion": appVersion,
      }),
    );
    if (response.statusCode == 200) {
      print('Event sent to server successfully!');
    } else {
      print(
          'Failed to send event to server. Status code: ${response.statusCode}');
    }
  }
}

Backend backend = Backend();
