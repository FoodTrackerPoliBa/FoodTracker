import 'dart:async';

import 'package:food_traker/src/backend/backend.dart';
import 'package:food_traker/src/backend/meal_data.dart';
import 'package:food_traker/src/backend/types/activity.dart';
import 'package:food_traker/src/backend/types/daily_overview_data.dart';
import 'package:food_traker/src/backend/types/ingredient.dart';
import 'package:food_traker/src/backend/types/meal_session.dart';
import 'package:food_traker/src/backend/types/exceptions/no_gemini_api_found.dart';
import 'package:food_traker/src/backend/user_data.dart';
import 'package:food_traker/src/dashboard/chatbot/chat_controller.dart';
import 'package:food_traker/src/dashboard/chatbot/message.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';

class GeminiManager {
  GenerativeModel? _client;

  ChatController controller = ChatController();

  GenerativeModel get client {
    if (_client == null) {
      throw Exception("No Gemini client initialized, please call init() first");
    }
    return _client!;
  }

  Future<bool> apiKeyConfigured() async {
    String? apiKey = await backend.getGeminiApiKey();
    return apiKey != null;
  }

  Future<void> init({bool raiseError = true, MealData? mealData}) async {
    String? apiKey = await backend.getGeminiApiKey();
    if (apiKey == null && raiseError) {
      throw NoGeminiApiFound();
    } else if (apiKey == null) {
      return;
    }

    _client = GenerativeModel(
        model: "gemini-1.5-pro",
        apiKey: apiKey,
        systemInstruction:
            Content.system(await generatePrefixPrompt(mealData: mealData)));
  }

