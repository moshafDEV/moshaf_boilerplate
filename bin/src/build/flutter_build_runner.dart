import 'dart:io';

import '../common/console.dart';
import '../common/process_utils.dart';
import '../common/prompt.dart';
import '../pre_launch/pre_launch_runner.dart';

const _targets = {'apk': 'apk', 'aab': 'appbundle', 'ipa': 'ipa'};

void printBuildUsage() {
  stdout.writeln('Usage: moshaf_boilerplate build [apk|aab|ipa] [flavor] [options]\n');
  stdout.writeln(
      'Switches to the flavor (env step: .env + Firebase files + build_runner),');
  stdout.writeln(
      'then runs "flutter build <target> --flavor <flavor> -t lib/main_<flavor>.dart".');
  stdout.writeln(
      'Missing target/flavor are picked interactively (plus version and, for ipa,');
  stdout.writeln('export method).\n');
  stdout.writeln('Options:');
  stdout.writeln('      --debug | --profile   Build mode (default: release)');
  stdout.writeln('      --split-per-abi       apk only: one APK per ABI');
  stdout.writeln('      --build-name <x.y.z>  Version name for this build');
  stdout.writeln('      --build-number <n>    Build number for this build');
  stdout.writeln(
      '      --bump <kind>         major | minor | patch | build — raise the pubspec');
  stdout.writeln(
      '                            version (build number +1) and save it after success');
  stdout.writeln(
      '      --save                Write --build-name/--build-number to pubspec.yaml');
  stdout.writeln('                            after a successful build');
  stdout.writeln(
      '      --export-method <m>   ipa only: app-store (default) | ad-hoc | development |');
  stdout.writeln('                            enterprise');
  stdout.writeln(
      '      --no-codesign         ipa only: archive without signing');
  stdout.writeln(
      '      --obfuscate           Obfuscate Dart code (symbols → build/symbols/<flavor>)');
  stdout.writeln('      --no-codegen          Skip build_runner in the env step');
  stdout.writeln('      --no-env              Skip the env step entirely');
  stdout.writeln('      --dry-run             Print the commands without running them');
  stdout.writeln('  -h, --help                Show this help');
  stdout.writeln('  -- <args>                 Pass everything after -- to flutter\n');
  stdout.writeln(
      'Without --save/--bump, --build-name/--build-number only affect that build;');
  stdout.writeln('pubspec.yaml is left untouched.\n');
  stdout.writeln('Examples:');
  stdout.writeln('  moshaf_boilerplate build');
  stdout.writeln('  moshaf_boilerplate build apk staging');
  stdout.writeln('  moshaf_boilerplate build ipa prod --bump patch');
  stdout.writeln(
      '  moshaf_boilerplate build ipa staging --export-method ad-hoc');
  stdout.writeln(
      '  moshaf_boilerplate build aab prod --build-name 1.4.0 --build-number 42 --save');
}

class _Args {
  final List<String> positional = [];
  final List<String> passthrough = [];
  final Set<String> flags = {};
  final Map<String, String> values = {};
}

/// Splits [args] into positionals, boolean flags, `--key value` options
/// (for [valueOptions]) and everything after a bare `--`. Exits on unknown
/// options so typos don't silently change what gets built.
_Args _parse(
  List<String> args, {
  required Set<String> boolFlags,
  Set<String> valueOptions = const {},
  required void Function() usage,
}) {
  final parsed = _Args();
  for (var i = 0; i < args.length; i++) {
    final a = args[i];
    if (a == '--') {
      parsed.passthrough.addAll(args.skip(i + 1));
      break;
    }
    if (boolFlags.contains(a)) {
      parsed.flags.add(a);
    } else if (valueOptions.contains(a)) {
      if (i + 1 >= args.length) {
        logError('Option $a needs a value.');
        exit(1);
      }
      parsed.values[a] = args[++i];
    } else if (a.startsWith('-')) {
      logError('Unknown option: $a');
      usage();
      exit(1);
    } else {
      parsed.positional.add(a);
    }
  }
  return parsed;
}

/// FVM first (same order as the rest of the CLI), but only if `fvm flutter`
/// actually works for this project — otherwise plain `flutter`.
Future<List<String>> _flutterCommand() async {
  if (await commandExists('fvm')) {
    final probe = await Process.run(
      'fvm',
      ['flutter', '--version'],
      runInShell: true,
    );
    if (probe.exitCode == 0) return ['fvm', 'flutter'];
    logWarn('fvm found but "fvm flutter" failed — falling back to flutter.');
  }
  if (await commandExists('flutter')) return ['flutter'];
  logError('Neither "fvm" nor "flutter" found on PATH.');
  exit(1);
}

Future<int> _stream(List<String> command, {required bool dryRun}) async {
  logHint('\$ ${command.join(' ')}');
  if (dryRun) return 0;
  final process = await Process.start(
    command.first,
    command.skip(1).toList(),
    mode: ProcessStartMode.inheritStdio,
    runInShell: true,
  );
  return process.exitCode;
}

