import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../common/console.dart';
import 'flavor_icon_runner.dart';

final _nameRegExp = RegExp(r'^[a-z][a-z0-9]*$');

/// Adds a new build flavor to an already-generated project (run with cwd
/// inside that project, same convention as `assets`/`pre_launch_task`):
/// registers it in the `Flavor` enum, scaffolds `main_<name>.dart`, appends
/// a block to `flavorizr.yaml`, creates a starter `.env.<name>`, and adds a
/// matching VS Code task. Native Android/iOS wiring itself is NOT run here —
/// see the printed next steps.
Future<void> mainFlavor(List<String> arguments) async {
  if (arguments.isNotEmpty && arguments[0] == 'icons') {
    return mainFlavorIcons(arguments.sublist(1));
  }

  if (arguments.isEmpty || arguments[0] != 'add' || arguments.length < 2) {
    logError(
      'Usage: moshaf_boilerplate flavor add <name>\n'
      '       moshaf_boilerplate flavor icons',
    );
    exit(1);
  }

  final name = arguments[1].toLowerCase();
  if (!_nameRegExp.hasMatch(name)) {
    logError(
      'Flavor name must be lowercase letters/digits, starting with a letter '
      '(e.g. "staging", "qa").',
    );
    exit(1);
  }
  if (name == 'dev' || name == 'prod') {
    logError('Flavor "$name" already exists.');
    exit(1);
  }

  final projectDir = Directory.current.path;

  try {
    await runStep(
      'Adding flavor "$name"',
      () => _addFlavor(projectDir, name),
    );
  } catch (e) {
    logError('Failed to add flavor "$name": $e');
    exit(1);
  }

  _printNextSteps(name);
}

Future<void> _addFlavor(String projectDir, String name) async {
  final packageName = await _readPackageName(projectDir);
  await _patchFlavorEnum(projectDir, name);
  await _writeMainEntrypoint(projectDir, name, packageName);
  await _patchFlavorizr(projectDir, name);
  await _writeEnvFile(projectDir, name);
  await _addVsCodeTask(projectDir, name);
  await _addLaunchJsonConfigs(projectDir, name);
}

Future<String> _readPackageName(String projectDir) async {
  final file = File(p.join(projectDir, 'pubspec.yaml'));
  final content = await file.readAsString();
  final match = RegExp(r'^name:\s*(\S+)', multiLine: true).firstMatch(content);
  if (match == null) {
    throw StateError('Could not read "name:" from pubspec.yaml.');
  }
  return match.group(1)!;
}

Future<void> _patchFlavorEnum(String projectDir, String name) async {
  final file = File(p.join(projectDir, 'lib/core/config/app_config.dart'));
  final content = await file.readAsString();

  final enumStart = content.indexOf('enum Flavor {');
  if (enumStart == -1) {
    throw StateError('Could not find "enum Flavor {" in app_config.dart.');
  }
  final semiIndex = content.indexOf(';', enumStart);
  if (semiIndex == -1) {
    throw StateError('Could not find the end of the Flavor enum entries.');
  }

  final entriesBlock = content.substring(enumStart, semiIndex);
  if (RegExp('\\b$name\\(').hasMatch(entriesBlock)) {
    logWarn('Flavor "$name" already in Flavor enum — skipping.');
    return;
  }
  final nextLevel = RegExp(r'\w+\(\d+\)').allMatches(entriesBlock).length;

  final newContent = content.replaceRange(
    semiIndex,
    semiIndex,
    ',\n  $name($nextLevel)',
  );
  await file.writeAsString(newContent);
}

Future<void> _writeMainEntrypoint(
  String projectDir,
  String name,
  String packageName,
) async {
  final file = File(p.join(projectDir, 'lib/main_$name.dart'));
  if (await file.exists()) {
    logWarn('lib/main_$name.dart already exists — leaving it untouched.');
    return;
  }

  final upper = name.toUpperCase();
  await file.writeAsString('''
import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:$packageName/core/config/app_config.dart';
import 'package:$packageName/core/utils/error_reporter.dart';
import 'package:$packageName/main.dart';

void main() {
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      ErrorReporter.install();
      FlavorConfig(
        name: "$upper",
        color: Colors.orange,
        location: BannerLocation.bottomEnd,
        variables: {"mode": Flavor.$name},
      );
      await mainCommon(flavor: Flavor.$name);
    },
    (error, stack) {
      log(
        'Error in mainCommon: \$error',
        name: 'MainCommon',
        error: error,
        stackTrace: stack,
      );
      ErrorReporter.recordZoneError(error, stack);
    },
  );
}
''');
}

Future<void> _patchFlavorizr(String projectDir, String name) async {
  final file = File(p.join(projectDir, 'flavorizr.yaml'));
  final content = await file.readAsString();

  if (RegExp('^\\s{2}$name:', multiLine: true).hasMatch(content)) {
    logWarn('Flavor "$name" already in flavorizr.yaml — skipping.');
    return;
  }

  final appNameMatch =
      RegExp(r'prod:\s*\n\s*app:\s*\n\s*name:\s*"([^"]+)"').firstMatch(content);
  final appName = appNameMatch?.group(1) ?? name;

  final basePackageMatch =
      RegExp(r'prod:[\s\S]*?applicationId:\s*"([^"]+)"').firstMatch(content);
  final basePackage = basePackageMatch?.group(1);
  if (basePackage == null) {
    throw StateError(
      'Could not find the "prod" applicationId in flavorizr.yaml to derive '
      'the new flavor\'s package name from.',
    );
  }

  final title = name[0].toUpperCase() + name.substring(1);
  final block = '''
  $name:
    app:
      name: "$appName $title"
    android:
      applicationId: "$basePackage.$name"
      # Drop your $name google-services.json in android/app/src/$name/ and
      # uncomment the line below to have flavorizr wire it in for you on
      # the next `dart run flutter_flavorizr -f`.
      # firebase:
      #   config: "android/app/src/$name/google-services.json"
    ios:
      bundleId: "$basePackage.$name"
      # Drop your $name GoogleService-Info.plist somewhere in the repo and
      # point to it here, then re-run flavorizr the same way as above.
      # firebase:
      #   config: "ios/config/$name/GoogleService-Info.plist"

''';

  final anchor = '# Deliberately excludes';
  final anchorIndex = content.indexOf(anchor);
  final insertAt =
      anchorIndex != -1 ? anchorIndex : content.indexOf('instructions:');
  if (insertAt == -1) {
    throw StateError('Could not find where to insert the new flavor block.');
  }

  final newContent =
      content.substring(0, insertAt) + block + content.substring(insertAt);
  await file.writeAsString(newContent);
}

