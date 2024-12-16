import 'package:flutter/material.dart';

class TotalPrice extends StatelessWidget {
  const TotalPrice({super.key, required this.mealSessions});
  final double mealSessions;

  @override
  Widget build(BuildContext context) {
    return Text("Total price: ${mealSessions.toStringAsFixed(2)} €",
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600));
  }
}
