import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:ProjectName/core/routes/app_path.dart';
import 'package:ProjectName/core/utils/error_reporter.dart';

/// Shared instance — a fresh observer hasn't seen existing routes pushed and would mistake the next pop for an empty stack.
final NavigatorStackGuard navigatorStackGuard = NavigatorStackGuard();

/// Restores [restoreRoute] if the navigator stack ever empties, which Flutter otherwise renders as an unlogged black screen.
class NavigatorStackGuard extends NavigatorObserver {
  NavigatorStackGuard({this.restoreRoute = Paths.splash});

  /// Route pushed (with the stack cleared) when the navigator ever empties.
  final String restoreRoute;

  /// Routes seen pushed, tracked by identity rather than a counter so a missed callback can't drive it negative.
  final List<Route<dynamic>> _routes = <Route<dynamic>>[];

  /// False until the first push — an empty [_routes] before that just means "just attached", not "stack is empty".
  bool _sawPush = false;

  @visibleForTesting
  int get depth => _routes.length;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _sawPush = true;
    _routes.add(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _routes.remove(route);
    _restoreIfEmpty();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _routes.remove(route);
    _restoreIfEmpty();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute == null) return;
    final index = oldRoute == null ? -1 : _routes.indexOf(oldRoute);
    if (index >= 0) {
      _routes[index] = newRoute;
    } else {
      _sawPush = true;
      _routes.add(newRoute);
    }
  }

  void _restoreIfEmpty() {
    if (!_sawPush || _routes.isNotEmpty) return;

    // Deferred a frame so a pushAndRemoveUntil's momentary empty state doesn't trigger this mid-navigation.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_routes.isNotEmpty) return;
      final nav = navigator;
      if (nav == null || !nav.mounted) return;

      // canPop() true means this observer's view is incomplete, not that the stack is actually empty.
      if (nav.canPop()) return;

      ErrorReporter.recordHandled(
        StateError('Navigator stack emptied'),
        StackTrace.current,
        reason: 'Navigator stack emptied; restored $restoreRoute',
      );
      debugPrint(
          'NavigatorStackGuard: stack was empty, restoring $restoreRoute');

      GoRouter.of(nav.context).go(restoreRoute);
    });
  }
}
