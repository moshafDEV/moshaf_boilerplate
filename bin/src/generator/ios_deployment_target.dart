import 'dart:io';

import 'package:dart_xcodeproj/dart_xcodeproj.dart';

import '../common/console.dart';

/// Firebase's iOS SDKs (installed by this boilerplate) require this via
/// Swift Package Manager; bump if a future dependency needs higher.
const minimumIosDeploymentTarget = '15.0';

/// Raises IPHONEOS_DEPLOYMENT_TARGET in project.pbxproj from Flutter's
/// default (13.0) — otherwise the build fails with a Firebase "Target
/// Integrity" error the first time firebase_* packages resolve via SPM.
///
/// Uses a real pbxproj parser (the same one flutter_flavorizr depends on,
/// so it's already proven against Flutter-generated projects) instead of a
/// blind text regex: it touches every build configuration on the project
/// itself and on every target (Runner, RunnerTests, and any flavor-specific
/// ones flavorizr later adds), so it can't silently miss a spot — and if
/// Xcode's file format ever changes in a way the parser can't handle, it
/// fails loudly here instead of quietly leaving the target unset.
Future<void> raiseIosDeploymentTarget(String projectPath) async {
  final xcodeprojPath = '$projectPath/ios/Runner.xcodeproj';
  if (!Directory(xcodeprojPath).existsSync()) {
    logWarn(
        'Warning: Runner.xcodeproj not found, skipping iOS deployment target bump.');
    return;
  }

  final project = await XcodeProject.open(xcodeprojPath);

  for (final config in project.buildConfigurationList.buildConfigurations) {
    config.buildSettings['IPHONEOS_DEPLOYMENT_TARGET'] =
        minimumIosDeploymentTarget;
  }
  for (final target in project.targets) {
    final configList = target.buildConfigurationList;
    if (configList == null) continue;
    for (final config in configList.buildConfigurations) {
      config.buildSettings['IPHONEOS_DEPLOYMENT_TARGET'] =
          minimumIosDeploymentTarget;
    }
  }

  await project.save();
}
