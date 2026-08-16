import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:example/core/config/loggers/crashlytic_logger.dart';
import 'package:example/core/constants/colors.dart';
import 'package:example/core/constants/textstyle.dart';
import 'package:example/core/routes/app_path.dart';
import 'package:example/core/routes/app_router.dart';
import 'package:example/presentation/components/button.dart';

/// Decides what a user sees when something throws; call [install] once, before runApp, from every entrypoint.
class ErrorReporter {
  ErrorReporter._();

  /// Set true once Firebase is up — before that, Crashlytics itself would throw inside the error handler.
  static bool crashlyticsReady = false;

  static void install() {
    ErrorWidget.builder = _buildErrorWidget;

    FlutterError.onError = (details) {
      FlutterError.presentError(details); // keeps the console dump
      _record(
        details.exception,
        details.stack,
        reason: details.library == null
            ? 'Flutter framework error'
            : 'Flutter error in ${details.library}',
      );
    };
  }

  /// For runZonedGuarded: reports non-fatal, since an uncaught Dart error doesn't actually terminate the app.
  static void recordZoneError(Object error, StackTrace stack) {
    debugPrint('Uncaught zone error: $error\n$stack');
    _record(error, stack, reason: 'Uncaught async error');
  }

  /// Report a handled error explicitly, e.g. from a catch block that recovers.
  static void recordHandled(Object error, StackTrace? stack,
          {required String reason}) =>
      _record(error, stack, reason: reason);

  static void _record(Object error, StackTrace? stack,
      {required String reason}) {
    if (!crashlyticsReady) return;
    try {
      CrashlyticsLogger.log(reason);
      CrashlyticsLogger.recordError(error, stack, reason: reason, fatal: false);
    } catch (e) {
      debugPrint('Crashlytics report failed: $e');
    }
  }

  /// Null if the failure happened before MaterialApp was up, so there's nothing to navigate with.
  static NavigatorState? _rootNavigator() {
    try {
      return appRouter.routerDelegate.navigatorKey.currentState;
    } catch (e) {
      debugPrint('ErrorReporter: no navigator available: $e');
      return null;
    }
  }

  static void _goBack() {
    try {
      _rootNavigator()?.maybePop();
    } catch (e, s) {
      debugPrint('ErrorReporter: back failed: $e\n$s');
    }
  }

  static void _restart() {
    try {
      final context = _rootNavigator()?.context;
      if (context != null) GoRouter.of(context).go(Paths.splash);
    } catch (e, s) {
      debugPrint('ErrorReporter: restart failed: $e\n$s');
    }
  }

  /// No Scaffold/Theme — this can land in a small slot, not just a full page, and may sit above MaterialApp.
  static Widget _buildErrorWidget(FlutterErrorDetails details) {
    final navigator = _rootNavigator();
    final canGoBack = navigator?.canPop() ?? false;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: ClipRect(
        child: Material(
          color: kMainWhite,
          textStyle: genStyle12Regular,
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: kMainDanger),
                    const SizedBox(height: 16),
                    Text(
                      'Something went wrong',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: genStyle14Bold,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      navigator == null
                          ? "We couldn't display this section. Please close the app and open it again."
                          : canGoBack
                              ? "We couldn't display this section. Please go back and try again."
                              : "We couldn't display this section. Restart the app to continue.",
                      maxLines: 3,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: genStyle12Regular.copyWith(color: kMainSecondary),
                    ),
                    if (navigator != null) ...[
                      const SizedBox(height: 24),
                      if (canGoBack)
                        PrimaryButton(text: 'Go back', onPressed: _goBack)
                      else
                        PrimaryButton(text: 'Restart app', onPressed: _restart),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
