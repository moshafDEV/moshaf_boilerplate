import 'dart:io';

import '../build/flutter_build_runner.dart';
import '../flavor/flavor_runner.dart';
import '../pre_launch/pre_launch_runner.dart';

/// One-line summaries, in display order. `pre_launch_task` is intentionally
/// absent: it still works but is deprecated in favor of `env`.
const commandSummaries = <String, String>{
  'create': 'Generate a Flutter boilerplate project (requires Flutter)',
  'env': 'Switch .env/Firebase config to a flavor (pick from a list)',
  'build': 'Env + flutter build for a flavor (apk / aab / ipa, versioning)',
  'assets': 'Regenerate typed asset constants from assets/',
  'flavor': 'Add a flavor, list flavors, or generate flavor icons',
  'version': 'Show the generator version',
  'help': 'Show help, or help for one command',
};

const _details = <String, String>{
  'create': '''
Usage: moshaf_boilerplate create

Interactive generator: asks for a project name and display name, then builds
the project (Clean Architecture, BLoC samples, flavors, CI, dependencies).''',
  'assets': '''
Usage: moshaf_boilerplate assets

Scans assets/ and (re)writes lib/core/constants/assets.gen.dart plus
assets_gen/, exposing every file as a typed Assets.<folder>.<file> constant.
Runs once during "create"; re-run after adding or removing assets.''',
  'version': '''
Usage: moshaf_boilerplate version

Prints the boilerplate generator version.''',
};

void printHelp() {
  stdout.writeln('Usage: moshaf_boilerplate <command> [arguments]\n');
  stdout.writeln('Commands:');
  for (final e in commandSummaries.entries) {
    stdout.writeln('  ${e.key.padRight(10)} ${e.value}');
  }
  stdout.writeln('\nRun "moshaf_boilerplate help <command>" for details.\n');
  stdout.writeln('Examples:');
  stdout.writeln('  moshaf_boilerplate create');
  stdout.writeln('  moshaf_boilerplate env              # pick a flavor');
  stdout.writeln('  moshaf_boilerplate env prod --yes');
  stdout.writeln('  moshaf_boilerplate build apk staging');
  stdout.writeln('  moshaf_boilerplate flavor add staging');
  stdout.writeln('  moshaf_boilerplate assets');
  stdout.writeln('\nDeprecated: "pre_launch_task <flavor>" → use "env <flavor>".');
}

/// Prints help for [command]; returns false when it isn't a known command.
bool printCommandHelp(String command) {
  switch (command) {
    case 'env':
    case 'pre_launch_task':
      printEnvUsage();
      return true;
    case 'flavor':
      printFlavorUsage();
      return true;
    case 'build':
      printBuildUsage();
      return true;
  }
  final text = _details[command];
  if (text == null) return false;
  stdout.writeln(text.trim());
  return true;
}
