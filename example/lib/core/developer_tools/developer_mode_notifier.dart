import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Single global instance (see main.dart's MultiProvider) — the only source
/// of truth for whether developer tools (floating button, API logging) are
/// visible/active anywhere in the app. In-memory only: resets to disabled on
/// every cold start, on every environment, including dev (see main.dart,
/// which re-enables it there explicitly on each launch).
@lazySingleton
class DeveloperModeNotifier extends ChangeNotifier {
  bool _enabled = false;
  bool get isEnabled => _enabled;

  void enable() {
    if (_enabled) return;
    _enabled = true;
    notifyListeners();
  }

  void disable() {
    if (!_enabled) return;
    _enabled = false;
    notifyListeners();
  }
}
