import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:example/core/developer_tools/developer_mode_notifier.dart';
import 'package:example/core/developer_tools/developer_navigation.dart';
import 'package:example/core/developer_tools/draggable_debug_button.dart';

/// Sits above every page (see app.dart's MaterialApp.router `builder`).
/// Renders nothing extra when developer mode is off — the floating button
/// only exists in the tree at all while [DeveloperModeNotifier.isEnabled].
/// Also hides itself while a developer-tools screen is on screen (see
/// [isDeveloperPageVisible]) — no point floating on top of the menu it opens.
class DeveloperOverlay extends StatelessWidget {
  final Widget child;

  const DeveloperOverlay({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final isEnabled = context.watch<DeveloperModeNotifier>().isEnabled;

    return ValueListenableBuilder<bool>(
      valueListenable: isDeveloperPageVisible,
      builder: (context, onDeveloperPage, _) {
        final showButton = isEnabled && !onDeveloperPage;
        return Stack(
          children: [
            child,
            if (showButton) const DraggableDebugButton(),
          ],
        );
      },
    );
  }
}