Future<void> _prepare(
  String flavor, {
  required bool skipEnv,
  required bool skipCodegen,
  required bool dryRun,
}) async {
  if (skipEnv) return;
  if (dryRun) {
    logHint('(dry run) env: .env.$flavor → .env'
        '${skipCodegen ? '' : ', then build_runner'}');
    return;
  }
  copyFlavorFiles(flavor);
  if (!skipCodegen) await runCodegenForFlavor(flavor);
}

String _requireMainFile(String flavor) {
  final main = 'lib/main_$flavor.dart';
  if (!File(main).existsSync()) {
    logError('$main not found — run from a generated project root.');
    exit(1);
  }
  return main;
}

final _versionLine =
    RegExp(r'^version:\s*(\d+\.\d+\.\d+)(?:\+(\d+))?\s*$', multiLine: true);
final _versionNameRe = RegExp(r'^\d+\.\d+\.\d+$');
const _exportMethods = ['app-store', 'ad-hoc', 'development', 'enterprise'];

({String name, int build})? _readPubspecVersion() {
  final file = File('pubspec.yaml');
  if (!file.existsSync()) return null;
  final m = _versionLine.firstMatch(file.readAsStringSync());
  if (m == null) return null;
  return (name: m.group(1)!, build: int.tryParse(m.group(2) ?? '') ?? 0);
}

void _writePubspecVersion(String name, int build) {
  final file = File('pubspec.yaml');
  final content = file.readAsStringSync();
  if (!_versionLine.hasMatch(content)) {
    logWarn('No "version:" line found in pubspec.yaml — not saved.');
    return;
  }
  file.writeAsStringSync(
    content.replaceFirst(_versionLine, 'version: $name+$build'),
  );
  logInfo('pubspec.yaml version → $name+$build');
}

String _bumpName(String name, String kind) {
  final p = name.split('.').map(int.parse).toList();
  switch (kind) {
    case 'major':
      return '${p[0] + 1}.0.0';
    case 'minor':
      return '${p[0]}.${p[1] + 1}.0';
    case 'patch':
      return '${p[0]}.${p[1]}.${p[2] + 1}';
    default:
      return name; // "build": only the build number moves
  }
}

String? _validateBuildNumber(String v) =>
    v.isEmpty || int.tryParse(v) != null ? null : 'Build number must be an integer.';

String? _validateVersionName(String v) =>
    v.isEmpty || _versionNameRe.hasMatch(v) ? null : 'Use x.y.z (e.g. 1.4.0).';

/// Warns (never blocks — Xcode-managed signing needs no local identity) when
/// no code-signing identity is installed, since that is the usual cause of an
/// ipa export failing.
Future<void> _checkSigningIdentity() async {
  if (!Platform.isMacOS) return;
  try {
    final r = await Process.run('security', ['find-identity', '-v', '-p', 'codesigning']);
    final out = r.stdout.toString();
    if (out.contains(' 0 valid identities found')) {
      logWarn(
        'No code-signing identity found in the keychain. Fine if Xcode '
        'manages signing with your signed-in team; otherwise sign in under '
        'Xcode → Settings → Accounts first.',
      );
    }
  } catch (_) {}
}

