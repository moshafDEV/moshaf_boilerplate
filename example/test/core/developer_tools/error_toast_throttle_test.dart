import 'package:flutter_test/flutter_test.dart';
import 'package:example/core/developer_tools/api_logs/api_log_store.dart';
import 'package:example/core/developer_tools/api_logs/error_toast_throttle.dart';

void main() {
  final t0 = DateTime(2026, 1, 1, 12);

  test('first error shows, the rest inside the cooldown are swallowed', () {
    final throttle = ErrorToastThrottle();

    expect(throttle.allow(t0), isTrue);
    expect(throttle.allow(t0.add(const Duration(seconds: 1))), isFalse);
    expect(throttle.allow(t0.add(const Duration(seconds: 3))), isFalse);
    expect(throttle.takeSuppressed(), 2);
    expect(throttle.takeSuppressed(), 0);
  });

  test('shows again once the cooldown has passed', () {
    final throttle = ErrorToastThrottle();

    throttle.allow(t0);
    expect(throttle.allow(t0.add(const Duration(seconds: 4))), isTrue);
  });

  test('error toasts can be muted without clearing logs', () {
    final store = ApiLogStore();

    expect(store.errorToastsEnabled, isTrue);
    store.toggleErrorToasts();
    expect(store.errorToastsEnabled, isFalse);
  });
}
