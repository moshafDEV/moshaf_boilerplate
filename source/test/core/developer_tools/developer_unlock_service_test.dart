import 'package:flutter_test/flutter_test.dart';
import 'package:ProjectName/core/developer_tools/developer_unlock_service.dart';

void main() {
  test('first 6 taps do not unlock', () {
    final service = DeveloperUnlockService();

    for (var i = 0; i < 6; i++) {
      expect(service.registerTap(), isFalse);
    }
  });

  test('7th tap unlocks', () {
    final service = DeveloperUnlockService();

    for (var i = 0; i < 6; i++) {
      service.registerTap();
    }

    expect(service.registerTap(), isTrue);
  });

  test('counter resets after unlocking — next 6 taps do not unlock again', () {
    final service = DeveloperUnlockService();

    for (var i = 0; i < 7; i++) {
      service.registerTap();
    }
    for (var i = 0; i < 6; i++) {
      expect(service.registerTap(), isFalse);
    }
  });
}
