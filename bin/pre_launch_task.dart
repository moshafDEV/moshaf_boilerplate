import 'dart:async';
import 'dart:convert';
import 'dart:io';

const red = '\x1B[31m';
const yellow = '\x1B[33m';
const green = '\x1B[32m';
const reset = '\x1B[0m';

void logError(String message) => print('$red$message$reset');
void logWarn(String message) => print('$yellow$message$reset');
void logInfo(String message) => print('$green$message$reset');

Future<bool> _commandExists(String cmd) async {
  final which = Platform.isWindows ? 'where' : 'which';
  try {
    final r = await Process.run(which, [cmd]);
    return r.exitCode == 0;
  } catch (_) {
    return false;
  }
}

Future<int> _run(String exe, List<String> args) async {
  logInfo('> $exe ${args.join(' ')}');
  final p = await Process.start(exe, args, mode: ProcessStartMode.inheritStdio);
  return await p.exitCode;
}

Future<bool> _tryDart() async {
  final hasDart = await _commandExists('dart');
  if (!hasDart) return false;

  var code = await _run('dart', ['pub', 'get']);
  if (code != 0) {
    logWarn('`dart pub get` failed — trying flutter…');
    return false;
  }

  // clean can fail; continue to build
  await _run('dart', ['run', 'build_runner', 'clean']);
  code = await _run('dart', [
    'run',
    'build_runner',
    'build',
    '--delete-conflicting-outputs',
  ]);
  return code == 0;
}

Future<bool> _tryFlutter() async {
  final hasFlutter = await _commandExists('flutter');
  if (!hasFlutter) return false;

  var code = await _run('flutter', ['pub', 'get']);
  if (code != 0) return false;

  await _run('flutter', ['pub', 'run', 'build_runner', 'clean']);
  code = await _run('flutter', [
    'pub',
    'run',
    'build_runner',
    'build',
    '--delete-conflicting-outputs',
  ]);
  return code == 0;
}

Future<bool> _tryFvmFlutter() async {
  final hasFvm = await _commandExists('fvm');
  if (!hasFvm) return false;

  var code = await _run('fvm', ['flutter', 'pub', 'get']);
  if (code != 0) return false;

  await _run('fvm', ['flutter', 'pub', 'run', 'build_runner', 'clean']);
  code = await _run('fvm', [
    'flutter',
    'pub',
    'run',
    'build_runner',
    'build',
    '--delete-conflicting-outputs',
  ]);
  return code == 0;
}

Future<bool> promptYesNoAutoYes(String label, {int seconds = 5}) async {
  final completer = Completer<String>();
  final lineSub = stdin
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .listen((line) {
        if (!completer.isCompleted) completer.complete(line.trim());
      });

  var remaining = seconds;
  void render() {
    stdout.write('\r$label (y/n, auto "y" in $remaining s): ');
  }

  render();

  final timer = Timer.periodic(const Duration(seconds: 1), (t) {
    remaining--;
    if (remaining <= 0) {
      t.cancel();
      if (!completer.isCompleted) completer.complete('y'); // auto yes
    } else {
      render(); // update countdown
    }
  });

  // Jika tidak ada terminal (mis. CI), langsung auto-yes tanpa tunggu
  if (!stdin.hasTerminal && !completer.isCompleted) {
    timer.cancel();
    completer.complete('y');
  }

  final result = (await completer.future).toLowerCase();
  await lineSub.cancel();
  timer.cancel();
  stdout.writeln(); // pindah baris dari \r

  if (result == 'n' || result == 'no') return false;
  // kosong / 'y' / selain 'n' dianggap yes
  return true;
}

Future<String?> _getDartVersion() async {
  try {
    final result = await Process.run('dart', ['--version']);
    final output = result.stderr.toString() + result.stdout.toString();
    final match = RegExp(r'(\d+)\.(\d+)\.(\d+)').firstMatch(output);
    if (match != null) {
      return '${match.group(1)}.${match.group(2)}.${match.group(3)}';
    }
  } catch (_) {}
  return null;
}

bool _versionLessThan(String v1, String v2) {
  final a = v1.split('.').map(int.parse).toList();
  final b = v2.split('.').map(int.parse).toList();
  for (var i = 0; i < 3; i++) {
    if (a[i] < b[i]) return true;
    if (a[i] > b[i]) return false;
  }
  return false;
}

Future<String?> _getMinDartVersionFromPubspec() async {
  final pubspec = File('pubspec.yaml');
  if (!pubspec.existsSync()) return null;
  final lines = await pubspec.readAsLines();
  final sdkLine = lines.firstWhere(
    (l) => l.trim().startsWith('sdk:'),
    orElse: () => '',
  );
  final match = RegExp(r'sdk:\s*">=([0-9.]+)"').firstMatch(sdkLine);
  return match?.group(1);
}

Future<void> mainPLT(List<String> arguments) async {
  // Check Dart SDK version
  final minVersion = await _getMinDartVersionFromPubspec();
  final currentVersion = await _getDartVersion();
  if (minVersion != null && currentVersion != null) {
    if (_versionLessThan(currentVersion, minVersion)) {
      logError(
        'Current Dart SDK version ($currentVersion) is lower than the minimum required ($minVersion). '
        'Please switch to the correct SDK (e.g., using fvm).',
      );
      exit(1);
    }
  }

  if (arguments.isEmpty) {
    logError('No flavor argument provided.');
    exit(1);
  }

  final flavor = arguments[0];
  final envFileMap = {'dev': '.env.dev', 'prod': '.env.prod'};
  final envFile = envFileMap[flavor];

  if (envFile == null) {
    logError('Unknown flavor. Use "dev" or "prod".');
    exit(1);
  }

  // Copy .env according to flavor
  final cwd = Directory.current.path;
  final envSource = File('$cwd/$envFile');
  final envTarget = File('$cwd/.env');

  if (!envSource.existsSync()) {
    logError('File $envFile not found.');
    exit(1);
  }

  envSource.copySync(envTarget.path);
  print('Using $envFile');

  // Map GoogleService-Info.plist
  final googleServiceFileMap = {
    'dev': 'GoogleService-Info-dev.plist',
    'prod': 'GoogleService-Info-prod.plist',
  };
  final googleServiceFile = googleServiceFileMap[flavor];
  final googleServiceFilePath = '$cwd/ios/Runner/$googleServiceFile';

  if (googleServiceFile == null || !File(googleServiceFilePath).existsSync()) {
    logWarn('GoogleService-Info file not found for this flavor.');
  } else {
    final targetPath = '$cwd/ios/Runner/GoogleService-Info.plist';
    File(googleServiceFilePath).copySync(targetPath);
    print('Using $googleServiceFile for GoogleService-Info.plist');
  }

  final run = await promptYesNoAutoYes('Run build_runner?');
  if (!run) {
    logInfo('Skipped build_runner execution.');
    return;
  }

  // Execution order: dart → fvm flutter → flutter
  try {
    final okDart = await _tryDart();
    if (okDart) return;

    final okFvm = await _tryFvmFlutter();
    if (okFvm) return;

    final okFlutter = await _tryFlutter();
    if (okFlutter) return;

    logError(
      'All strategies failed. Please ensure SDK & dependencies are installed correctly.',
    );
    exit(1);
  } catch (e) {
    logError('Failed to run build_runner: $e');
    exit(1);
  }
}

void main(List<String> arguments) async => await mainPLT(arguments);