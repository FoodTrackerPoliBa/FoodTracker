import 'package:flutter/material.dart';
import 'package:food_traker/src/backend/types/activity_level.dart';
import 'package:food_traker/src/backend/user_data.dart';

class PreviewActivityLevel extends StatefulWidget {
  const PreviewActivityLevel({super.key});

  @override
  State<PreviewActivityLevel> createState() => _PreviewActivityLevelState();
}

class _PreviewActivityLevelState extends State<PreviewActivityLevel> {
  ActivityLevel activityLevel = UserData.activityLevel!;

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Select activity level"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final ActivityLevel level in ActivityLevel.values)
            RadioListTile<ActivityLevel>(
              title: Text(level.value),
              value: level,
              groupValue: activityLevel,
              onChanged: (ActivityLevel? value) {
                activityLevel = value!;
                setState(() {});
              },
            ),
        ],
      ),
      actions: <Widget>[
        TextButton(
            child: const Text("Cancel"),
            onPressed: () {
              Navigator.pop(context);
            }),
        FilledButton(
            child: const Text("Save"),
            onPressed: () async {
              await UserData.setActivityLevel(activityLevel);
              if (context.mounted) {
                Navigator.pop(context);
              }
            }),
      ],
    );
  }
}
