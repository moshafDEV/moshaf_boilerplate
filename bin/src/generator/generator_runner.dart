import 'dart:io';

import '../assets/assets_runner.dart';
import '../common/console.dart';
import '../common/file_ops.dart';
import '../common/package_locator.dart';
import '../common/process_utils.dart';
import '../common/version_utils.dart';
import '../pre_launch/build_runner_strategy.dart';
import 'android_compile_sdk.dart';
import 'constants.dart';
import 'dependency_installer.dart';
import 'flavorizr_runner.dart';
import 'ios_deployment_target.dart';
import 'macos_entitlements.dart';

Future<void> printGeneratorVersion() async {
  final version = await getPubspecVersion();
  stdout.writeln('🚀 MOSHAF Boilerplate Generator');
  stdout.writeln('Version: $version');
}

void printHelp() {
  stdout.writeln('Usage: moshaf_boilerplate <command> [arguments]\n');
  stdout.writeln('Commands:');
  stdout.writeln(
      '  create                     Generate Flutter boilerplate (requires Flutter)');
  stdout.writeln(
      '  pre_launch_task <flavor>   Prepare environment before running the app');
  stdout.writeln(
      '  assets                     Regenerate lib/core/constants/assets.gen.dart from assets/');
  stdout.writeln(
      '  flavor add <name>          Scaffold a new build flavor (e.g. staging, qa)');
  stdout.writeln(
      '  flavor icons               Generate ribboned dev/staging app icons');
  stdout.writeln(
      '  version                    Show the boilerplate generator version');
  stdout.writeln('  help                       Show this help message\n');
  stdout.writeln('pre_launch_task:');
  stdout.writeln(
      '  Copies the correct .env and GoogleService-Info.plist for the given flavor,');
  stdout.writeln('  then optionally runs build_runner (auto-yes after 5 s).\n');
  stdout.writeln(
      '  Works for any flavor name, e.g. "dev" copies .env.dev → .env and');
  stdout.writeln(
      '  GoogleService-Info-dev.plist (same for "prod", or any flavor added via');
  stdout.writeln('  "flavor add").\n');
  stdout.writeln('  Execution strategy (first success wins):');
  stdout.writeln('    fvm flutter pub run build_runner build');
  stdout.writeln('    dart run build_runner build');
  stdout.writeln('    flutter pub run build_runner build\n');
  stdout.writeln(
      '  VSCode: configured automatically via .vscode/tasks.json in generated projects.\n');
  stdout.writeln('assets:');
  stdout.writeln(
      '  Scans the assets/ folder and (re)writes lib/core/constants/assets.gen.dart,');
  stdout.writeln(
      '  exposing every file as a typed Assets.<folder>.<file> String constant.');
  stdout.writeln(
      '  Runs automatically once during "create"; re-run it anytime after adding');
  stdout.writeln('  or removing files under assets/.\n');
  stdout.writeln('flavor add <name>:');
  stdout.writeln(
      '  Registers a new flavor in the Flavor enum, scaffolds lib/main_<name>.dart,');
  stdout.writeln(
      '  appends a block to flavorizr.yaml, creates a starter .env.<name>, and adds');
  stdout.writeln(
      '  a matching VS Code task. Does NOT run flutter_flavorizr for you — native');
  stdout.writeln(
      '  Android/iOS wiring stays a deliberate, reviewable step (prints the exact');
  stdout.writeln('  next commands to run).\n');
  stdout.writeln('flavor icons:');
  stdout.writeln(
      '  Draws a "DEV"/"STAGING" ribbon across flutter_launcher_icons.yaml\'s base');
  stdout.writeln(
      '  icon and writes flutter_launcher_icons-dev.yaml / -staging.yaml pointing at');
  stdout.writeln(
      '  the result — flutter_launcher_icons picks those up on its own next run.');
  stdout.writeln(
      '  prod gets its own unribboned copy of the config (same convention as the');
  stdout.writeln('  in-app flavor banner — no ribbon there either).\n');
  stdout.writeln('Examples:');
  stdout.writeln('  moshaf_boilerplate create');
  stdout.writeln('  moshaf_boilerplate pre_launch_task dev');
  stdout.writeln('  moshaf_boilerplate pre_launch_task prod');
  stdout.writeln('  moshaf_boilerplate assets');
  stdout.writeln('  moshaf_boilerplate flavor add staging');
  stdout.writeln('  moshaf_boilerplate flavor icons');
  stdout.writeln('  moshaf_boilerplate version');
}

