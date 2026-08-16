import 'dart:io';

/// Thrown by [executeCommand] on a non-zero exit code. Keeps [stderr]
/// available as a separate field (not just baked into the message) so
/// callers that need to inspect *why* a command failed — e.g. to report
/// which package caused a `pub add` conflict — don't have to re-parse it
/// back out of a formatted string.
class CommandFailedException implements Exception {
  final String command;
  final String stderr;

  const CommandFailedException(this.command, this.stderr);

  @override
  String toString() => 'Error executing command "$command": $stderr';
}

/// Checks whether [cmd] is resolvable on PATH.
Future<bool> commandExists(String cmd) async {
  final which = Platform.isWindows ? 'where' : 'which';
  try {
    final result = await Process.run(which, [cmd]);
    return result.exitCode == 0;
  } catch (_) {
    return false;
  }
}

/// Runs a whitespace-split shell [command], preferring FVM for `flutter`/
/// `dart` invocations and falling back to the plain executable when FVM is
/// unavailable or fails. Throws with the captured stderr on failure so
/// callers can abort instead of silently continuing.
///
/// [workingDirectory] scopes the command to a specific project folder
/// (defaults to the caller's own cwd when omitted) — used by `create` so
/// every command runs inside `./<projectName>` instead of relying on the
/// current directory already being the project.
Future<void> executeCommand(String command, {String? workingDirectory}) async {
  final parts = command.split(' ');
  final executable = parts.first;
  final arguments = parts.skip(1).toList();

  ProcessResult result;
  if (executable == 'flutter' || executable == 'dart') {
    result = await Process.run(
      'fvm',
      [executable, ...arguments],
      runInShell: true,
      workingDirectory: workingDirectory,
    );
    if (result.exitCode != 0) {
      result = await Process.run(
        executable,
        arguments,
        runInShell: true,
        workingDirectory: workingDirectory,
      );
    }
  } else {
    result = await Process.run(
      executable,
      arguments,
      runInShell: true,
      workingDirectory: workingDirectory,
    );
  }

  if (result.exitCode != 0) {
    throw CommandFailedException(command, result.stderr.toString());
  }
}
