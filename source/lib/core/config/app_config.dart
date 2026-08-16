import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:ProjectName/core/config/firebase_support.dart';
import 'package:ProjectName/core/config/loggers/crashlytic_logger.dart';
import 'package:ProjectName/core/env/env.dart';

enum Flavor {
  dev(0),
  prod(1);

  const Flavor(this.level);
  final int level;
}

class AppConfig {
  final Flavor flavor;
  final String apiUrl;
  // final MessagingAuth messagingAuth;

  static AppConfig? _instance;

  factory AppConfig() {
    if (_instance == null) {
      throw UnimplementedError('AppConfig must be initialized first.');
    }

    return _instance!;
  }

  static Future<void> initialize({required Flavor flavor}) async {
    // Guarded twice: without real google-services.json/GoogleService-Info.plist
    // in place, Firebase.initializeApp() itself throws (see README > Flavors);
    // and firebase_analytics/firebase_messaging ship no Windows/Linux
    // implementation at all, so this must stay off there regardless of the
    // flag (see firebase_support.dart).
    if (Env.enableFirebase && isFirebaseSupported) {
      final firebaseApp = await Firebase.initializeApp();
      debugPrint('>> Firebase Project ID: ${firebaseApp.options.projectId}');

      if (isFirebaseCrashlyticsSupported) {
        await CrashlyticsLogger.init();
      }

      final fcmToken = await FirebaseMessaging.instance.getToken();
      debugPrint('>> FCM Token: ${fcmToken ?? ''}');
    }

    // get base url
    final apiUrl = Env.apiUrl;

    _instance = AppConfig._internal(flavor: flavor, apiUrl: apiUrl);
  }

  AppConfig._internal({required this.flavor, required this.apiUrl});

  static AppConfig get instance => AppConfig();

  static bool get isDev => instance.flavor == Flavor.dev;
  static bool get isProd => instance.flavor == Flavor.prod;
}
