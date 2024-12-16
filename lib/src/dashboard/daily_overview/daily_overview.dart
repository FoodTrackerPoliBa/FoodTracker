import 'package:flutter/material.dart';
import 'package:food_traker/src/backend/backend.dart';
import 'package:food_traker/src/backend/types/daily_overview_data.dart';
import 'package:food_traker/src/dashboard/daily_overview/burned/burned.dart';
import 'package:food_traker/src/dashboard/daily_overview/main_kcal_meter/main_kcal_meter.dart';
import 'package:food_traker/src/dashboard/daily_overview/row_nutrients/row_nutrients.dart';
import 'package:food_traker/src/dashboard/daily_overview/supplied/supplied.dart';
import 'package:food_traker/src/dashboard/daily_overview/total_price/total_price.dart';
import 'package:food_traker/src/globals.dart';

class DailyOverview extends StatelessWidget {
  const DailyOverview({super.key, required this.day});
  final DateTime day;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AnimatedBuilder(
          animation: backend,
          builder: (context, child) => FutureBuilder<DailyOverviewData>(
            future: backend.getDailyOverviewData(date: day),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              final DailyOverviewData data =
                  snapshot.data ?? DailyOverviewData.empty();
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Supplied(supplied: data.supplied),
                      ),
                      MainKcalMeter(
                        data: data,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Burned(burned: data.burned),
                      ),
                    ],
                  ),
                  RowNutrients(data: data),
                  if (trackPrices) TotalPrice(mealSessions: data.price)
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
