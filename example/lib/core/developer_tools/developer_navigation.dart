import 'package:flutter/material.dart';
import 'package:example/core/routes/app_router.dart';

/// Developer-tools screens (menu, API log viewer, ...) are deliberately NOT
/// registered as go_router routes — they're pushed straight onto the root
/// Navigator instead, same pattern as ErrorReporter's recovery screen. That
/// keeps them unreachable by path/deep-link, matching "hidden from normal
/// users" — only the floating button (itself gated by DeveloperModeNotifier)
/// can open them.
///
/// Debounced: a GestureDetector combining drag + tap (see
/// DraggableDebugButton) can fire onTap more than once for what's visually a
/// single press, and a user mashing the button would otherwise stack the
/// same page many times over. One push per [_debounce] window is enough.
const _debounce = Duration(milliseconds: 600);
DateTime? _lastPushAt;

/// True while any developer-tools screen is on screen — lets DeveloperOverlay
/// hide the floating button so it doesn't float on top of the dev tools
/// themselves. Stays true through the whole developer-tools navigation
/// stack (menu → API logs → log detail, ...), since it only flips back once
/// the outermost [pushDeveloperPage] route is popped.
final ValueNotifier<bool> isDeveloperPageVisible = ValueNotifier(false);

void pushDeveloperPage(Widget page) {
  final now = DateTime.now();
  if (_lastPushAt != null && now.difference(_lastPushAt!) < _debounce) return;
  _lastPushAt = now;

  final navigator = appRouter.routerDelegate.navigatorKey.currentState;
  if (navigator == null) return;

  isDeveloperPageVisible.value = true;
  navigator
      .push(MaterialPageRoute(builder: (_) => page))
      .whenComplete(() => isDeveloperPageVisible.value = false);
}

/// Null if called before the app's root Navigator has mounted.
BuildContext? rootDeveloperContext() {
  try {
    return appRouter.routerDelegate.navigatorKey.currentState?.context;
  } catch (_) {
    return null;
  }
}
