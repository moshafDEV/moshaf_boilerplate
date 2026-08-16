import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as p;

/// Resolves a directory bundled next to a globally-activated package.
///
/// Uses `Isolate.resolvePackageUri` to find where pub installed
/// [packageName], then looks for [customTargetDir] (default: `source`)
/// next to its `lib/` folder. This is how the generator finds its own
/// bundled `source/` template after `dart pub global activate`.
Future<Directory> getSourceDir(
  String packageName, {
  String? customTargetDir,
}) async {
  final libUri = await Isolate.resolvePackageUri(
    Uri.parse('package:$packageName/'),
  );
  if (libUri == null) {
    throw StateError(
      'Could not resolve package:$packageName/. Check the package name & global activation.',
    );
  }

  final packageRoot =
      Directory.fromUri(libUri).parent; // .../package-<version>/
  final sourceDir = Directory(
    p.join(packageRoot.path, customTargetDir ?? 'source'),
  );

  if (!sourceDir.existsSync()) {
    throw FileSystemException(
      "The '${customTargetDir ?? 'source'}' folder was not found in ${packageRoot.path}.\n"
      'Make sure it is not ignored by .pubignore/.gitignore when publishing.',
    );
  }
  return sourceDir;
}

/// Reads the `version:` field from this package's own pubspec.yaml.
Future<String> getPubspecVersion() async {
  const pkg = 'moshaf_boilerplate';
  final source = await getSourceDir(pkg, customTargetDir: '.');

  final pubspecFile = File('${source.path}/pubspec.yaml');
  if (pubspecFile.existsSync()) {
    final lines = pubspecFile.readAsLinesSync();
    final versionLine = lines.firstWhere(
      (line) => line.trim().startsWith('version:'),
      orElse: () => '',
    );
    if (versionLine.isNotEmpty) {
      return versionLine.split(':').last.trim();
    }
  }
  return '-unknown';
}
