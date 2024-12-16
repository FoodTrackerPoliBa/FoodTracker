import 'package:flutter/material.dart';
import 'package:food_traker/src/backend/backend.dart';
import 'package:food_traker/src/backend/types/activity.dart';
import 'package:food_traker/src/utils.dart';

class ActivityCard extends StatelessWidget {
  const ActivityCard({super.key, required this.activity});
  final Activity activity;

  Future<void> confirmDelete(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Delete Activity'),
              content:
                  const Text('Are you sure you want to delete this activity?'),
              actions: [
                TextButton(
                    onPressed: () {
                      Utils.pop(
                          context: context, currentRouteName: 'activity_card');
                    },
                    child: const Text('Cancel')),
                TextButton(
                    onPressed: () async {
                      await backend.deleteActivity(activity.id);
                      if (context.mounted) {
                        Utils.pop(
                            context: context, currentRouteName: 'activity');
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
      child: Card(
        child: SizedBox(
          height: 120,
          width: 120,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(activity.name,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface)),
              Text('${activity.calories} kcal',
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface)),
            ],
          ),
        ),
      ),
    );
  }
}
