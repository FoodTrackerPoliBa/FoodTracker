class NoGeminiApiFound implements Exception {
  final String message;

  NoGeminiApiFound({this.message = 'No Gemini API found'});

  @override
  String toString() {
    return 'NoGeminiApiFound: $message';
  }
}