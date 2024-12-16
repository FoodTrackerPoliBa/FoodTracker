import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_traker/src/backend/backend.dart';
import 'package:food_traker/src/utils.dart';

class AddActivity extends StatefulWidget {
  const AddActivity({super.key, required this.timestamp});
  final DateTime timestamp;
  @override
  State<AddActivity> createState() => _AddActivityState();
}

class _AddActivityState extends State<AddActivity> {
  final TextEditingController _activityNameController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();

  Future<bool?> showDialogTooHigh() async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text(
              'Calories for the activity is quite high. Are you sure you want to add this value?'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('Yes')),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Activity'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            maxLength: 100,
            controller: _activityNameController,
            decoration: const InputDecoration(
                labelText: 'Activity name', counterText: ""),
          ),
          TextField(
            controller: _caloriesController,
            decoration: const InputDecoration(labelText: 'Calories'),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () {
              Utils.pop(context: context, currentRouteName: 'add_activity');
            },
            child: const Text('Cancel')),
        FilledButton(
          onPressed: () async {
            final String activityName = _activityNameController.text;
            final int calories = int.parse(_caloriesController.text);
            if (calories > 2000) {
              final bool? shouldAdd = await showDialogTooHigh();
              if (!(shouldAdd ?? false)) {
                return;
              }
            }
            await backend.addActivity(activityName, calories, widget.timestamp);
            if (context.mounted) {
              Utils.pop(context: context, currentRouteName: 'add_activity');
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
