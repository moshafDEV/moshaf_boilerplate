import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ProjectName/core/developer_tools/developer_mode_notifier.dart';
import 'package:ProjectName/core/developer_tools/developer_navigation.dart';
import 'package:ProjectName/core/developer_tools/developer_overlay.dart';
import 'package:ProjectName/core/developer_tools/draggable_debug_button.dart';

Widget _wrap(DeveloperModeNotifier notifier) {
  return MaterialApp(
    home: ChangeNotifierProvider.value(
      value: notifier,
      child: const DeveloperOverlay(child: Scaffold(body: SizedBox.expand())),
    ),
  );
}

void main() {
  // isDeveloperPageVisible is a module-level global — reset it so one
  // test's state can't leak into the next.
  setUp(() => isDeveloperPageVisible.value = false);

  testWidgets('floating button does not appear when developer mode is off',
      (tester) async {
    await tester.pumpWidget(_wrap(DeveloperModeNotifier()));

    expect(find.byType(DraggableDebugButton), findsNothing);
  });

  testWidgets('floating button appears when developer mode is on',
      (tester) async {
    await tester.pumpWidget(_wrap(DeveloperModeNotifier()..enable()));

    expect(find.byType(DraggableDebugButton), findsOneWidget);
  });

  testWidgets('floating button can be dragged to a new position', (tester) async {
    await tester.pumpWidget(_wrap(DeveloperModeNotifier()..enable()));

    final before = tester.getTopLeft(find.byType(DraggableDebugButton));

    // Default corner is bottom-left (see DraggableDebugButton) — drag up
    // and to the right, away from that corner, so the move isn't
    // immediately clamped back to the same edge it started at.
    await tester.drag(find.byType(DraggableDebugButton), const Offset(100, -100));
    await tester.pump();

    final after = tester.getTopLeft(find.byType(DraggableDebugButton));

    expect(after, isNot(equals(before)));
    expect(after.dx, greaterThan(before.dx));
    expect(after.dy, lessThan(before.dy));
  });

  testWidgets('floating button hides while a developer page is visible',
      (tester) async {
    await tester.pumpWidget(_wrap(DeveloperModeNotifier()..enable()));
    expect(find.byType(DraggableDebugButton), findsOneWidget);

    isDeveloperPageVisible.value = true;
    await tester.pump();
    expect(find.byType(DraggableDebugButton), findsNothing);

    isDeveloperPageVisible.value = false;
    await tester.pump();
    expect(find.byType(DraggableDebugButton), findsOneWidget);
  });
}
