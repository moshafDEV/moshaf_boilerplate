import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:example/core/developer_tools/api_logs/api_log_model.dart';

/// In-memory only — logs never touch disk. Newest first, capped at
/// [maxLogs] so a long dev session can't grow this unbounded.
@lazySingleton
class ApiLogStore extends ChangeNotifier {
  static const maxLogs = 100;

  final List<ApiLogEntry> _logs = [];

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
