import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:food_traker/setup.dart';
import 'package:food_traker/src/backend/analytics.dart';
import 'package:food_traker/src/backend/first_start_setup.dart';
import 'package:food_traker/src/dashboard/dashboard.dart';
import 'package:food_traker/src/logging.dart';
import 'package:food_traker/src/router_observer.dart';
import 'package:openfoodfacts/openfoodfacts.dart' as off;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  FlutterError.onError = (details) {
    if (details.toStringShort().contains("hasSize")) {
      /// Avoid use talker for widget overflows
      FlutterError.presentError(details);
      return;
    }
    logging.handle(
      details,
      details.stack,
      "Flutter error:",
    );
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    logging.error("Platform error: $error", error, stack);
    return false;
  };
  WidgetsFlutterBinding.ensureInitialized();
  off.OpenFoodAPIConfiguration.userAgent = off.UserAgent(name: 'FoodTracker');

  off.OpenFoodAPIConfiguration.globalLanguages = <off.OpenFoodFactsLanguage>[
    off.OpenFoodFactsLanguage.ITALIAN
  ];

  off.OpenFoodAPIConfiguration.globalCountry = off.OpenFoodFactsCountry.ITALY;
  sqfliteFfiInit();

  await FirstStartSetup.init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Register the observer
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Unregister the observer
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        // App is in the foreground
        analytics.appResumed();
        break;
      case AppLifecycleState.inactive:
        // App is inactive. Pause ongoing tasks.
        analytics.appInactive();
        break;
      case AppLifecycleState.paused:
        // App is paused. Release resources.
        analytics.appPaused();
        break;
      case AppLifecycleState.detached:
        // App is detached from the engine. Free up resources.
        analytics.appDetached();
        break;
      case AppLifecycleState.hidden:
        // App is hidden. Hide the UI.
        analytics.appHidden();
      default:
        print('Unknown lifecycle state');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        navigatorObservers: [RouteObserverClass()],
        debugShowCheckedModeBanner: false,
        title: 'FoodTracker',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.orange, brightness: Brightness.light),
          useMaterial3: true,
        ),
        home: firstStart! ? const Setup() : const Dashboard());
  }
}
