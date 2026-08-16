import 'dart:io';

import 'src/assets/assets_runner.dart';
import 'src/generator/generator_runner.dart';
import 'src/pre_launch/pre_launch_runner.dart';

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    printHelp();
    exit(0);
  }

  final command = args.first.toLowerCase();

  switch (command) {
    case 'create':
      await runGenerator();
      break;

    case 'pre_launch_task':
      await mainPLT(args.sublist(1));
      break;

    case 'assets':
      await mainAssets(args.sublist(1));
      break;

    case 'version':
    case '--version':
    case '-v':
      await printGeneratorVersion();
      break;

    case 'help':
    case '--help':
    case '-h':
    default:
      printHelp();
      break;
  }
}
