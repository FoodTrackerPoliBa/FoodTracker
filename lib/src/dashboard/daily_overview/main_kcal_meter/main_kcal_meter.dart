import 'dart:math';

import 'package:flutter/material.dart';
import 'package:food_traker/src/backend/types/daily_overview_data.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class MainKcalMeter extends StatelessWidget {
  const MainKcalMeter({super.key, required this.data});
  final DailyOverviewData data;

  @override
  Widget build(BuildContext context) {
    return CircularPercentIndicator(
      radius: 90.0,
      lineWidth: 13.0,
      animation: true,
      percent: min(data.actual.kcalories / data.target.kcalories, 1),
      arcType: ArcType.FULL,
      progressColor: Theme.of(context).colorScheme.primary,
      arcBackgroundColor: Theme.of(context).colorScheme.primary.withAlpha(50),
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_fire_department,
              size: 30, color: Theme.of(context).colorScheme.onSurface),
          Text("${(data.target.kcalories - data.actual.kcalories).abs()}",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  letterSpacing: -1)),
          if (data.target.kcalories - data.actual.kcalories > 0)
            Text(
              "kcal left",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
            )
          else
            Text(
              "kcal over",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
            ),
          const SizedBox(height: 10),
          Text(" of ${data.target.kcalories} kcal",
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
        ],
      ),
      circularStrokeCap: CircularStrokeCap.round,
    );
  }
}
