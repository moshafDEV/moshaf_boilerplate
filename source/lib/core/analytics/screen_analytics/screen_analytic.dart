import 'package:ProjectName/core/analytics/analytic.dart';
import 'package:ProjectName/core/analytics/screen_analytics/screen_analytic_listener.dart';

mixin ScreenAnalyticTracker {
  late Analytic analytic;
  String? _currentScreen;
  DateTime? _lastActiveScreenTime;

  final List<ScreenAnalyticListener> _listeners = [];

  String? getCurrentScreen() {
    return _currentScreen;
  }

  void trackScreen(String screenName) {
    if (_currentScreen == null) {
      _currentScreen = screenName;
      _lastActiveScreenTime = DateTime.now();
      return;
    }

    if (_currentScreen != screenName) {
      Duration prevScreenDuration = _calcActiveDuration();
      String prevScreen = _currentScreen!;

      //track new screeen
      _currentScreen = screenName;
      _lastActiveScreenTime = DateTime.now();

      if (prevScreenDuration.inMilliseconds > 1000) {
        analytic.sendScreenEngagementEvent(
          screenName: prevScreen,
          duration: prevScreenDuration,
        );
      }
      notifyListeners(prevScreen, _currentScreen!, prevScreenDuration);
    }
  }

  void stopTrackCurrent() {
    if (_currentScreen != null) {
      final Duration activeDuration = _calcActiveDuration();
      if (activeDuration.inMilliseconds > 1000) {
        analytic.sendScreenEngagementEvent(
          screenName: _currentScreen!,
          duration: activeDuration,
        );
      }
      _currentScreen = null;
      _lastActiveScreenTime = null;
    }
  }

  void addListener(ScreenAnalyticListener listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }
  }

  void removeListener(ScreenAnalyticListener listener) {
    if (_listeners.contains(listener)) {
      _listeners.remove(listener);
    }
  }

  void notifyListeners(
    String prevScreen,
    String currScreen,
    Duration prevScreenDuration,
  ) {
    if (_listeners.isEmpty) {
      return;
    }

    for (ScreenAnalyticListener listener in _listeners) {
      listener.onScreenChanged(prevScreen, currScreen, prevScreenDuration);
    }
  }

  Duration _calcActiveDuration() {
    final int currTime = DateTime.now().millisecondsSinceEpoch;
    final int lastTime = _lastActiveScreenTime == null
        ? 0
        : _lastActiveScreenTime!.millisecondsSinceEpoch;
    int diffMs = currTime - lastTime;
    return Duration(milliseconds: diffMs);
  }
}
