import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ProjectName/app.dart';
import 'package:ProjectName/core/analytics/analytic.dart';
import 'package:ProjectName/core/config/app_config.dart';
import 'package:ProjectName/core/config/di_module/init_config.dart';
import 'package:ProjectName/core/config/firebase_support.dart';
import 'package:ProjectName/core/config/startup_error_app.dart';
import 'package:ProjectName/core/env/env.dart';
import 'package:ProjectName/core/env/secure_storage_key.dart';
import 'package:ProjectName/core/utils/bloc_providers.dart';
import 'package:ProjectName/core/utils/error_reporter.dart';
import 'package:ProjectName/core/utils/storage_data.dart';

Future<void> mainCommon({required Flavor flavor}) async {
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  String? locale;
  try {
    await AppConfig.initialize(flavor: flavor);

    await initConfig();

    // Only true when Firebase (and specifically Crashlytics) actually got
    // initialized above — otherwise Crashlytics itself would throw inside
    // the error handler.
    ErrorReporter.crashlyticsReady = Env.enableFirebase &&
        isFirebaseSupported &&
        isFirebaseCrashlyticsSupported;

    // setup analytic
    final analytic = getIt<Analytic>();
    await analytic.init();

    locale = await storage.read(key: localeLangId);
  } catch (e, s) {
    // Startup must always end in a runApp call. Without this, a throw here
    // left the Flutter view unattached — a blank window with the reason
    // logged nowhere the user could reach.
    debugPrint('Startup failed: $e\n$s');
    ErrorReporter.recordZoneError(e, s);
    runApp(
      StartupErrorApp(
        error: e,
        onRetry: () async {
          // initConfig registers singletons, so a plain retry would throw
          // "already registered".
          await getIt.reset();
          await mainCommon(flavor: flavor);
        },
      ),
    );
    return;
  }

  runApp(
    ScreenUtilInit(
      builder: (_, __) => getBlocWrapper(
        EasyLocalization(
          supportedLocales: const [Locale('en'), Locale('id')],
          path: 'assets/translations',
          fallbackLocale: const Locale('en'),
          startLocale: Locale(locale ?? 'en'),
          // Default is a bare ErrorWidget — the grey box again. A failed
          // translation load must not take the whole app down with it.
          errorWidget: (message) => StartupErrorApp(
            error: message ?? 'Translations failed to load',
            onRetry: () async {
              await getIt.reset();
              await mainCommon(flavor: flavor);
            },
          ),
          child: const App(),
        ),
      ),
    ),
  );
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
}
