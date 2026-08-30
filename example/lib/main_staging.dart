import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:example/core/config/app_config.dart';
import 'package:example/core/utils/error_reporter.dart';
import 'package:example/main.dart';

void main() {
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      ErrorReporter.install();
      FlavorConfig(
        name: "STAGING",
        color: Colors.red,
        location: BannerLocation.bottomEnd,
        variables: {"mode": Flavor.staging},
      );
      await mainCommon(flavor: Flavor.staging);
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