Future<void> _writeEnvFile(String projectDir, String name) async {
  final envFile = File(p.join(projectDir, '.env.$name'));
  if (await envFile.exists()) {
    logWarn('.env.$name already exists — leaving it untouched.');
    return;
  }

  final envDartFile = File(p.join(projectDir, 'lib/core/env/env.dart'));
  final varNames = <String>[];
  if (await envDartFile.exists()) {
    final envDartContent = await envDartFile.readAsString();
    varNames.addAll(
      RegExp(r"varName:\s*'([^']+)'")
          .allMatches(envDartContent)
          .map((m) => m.group(1)!),
    );
  }
  if (varNames.isEmpty) {
    varNames.addAll(['APP_NAME', 'API_URL', 'ENABLE_FIREBASE']);
  }

  await envFile.writeAsString('${varNames.map((v) => '$v=').join('\n')}\n');
}

Future<void> _addVsCodeTask(String projectDir, String name) async {
  final file = File(p.join(projectDir, '.vscode/tasks.json'));
  if (!await file.exists()) {
    logWarn('.vscode/tasks.json not found — skipping VS Code task entry.');
    return;
  }

  final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
  final tasks = (json['tasks'] as List).cast<Map<String, dynamic>>();

  final title = name[0].toUpperCase() + name.substring(1);
  final label = 'Set Env for $title';
  if (tasks.any((t) => t['label'] == label)) {
    logWarn('VS Code task "$label" already exists — skipping.');
    return;
  }

  tasks.add({
    'label': label,
    'type': 'shell',
    'command': 'moshaf_boilerplate',
    'args': ['pre_launch_task', name],
    'group': {'kind': 'build', 'isDefault': false},
  });
  json['tasks'] = tasks;

  const encoder = JsonEncoder.withIndent('  ');
  await file.writeAsString('${encoder.convert(json)}\n');
}

/// Adds Debug/Profile/Release launch configs for [name], matching the
/// dev/prod entries `flutter create`-based projects ship with.
Future<void> _addLaunchJsonConfigs(String projectDir, String name) async {
  final file = File(p.join(projectDir, '.vscode/launch.json'));
  if (!await file.exists()) {
    logWarn('.vscode/launch.json not found — skipping launch config entries.');
    return;
  }

  final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
  final configurations =
      (json['configurations'] as List).cast<Map<String, dynamic>>();

  final title = name[0].toUpperCase() + name.substring(1);
  final projectLabel = _projectLabelFrom(configurations) ?? 'App';

  for (final mode in ['Debug', 'Profile', 'Release']) {
    final configName = '$projectLabel $mode: Run $title Flavor';
    if (configurations.any((c) => c['name'] == configName)) continue;

    configurations.add({
      'name': configName,
      'request': 'launch',
      'type': 'dart',
      'flutterMode': mode.toLowerCase(),
      'program': 'lib/main_$name.dart',
      'args': ['--flavor', name],
      'preLaunchTask': 'Set Env for $title',
    });
  }
  json['configurations'] = configurations;

  const encoder = JsonEncoder.withIndent('  ');
  await file.writeAsString('${encoder.convert(json)}\n');
}

/// Existing configs are named "<ProjectLabel> <Mode>: Run <Flavor> Flavor" —
/// reuse whatever prefix is already there instead of hardcoding one.
String? _projectLabelFrom(List<Map<String, dynamic>> configurations) {
  for (final c in configurations) {
    final name = c['name'] as String?;
    if (name == null) continue;
    final match = RegExp(r'^(.*) (Debug|Profile|Release): Run ').firstMatch(name);
    if (match != null) return match.group(1);
  }
  return null;
}

void _printNextSteps(String name) {
  stdout.writeln('');
  logInfo('Flavor "$name" added. Next steps:');
  logHint('  1. Fill in .env.$name.');
  logHint(
    '  2. Review the new "$name" block in flavorizr.yaml — set the real '
    'applicationId/bundleId if the generated one is a placeholder.',
  );
  logHint('  3. Run: dart run flutter_flavorizr -f');
  logHint(
    '     Regenerates native Android/iOS config for ALL flavors — review '
    'the diff before committing (not run automatically, see flavorizr.yaml).',
  );
  logHint(
    '  4. Optional Firebase: drop android/app/src/$name/google-services.json '
    'and a GoogleService-Info-$name.plist, then uncomment the firebase: '
    'block for "$name" in flavorizr.yaml before step 3.',
  );
  logHint('  5. Run: moshaf_boilerplate pre_launch_task $name');
  logHint('  6. Run: flutter run --flavor $name -t lib/main_$name.dart');
  logHint(
    '  CI (Jenkinsfile / ci/config.groovy) is NOT updated automatically — '
    'wire "$name" in manually if it should build in CI.',
  );
}
