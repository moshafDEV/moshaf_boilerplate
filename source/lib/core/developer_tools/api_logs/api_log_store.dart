import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:ProjectName/core/developer_tools/api_logs/api_log_model.dart';

/// In-memory only — logs never touch disk. Newest first, capped at
/// [maxLogs] so a long dev session can't grow this unbounded.
@lazySingleton
class ApiLogStore extends ChangeNotifier {
  static const maxLogs = 100;

  final List<ApiLogEntry> _logs = [];

  bool _errorToastsEnabled = true;

  /// Whether failed calls raise a snackbar. Failed calls are always logged;
  /// this only mutes the popup (Developer Menu → Error Toasts).
  bool get errorToastsEnabled => _errorToastsEnabled;

  void toggleErrorToasts() {
    _errorToastsEnabled = !_errorToastsEnabled;
    notifyListeners();
  }

  List<ApiLogEntry> getLogs() => List.unmodifiable(_logs);

  void add(ApiLogEntry entry) {
    _logs.insert(0, entry);
    if (_logs.length > maxLogs) {
      _logs.removeRange(maxLogs, _logs.length);
    }
    notifyListeners();
  }

  void clear() {
    _logs.clear();
    notifyListeners();
  }
}
