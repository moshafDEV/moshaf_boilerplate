import 'dart:io';

import '../common/console.dart';

/// `flutter_secure_storage` (installed by this boilerplate) raised its own
/// Android compileSdk requirement to 37 in v11.0.0, matching Flutter 3.35+'s
/// own minSdk 24 baseline — a permanent move, not a transient plugin bug (see
/// its changelog). Flutter's own default compileSdk (`flutter.compileSdkVersion`
/// in the generated build.gradle.kts) hasn't caught up yet (still 36 as of
/// Flutter 3.47.0), so without this override every fresh `create` fails on
/// first Android build with an AAR metadata mismatch. Bump if a future
/// dependency needs higher.
const minimumAndroidCompileSdk = 37;

/// Raises `compileSdk` in android/app/build.gradle.kts from Flutter's own
/// default to at least [minimumAndroidCompileSdk], via
/// `maxOf(flutter.compileSdkVersion, $minimumAndroidCompileSdk)` — a floor,
/// not a fixed override, so this becomes a no-op automatically once Flutter's
/// own default catches up or exceeds it.
///
/// Building against this compileSdk requires Android SDK Platform
/// [minimumAndroidCompileSdk] to be installed locally (`sdkmanager
/// "platforms;android-$minimumAndroidCompileSdk"` or via Android Studio's SDK
/// Manager) — including on any CI agent building this project.
Future<void> raiseAndroidCompileSdk(String projectPath) async {
  final buildGradleFile = File('$projectPath/android/app/build.gradle.kts');
  if (!await buildGradleFile.exists()) {
    logWarn(
        'Warning: android/app/build.gradle.kts not found, skipping compileSdk floor.');
    return;
  }

  final contents = await buildGradleFile.readAsString();
  const target = 'compileSdk = flutter.compileSdkVersion';
  if (!contents.contains(target)) {
    logWarn(
        'Warning: expected "$target" not found in android/app/build.gradle.kts, skipping compileSdk floor.');
    return;
  }

  final updated = contents.replaceFirst(
    target,
    'compileSdk = maxOf(flutter.compileSdkVersion, $minimumAndroidCompileSdk)',
  );
  await buildGradleFile.writeAsString(updated);
}
