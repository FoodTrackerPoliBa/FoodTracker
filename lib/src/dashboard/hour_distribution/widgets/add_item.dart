import 'package:flutter/material.dart';
import 'package:food_traker/src/backend/types/meal_type.dart';
import 'package:food_traker/src/dashboard/add_activity/add_activity.dart';
import 'package:food_traker/src/dashboard/add_meal_details/add_meal_details.dart';
import 'package:food_traker/src/dashboard/add_meal_intake/add_meal_intake.dart';
import 'package:food_traker/src/dashboard/settings/recipes_view.dart';
import 'package:food_traker/src/utils.dart';

class AddItem extends StatelessWidget {
  const AddItem({super.key, required this.timeSelected});
  final DateTime timeSelected;

  void buildNextPage(
      MealType mealType, DateTime timeSelected, BuildContext context) {
    Utils.push(
        context: context,
        routeName: 'add_meal_intake',
        page: RecipesSelector(
          title: mealType.name,
          onRecipePressed: (recipe) {
            Utils.push(
                context: context,
                routeName: 'recieps_view',
                page: AddMealDetails(
                  meal: recipe,
                  mealType: mealType,
                  timeSelected: timeSelected,
                ));
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          leading: const Icon(Icons.directions_run),
          title: const Text('Activity'),
          subtitle: const Text('e.g: Running, Cycling, Swimming'),
          onTap: () async {
            Navigator.pop(context);
            await showDialog(
                context: context,
                builder: (context) {
                  return AddActivity(
                    timestamp: timeSelected,
                  );
                });
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.free_breakfast),
          title: const Text('Breakfast'),
          subtitle: const Text('e.g. eggs, toast, coffee'),
          onTap: () {
            Utils.pop(context: context, currentRouteName: 'add_item');
            Utils.push(
                context: context,
                routeName: 'add_meal_intake',
                page: AddMealIntake(
                  mealType: MealType.breakfast,
                  timeSelected: timeSelected,
                ));
          },
        ),
        ListTile(
          leading: const Icon(Icons.lunch_dining),
          title: const Text('Lunch'),
          subtitle: const Text('e.g. sandwich, salad, soup'),
          onTap: () {
            Utils.pop(context: context, currentRouteName: 'add_item');
            Utils.push(
                context: context,
                routeName: 'add_meal_intake',
                page: AddMealIntake(
                  mealType: MealType.lunch,
                  timeSelected: timeSelected,
                ));
          },
        ),
        ListTile(
          leading: const Icon(Icons.dinner_dining),
          title: const Text('Dinner'),
          subtitle: const Text('e.g. pasta, steak, vegetables'),
          onTap: () {
            Utils.pop(context: context, currentRouteName: 'add_item');
            Utils.push(
                context: context,
                routeName: 'add_meal_intake',
                page: AddMealIntake(
                  mealType: MealType.dinner,
                  timeSelected: timeSelected,
                ));
          },
        ),
        ListTile(
          leading: const Icon(Icons.fastfood),
          title: const Text('Snack'),
          subtitle: const Text('e.g. chips, fruit, nuts'),
          onTap: () {
            Utils.pop(context: context, currentRouteName: 'add_item');
            Utils.push(
                context: context,
                routeName: 'add_meal_intake',
                page: AddMealIntake(
                  mealType: MealType.snack,
                  timeSelected: timeSelected,
                ));
          },
        ),
      ],
    );
  }
}
