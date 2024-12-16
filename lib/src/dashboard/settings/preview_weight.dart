import 'package:flutter/material.dart';
import 'package:food_traker/src/backend/types/exceptions/insane_value.dart';
import 'package:food_traker/src/backend/user_data.dart';
import 'package:food_traker/src/utils.dart';

class PreviewWeight extends StatefulWidget {
  const PreviewWeight({super.key});

  @override
  State<PreviewWeight> createState() => _PreviewWeightState();
}

class _PreviewWeightState extends State<PreviewWeight> {
  final TextEditingController controller =
      TextEditingController(text: UserData.weight!.toStringAsFixed(1));

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Enter weight"),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: "Weight (kg)",
        ),
        inputFormatters: CustomTextInputFormatter.doubleOnly(),
      ),
      actions: <Widget>[
        TextButton(
            child: const Text("Cancel"),
            onPressed: () {
              Utils.pop(context: context, currentRouteName: "preview_weight");
            }),
        FilledButton(
            child: const Text("Save"),
            onPressed: () async {
              final double? weight = double.tryParse(controller.text);
              if (weight != null) {
                try {
                  await UserData.setWeight(weight);
                } on InsaneValueException {
                  if (context.mounted) {
                    await Utils.showDialogNotValidValue(context);
                  }
                }
                if (context.mounted) {
                  Utils.pop(
                      context: context, currentRouteName: "preview_weight");
                }
              }
            }),
      ],
    );
  }
}
