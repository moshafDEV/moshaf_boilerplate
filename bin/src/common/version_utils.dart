import 'dart:io';

/// Compares two `major.minor.patch` version strings.
bool versionLessThan(String v1, String v2) {
  final a = v1.split('.').map(int.parse).toList();
  final b = v2.split('.').map(int.parse).toList();
  for (var i = 0; i < 3; i++) {
    if (a[i] < b[i]) return true;
    if (a[i] > b[i]) return false;
  }
  return false;
}

Future<String?> getDartVersion() async {
  try {
    final result = await Process.run('dart', ['--version']);
    final output = result.stderr.toString() + result.stdout.toString();
    final match = RegExp(r'(\d+)\.(\d+)\.(\d+)').firstMatch(output);
    if (match != null) {
      return '${match.group(1)}.${match.group(2)}.${match.group(3)}';
    }
  } catch (_) {
    // Dart not on PATH; caller treats a null version as "unknown".
  }
  return null;
}

/// Reads the minimum Dart SDK constraint (`environment: sdk: ">=x.y.z"`)
/// from the pubspec.yaml in the current working directory.
Future<String?> getMinDartVersionFromPubspec() async {
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

/// Extracts the `major.minor.patch` version from `flutter --version` output.
String? parseFlutterVersion(String versionOutput) {
  final match = RegExp(r'Flutter (\d+\.\d+\.\d+)').firstMatch(versionOutput);
  return match?.group(1);
}
