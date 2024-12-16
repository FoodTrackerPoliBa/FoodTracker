import 'package:flutter/material.dart';
import 'package:food_traker/src/backend/types/gender.dart';
import 'package:food_traker/src/backend/user_data.dart';

class PreviewGender extends StatefulWidget {
  const PreviewGender({super.key});

  @override
  State<PreviewGender> createState() => _PreviewGenderState();
}

class _PreviewGenderState extends State<PreviewGender> {
  Gender gender = UserData.gender!;

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Select gender"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          RadioListTile(
              title: const Text("Male"),
              value: gender == Gender.male,
              groupValue: true,
              onChanged: (bool? value) {
                gender = Gender.male;
                setState(() {});
              }),
          RadioListTile(
              title: const Text("Female"),
              value: gender == Gender.female,
              groupValue: true,
              onChanged: (bool? value) {
                gender = Gender.female;
                setState(() {});
              })
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
              await UserData.setGender(gender);
              if (context.mounted) {
                Navigator.pop(context);
              }
            }),
      ],
    );
  }
}
