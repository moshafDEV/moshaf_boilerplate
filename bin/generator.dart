import 'dart:io';

import 'src/assets/assets_runner.dart';
import 'src/build/flutter_build_runner.dart';
import 'src/common/console.dart';
import 'src/common/help.dart';
import 'src/common/prompt.dart';
import 'src/flavor/flavor_runner.dart';
import 'src/generator/generator_runner.dart';
import 'src/pre_launch/pre_launch_runner.dart';

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    printHelp();
    exit(0);
  }

  final command = args.first.toLowerCase();
  final rest = args.sublist(1);

  // `moshaf_boilerplate <command> --help` for any command.
  if (command != 'help' &&
      (rest.takeWhile((a) => a != '--').contains('--help') ||
          rest.takeWhile((a) => a != '--').contains('-h')) &&
      printCommandHelp(command)) {
    return;
  }

  switch (command) {
    case 'create':
      await runGenerator();
      break;

    case 'env':
      await mainEnv(rest);
      break;

    case 'build':
      await mainBuild(rest);
      break;

    // Deprecated alias of `env`; prints a warning, then behaves the same.
    case 'pre_launch_task':
      await mainPLT(rest);
      break;

    case 'assets':
      await mainAssets(rest);
      break;

    case 'flavor':
      await mainFlavor(rest);
      break;

    case 'version':
    case '--version':
    case '-v':
      await printGeneratorVersion();
      break;

    case 'help':
    case '--help':
    case '-h':
      if (rest.isEmpty) {
        printHelp();
      } else if (!printCommandHelp(rest.first.toLowerCase())) {
        logError('Unknown command "${rest.first}".');
        exit(1);
      }
      break;

    default:
      logError('Unknown command "${args.first}".');
      final hint = suggestClosest(command, commandSummaries.keys);
      if (hint != null) logHint('Did you mean "$hint"?');
      stdout.writeln('');
      printHelp();
      exit(1);
  }
}
