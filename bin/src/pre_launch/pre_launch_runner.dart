import 'dart:io';

import '../common/console.dart';
import '../common/version_utils.dart';
import 'build_runner_strategy.dart';

/// Prepares a generated project for a given [flavor] before running it:
/// copies the matching `.env` and `GoogleService-Info.plist`, then
/// (optionally) runs build_runner.
///
/// File names are derived by convention (`.env.<flavor>`,
/// `GoogleService-Info-<flavor>.plist`) rather than a fixed lookup table —
/// this must work for any flavor a project defines (see `flavor add`), not
/// just the built-in "dev"/"prod".
Future<void> mainPLT(List<String> arguments) async {
  await _checkDartVersion();

  if (arguments.isEmpty) {
    logError('No flavor argument provided.');
    exit(1);
  }

  final flavor = arguments[0];
  final envFile = '.env.$flavor';

  _copyEnvFile(envFile);
  _copyGoogleServiceFile(flavor);

  logHint(
    'build_runner regenerates code that depends on your .env values and '
    'annotations (envied\'s .g.dart, injectable\'s DI registration, freezed/'
    'json_serializable models). Re-run it whenever those change, e.g. after '
    'switching flavor.',
  );
  final shouldRun = await promptYesNoAutoYes('Run build_runner?');
  if (!shouldRun) {
    logInfo('Skipped build_runner execution.');
    return;
  }

  BuildRunnerResult result;
  try {
    result = await runStep(
      'Generating code (build_runner) for flavor: $flavor',
      () => runBuildRunner(),
    );
  } catch (e) {
    logError('Failed to run build_runner: $e');
    exit(1);
  }

  if (!result.success) {
    logError(
        'All strategies failed. Please ensure SDK & dependencies are installed correctly.');
    if (result.output.trim().isNotEmpty) {
      stdout.writeln('');
      logHint('--- build_runner output (for debugging) ---');
      stdout.writeln(result.output.trim());
    }
    exit(1);
  }
}

Future<void> _checkDartVersion() async {
  final minVersion = await getMinDartVersionFromPubspec();
  final currentVersion = await getDartVersion();
  if (minVersion != null &&
      currentVersion != null &&
      versionLessThan(currentVersion, minVersion)) {
    logError(
      'Current Dart SDK version ($currentVersion) is lower than the minimum required ($minVersion). '
      'Please switch to the correct SDK (e.g., using fvm).',
    );
    exit(1);
  }
}

void _copyEnvFile(String envFile) {
  final cwd = Directory.current.path;
  final envSource = File('$cwd/$envFile');
  final envTarget = File('$cwd/.env');

  if (!envSource.existsSync()) {
    logError('File $envFile not found.');
    exit(1);
  }

  envSource.copySync(envTarget.path);
  logInfo('Using $envFile');
}

void _copyGoogleServiceFile(String flavor) {
  final cwd = Directory.current.path;
  final googleServiceFile = 'GoogleService-Info-$flavor.plist';
  final googleServiceFilePath = '$cwd/ios/Runner/$googleServiceFile';

  if (!File(googleServiceFilePath).existsSync()) {
    logWarn('GoogleService-Info file not found for this flavor.');
    return;
  }

  File(googleServiceFilePath)
      .copySync('$cwd/ios/Runner/GoogleService-Info.plist');
  logInfo('Using $googleServiceFile for GoogleService-Info.plist');
}
