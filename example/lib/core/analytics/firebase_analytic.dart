import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:example/core/analytics/analytic.dart';

// Registered conditionally via AppModule.analytic (not @LazySingleton here)
// — only NoOpAnalytic is used when ENABLE_FIREBASE is false, so this class
// is never constructed without Firebase having been initialized first.
class FirebaseAnalytic implements Analytic {
  final FirebaseAnalytics fAnalytic = FirebaseAnalytics.instance;

  @override
  Future<void> init() async {
    await fAnalytic.setAnalyticsCollectionEnabled(true);
  }

  @override
  Future<void> sendEvent({
    required String eventName,
    Map<String, String>? param,
  }) async {
    await fAnalytic.logEvent(name: eventName, parameters: param);
  }

  @override
  Future<void> sendScreenEngagementEvent({
    required String screenName,
    Duration duration = Duration.zero,
    String? screenWidgetClass,
  }) async {
    screenName = screenName.contains("/")
        ? screenName.replaceFirst("/", "")
        : screenName;

    return fAnalytic.logScreenView(screenName: screenName);
  }
}
