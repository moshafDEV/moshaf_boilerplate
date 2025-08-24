import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class CrashlyticsLogger {
  static Future<void> init({bool sendReportInDebug = false}) async {
    //handle uncaught errors
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    bool sendReport = false;
    if (!kDebugMode) {
      sendReport = true;
    }

    if (kDebugMode && sendReportInDebug) {
      sendReport = true;
    }
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
      sendReport,
    );
  }

  static void log(String info) {
    FirebaseCrashlytics.instance.log(info);
  }

  static void recordError(
    dynamic exception,
    StackTrace? stack, {
    dynamic reason,
    bool fatal = false,
  }) {
    FirebaseCrashlytics.instance.recordError(
      exception,
      stack,
      reason: reason,
      fatal: fatal,
    );
  }
}
