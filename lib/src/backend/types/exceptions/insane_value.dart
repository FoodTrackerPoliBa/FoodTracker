class InsaneValueException implements Exception {
  final String message;

  InsaneValueException({this.message = "The value provided is stange"});

  @override
  String toString() {
    return 'InsaneValueException: $message';
  }
}