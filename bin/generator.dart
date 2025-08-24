import 'dart:io';
import 'dart:async';


void main(List<String> args) async {
  if (args.isEmpty) {
    _printHelp();
    exit(0);
  }

  final command = args.first.toLowerCase();

  switch (command) {
    case 'create':
      await runGenerator();
      break;

    case 'version':
    case '--version':
    case '-v':
      _printGeneratorVersion();
      break;

    case 'help':
    case '--help':
    case '-h':
    default:
      _printHelp();
      break;
  }
}

void _printGeneratorVersion() {
  stdout.writeln('🚀 MOSHAF Boilerplate Generator');
  stdout.writeln('Version: 1.0.0-dev.1');
}

void _printHelp() {
  stdout.writeln('Usage: moshaf_boilerplate <command>\n');
  stdout.writeln('Commands:');
  stdout.writeln('  create      Generate boilerplate (requires Flutter)');
  stdout.writeln('  version     Show the boilerplate generator version');
  stdout.writeln('  help        Show this help message\n');
  stdout.writeln('Examples:');
  stdout.writeln('  moshaf_boilerplate create');
  stdout.writeln('  moshaf_boilerplate version');
}

Future<void> runGenerator() async {
  stdout.writeln('\x1B[32m----------------------------------------------------------------\x1B[0m');
  stdout.writeln('\x1B[32mWelcome to the MOSHAF Flutter Boilerplate Generator! v1.0.0\x1B[0m');
  stdout.writeln('\x1B[32m----------------------------------------------------------------\x1B[0m');
  stdout.writeln('This tool will help you set up a Flutter project with:');
  stdout.writeln('- Clean Architecture structure');
  stdout.writeln('- Sample BLoC code for state management');
  stdout.writeln('- Pre-configured dependencies for scalable development');
  stdout.writeln('- Automated file and folder setup');
  stdout.writeln('- Best practices for maintainable code');
  stdout.writeln('Let\'s get started!');
  stdout.writeln('Powered by MOSHAF');
  stdout.writeln('');

  // Check Flutter version
  ProcessResult result;
  try {
    result = await Process.run('flutter', ['--version'], runInShell: true);
    if (result.exitCode != 0) {
      // Try with FVM if flutter fails
      result = await Process.run('fvm', ['flutter', '--version'], runInShell: true);
    }
  } catch (e) {
    stdout.writeln('\x1B[31mFailed to run "flutter --version". Make sure Flutter or FVM is installed and in your PATH.\x1B[0m');
    return;
  }

  String flutterVersion = '';
  if (result.exitCode == 0) {
    RegExp versionRegex = RegExp(r'Flutter (\d+\.\d+\.\d+)');
    var match = versionRegex.firstMatch(result.stdout);
    if (match != null) {
      flutterVersion = match.group(1) ?? '';
      if (flutterVersion != '3.32.2') {
        stdout.writeln('\x1B[33mFlutter version detected: $flutterVersion\x1B[0m');
        stdout.writeln('\x1B[31mWarning: Recommended Flutter version is 3.32.2, but detected $flutterVersion.\x1B[0m');
        stdout.writeln('\x1B[31mPlease use Flutter 3.32.2 for best compatibility with this boilerplate.\x1B[0m');
      }else{
        stdout.writeln('\x1B[36mFlutter version detected: $flutterVersion\x1B[0m');
      }
    } else {
      stdout.writeln('\x1B[31mCould not detect Flutter version.\x1B[0m');
    }
  } else {
    stdout.writeln('\x1B[31mFailed to run "flutter --version". Make sure Flutter or FVM is installed and in your PATH.\x1B[0m');
  }

  stdout.write('Please enter the Flutter project name (e.g. moshaf_app or moshafapp): ');

  String? projectName = stdin.readLineSync();

  // Validate project name
  if (projectName == null || projectName.trim().isEmpty) {
    print('\x1B[31mError: Project name cannot be empty.\x1B[0m');
    return;
  }

  // Validate project name format
  if (!RegExp(r'^[a-z0-9_]+$').hasMatch(projectName)) {
    print('\x1B[31mError: Invalid project name "$projectName".\x1B[0m');
    print('The name should consist of lowercase letters, numbers, and underscores only.');
    print('\x1B[33mExample of a valid name: moshaf_app or moshafapp\x1B[0m');
    print('');
    return;
  }

  stdout.writeln('\x1B[32mInitializing the setup for your Flutter project: "$projectName". Please hold on...\x1B[0m');
  print('');
  
  // Process of creating and setting up the Flutter project
  await _runCommandWithProgress('flutter create $projectName', 'Creating Flutter project', projectName);

  await _runCommandWithProgress('Modifying files in folder', 'Modifying files in folder', projectName);
  await _modifyFilesInFolder('source', 'ProjectName', projectName);

  await _runCommandWithProgress('Copying and replacing files', 'Copying and replacing files', projectName);
  await _copyAndReplaceAndDelete('source', './$projectName');

  await _runCommandWithProgress('Cleaning up directory', 'Cleaning up directory', projectName);
  await _cleanProjectDirectory(projectName);

  await _runCommandWithProgress('Installing dependencies', 'Installing dependencies', projectName);
  await _installDependencies([
    'envied', 'dartz', 'dio', 'equatable', 'flutter_bloc', 'flutter_secure_storage', 'get_it',
    'gtm', 'http', 'device_info_plus', 'package_info_plus', 'pretty_dio_logger', 'crypto',
    'timezone', 'firebase_analytics', 'firebase_crashlytics', 'flutter_flavor', 'injectable',
    'flutter_dotenv', 'easy_localization', 'firebase_messaging', 'flutter_screenutil', 'chucker_flutter',
    'flutter_svg', 'awesome_extensions', 'cached_network_image', 'freezed_annotation', 'flutter_inappwebview',
    'pinput'
  ], false, projectName);

  await _runCommandWithProgress('Installing dev dependencies', 'Installing dev dependencies', projectName);
  await _installDependencies([
    'build_runner', 'flutter_lints', 'freezed', 'json_serializable'
  ], true, projectName);

  await _selfDestruct();
}