Future<void> mainBuild(List<String> arguments) async {
  final own = arguments.takeWhile((a) => a != '--');
  if (own.contains('--help') || own.contains('-h')) {
    printBuildUsage();
    return;
  }
  final parsed = _parse(
    arguments,
    boolFlags: {
      '--debug', '--profile', '--split-per-abi', '--obfuscate',
      '--no-codegen', '--no-env', '--dry-run', '--save', '--no-codesign',
    },
    valueOptions: {'--build-name', '--build-number', '--bump', '--export-method'},
    usage: printBuildUsage,
  );
  if (parsed.flags.containsAll(['--debug', '--profile'])) {
    logError('Choose either --debug or --profile, not both.');
    exit(1);
  }

  String? target;
  String? requestedFlavor;
  for (final a in parsed.positional) {
    if (_targets.containsKey(a.toLowerCase())) {
      target = a.toLowerCase();
    } else if (requestedFlavor == null) {
      requestedFlavor = a;
    } else {
      logError('Unexpected argument "$a".');
      printBuildUsage();
      exit(1);
    }
  }
  final incomplete = target == null || requestedFlavor == null;

  target ??= promptSelect('Select build target:', _targets.keys.toList());
  if (target == null) {
    logError('No build target provided (apk, aab or ipa).');
    printBuildUsage();
    exit(1);
  }
  if (target == 'ipa' && !Platform.isMacOS) {
    logError('Building an ipa requires macOS.');
    exit(1);
  }
  if (parsed.flags.contains('--split-per-abi') && target != 'apk') {
    logError('--split-per-abi only applies to apk builds.');
    exit(1);
  }
  if (target != 'ipa' &&
      (parsed.values.containsKey('--export-method') ||
          parsed.flags.contains('--no-codesign'))) {
    logError('--export-method / --no-codesign only apply to ipa builds.');
    exit(1);
  }

  final flavor = resolveFlavor(requestedFlavor);
  final main = _requireMainFile(flavor);
  final dryRun = parsed.flags.contains('--dry-run');

  // ipa export method: validate, or ask when the command was incomplete.
  var exportMethod = parsed.values['--export-method'];
  if (exportMethod != null && !_exportMethods.contains(exportMethod)) {
    logError('Unknown export method "$exportMethod". '
        'Use: ${_exportMethods.join(' | ')}');
    exit(1);
  }
  if (target == 'ipa' &&
      exportMethod == null &&
      incomplete &&
      !parsed.flags.contains('--no-codesign')) {
    exportMethod = promptSelect('Export method:', _exportMethods);
  }

  // Version: --bump wins; explicit flags next; otherwise ask if incomplete.
  final current = _readPubspecVersion();
  String? buildName = parsed.values['--build-name'];
  String? buildNumber = parsed.values['--build-number'];
  var save = parsed.flags.contains('--save');

  final bump = parsed.values['--bump'];
  if (bump != null) {
    if (!{'major', 'minor', 'patch', 'build'}.contains(bump)) {
      logError('--bump must be one of: major, minor, patch, build.');
      exit(1);
    }
    if (buildName != null || buildNumber != null) {
      logError('Use either --bump or --build-name/--build-number, not both.');
      exit(1);
    }
    if (current == null) {
      logError('No "version: x.y.z+n" line in pubspec.yaml to bump.');
      exit(1);
    }
    buildName = _bumpName(current.name, bump);
    buildNumber = '${current.build + 1}';
    save = true;
  } else if (incomplete && buildName == null && buildNumber == null) {
    final cur = current == null ? 'unset' : '${current.name}+${current.build}';
    final nameIn = promptText(
      'Version name [current: $cur, Enter to keep]:',
      validator: _validateVersionName,
    );
    final numIn = promptText(
      'Build number [Enter to keep]:',
      validator: _validateBuildNumber,
    );
    if (nameIn != null && nameIn.isNotEmpty) buildName = nameIn;
    if (numIn != null && numIn.isNotEmpty) buildNumber = numIn;
    if (buildName != null || buildNumber != null) {
      final ans = promptText('Save to pubspec.yaml? (y/N):');
      save = ans != null && ans.toLowerCase().startsWith('y');
    }
  }
  if (buildName != null && !_versionNameRe.hasMatch(buildName)) {
    logError('--build-name must look like x.y.z (got "$buildName").');
    exit(1);
  }
  if (buildNumber != null && int.tryParse(buildNumber) == null) {
    logError('--build-number must be an integer (got "$buildNumber").');
    exit(1);
  }

  if (target == 'ipa' && !parsed.flags.contains('--no-codesign')) {
    await _checkSigningIdentity();
  }

  await _prepare(
    flavor,
    skipEnv: parsed.flags.contains('--no-env'),
    skipCodegen: parsed.flags.contains('--no-codegen'),
    dryRun: dryRun,
  );

  final mode = parsed.flags.contains('--debug')
      ? 'debug'
      : parsed.flags.contains('--profile')
          ? 'profile'
          : 'release';
  final command = [
    ...await _flutterCommand(),
    'build',
    _targets[target]!,
    '--$mode',
    '--flavor',
    flavor,
    '-t',
    main,
    if (parsed.flags.contains('--split-per-abi')) '--split-per-abi',
    if (buildName != null) ...['--build-name', buildName],
    if (buildNumber != null) ...['--build-number', buildNumber],
    if (exportMethod != null) '--export-method=$exportMethod',
    if (parsed.flags.contains('--no-codesign')) '--no-codesign',
    if (parsed.flags.contains('--obfuscate')) ...[
      '--obfuscate',
      '--split-debug-info=build/symbols/$flavor',
    ],
    ...parsed.passthrough,
  ];

  final code = await _stream(command, dryRun: dryRun);
  if (code != 0) {
    logError('Build failed (exit $code).');
    exit(code);
  }

  if (save && (buildName != null || buildNumber != null)) {
    final newName = buildName ?? current?.name;
    final newBuild = buildNumber != null
        ? int.parse(buildNumber)
        : (current?.build ?? 0);
    if (newName == null) {
      logWarn('Cannot save: pubspec.yaml has no version to build on.');
    } else if (dryRun) {
      logHint('(dry run) would save pubspec.yaml version → $newName+$newBuild');
    } else {
      _writePubspecVersion(newName, newBuild);
    }
  }
  if (dryRun) return;

  logInfo('Build finished.');
  final output = switch (target) {
    'apk' => 'build/app/outputs/flutter-apk/',
    'aab' =>
      'build/app/outputs/bundle/$flavor${mode[0].toUpperCase()}${mode.substring(1)}/',
    _ => 'build/ios/ipa/',
  };
  logHint('Output: $output');
  if (parsed.flags.contains('--obfuscate')) {
    logHint('Keep build/symbols/$flavor — needed to symbolicate crash reports.');
  }
}
