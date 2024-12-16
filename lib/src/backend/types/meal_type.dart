enum MealType {
  breakfast,
  lunch,
  dinner,
  snack;

  String get name {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
      default:
        throw Exception('Invalid meal type');
    }
  }
}
