import 'dart:io';

import '../common/console.dart';
import '../common/flavors.dart';
import '../common/prompt.dart';
import '../common/version_utils.dart';
import 'build_runner_strategy.dart';

/// Prepares a generated project for a flavor before running it: copies the
/// matching `.env` and `GoogleService-Info.plist`, then (optionally) runs
/// build_runner.
///
/// With no flavor argument, offers the flavors discovered from `.env.*`
/// files as an interactive choice. File names are derived by convention
/// (`.env.<flavor>`, `GoogleService-Info-<flavor>.plist`) rather than a fixed
/// lookup table — this must work for any flavor a project defines (see
/// `flavor add`), not just the built-in "dev"/"prod".
///
/// Flags: `--yes`/`-y` runs build_runner without asking, `--no-build` skips
/// it, `--help`/`-h` prints usage.
Future<void> mainEnv(List<String> arguments) async {
  if (arguments.contains('--help') || arguments.contains('-h')) {
    printEnvUsage();
    return;
  }

  final skipBuild = arguments.contains('--no-build');
  final autoYes = arguments.contains('--yes') || arguments.contains('-y');
  final positional = arguments.where((a) => !a.startsWith('-')).toList();
  final unknownFlags = arguments.where((a) =>
      a.startsWith('-') && !{'--yes', '-y', '--no-build'}.contains(a));
  if (unknownFlags.isNotEmpty) {
    logError('Unknown option: ${unknownFlags.first}');
    printEnvUsage();
    exit(1);
  }

  await _checkDartVersion();

  final flavor = resolveFlavor(positional.isEmpty ? null : positional.first);

  copyFlavorFiles(flavor);

  if (skipBuild) {
    logInfo('Skipped build_runner (--no-build).');
    return;
  }

  logHint(
    'build_runner regenerates code that depends on your .env values and '
    'annotations (envied\'s .g.dart, injectable\'s DI registration, freezed/'
    'json_serializable models). Re-run it whenever those change, e.g. after '
    'switching flavor.',
  );
  final shouldRun = autoYes || await promptYesNoAutoYes('Run build_runner?');
  if (!shouldRun) {
    logInfo('Skipped build_runner execution.');
    return;
  }

  await runCodegenForFlavor(flavor);
}

/// Runs build_runner for [flavor], exiting the process on failure.
Future<void> runCodegenForFlavor(String flavor) async {
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

/// Deprecated alias of [mainEnv], kept so existing scripts, VS Code tasks and
/// CI jobs calling `pre_launch_task` keep working.
Future<void> mainPLT(List<String> arguments) async {
  logWarn(
    'Warning: "pre_launch_task" is deprecated — use '
    '"moshaf_boilerplate env <flavor>" instead. It still works for now.',
  );
  await mainEnv(arguments);
}

void printEnvUsage() {
  stdout.writeln('Usage: moshaf_boilerplate env [flavor] [options]\n');
  stdout.writeln(
      'Copies .env.<flavor> to .env (and GoogleService-Info-<flavor>.plist),');
  stdout.writeln('then optionally runs build_runner.\n');
  stdout.writeln('Without [flavor], pick one of the .env.* files found here.\n');
  stdout.writeln('Options:');
  stdout.writeln('  -y, --yes     Run build_runner without asking');
  stdout.writeln('      --no-build  Skip build_runner');
  stdout.writeln('  -h, --help    Show this help');
}

/// Resolves the flavor to use: the given one (validated against the
/// `.env.*` files that exist), or an interactive pick when none was given.
String resolveFlavor(String? requested) {
  final available = discoverFlavors();

  if (available.isEmpty) {
    logError(
      'No .env.<flavor> files found in ${Directory.current.path}. '
      'Run this from a generated project root.',
    );
    exit(1);
  }

  if (requested == null) {
    final picked = promptSelect('Select flavor:', available);
    if (picked == null) {
      logError('No flavor provided.');
      stdout.writeln('Available: ${available.join(', ')}');
      printEnvUsage();
      exit(1);
    }
    return picked;
  }

  if (!available.contains(requested)) {
    logError('Unknown flavor "$requested".');
    final hint = suggestClosest(requested, available);
    if (hint != null) logHint('Did you mean "$hint"?');
    stdout.writeln('Available: ${available.join(', ')}');
    exit(1);
  }
  return requested;
}

/// Copies `.env.<flavor>` → `.env` and, when present, the flavor's
/// GoogleService-Info plist. Exits the process if the env file is missing.
void copyFlavorFiles(String flavor) {
  _copyEnvFile('.env.$flavor');
  _copyGoogleServiceFile(flavor);
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
