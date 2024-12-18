import 'package:flutter/material.dart';

class RecipeAlreadyPresent implements Exception {
  final String? message;

  const RecipeAlreadyPresent([this.message]);

  @override
  String toString() {
    return message != null
        ? 'RecipeAlreadyPresent: $message'
        : 'RecipeAlreadyPresent';
  }

  Future<void> showAlert(BuildContext context, String recipeName) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Recipe Already Present'),
          content:
              Text("The $recipeName recipe is already present in your list."),
          actions: <Widget>[
            FilledButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
