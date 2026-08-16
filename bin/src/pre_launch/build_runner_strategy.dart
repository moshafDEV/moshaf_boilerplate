import 'dart:io';

import '../common/process_utils.dart';

/// Outcome of [runBuildRunner]: whether any strategy succeeded, and the
/// captured stdout+stderr of every attempted strategy. [output] is only
/// meant to be shown to the user when [success] is false — a successful run
/// should stay quiet instead of dumping pub/build_runner's verbose progress
/// into the CLI's own step-by-step log.
class BuildRunnerResult {
  final bool success;
  final String output;

  const BuildRunnerResult(this.success, this.output);
}

/// Runs `build_runner build --delete-conflicting-outputs`, trying FVM's
/// Flutter first, then plain Dart, then plain Flutter — the first tool that
/// exists and succeeds wins. Every command's output is captured rather than
/// streamed live; it's only surfaced (concatenated across every attempted
/// strategy) when all of them fail, so there's still something to debug.
///
/// [workingDirectory] scopes every command to a specific project folder
/// (defaults to the caller's own cwd when omitted).
Future<BuildRunnerResult> runBuildRunner({String? workingDirectory}) async {
  final attempts = <String>[];

  final fvm = await _tryFvmFlutter(workingDirectory);
  if (fvm.success) return fvm;
  attempts.add(fvm.output);

  final dart = await _tryDart(workingDirectory);
  if (dart.success) return dart;
  attempts.add(dart.output);

  final flutter = await _tryFlutter(workingDirectory);
  if (flutter.success) return flutter;
  attempts.add(flutter.output);

  return BuildRunnerResult(
    false,
    attempts.where((output) => output.isNotEmpty).join('\n---\n'),
  );
}

Future<BuildRunnerResult> _tryFvmFlutter(String? workingDirectory) async {
  if (!await commandExists('fvm')) return const BuildRunnerResult(false, '');
  return _runPipeline(
    'fvm',
    pubGetArgs: ['flutter', 'pub', 'get'],
    cleanArgs: ['flutter', 'pub', 'run', 'build_runner', 'clean'],
    buildArgs: [
      'flutter',
      'pub',
      'run',
      'build_runner',
      'build',
      '--delete-conflicting-outputs',
    ],
    workingDirectory: workingDirectory,
  );
}

Future<BuildRunnerResult> _tryDart(String? workingDirectory) async {
  if (!await commandExists('dart')) return const BuildRunnerResult(false, '');
  return _runPipeline(
    'dart',
    pubGetArgs: ['pub', 'get'],
    cleanArgs: ['run', 'build_runner', 'clean'],
    buildArgs: ['run', 'build_runner', 'build', '--delete-conflicting-outputs'],
    workingDirectory: workingDirectory,
  );
}

Future<BuildRunnerResult> _tryFlutter(String? workingDirectory) async {
  if (!await commandExists('flutter')) {
    return const BuildRunnerResult(false, '');
  }
  return _runPipeline(
    'flutter',
    pubGetArgs: ['pub', 'get'],
    cleanArgs: ['pub', 'run', 'build_runner', 'clean'],
    buildArgs: [
      'pub',
      'run',
      'build_runner',
      'build',
      '--delete-conflicting-outputs',
    ],
    workingDirectory: workingDirectory,
  );
}

/// Runs `pub get` → `build_runner clean` → `build_runner build` with [exe],
/// capturing every command's output into one log. `pub get` gates the
/// pipeline (no point cleaning/building against unresolved deps); `clean`'s
/// exit code is intentionally ignored (e.g. nothing to clean yet shouldn't
/// block the actual build); the final result's success mirrors the build
/// step's exit code.
Future<BuildRunnerResult> _runPipeline(
  String exe, {
  required List<String> pubGetArgs,
  required List<String> cleanArgs,
  required List<String> buildArgs,
  String? workingDirectory,
}) async {
  final log = StringBuffer();

  final pubGet = await _runCaptured(exe, pubGetArgs, log, workingDirectory);
  if (pubGet.exitCode != 0) return BuildRunnerResult(false, log.toString());

  await _runCaptured(exe, cleanArgs, log, workingDirectory);

  final build = await _runCaptured(exe, buildArgs, log, workingDirectory);
  return BuildRunnerResult(build.exitCode == 0, log.toString());
}

Future<ProcessResult> _runCaptured(
  String exe,
  List<String> args,
  StringBuffer log,
  String? workingDirectory,
) async {
  final result = await Process.run(
    exe,
    args,
    runInShell: true,
    workingDirectory: workingDirectory,
  );
  log.writeln('\$ $exe ${args.join(' ')}');
  if (result.stdout.toString().isNotEmpty) log.writeln(result.stdout);
  if (result.stderr.toString().isNotEmpty) log.writeln(result.stderr);
  return result;
}
