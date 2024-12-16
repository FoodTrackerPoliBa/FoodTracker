import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_traker/src/backend/analytics.dart';
import 'package:food_traker/src/backend/backend.dart';

class CustomTextInputFormatter {
  static List<TextInputFormatter> doubleOnly() => <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[0-9]+[,.]{0,1}[0-9]*')),
        TextInputFormatter.withFunction(
          (oldValue, newValue) => newValue.copyWith(
            text: newValue.text.replaceAll(',', '.'),
          ),
        ),
      ];
}

extension StringExtensions on String {
  String capitalize() => this[0].toUpperCase() + substring(1).toLowerCase();
}

class Utils {
  static Future<void> importBackup() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final data = await file.readAsString();
      await backend.importDatabase(data);
    }
  }

  static Future<T?> push<T>(
      {required BuildContext context,
      required String routeName,
      required Widget page}) async {
    analytics.routeChange(routeName).ignore();
    return await Navigator.of(context)
        .push<T>(MaterialPageRoute(builder: (context) => page));
  }

  static Future<void> pop(
      {required BuildContext context, required String currentRouteName}) async {
    Navigator.of(context).pop();
    analytics.routePop(currentRouteName).ignore();
  }

  static Future<void> showDialogNotValidValue(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Invalid Value Entered'),
          content: const Text('Please enter a realistic value for this field.'),
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
