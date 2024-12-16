import 'package:food_traker/src/backend/analytics.dart';
import 'package:food_traker/src/backend/backend.dart';
import 'package:food_traker/src/backend/gemini_manager.dart';
import 'package:food_traker/src/backend/user_data.dart';

bool? firstStart;

class FirstStartSetup {
  static Future<void> init() async {
    await backend.init();
    await analytics.init();
    await UserData.init();
    if (!UserData.firstStart) {
      backend.updateImagesUrls();

      await geminiManager.init(raiseError: false);
    }
    firstStart = UserData.firstStart;
  }
}
