class NoFoodFounded implements Exception {
  final String message;

  NoFoodFounded({this.message = 'No food founded'});

  @override
  String toString() {
    return 'NoFoodFounded: $message';
  }
}