Future<void> runGenerator() async {
  final version = await getPubspecVersion();
  logInfo('----------------------------------------------------------------');
  logInfo('Welcome to the MOSHAF Flutter Boilerplate Generator! v$version');
  logInfo('----------------------------------------------------------------');
  stdout.writeln('This tool will help you set up a Flutter project with:');
  stdout.writeln('- Clean Architecture structure');
  stdout.writeln('- Sample BLoC code for state management');
  stdout.writeln('- Pre-configured dependencies for scalable development');
  stdout.writeln('- Automated file and folder setup');
  stdout.writeln('- Best practices for maintainable code');
  stdout.writeln("Let's get started!");
  stdout.writeln('Powered by MOSHAF');
  stdout.writeln('');

  if (!await _checkFlutterVersion()) return;

  final projectName = _promptProjectName();
  if (projectName == null) return;

  if (!_confirmSafeToGenerateInto(projectName)) return;

  // Separate from projectName on purpose: that one is constrained to a
  // valid Dart package identifier (lowercase snake_case), which makes a
  // poor human-facing app name/title. Optional — left blank, it falls
  // back to a title-cased version of projectName.
  final appDisplayName = _promptAppDisplayName(projectName);

  logInfo(
      'Initializing the setup for your Flutter project: "$projectName". Please hold on...');
  stdout.writeln('');

  // Everything below lives inside this one folder, start to finish — never
  // touches anything else in the current directory. A failure at any point
  // is always safe to recover from the same way: remove "./<projectName>"
  // and try again.
  final projectDir = './$projectName';

  // Dependencies are intentionally left unpinned so every generated project
  // picks up the latest compatible versions. That means a version conflict
  // can surface at any time as the Flutter/Dart SDK evolves — when it does,
  // we still want the run to finish (the packages that resolve fine keep
  // going in) and simply warn about the ones that didn't, instead of
  // aborting the whole generation over it. See dependencyFailures below.
  final dependencyFailures = <DependencyFailure>[];

  try {
    final source = await getSourceDir('moshaf_boilerplate');

    await runStep('Creating Flutter project for project: $projectName',
        () async {
      await executeCommand('flutter create $projectName');
      await raiseIosDeploymentTarget(projectDir);
      await addMacosKeychainEntitlement(projectDir, projectName);
      await raiseAndroidCompileSdk(projectDir);
    });

    await runStep('Merging template into project for project: $projectName',
        () async {
      final generatedPubspec = File('$projectDir/pubspec.yaml');
      // Read before the template's own pubspec.yaml overwrites this one.
      final overrides = await extractPubspecVersionOverrides(generatedPubspec);

      await copyFolder(source.path, projectDir);
      await modifyFilesInFolder(projectDir, 'ProjectName', projectName);
      await modifyFilesInFolder(projectDir, 'ProjectDisplayName', appDisplayName);

      if (overrides != null) {
        await applyPubspecVersionOverrides(generatedPubspec, overrides);
      }
    });
  } catch (e) {
    stdout.writeln('');
    logError('Generation aborted: $e');
    logHint(
        'Partially generated files may remain in "$projectDir" — remove it before retrying.');
    return;
  }

  // Its own soft-fail block (not the hard-abort one above/below) since the
  // project is already fully scaffolded at this point — a failure here just
  // means assets.gen.dart is missing/stale, not that generation as a whole
  // needs to be aborted and retried from scratch.
  try {
    await runStep('Generating asset constants for project: $projectName',
        () => generateAssetsFile(projectDir));
  } catch (e) {
    stdout.writeln('');
    logWarn('Asset constants generation failed: $e');
    logHint(
      'Your project is ready in "$projectDir" — once fixed, run '
      '"moshaf_boilerplate assets" manually from inside it.',
    );
  }

  try {
    await runStep('Installing dependencies for project: $projectName',
        () async {
      dependencyFailures.addAll(
        await installDependencies(
          generatorDependencies,
          isDev: false,
          workingDirectory: projectDir,
        ),
      );
    });

    // Flutter's Swift Package Manager plugin-symlink generation isn't
    // idempotent across repeated `flutter pub get`s in the same project —
    // without this, the dev-dependency install below crashes with
    // "PathExistsException: ... File exists" on whichever plugin symlink
    // the step above just created. See _resetSpmEphemeralPackages.
    await _resetSpmEphemeralPackages(projectDir);

    await runStep('Installing dev dependencies for project: $projectName',
        () async {
      dependencyFailures.addAll(
        await installDependencies(
          generatorDevDependencies,
          isDev: true,
          workingDirectory: projectDir,
        ),
      );
    });
  } catch (e) {
    stdout.writeln('');
    logError('Generation aborted: $e');
    logHint(
        'Partially generated files may remain in "$projectDir" — remove it before retrying.');
    return;
  }

  // Surfaced here, before the flavor-configuration attempt below, since a
  // dependency that failed to install (most commonly flutter_flavorizr
  // itself) is the actual root cause when that step then fails with a
  // confusing "Could not find package" error from `dart run`.
  if (dependencyFailures.isNotEmpty) {
    _warnAboutDependencyFailures(dependencyFailures);
  }

  // A flavorizr/build_runner failure here doesn't mean the project is
  // broken — every other step already succeeded — so each gets its own
  // try/catch with advice to fix and retry that one step, instead of the
  // generic "remove and start over" abort message above.
  final flavorizrDepFailed =
      dependencyFailures.any((f) => f.package == 'flutter_flavorizr');
  if (flavorizrDepFailed) {
    logWarn(
        'Skipping flavor configuration: flutter_flavorizr failed to install (see warning above).');
    logHint(
        'Fix that dependency, then run "dart run flutter_flavorizr -f" manually from inside "$projectDir".');
  } else {
    try {
      await runStep('Applying flavor configuration for project: $projectName',
          () async {
        await runFlavorizr(workingDirectory: projectDir);
        // Re-asserted in case flavorizr's newly duplicated Debug-dev/
        // Release-dev/etc. configs didn't fully inherit 15.0 from the base
        // configs raised in the first step, above.
        await raiseIosDeploymentTarget(projectDir);
      });
    } catch (e) {
      stdout.writeln('');
      logWarn('Flavor configuration failed: $e');
      logHint(
        'Your project is ready in "$projectDir" — once the issue is fixed, run '
        '"dart run flutter_flavorizr -f" manually from inside it.',
      );
    }
  }

  var buildRunnerLog = '';
  try {
    await runStep('Generating code (build_runner) for project: $projectName',
        () async {
      final result = await runBuildRunner(workingDirectory: projectDir);
      buildRunnerLog = result.output;
      if (!result.success) {
        throw 'all build_runner strategies (fvm flutter / dart / flutter) failed';
      }
    });
  } catch (e) {
    stdout.writeln('');
    logWarn('build_runner failed: $e');
    if (buildRunnerLog.trim().isNotEmpty) {
      stdout.writeln('');
      logHint('--- build_runner output (for debugging) ---');
      stdout.writeln(buildRunnerLog.trim());
    }
    logHint(
      'Your project is ready in "$projectDir" — once the SDK/toolchain issue is fixed, run '
      '"flutter pub run build_runner build --delete-conflicting-outputs" manually from inside it.',
    );
    return;
  }

  stdout.writeln('');
  logInfo('Your Flutter project is now ready in "$projectDir"!');
  if (dependencyFailures.isNotEmpty) {
    logWarn(
        'Remember to fix the dependency warnings above before your first run.');
  }
  logInfo('Thank you for using MOSHAF Boilerplate Generator.');
  logInfo('💻 Happy coding and good luck with your project! 🚀');
}

