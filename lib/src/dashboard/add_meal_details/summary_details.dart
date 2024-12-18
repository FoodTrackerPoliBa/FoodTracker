import 'package:flutter/material.dart';
import 'package:food_traker/src/backend/backend.dart';
import 'package:food_traker/src/backend/types/ingredient.dart';
import 'package:food_traker/src/globals.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class _NutrientSummary extends StatelessWidget {
  final String label;
  final Color color;
  final double percentage;
  final double amount;
  const _NutrientSummary({
    required this.label,
    required this.color,
    required this.percentage,
    required this.amount,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: color, fontSize: 12)),
          Text(
            '${amount.toStringAsFixed(2)} g',
            style: const TextStyle(fontSize: 14.0),
          ),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class SummaryDetails extends StatelessWidget {
  final List<Ingredient> ingredientsAmount;
  final int nTotalPortions;
  final int nEatenPortions;
  static final Color _carbs = Colors.blue.shade600; // Carbs
  static final Color _sugar = Colors.blue.shade200;
  static final Color _proteins = Colors.red.shade600; // Proteins
  static final Color _fiber = Colors.green.shade600; // Fiber
  static final Color _fat = Colors.orange.shade600; // Fat

  static final List<Color> _palette = [
    _carbs,
    _proteins,
    _fiber,
    _fat,
  ];
  const SummaryDetails({
    super.key,
    required this.ingredientsAmount,
    required this.nTotalPortions,
    required this.nEatenPortions,
  });

  @override
  Widget build(BuildContext context) {
    final List<Ingredient> ingredients = ingredientsAmount;

    double totalCarbs = 0;
    double totalSugar = 0;
    double totalProteins = 0;
    double totalFiber = 0;
    double totalFat = 0;
    double totalKcal = 0;

    for (Ingredient ingredient in ingredients) {
      final double amount = (ingredient.amount ?? 0) / 100;
      totalCarbs += ((ingredient.carbohydrates ?? 0) * amount) /
          nTotalPortions *
          nEatenPortions;
      totalSugar +=
          ((ingredient.sugar ?? 0) * amount) / nTotalPortions * nEatenPortions;
      totalProteins += ((ingredient.protein ?? 0) * amount) /
          nTotalPortions *
          nEatenPortions;
      totalFiber +=
          ((ingredient.fiber ?? 0) * amount) / nTotalPortions * nEatenPortions;
      totalFat +=
          ((ingredient.fat ?? 0) * amount) / nTotalPortions * nEatenPortions;
      totalKcal +=
          (ingredient.calories * amount) / nTotalPortions * nEatenPortions;
    }

    final double totalNutrients =
        totalCarbs + totalProteins + totalFiber + totalFat;

    if ([
      (totalCarbs / totalNutrients * 100),
      (totalProteins / totalNutrients * 100),
      (totalFiber / totalNutrients * 100),
      (totalFat / totalNutrients * 100),
    ].any((value) => value.isNaN)) {
      return const Center(
          child: Text(
              "No Data.\nPlease add quantities to get the nutrients value.",
              textAlign: TextAlign.center));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _NutrientSummary(
                        label: 'Carbs',
                        color: _carbs,
                        percentage: (totalCarbs / totalNutrients * 100),
                        amount: totalCarbs,
                      ),
                      _NutrientSummary(
                        label: 'Proteins',
                        color: _proteins,
                        percentage: (totalProteins / totalNutrients * 100),
                        amount: totalProteins,
                      ),
                      _NutrientSummary(
                        label: 'Fat',
                        color: _fat,
                        percentage: (totalFat / totalNutrients * 100),
                        amount: totalFat,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _NutrientSummary(
                          label: 'Sugar',
                          color: _sugar,
                          percentage: (totalSugar / totalNutrients * 100),
                          amount: totalSugar),
                      _NutrientSummary(
                        label: 'Fiber',
                        color: _fiber,
                        percentage: (totalFiber / totalNutrients * 100),
                        amount: totalFiber,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 130,
              height: 130,
              child: SfCircularChart(
                palette: _palette,
                annotations: <CircularChartAnnotation>[
                  CircularChartAnnotation(
                    widget: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          totalKcal.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Kcal',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                series: <DoughnutSeries>[
                  DoughnutSeries<_NutrientData, String>(
                    dataSource: [
                      _NutrientData('Carbs', totalCarbs),
                      _NutrientData('Proteins', totalProteins),
                      _NutrientData('Fiber', totalFiber),
                      _NutrientData('Fat', totalFat),
                    ],
                    xValueMapper: (_NutrientData data, _) => data.nutrient,
                    yValueMapper: (_NutrientData data, _) => data.amount,
                    innerRadius: '80%',
                  ),
                ],
              ),
            ),
          ],
        ),
        if (trackPrices) ...[
          const Spacer(),
          Text(
            'Total cost: ${(backend.calculatePriceFromIngredients(ingredients, nTotalPortions) * nEatenPortions).toStringAsFixed(2)} €',
            style: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ]
      ],
    );
  }
}

class _NutrientData {
  _NutrientData(this.nutrient, this.amount);

  final String nutrient;
  final double amount;
}
