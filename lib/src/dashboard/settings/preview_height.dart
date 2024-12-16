import 'package:flutter/material.dart';
import 'package:food_traker/src/backend/types/exceptions/insane_value.dart';
import 'package:food_traker/src/backend/user_data.dart';
import 'package:food_traker/src/utils.dart';

class PreviewHeight extends StatefulWidget {
  const PreviewHeight({super.key});

  @override
  State<PreviewHeight> createState() => _PreviewHeightState();
}

class _PreviewHeightState extends State<PreviewHeight> {
  final TextEditingController controller =
      TextEditingController(text: UserData.height.toString());

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Enter height"),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: "Height (cm)",
        ),
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
              final int? height = int.tryParse(controller.text);
              if (height != null) {
                try {
                  await UserData.setHeight(height);
                } on InsaneValueException {
                  if (context.mounted) {
                    await Utils.showDialogNotValidValue(context);
                  }
                }
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            }),
      ],
    );
  }
}
