import 'package:flutter/material.dart';
import 'package:food_traker/src/backend/backend.dart';
import 'package:food_traker/src/backend/types/meal_session.dart';
import 'package:food_traker/src/dashboard/add_meal_details/add_meal_details.dart';
import 'package:food_traker/src/utils.dart';

class MealCard extends StatelessWidget {
  const MealCard({super.key, required this.mealSession});
  final MealSession mealSession;

  Future<void> confirmDelete(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Delete Meal'),
              content: const Text('Are you sure you want to delete this meal?'),
              actions: [
                TextButton(
                    onPressed: () {
                      Utils.pop(
                          context: context, currentRouteName: 'meal_card');
                    },
                    child: const Text('Cancel')),
                TextButton(
                    onPressed: () async {
                      await backend.deleteMealSession(mealSession.id);
                      if (context.mounted) {
                        Utils.pop(
                            context: context, currentRouteName: 'meal_card');
                      }
                    },
                    child: const Text('Delete')),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () => confirmDelete(context),
      onTap: () {
        Utils.push(
            context: context,
            routeName: 'add_meal_details',
            page: AddMealDetails(mealSession: mealSession));
      },
      child: Card(
        child: SizedBox(
          height: 120,
          width: 120,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(mealSession.name,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface)),
              Text('${mealSession.calories} kcal',
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface)),
            ],
          ),
        ),
      ),
    );
  }
}
