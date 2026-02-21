import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ProjectName/app.dart';
import 'package:ProjectName/core/config/app_config.dart';
import 'package:ProjectName/core/config/di_module/init_config.dart';
import 'package:ProjectName/core/env/secure_storage_key.dart';
import 'package:ProjectName/core/utils/bloc_providers.dart';
import 'package:ProjectName/core/utils/storage_data.dart';

void mainCommon({required Flavor flavor}) async {
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await AppConfig.initialize(flavor: flavor);

  await initConfig();

  // setup analytic
  // final analytic = getIt<Analytic>();
  // await analytic.init();

  String? locale = await storage.read(key: localeLangId);

  runApp(
    ScreenUtilInit(
      builder: (_, __) => getBlocWrapper(
        EasyLocalization(
          supportedLocales: const [Locale('en'), Locale('id')],
          path: 'assets/translations',
          fallbackLocale: const Locale('en'),
          startLocale: Locale(locale ?? 'en'),
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
