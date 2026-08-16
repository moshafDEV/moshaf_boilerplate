import 'dart:io';

import 'package:path/path.dart' as p;

const _binaryExtensions = [
  '.ico',
  '.jpg',
  '.jpeg',
  '.png',
  '.gif',
  '.bmp',
  '.tiff',
  '.jar',
  '.ttf',
  '.otf',
  '.woff',
  '.woff2',
];

bool isBinaryFile(File file) {
  final name = file.uri.pathSegments.last;
  final extension = '.${name.split('.').last.toLowerCase()}';
  return _binaryExtensions.contains(extension);
}

/// Replaces every occurrence of [searchValue] with [replaceValue] in [file].
Future<void> replaceTextInFile(
  File file,
  String searchValue,
  String replaceValue,
) async {
  final content = await file.readAsString();
  if (content.contains(searchValue)) {
    await file.writeAsString(content.replaceAll(searchValue, replaceValue));
  }
}

/// Recursively rewrites [searchValue] to [replaceValue] in every text file
/// under [folderPath] (binary files and `.DS_Store` are left untouched).
Future<void> modifyFilesInFolder(
  String folderPath,
  String searchValue,
  String replaceValue,
) async {
  final dir = Directory(folderPath);
  if (!await dir.exists()) return;

  await for (final entity in dir.list(recursive: true)) {
    if (entity is! File) continue;
    if (entity.uri.pathSegments.last == '.DS_Store' || isBinaryFile(entity)) {
      continue;
    }
    await replaceTextInFile(entity, searchValue, replaceValue);
  }
}

/// Template files are stored with a `dot_` prefix (e.g. `dot_env`,
/// `dot_vscode/`) so they survive pub publishing; this restores the real
/// leading dot once the template is copied into a real project.
String restoreDotSegments(String relativePath, {String dotPrefix = 'dot_'}) {
  final parts = p.split(relativePath).map((segment) {
    return segment.startsWith(dotPrefix)
        ? '.${segment.substring(dotPrefix.length)}'
        : segment;
  }).toList();
  return p.joinAll(parts);
}

/// Copies [source] into [destination], restoring `dot_*` segments in path
/// names along the way. Placeholder substitution for the actual project
/// name happens separately, in file *contents*, via [modifyFilesInFolder].
Future<void> copyFolderRecursive(
  Directory source,
  Directory destination, {
  String dotPrefix = 'dot_',
}) async {
  if (!await source.exists()) {
    throw ArgumentError('Source folder was not found: ${source.path}');
  }

  await destination.create(recursive: true);

  await for (final entity in source.list(recursive: true, followLinks: false)) {
    final rel = p.relative(entity.path, from: source.path);
    final relMapped = restoreDotSegments(rel, dotPrefix: dotPrefix);
    final targetPath = p.join(destination.path, relMapped);

    if (entity is Directory) {
      await Directory(targetPath).create(recursive: true);
    } else if (entity is File) {
      await File(targetPath).parent.create(recursive: true);
      await entity.copy(targetPath);
    }
  }
}

/// Copies [source] into [destinationPath].
Future<void> copyFolder(String source, String destinationPath) async {
  await copyFolderRecursive(Directory(source), Directory(destinationPath));
}

/// SDK/lint version constraints extracted from a freshly `flutter create`-d
/// pubspec.yaml, to be re-applied after the template overwrites it — see
/// [extractPubspecVersionOverrides] / [applyPubspecVersionOverrides].
class PubspecVersionOverrides {
  final String sdkLine;
  final String? cupertinoIconsVersion;
  final String? flutterLintsVersion;

  const PubspecVersionOverrides({
    required this.sdkLine,
    this.cupertinoIconsVersion,
    this.flutterLintsVersion,
  });
}

/// Reads the SDK/lint version constraints out of [pubspec] before the
/// template's own pubspec.yaml overwrites it, so they can be restored
/// afterwards with [applyPubspecVersionOverrides]. Returns null if [pubspec]
/// doesn't exist or has no `sdk:` constraint to preserve.
Future<PubspecVersionOverrides?> extractPubspecVersionOverrides(
  File pubspec,
) async {
  if (!await pubspec.exists()) return null;

  String? sdkLine;
  String? cupertinoIconsVersion;
  String? flutterLintsVersion;

  for (final line in await pubspec.readAsLines()) {
    final trimmed = line.trim();
    if (trimmed.startsWith('sdk:') && !line.contains('flutter')) {
      sdkLine = line;
    }
    if (trimmed.startsWith('cupertino_icons:')) cupertinoIconsVersion = trimmed;
    if (trimmed.startsWith('flutter_lints:')) flutterLintsVersion = trimmed;
  }

  if (sdkLine == null) return null;
  return PubspecVersionOverrides(
    sdkLine: sdkLine,
    cupertinoIconsVersion: cupertinoIconsVersion,
    flutterLintsVersion: flutterLintsVersion,
  );
}

/// Re-applies [overrides] onto [pubspec] — the template's pubspec, now
/// merged into the project — so the final pubspec keeps the SDK version
/// `flutter create` detected rather than whatever placeholder ships with
/// the template.
Future<void> applyPubspecVersionOverrides(
  File pubspec,
  PubspecVersionOverrides overrides,
) async {
  if (!await pubspec.exists()) return;

  final lines = await pubspec.readAsLines();
  final updatedLines = <String>[];
  var inEnvironment = false;
  var inDependencies = false;
  var inDevDependencies = false;

  for (final line in lines) {
    final trimmed = line.trim();

    if (trimmed.startsWith('environment:')) {
      inEnvironment = true;
      inDependencies = false;
      inDevDependencies = false;
      updatedLines.add(line);
      continue;
    }
    if (trimmed.startsWith('dependencies:')) {
      inDependencies = true;
      inEnvironment = false;
      inDevDependencies = false;
      updatedLines.add(line);
      continue;
    }
    if (trimmed.startsWith('dev_dependencies:')) {
      inDevDependencies = true;
      inEnvironment = false;
      inDependencies = false;
      updatedLines.add(line);
      continue;
    }

    if (inEnvironment &&
        trimmed.startsWith('sdk:') &&
        !line.contains('flutter')) {
      updatedLines.add(overrides.sdkLine);
      continue;
    }
    if (inDependencies &&
        trimmed.startsWith('cupertino_icons:') &&
        overrides.cupertinoIconsVersion != null) {
      updatedLines.add('  ${overrides.cupertinoIconsVersion}');
      continue;
    }
    if (inDevDependencies &&
        trimmed.startsWith('flutter_lints:') &&
        overrides.flutterLintsVersion != null) {
      updatedLines.add('  ${overrides.flutterLintsVersion}');
      continue;
    }

    // A new top-level (non-indented) key ends whichever section we were in.
    if ((inEnvironment || inDependencies || inDevDependencies) &&
        line.isNotEmpty &&
        !line.startsWith(' ') &&
        !line.startsWith('\t')) {
      inEnvironment = false;
      inDependencies = false;
      inDevDependencies = false;
    }

    updatedLines.add(line);
  }

  await pubspec.writeAsString(updatedLines.join('\n'));
}
