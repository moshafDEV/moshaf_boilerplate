import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// ANSI color codes shared by every CLI command, so output styling stays
/// consistent instead of each file hardcoding its own escape sequences.
const String red = '\x1B[31m';
const String yellow = '\x1B[33m';
const String green = '\x1B[32m';
const String cyan = '\x1B[36m';
const String reset = '\x1B[0m';

void logError(String message) => stdout.writeln('$red$message$reset');
void logWarn(String message) => stdout.writeln('$yellow$message$reset');
void logInfo(String message) => stdout.writeln('$green$message$reset');
void logHint(String message) => stdout.writeln('$cyan$message$reset');

/// Runs [action] while showing a spinner line, then replaces it with a
/// success/failure line. Unlike a plain progress print, the spinner is tied
/// to the real async work: if [action] throws, the step is reported as
/// failed and the error is rethrown so the caller can stop the pipeline
/// instead of continuing on top of a broken step.
Future<T> runStep<T>(
  String label,
  Future<T> Function() action,
) async {
  const frames = ['|', '/', '-', '\\'];
  var frame = 0;

  void render() {
    stdout.write('\r$yellow$label ${frames[frame]}$reset');
  }

  render();
  final timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
    frame = (frame + 1) % frames.length;
    render();
  });

  try {
    final result = await action();
    timer.cancel();
    stdout.write('\r$green$label ✔ Completed.$reset\n');
    return result;
  } catch (e) {
    timer.cancel();
    stdout.write('\r$red$label ✘ Failed: $e$reset\n');
    rethrow;
  }
}

/// Asks a yes/no question on stdin, auto-answering "yes" after [seconds]
/// (or immediately when stdin has no terminal, e.g. in CI).
Future<bool> promptYesNoAutoYes(String label, {int seconds = 5}) async {
  final completer = Completer<String>();
  final lineSub = stdin
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .listen((line) {
    if (!completer.isCompleted) completer.complete(line.trim());
  });

  var remaining = seconds;
  void render() => stdout.write('\r$label (y/n, auto "y" in $remaining s): ');
  render();

  final timer = Timer.periodic(const Duration(seconds: 1), (t) {
    remaining--;
    if (remaining <= 0) {
      t.cancel();
      if (!completer.isCompleted) completer.complete('y');
    } else {
      render();
    }
  });

  if (!stdin.hasTerminal && !completer.isCompleted) {
    timer.cancel();
    completer.complete('y');
  }

  final result = (await completer.future).toLowerCase();
  await lineSub.cancel();
  timer.cancel();
  stdout.writeln();

  if (result == 'n' || result == 'no') return false;
  return true;
}
