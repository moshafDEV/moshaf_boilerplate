/// Limits the "API error" toast to one per [cooldown], counting what it
/// swallowed so the next toast can say "+N more" instead of stacking a queue
/// of snackbars while a screen retries or fans out several calls.
class ErrorToastThrottle {
  ErrorToastThrottle({this.cooldown = const Duration(seconds: 4)});

  final Duration cooldown;
  DateTime? _lastShown;
  int _suppressed = 0;

  /// True when a toast may be shown now. Otherwise the call is counted as
  /// suppressed.
  bool allow(DateTime now) {
    final last = _lastShown;
    if (last != null && now.difference(last) < cooldown) {
      _suppressed++;
      return false;
    }
    _lastShown = now;
    return true;
  }

  /// Number of errors swallowed since the last toast; resets to zero.
  int takeSuppressed() {
    final count = _suppressed;
    _suppressed = 0;
    return count;
  }
}
