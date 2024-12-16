class FoodAlreadyPresent implements Exception {
  final String? message;

  const FoodAlreadyPresent([this.message]);

  @override
  String toString() {
    return message != null ? 'FoodAlreadyPresent: $message' : 'FoodAlreadyPresent';
  }
}
