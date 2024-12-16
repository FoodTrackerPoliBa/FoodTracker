enum Gender {
  male,
  female;

  String get value {
    switch (this) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      default:
        throw Exception('Invalid gender');
    }
  }
}
