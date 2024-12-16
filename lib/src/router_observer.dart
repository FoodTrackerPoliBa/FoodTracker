import 'package:flutter/material.dart';
import 'package:food_traker/src/backend/analytics.dart';

class RouteObserverClass extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    analytics.logRouteActivity('push');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    analytics.logRouteActivity('pop');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    analytics.logRouteActivity('replace');
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    analytics.logRouteActivity('remove');
  }

  @override
  void didStartUserGesture(
      Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didStartUserGesture(route, previousRoute);
    analytics.logRouteActivity('start_user_gesture');
  }

  @override
  void didStopUserGesture() {
    super.didStopUserGesture();
    analytics.logRouteActivity('stop_user_gesture');
  }
}