/// Prints a consolidated, easy-to-spot warning for every dependency that
/// `flutter pub add` could not resolve, so the user notices it right away
/// instead of only discovering it as a confusing build error on first run.
void _warnAboutDependencyFailures(List<DependencyFailure> failures) {
  stdout.writeln('');
  logWarn(
      '⚠ ${failures.length} dependenc${failures.length == 1 ? 'y' : 'ies'} could not be added automatically:');
  for (final failure in failures) {
    logWarn('  - ${failure.package}: ${failure.reason}');
  }
  logHint(
    'These were skipped so the rest of the project could still be generated. Add them manually to '
    'pubspec.yaml (check for a version conflict with your Flutter/Dart SDK), then run "flutter pub get".',
  );
}

/// Verifies the Flutter toolchain is reachable and at least [minFlutterVersion].
/// Returns false (after printing why) when generation cannot proceed.
Future<bool> _checkFlutterVersion() async {
  ProcessResult result;
  try {
    result =
        await Process.run('fvm', ['flutter', '--version'], runInShell: true);
    if (result.exitCode != 0) {
      result = await Process.run('flutter', ['--version'], runInShell: true);
    }
  } catch (e) {
    logError(
        'Failed to run "flutter --version". Make sure Flutter or FVM is installed and in your PATH.');
    return false;
  }

  if (result.exitCode != 0) {
    logError(
        'Failed to run "flutter --version". Make sure Flutter or FVM is installed and in your PATH.');
    return false;
  }

  final flutterVersion = parseFlutterVersion(result.stdout);
  if (flutterVersion == null) {
    logError('Could not detect Flutter version.');
    return false;
  }

  if (versionLessThan(flutterVersion, minFlutterVersion)) {
    logWarn('Flutter version detected: $flutterVersion');
    logError(
        'Warning: recommended Flutter version is $minFlutterVersion or higher, but detected $flutterVersion.');
    logError(
        'Please use Flutter $minFlutterVersion or newer for best compatibility with this boilerplate.');
  } else {
    logHint('Flutter version detected: $flutterVersion');
  }
  return true;
}

