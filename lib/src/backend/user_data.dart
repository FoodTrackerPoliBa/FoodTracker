import 'package:food_traker/src/backend/backend.dart';
import 'package:food_traker/src/backend/types/activity_level.dart';
import 'package:food_traker/src/backend/types/gender.dart';
import 'package:food_traker/src/globals.dart';

class UserData {
  static String? _name;
  static DateTime? _birthday;
  static int? _height;
  static double? _weight;
  static Gender? _gender;
  static ActivityLevel? _activityLevel;

  /// The user's name
  static String? get name {
    return _name;
  }


  /// The user's birthday
  static DateTime? get birthday {
    return _birthday;
  }

  /// The user's height in cm
  static int? get height {
    return _height;
  }

  /// The user's weight in kg
  static double? get weight {
    return _weight;
  }

  /// The user gender, used for calculating the BMR and others indicators
  static Gender? get gender {
    return _gender;
  }

  /// The user activity level, used for calculating the BMR and others indicators
  static ActivityLevel? get activityLevel {
    return _activityLevel;
  }

  static bool get firstStart {
    return _name == null || _birthday == null || _height == null || _weight == null || _gender == null || _activityLevel == null;
  }

  static Future<void> init() async {
    _name = await backend.getName();
    _birthday = await backend.getBirthday();
    _height = await backend.getHeight();
    _weight = await backend.getWeight();
    _gender = await backend.getGender();
    _activityLevel = await backend.getActivityLevel();
  }

  /// Set the user name
  static Future<void> setName(String name) async {
    await backend.setName(name);
    _name = name;
  }

  /// Set the user birthday
  static Future<void> setBirthday(DateTime birthday) async {
    await backend.setBirthday(birthday);
    _birthday = birthday;
  }

  /// Set the user height
  static Future<void> setHeight(int height) async {
    await backend.setHeight(height);
    _height = height;
  }

  /// Set the user weight
  static Future<void> setWeight(double weight) async {
    await backend.setWeight(weight);
    _weight = weight;
  }

  /// Set the user gender
  static Future<void> setGender(Gender gender) async {
    await backend.setGender(gender);
    _gender = gender;
  }

  /// Set the activity level of the user
  static Future<void> setActivityLevel(ActivityLevel activityLevel) async {
    await backend.setActivityLevel(activityLevel);
    _activityLevel = activityLevel;
  }

  /// Get the age of the user in years
  static double get age {
    if (birthday == null) {
      throw Exception('Birthday not set');
    }
    return DateTime.now().difference(birthday!).inDays / 365;
  }

  /// Calculate the daily energy goal based on the user's age, height, weight,
  /// and activity level and using the Mifflin-St. Jeor equation
  static Future<int> dailyEnergyGoal({required DateTime date}) async {
    if (gender == null || height == null || weight == null || activityLevel == null) {
      throw Exception('User data not set');
    }
    final int brunedEnergy = await backend.calculateTotalBurned(date: date);
    if (gender == Gender.male) {
      return (((10 * weight! + 6.25 * height! - 5 * age + 5) *
                  activityLevel!.factor) +
              brunedEnergy)
          .round();
    } else if (gender == Gender.female) {
      return (((10 * weight! + 6.25 * height! - 5 * age - 161) *
                  activityLevel!.factor) +
              brunedEnergy)
          .round();
    } else {
      throw Exception('Something went wrong');
    }
  }

  static Future<int> proteinGoal({required DateTime date}) async {
    return ((await dailyEnergyGoal(date: date)) *
            DailyNutrientsDistributionConstants.proteinPercentage /
            NutrientsConstants.proteinPerKcal)
        .round();
  }

  static Future<int> fatGoal({required DateTime date}) async {
    return ((await dailyEnergyGoal(date: date)) *
            DailyNutrientsDistributionConstants.fatPercentage /
            NutrientsConstants.fatPerKcal)
        .round();
  }

  static Future<int> carbsGoal({required DateTime date}) async {
    return ((await dailyEnergyGoal(date: date)) *
            DailyNutrientsDistributionConstants.carbsPercentage /
            NutrientsConstants.carbsPerKcal)
        .round();
  }

  static Future<int> sugarGoal({required DateTime date}) async {
    return ((await dailyEnergyGoal(date: date)) *
            DailyNutrientsDistributionConstants.sugarPercentage /
            NutrientsConstants.sugarPerKcal)
        .round();
  }
}
