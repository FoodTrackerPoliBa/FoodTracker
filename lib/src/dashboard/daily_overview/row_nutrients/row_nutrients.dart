import 'package:flutter/material.dart';
import 'package:food_traker/src/backend/types/daily_overview_data.dart';

enum _NutrientType { protein, fat, carbohydrates, sugar }

class RowNutrients extends StatelessWidget {
  final DailyOverviewData data;

  const RowNutrients({super.key, required this.data});
  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction: Axis.horizontal,
      alignment: WrapAlignment.spaceAround,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _NutrientWidget(type: _NutrientType.protein, data: data),
        _NutrientWidget(type: _NutrientType.fat, data: data),
        _NutrientWidget(type: _NutrientType.carbohydrates, data: data),
        _NutrientWidget(type: _NutrientType.sugar, data: data),
      ],
    );
  }
}

class _NutrientWidget extends StatelessWidget {
  final _NutrientType type;
  final DailyOverviewData data;
  const _NutrientWidget({required this.type, required this.data});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 25,
            width: 25,
            child: CircularProgressIndicator(
                value: _getPercentage(),
                backgroundColor:
                    Theme.of(context).colorScheme.primary.withAlpha(50),
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary)),
          ),
          const SizedBox(width: 7),
          Text(
            _getNutrientValue(),
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Theme.of(context).colorScheme.onSurface),
          ),
        ],
      ),
    );
  }

  double _getPercentage() {
    switch (type) {
      case _NutrientType.protein:
        if (data.target.protein == 0) return 0;
        return data.actual.protein / data.target.protein;
      case _NutrientType.fat:
        if (data.target.fat == 0) return 0;
        return data.actual.fat / data.target.fat;
      case _NutrientType.carbohydrates:
        if (data.target.carbs == 0) return 0;
        return data.actual.carbs / data.target.carbs;
      case _NutrientType.sugar:
        if (data.target.sugar == 0) return 0;
        return 1 - data.actual.sugar / data.target.sugar;
      default:
        throw Exception('Unknown nutrient type');
    }
  }

  String _getNutrientValue() {
    switch (type) {
      case _NutrientType.protein:
        return '${data.actual.protein}/${data.target.protein}g\nprotein';
      case _NutrientType.fat:
        return '${data.actual.fat}/${data.target.fat}g\nfat';
      case _NutrientType.carbohydrates:
        return '${data.actual.carbs}/${data.target.carbs}g\ncarbs';
      case _NutrientType.sugar:
        return '${data.actual.sugar}/${data.target.sugar}g\nsugar';
      default:
        throw Exception('Unknown nutrient type');
    }
  }
}