/// Deletes ios/Flutter/ephemeral/Packages/ if it exists, so the next
/// `flutter pub add` (and its implicit `pub get`) regenerates Swift Package
/// Manager's plugin symlinks from scratch instead of colliding with ones a
/// previous `pub get` in this same run already created. Safe on any Flutter
/// version/config: the whole ephemeral/ folder is always fully disposable
/// (Flutter regenerates it on the next pub get/build regardless), and this
/// only touches it when it exists — i.e. only when SPM actually created it.
Future<void> _resetSpmEphemeralPackages(String projectDir) async {
  final dir = Directory('$projectDir/ios/Flutter/ephemeral/Packages');
  if (await dir.exists()) {
    await dir.delete(recursive: true);
  }
}

/// Prompts for a project name and validates it against the lowercase
/// `snake_case` format Flutter/Dart package names require.
String? _promptProjectName() {
  stdout.write(
      'Please enter the Flutter project name (e.g. moshaf_app or moshafapp): ');
  final projectName = stdin.readLineSync();

  if (projectName == null || projectName.trim().isEmpty) {
    logError('Error: project name cannot be empty.');
    return null;
  }

  if (!RegExp(r'^[a-z0-9_]+$').hasMatch(projectName)) {
    logError('Error: invalid project name "$projectName".');
    stdout.writeln(
        'The name should consist of lowercase letters, numbers, and underscores only.');
    logWarn('Example of a valid name: moshaf_app or moshafapp');
    stdout.writeln('');
    return null;
  }

  return projectName;
}

/// Prompts for a human-facing app name/title — no format constraints
/// (unlike the project name), since it never has to be a valid identifier.
/// Left blank, falls back to a title-cased version of [projectName].
String _promptAppDisplayName(String projectName) {
  final fallback = _titleCaseFromSnakeCase(projectName);
  stdout.write(
      'Please enter the app display name (press Enter to use "$fallback"): ');
  final input = stdin.readLineSync();

  if (input == null || input.trim().isEmpty) {
    return fallback;
  }
  return input.trim();
}

String _titleCaseFromSnakeCase(String name) {
  return name
      .split('_')
      .where((word) => word.isNotEmpty)
      .map((word) => word[0].toUpperCase() + word.substring(1))
      .join(' ');
}

/// Guards the one way `create` can clobber existing work now that
/// generation stays inside "./<projectName>" the whole time: that folder
/// already existing (it would get merged into and dependency-installed
/// over, potentially mixing with whatever was already there).
bool _confirmSafeToGenerateInto(String projectName) {
  if (Directory('./$projectName').existsSync()) {
    logError('Error: a folder named "$projectName" already exists here.');
    logHint('Remove it or choose another project name, then try again.');
    return false;
  }

  return true;
}
