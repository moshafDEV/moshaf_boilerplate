// `flutter create` ships its own default counter-app test here, referencing
// a `MyApp` class that doesn't exist in this template — this file exists
// purely to override that with something that actually passes out of the
// box. Pumping the real `App()` needs full DI/routing/localization
// bootstrap (see main.dart's mainCommon) to work at all, which is more than
// a starter sanity test is worth — see forgot_password_link_test.dart or
// developer_overlay_test.dart for real examples of testing this project's
// own widgets.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('test harness is wired up', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Text('OK'))));

    expect(find.text('OK'), findsOneWidget);
  });
}
