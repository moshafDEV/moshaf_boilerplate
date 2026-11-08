import 'dart:io';

import 'console.dart';

/// True when stdin is a real terminal, i.e. a person can answer a
/// prompt. False under CI, pipes, and IDE tasks without a TTY — callers must
/// then fall back to explicit arguments instead of asking.
bool get isInteractive => stdin.hasTerminal;

/// Arrow-key (or j/k, or number) selector. Returns the chosen option, or
/// null when stdin isn't interactive. Ctrl-C exits like any other command.
String? promptSelect(String label, List<String> options) {
  if (!isInteractive || options.isEmpty) return null;

  var index = 0;
  var firstRender = true;

  void render() {
    if (!firstRender) stdout.write('\x1B[${options.length}A');
    firstRender = false;
    for (var i = 0; i < options.length; i++) {
      final selected = i == index;
      final marker = selected ? '❯' : ' ';
      final line = '$marker ${i + 1}. ${options[i]}';
      stdout.writeln('\x1B[2K${selected ? '$cyan$line$reset' : line}');
    }
  }

  final bool oldEcho;
  final bool oldLine;
  try {
    oldEcho = stdin.echoMode;
    oldLine = stdin.lineMode;
    stdin.echoMode = false;
    stdin.lineMode = false;
  } on StdinException {
    // hasTerminal said yes but raw mode isn't available (e.g. /dev/null).
    return null;
  }
  stdout.writeln('$yellow$label$reset ${cyan}(↑/↓ to move, Enter to select)$reset');
  stdout.write('\x1B[?25l');

  try {
    render();
    while (true) {
      final key = stdin.readByteSync();
      if (key == 3 || key == 4 || key == -1) {
        // Ctrl-C / Ctrl-D / EOF
        stdout.write('\x1B[?25h');
        stdin.echoMode = oldEcho;
        stdin.lineMode = oldLine;
        stdout.writeln();
        exit(130);
      }
      if (key == 10 || key == 13) break;
      if (key == 27) {
        // ESC [ A / ESC [ B
        if (stdin.readByteSync() == 91) {
          final arrow = stdin.readByteSync();
          if (arrow == 65) index = (index - 1 + options.length) % options.length;
          if (arrow == 66) index = (index + 1) % options.length;
        }
      } else if (key == 107) {
        index = (index - 1 + options.length) % options.length; // k
      } else if (key == 106) {
        index = (index + 1) % options.length; // j
      } else if (key >= 49 && key <= 57 && key - 49 < options.length) {
        index = key - 49;
      }
      render();
    }
  } finally {
    stdout.write('\x1B[?25h');
    stdin.echoMode = oldEcho;
    stdin.lineMode = oldLine;
  }
  return options[index];
}

/// Asks for a line of text, re-asking until [validator] returns null.
/// Returns null when stdin isn't interactive.
String? promptText(
  String label, {
  String? Function(String value)? validator,
}) {
  if (!isInteractive) return null;
  while (true) {
    stdout.write('$yellow$label$reset ');
    final value = (stdin.readLineSync() ?? '').trim();
    final error = validator?.call(value);
    if (error == null) return value;
    logError(error);
  }
}

/// Closest [options] entry to [input] (edit distance <= 2), for "did you
/// mean" hints on typos.
String? suggestClosest(String input, Iterable<String> options) {
  String? best;
  var bestDistance = 3;
  for (final option in options) {
    final d = _editDistance(input.toLowerCase(), option.toLowerCase());
    if (d < bestDistance) {
      bestDistance = d;
      best = option;
    }
  }
  return best;
}

int _editDistance(String a, String b) {
  var prev = List<int>.generate(b.length + 1, (i) => i);
  for (var i = 1; i <= a.length; i++) {
    final curr = List<int>.filled(b.length + 1, 0)..[0] = i;
    for (var j = 1; j <= b.length; j++) {
      final cost = a[i - 1] == b[j - 1] ? 0 : 1;
      curr[j] = [prev[j] + 1, curr[j - 1] + 1, prev[j - 1] + cost]
          .reduce((x, y) => x < y ? x : y);
    }
    prev = curr;
  }
  return prev[b.length];
}
