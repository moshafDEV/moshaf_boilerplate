import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:ProjectName/core/config/app_config.dart';
import 'package:ProjectName/core/utils/error_reporter.dart';
import 'package:ProjectName/main.dart';

void main() {
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      ErrorReporter.install();
      FlavorConfig(
        name: "DEV",
        color: Colors.red,
        location: BannerLocation.topStart,
        variables: {"mode": Flavor.dev},
      );
      await mainCommon(flavor: Flavor.dev);
    },
    (error, stack) {
      log(
        'Error in mainCommon: $error',
        name: 'MainCommon',
        error: error,
        stackTrace: stack,
      );
      ErrorReporter.recordZoneError(error, stack);
    },
  );
}
