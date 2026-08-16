import '../common/process_utils.dart';

/// Applies the native Android/iOS flavor setup described by the generated
/// project's `flavorizr.yaml` — see that file for exactly which processors
/// run and why (only native Android/iOS config; this project's own
/// lib/main.dart + flutter_flavor-based FlavorConfig are left untouched).
///
/// `-f` skips flutter_flavorizr's interactive confirmation prompt, since
/// this always runs non-interactively as part of `create`.
Future<void> runFlavorizr({String? workingDirectory}) async {
  await executeCommand(
    'dart run flutter_flavorizr -f',
    workingDirectory: workingDirectory,
  );
}
