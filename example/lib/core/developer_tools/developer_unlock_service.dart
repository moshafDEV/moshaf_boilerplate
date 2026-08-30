import 'package:injectable/injectable.dart';

/// Counts taps on a hidden trigger (e.g. the app version in About) toward
/// the unlock threshold. A gap longer than [tapTimeout] between taps resets
/// the count, so it can't be reached by idle, unrelated taps over time.
@lazySingleton
class DeveloperUnlockService {
  static const requiredTaps = 7;
  static const tapTimeout = Duration(seconds: 3);

  int _tapCount = 0;
  DateTime? _lastTapAt;

  /// Registers one tap. Returns true exactly on the tap that reaches
  /// [requiredTaps] (and resets the counter for next time); false otherwise.
  bool registerTap() {
    final now = DateTime.now();
    if (_lastTapAt != null && now.difference(_lastTapAt!) > tapTimeout) {
      _tapCount = 0;
    }
    _lastTapAt = now;
    _tapCount++;

    if (_tapCount >= requiredTaps) {
      _tapCount = 0;
      return true;
    }
    return false;
  }
}
