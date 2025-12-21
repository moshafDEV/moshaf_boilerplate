abstract class Analytic {
  static const String kPrefixNameEvent = "moshaf";

  Future<void> init();

  Future<void> sendEvent(
      {required String eventName, Map<String, String>? param});

  sendScreenEngagementEvent(
      {required String screenName,
      Duration duration = Duration.zero,
      String? screenWidgetClass});
}