/// Run command with a progress and show success/fail with colored output
Future<void> _runCommandWithProgress(String command, String taskName, String projectName) async {
  // If the command is not a real shell command, just show text status.
  // We assume commands like 'Modifying files in folder', 'Copying and replacing files', 'Cleaning up directory'
  // are not shell commands, so we use _runTextStatus instead.
  final fakeCommands = [
    'Modifying files in folder',
    'Copying and replacing files',
    'Cleaning up directory',
    'Installing dependencies',
    'Installing dev dependencies'
  ];
  if (fakeCommands.contains(command)) {
    // Show progress spinner for consistency
    var spinner = _getSpinner();
    var spinnerState = 0;
    stdout.write('\x1B[33m[MOSHAF] $taskName for project: $projectName ${spinner[spinnerState]}\x1B[0m');
    var timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      spinnerState = (spinnerState + 1) % spinner.length;
      stdout.write('\r\x1B[33m[MOSHAF] $taskName for project: $projectName ${spinner[spinnerState]}\x1B[0m');
    });
    await Future.delayed(Duration(milliseconds: 600));
    timer.cancel();
    stdout.write('\r\x1B[32m[MOSHAF] $taskName for project: $projectName ✔ Completed.\x1B[0m\n');
    return;
  }

  stdout.write('\x1B[33m[MOSHAF] $taskName for project: $projectName... \x1B[0m');

  var spinner = _getSpinner();
  var spinnerState = 0;

  var timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
    spinnerState = (spinnerState + 1) % spinner.length;
    stdout.write('\r\x1B[33m[MOSHAF] $taskName for project: $projectName ${spinner[spinnerState]}\x1B[0m');
  });

  try {
    await _executeCommand(command);
    timer.cancel();
    stdout.write('\r\x1B[32m[MOSHAF] $taskName for project: $projectName ✔ Completed.\x1B[0m\n');
  } catch (e) {
    timer.cancel();
    stdout.write('\r\x1B[31m[MOSHAF] $taskName for project: $projectName ✘ Failed: $e\x1B[0m\n');
  }
}

/// Get spinner to show on CLI
List<String> _getSpinner() {
  return ['|', '/', '-', '\\'];
}

