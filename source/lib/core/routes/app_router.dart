import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ProjectName/core/env/secure_storage_key.dart';
import 'package:ProjectName/core/routes/app_path.dart';
import 'package:ProjectName/core/routes/app_routes.dart';
import 'package:ProjectName/core/routes/route_error_page.dart';
import 'package:ProjectName/core/utils/error_reporter.dart';
import 'package:ProjectName/core/utils/navigator_stack_guard.dart';
import 'package:ProjectName/core/utils/storage_data.dart';

/// Routes that don't require an auth token — everything else redirects to
/// [Paths.welcome] when signed out.
const publicRoutes = {
  Paths.welcome,
  Paths.login,
  Paths.register,
  Paths.forgotPassword,
};

/// Routes exempt from the auth gate entirely — reachable whether signed in
/// or out, and never redirected away either direction. Splash needs this so
/// its 2s animation always plays; About needs it so the developer-mode
/// unlock gesture works even when there's no real login to test against.
const alwaysAllowedRoutes = {
  Paths.splash,
  Paths.about,
};

/// Pure auth-gate decision, split out from [_redirect] so it's unit-testable
/// without mocking flutter_secure_storage's platform channel — the storage
/// read is the only part that needs a real Flutter test/app environment.
@visibleForTesting
String? redirectDecision({required bool isAuthed, required String location}) {
  if (alwaysAllowedRoutes.contains(location)) return null;

  final isPublicRoute = publicRoutes.contains(location);
  if (!isAuthed && !isPublicRoute) return Paths.welcome;
  if (isAuthed && isPublicRoute) return Paths.home;
  return null;
}

/// Single source of truth for the splash/welcome auth gate — replaces the
/// duplicated Timer+mounted-check+token-read that used to live in both
/// SplashScreen and WelcomePage.
FutureOr<String?> _redirect(BuildContext context, GoRouterState state) async {
  final accessToken = await SecureStorageUtils.getStorage(bearerToken);
  return redirectDecision(
    isAuthed: accessToken.isNotEmpty,
    location: state.matchedLocation,
  );
}

/// Module-level singleton, same convention as [navigatorStackGuard] — a
/// GoRouter must not be recreated on every rebuild, or its page stack resets.
final GoRouter appRouter = GoRouter(
  initialLocation: Paths.splash,
  routes: appRoutes,
  redirect: _redirect,
  observers: [navigatorStackGuard],
  errorBuilder: (context, state) {
    ErrorReporter.recordHandled(
      state.error ?? Exception('Unknown route'),
      StackTrace.current,
      reason: 'No route matched "${state.uri}"',
    );
    return RouteErrorPage(
      title: 'Page not found',
      detail: 'No screen is registered for "${state.uri}".',
    );
  },
);
