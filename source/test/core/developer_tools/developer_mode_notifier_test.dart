import 'package:flutter_test/flutter_test.dart';
import 'package:ProjectName/core/developer_tools/developer_mode_notifier.dart';

void main() {
  test('developer mode defaults to disabled', () {
    final notifier = DeveloperModeNotifier();
    expect(notifier.isEnabled, isFalse);
  });

  test('enable() turns it on and notifies once', () {
    final notifier = DeveloperModeNotifier();
    var notifyCount = 0;
    notifier.addListener(() => notifyCount++);

    notifier.enable();

    expect(notifier.isEnabled, isTrue);
    expect(notifyCount, 1);
  });

  test('enable() twice only notifies once', () {
    final notifier = DeveloperModeNotifier();
    var notifyCount = 0;
    notifier.addListener(() => notifyCount++);

    notifier.enable();
    notifier.enable();

    expect(notifyCount, 1);
  });

  test('disable() turns it off', () {
    final notifier = DeveloperModeNotifier()..enable();

    notifier.disable();

    expect(notifier.isEnabled, isFalse);
  });
}
