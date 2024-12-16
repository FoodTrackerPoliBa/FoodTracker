enum ActivityLevel {
  sedentary,
  lightlyActive,
  moderatelyActive,
  veryActive,
  superActive;

  double get factor {
    switch (this) {
      case ActivityLevel.sedentary:
        return 1.2;
      case ActivityLevel.lightlyActive:
        return 1.375;
      case ActivityLevel.moderatelyActive:
        return 1.55;
      case ActivityLevel.veryActive:
        return 1.725;
      case ActivityLevel.superActive:
        return 1.9;
    }
  }

  String get value {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'Sedentary';
      case ActivityLevel.lightlyActive:
        return 'Lightly active';
      case ActivityLevel.moderatelyActive:
        return 'Moderately active';
      case ActivityLevel.veryActive:
        return 'Very active';
      case ActivityLevel.superActive:
        return 'Super active';
    }
  }
}
