import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:example/core/config/app_config.dart';
import 'package:example/main.dart';

void main() {
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      FlavorConfig(variables: {"mode": Flavor.prod});
      mainCommon(flavor: Flavor.prod);
    },
    (error, stack) => log(
      'Error in mainCommon: $error',
      name: 'MainCommon',
      error: error,
      stackTrace: stack,
    ),
    // CrashlyticsLogger.recordError(error, stack, fatal: true), // need firebase
  );
}
