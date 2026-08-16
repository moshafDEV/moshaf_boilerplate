import 'package:ProjectName/core/analytics/analytic.dart';

/// Registered instead of [FirebaseAnalytic] when `ENABLE_FIREBASE` is false,
/// so anything that requests [Analytic] from DI (e.g. `ScreenAnalyticTracker`)
/// gets a safe no-op instead of a class whose constructor touches
/// `FirebaseAnalytics.instance` without Firebase ever having been initialized.
class NoOpAnalytic implements Analytic {
  @override
  Future<void> init() async {}

  @override
  Future<void> sendEvent({
    required String eventName,
    Map<String, String>? param,
  }) async {}

  @override
  Future<void> sendScreenEngagementEvent({
    required String screenName,
    Duration duration = Duration.zero,
    String? screenWidgetClass,
  }) async {}
}
