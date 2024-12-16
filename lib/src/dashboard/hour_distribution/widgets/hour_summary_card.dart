import 'package:flutter/material.dart';
import 'package:food_traker/src/backend/types/activity.dart';
import 'package:food_traker/src/backend/types/meal_session.dart';

class HourSummaryCard extends StatelessWidget {
  const HourSummaryCard(
      {super.key,
      required this.meals,
      required this.activities,
      required this.index});
  final List<MealSession> meals;
  final List<Activity> activities;
  final int index;

  int get totalCalories {
    int total = 0;
    for (final MealSession meal in meals) {
      total += meal.calories;
    }
    for (final Activity activity in activities) {
      total -= activity.calories;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        height: 60,
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$index:00',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall!
                    .copyWith(color: Theme.of(context).colorScheme.onSurface)),
            Text('$totalCalories kcal',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall!
                    .copyWith(color: Theme.of(context).colorScheme.onSurface)),
          ],
        ),
      ),
    );
  }
}
