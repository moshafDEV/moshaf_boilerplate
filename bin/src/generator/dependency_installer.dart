import '../common/process_utils.dart';

/// One dependency that `flutter pub add` could not resolve, with a short,
/// human-readable reason extracted from pub's stderr output.
class DependencyFailure {
  final String package;
  final String reason;

  const DependencyFailure(this.package, this.reason);
}

/// Installs [deps] via `flutter pub add`, keeping dependencies unpinned so
/// every generated project always picks up the latest compatible versions.
///
/// `flutter pub add` resolves its whole argument list atomically: if one
/// package conflicts, none of them get added. To avoid that one conflicting
/// package blocking every other dependency, this first tries the fast batch
/// path, and only if that fails falls back to adding packages one at a time
/// — so everything that resolves cleanly still gets installed, and the
/// caller gets back exactly which package(s) failed and why, instead of the
/// whole `create` run aborting.
Future<List<DependencyFailure>> installDependencies(
  List<String> deps, {
  required bool isDev,
  String? workingDirectory,
}) async {
  final devFlag = isDev ? '--dev ' : '';

  try {
    await executeCommand(
      'flutter pub add $devFlag${deps.join(' ')}',
      workingDirectory: workingDirectory,
    );
    return const [];
  } catch (_) {
    // Batch add failed — fall through to the one-by-one fallback below.
  }

  final failures = <DependencyFailure>[];
  for (final dep in deps) {
    try {
      await executeCommand(
        'flutter pub add $devFlag$dep',
        workingDirectory: workingDirectory,
      );
    } catch (e) {
      failures.add(DependencyFailure(dep, _shortReason(e)));
    }
  }
  return failures;
}

/// Reduces a (possibly long, multi-line) pub error down to one readable line.
String _shortReason(Object error) {
  final text =
      error is CommandFailedException ? error.stderr : error.toString();
  final firstLine = text
      .split('\n')
      .map((line) => line.trim())
      .firstWhere((line) => line.isNotEmpty, orElse: () => text.trim());
  return firstLine.length > 160 ? '${firstLine.substring(0, 160)}…' : firstLine;
}
