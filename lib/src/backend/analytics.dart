import 'package:food_traker/src/backend/backend.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class Analytics {
  /// Cache in case of offline
  /// - Event name
  /// - Event parameters
  /// - Event timestamp
  final List<(String, Map<String, dynamic>, int)> _events = [];
  String? userId = "";
  Future<void> logEventAndLocal(
      {required String name, Map<String, dynamic>? parameters}) async {
    assert(userId != null,
        "userId not set, please call init() before calling logEventAndLocal");
    if (_events.isNotEmpty) {
      List<(String, Map<String, dynamic>, int)> failedEvents = [];

      for (var event in _events) {
        backend
            .addEventToServer(userId!, event.$1, event.$2,
                millisecondsSinceEpoch: event.$3)
            .onError((error, stackTrace) {
          // logging.info("Failed to send event to server: ${event.$1} storing it locally");
          failedEvents.add(event);
        }).ignore();
      }
      _events.clear();
      _events.addAll(failedEvents);
    }
    backend
        .addEventToServer(userId!, name, parameters ?? {})
        .onError((error, stackTrace) {
      _events
          .add((name, parameters ?? {}, DateTime.now().millisecondsSinceEpoch));
    }).ignore();
  }

  Future<void> init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('user_id');
    if (userId == null) {
      userId = const Uuid().v4();
      await prefs.setString('user_id', userId!);
    }
    logEventAndLocal(name: "app_launched");
  }

  Future<void> routeChange(String route) async {
    await logEventAndLocal(name: "route_change", parameters: {"route": route});
  }

  Future<void> routePop(String currentRoute) async {
    await logEventAndLocal(
        name: "route_pop", parameters: {"current_route": currentRoute});
  }

  Future<void> logRouteActivity(String activityType) async {
    await logEventAndLocal(
        name: "route_activity", parameters: {"activity_type": activityType});
  }

  Future<void> appResumed() async {
    await logEventAndLocal(name: "app_resumed");
  }

  Future<void> appInactive() async {
    await logEventAndLocal(name: "app_inactive");
  }

  Future<void> appPaused() async {
    await logEventAndLocal(name: "app_paused");
  }

  Future<void> appDetached() async {
    await logEventAndLocal(name: "app_detached");
  }

  Future<void> appHidden() async {
    await logEventAndLocal(name: "app_hidden");
  }
}

final analytics = Analytics();