/// Runs a shell command, with fallback to FVM if Flutter fails.
Future<void> _executeCommand(String command) async {
  try {
    List<String> parts = command.split(' ');
    String executable = parts[0];
    List<String> arguments = parts.skip(1).toList();

    ProcessResult result = await Process.run(
      executable,
      arguments,
      runInShell: true,
    );

    if (result.exitCode != 0) {
      if (executable == 'flutter') {
        result = await Process.run(
          'fvm',
          [executable, ...arguments],
          runInShell: true,
        );
        if (result.exitCode != 0) {
          throw 'Error executing command: ${result.stderr}';
        }
      } else {
        throw 'Error executing command: ${result.stderr}';
      }
    }
  } catch (e) {
    rethrow;
  }
}

/// Installs dependencies [deps] using `flutter pub add`. If [isDev] is true, adds as dev dependencies.
Future<void> _installDependencies(List<String> deps, bool isDev, String projectName) async {
  try {
    String command = 'flutter pub add ${isDev ? '--dev ' : ''}${deps.join(' ')}';
    await _executeCommand(command);
  } catch (e) {
    stdout.writeln('\x1B[31m✘ Failed to install ${isDev ? '--dev ' : ''} dependencies: $e\x1B[0m');
  }
}

/// Replaces all occurrences of [searchValue] with [replaceValue] in [file].
Future<void> _replaceTextInFile(File file, String searchValue, String replaceValue) async {
  try {
    String content = await file.readAsString();
    if (content.contains(searchValue)) {
      content = content.replaceAll(searchValue, replaceValue);
      await file.writeAsString(content);
    }
  } catch (e) {
    print('\x1B[31mError replacing text in ${file.path}: $e\x1B[0m');
  }
}

/// Recursively modifies files in [folderPath], replacing [searchValue] with [replaceValue].
Future<void> _modifyFilesInFolder(String folderPath, String searchValue, String replaceValue) async {
  var dir = Directory(folderPath);

  if (await dir.exists()) {
    await for (var entity in dir.list(recursive: true)) {
      if (entity is File) {
        // Make sure not to modify image files or '.DS_Store' files
        if (entity.uri.pathSegments.last == '.DS_Store' || _isImageFile(entity)) continue;
        await _replaceTextInFile(entity, searchValue, replaceValue);
      }
    }
  }
}

/// Checks if [file] is an image file by its extension.
bool _isImageFile(File file) {
  final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.tiff'];
  final extension = '.' + file.uri.pathSegments.last.split('.').last.toLowerCase();
  return imageExtensions.contains(extension);
}

/// Recursively copies [source] folder to [destination], replacing [replace] with [replaceWith] in paths.
Future<void> _copyFolderRecursive(
  Directory source,
  Directory destination,
  String replace,
  String replaceWith,
) async {
  try {
    if (!await destination.exists()) {
      await destination.create(recursive: true);
    }

    var entities = source.listSync();
    for (var entity in entities) {
      String relativePath = entity.path.replaceFirst(source.path, '');
      String targetPath = '${destination.path}/$relativePath'.replaceAll(replace, replaceWith);

      if (entity is Directory) {
        var newDestination = Directory(targetPath);
        await _copyFolderRecursive(entity, newDestination, replace, replaceWith);
      } else if (entity is File) {
        var newFile = File(targetPath);
        await entity.copy(newFile.path);
      }
    }
  } catch (e) {}
}

/// Copies [source] folder to [projectName] directory, replacing text and then deletes [source].
Future<void> _copyAndReplaceAndDelete(String source, String projectName) async {
  var sourceDir = Directory(source);
  var destinationDir = Directory(projectName);

  try {
    await _copyFolderRecursive(sourceDir, destinationDir, 'ProjectName', projectName);
    await sourceDir.delete(recursive: true);
  } catch (e) {}
}

/// Cleans up the project directory by copying and replacing files from './[projectName]' to '.'.
Future<void> _cleanProjectDirectory(String projectName) async {
  await _copyAndReplaceAndDelete('./$projectName', '.');
}

/// Deletes the script file after execution.
Future<void> _selfDestruct() async {
  var scriptFile = File(Platform.script.toFilePath());
  try {
    await scriptFile.delete();
    print('');
    print('Your Flutter project is now ready and set up with best practices!');
    print('Thank you for using MOSHAF Boilerplate Generator.');
    print('💻 Happy coding and good luck with your project! 🚀');
  } catch (e) {}
}