  Future<String> generatePrefixPrompt({MealData? mealData}) async {
    String prompt =
        "You are an AI assistant for a calorie tracker.\nThese are the data of the user:\n";
    String name = UserData.name!;
    double age = UserData.age;
    int height = UserData.height!;
    double weight = UserData.weight!;
    String gender = UserData.gender!.name;
    String activityLevel = UserData.activityLevel!.value;
    int totalCaloriesTargetToday =
        await UserData.dailyEnergyGoal(date: DateTime.now());
    DailyOverviewData actualCalories =
        await backend.getDailyOverviewData(date: DateTime.now());
    int totalCaloriesToday =
        actualCalories.target.kcalories - actualCalories.actual.kcalories;
    DateFormat dateFormat = DateFormat('yyyy-MM-dd EEEE HH:mm');
    String timestamp = dateFormat.format(DateTime.now());
    prompt += "Actual timestamp: $timestamp\n\n";
    prompt += "Name: $name\n";
    prompt += "Age: ${age.toInt()}\n";
    prompt += "Height: $height cm\n";
    prompt += "Weight: $weight kg\n";
    prompt += "Gender: $gender\n";
    prompt += "Activity Level: $activityLevel\n\n";
    prompt += "Today's target calories: $totalCaloriesTargetToday kcal\n";
    prompt +=
        "Today's actual calories: ${actualCalories.actual.kcalories} kcal\n";
    prompt += "Today's remaining calories: $totalCaloriesToday kcal\n";
    prompt += "User today nutrients:\n";
    prompt += "\tCarbs: ${actualCalories.actual.carbs} g\n";
    prompt += "\tProtein: ${actualCalories.actual.protein} g\n";
    prompt += "\tFat: ${actualCalories.actual.fat} g\n";
    prompt += "\tKcalories: ${actualCalories.actual.kcalories} kcal\n\n";
    prompt += "User daily nutrients target:\n";
    prompt += "\tCarbs: ${actualCalories.target.carbs} g\n";
    prompt += "\tProtein: ${actualCalories.target.protein} g\n";
    prompt += "\tFat: ${actualCalories.target.fat} g\n";
    prompt += "\tKcalories: ${actualCalories.target.kcalories} kcal\n\n";
    prompt += "Sugar suggested limit: ${actualCalories.target.sugar}g\n";
    prompt += "Actual sugar consumed: ${actualCalories.actual.sugar}g\n\n";
    prompt += "Language: Italian\n\n"; // TODO: add language from user data
    prompt += "Week events:\n";
    for (int dayCounter = 0; dayCounter < 7; dayCounter++) {
      int effectiveDay = 7 - dayCounter;
      DateTime start = DateTime.now().subtract(Duration(days: effectiveDay));
      DateTime end = start.add(const Duration(days: 1));
      final List<MealSession> meals =
          await backend.getMealSessions(start: start, end: end);
      final List<Activity> activities =
          await backend.getActivities(start: start, end: end);
      prompt += "Day ${DateFormat('yyyy-MM-dd EEEE').format(end)}:\n";
      prompt += "\tMeals:\n";
      if (meals.isNotEmpty) {
        for (MealSession meal in meals) {
          prompt += "\t\tTime: ${dateFormat.format(meal.timestamp)}\n";
          prompt += "\t\t${meal.name} - ${meal.calories} kcal\n";
          prompt += "\t\tIngredients:\n";
          for (Ingredient ingredient in meal.ingredients) {
            final double finalAmount =
                ingredient.amount! / meal.nTotalPortions * meal.nEatenPortions;
            prompt +=
                "\t\t\t${ingredient.name} - ${finalAmount.toStringAsFixed(2)}g - ${((ingredient.calories / 100) * finalAmount).toStringAsFixed(2)} kcal\n";
            prompt +=
                "\t\t\t\tKcalories: ${((ingredient.calories / 100) * finalAmount).toStringAsFixed(2)}g\n";
            prompt +=
                "\t\t\t\tFat: ${(((ingredient.fat ?? 0) / 100) * finalAmount).toStringAsFixed(2)}g\n";
            prompt +=
                "\t\t\t\tCarbohydrates: ${(((ingredient.carbohydrates ?? 0) / 100) * finalAmount).toStringAsFixed(2)}g\n";
            prompt +=
                "\t\t\t\tSugar: ${(((ingredient.sugar ?? 0) / 100) * finalAmount).toStringAsFixed(2)}g\n";
            prompt +=
                "\t\t\t\tFiber: ${(((ingredient.fiber ?? 0) / 100) * finalAmount).toStringAsFixed(2)}g\n";
            prompt +=
                "\t\t\t\tProtein: ${(((ingredient.protein ?? 0) / 100) * finalAmount).toStringAsFixed(2)}g\n";
          }
          prompt += "\n";
        }
      } else {
        prompt += "\t\tNo meals recorded\n";
      }
      prompt += "\tActivities:\n";
      if (activities.isNotEmpty) {
        for (Activity activity in activities) {
          prompt += "\t\t${activity.name} - ${activity.calories} kcal\n";
        }
      } else {
        prompt += "\t\tNo activities recorded\n";
      }
      prompt += "\n";
    }

    if (mealData != null) {
      prompt +=
          "In addition, the user is in the meal configuration screen and is currently viewing and editing a meal. The informations on the screen are:\n";
      prompt += "Meal name: ";
      if (mealData.name.isEmpty) {
        prompt += "No name available";
      } else {
        prompt += mealData.name;
      }
      prompt += "\n";
      prompt += "Meal ingredients and nutrients:\n";

      for (Ingredient ingredient in mealData.ingredients) {
        final double finalAmount = ingredient.amount! /
            mealData.nTotalPortions *
            mealData.nEatenPortions;
        prompt +=
            "\t${ingredient.name} - ${finalAmount.toStringAsFixed(2)}g - ${((ingredient.calories / 100) * finalAmount).toStringAsFixed(2)} kcal\n";
        prompt +=
            "\t\tKcalories: ${((ingredient.calories / 100) * finalAmount).toStringAsFixed(2)}g\n";
        prompt +=
            "\t\tFat: ${(((ingredient.fat ?? 0) / 100) * finalAmount).toStringAsFixed(2)}g\n";
        prompt +=
            "\t\tCarbohydrates: ${(((ingredient.carbohydrates ?? 0) / 100) * finalAmount).toStringAsFixed(2)}g\n";
        prompt +=
            "\t\tSugar: ${(((ingredient.sugar ?? 0) / 100) * finalAmount).toStringAsFixed(2)}g\n";
        prompt +=
            "\t\tFiber: ${(((ingredient.fiber ?? 0) / 100) * finalAmount).toStringAsFixed(2)}g\n";
        prompt +=
            "\t\tProtein: ${(((ingredient.protein ?? 0) / 100) * finalAmount).toStringAsFixed(2)}g\n";
      }
      prompt += "\n";
    }
    return prompt;
  }

  List<Content> castMessagesToContents() {
    List<Content> contents = [];
    for (Message message in controller.messages) {
      contents.add(Content.text(
        message.text,
      ));
    }
    return contents;
  }

  /// If the user is into a meal screen (for adding a new meal or view an existing one)
  /// this variable contains all the useful data about the meal
  Future<void> sendMessage(String message, {MealData? mealData}) async {
    await geminiManager.init(mealData: mealData);
    final ChatSession chatSession =
        client.startChat(history: castMessagesToContents());
    controller.addUserMessage(message);
    Stream<GenerateContentResponse> streams =
        chatSession.sendMessageStream(castMessagesToContents().last);

    Message aiResposne = Message(text: "", senderType: SenderType.assistant);
    controller.addMessage(aiResposne);
    await for (GenerateContentResponse candidates in streams) {
      aiResposne.text += candidates.text ?? "";
      controller.notify();
    }
  }

  Future<String> generateContent(String message) async {
    final GenerateContentResponse response = await client.generateContent([
      Content(SenderType.user.name, [TextPart(message)])
    ]);
    return response.text ?? "";
  }
}

final GeminiManager geminiManager = GeminiManager();
