import 'dart:io';

import 'package:path/path.dart' as p;

import '../common/console.dart';

const _dartReservedWords = {
  'assert', 'break', 'case', 'catch', 'class', 'const', 'continue', 'default',
  'do', 'else', 'enum', 'extends', 'false', 'final', 'finally', 'for', 'if',
  'in', 'is', 'new', 'null', 'rethrow', 'return', 'super', 'switch', 'this',
  'throw', 'true', 'try', 'var', 'void', 'while', 'with',
};

/// Splits [basenameWithoutExt] on `-`, `_`, whitespace, and any non
/// alphanumeric character, dropping the separators. Doesn't split on
/// internal case boundaries (an already-camelCase filename stays one
/// token) — a deliberate simplification, fine as long as asset filenames
/// stick to snake_case/kebab-case, which every file in this template does.
List<String> _tokenize(String basenameWithoutExt) {
  return basenameWithoutExt
      .split(RegExp(r'[^A-Za-z0-9]+'))
      .where((t) => t.isNotEmpty)
      .toList();
}

String _capitalize(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

/// lowerCamelCase identifier for a generated field name, e.g.
/// `img_landing` -> `imgLanding`, `Manrope-Bold` -> `manropeBold`.
String _toCamelCase(String basenameWithoutExt) {
  final tokens = _tokenize(basenameWithoutExt).map((t) => t.toLowerCase()).toList();
  if (tokens.isEmpty) return 'asset';

  final buffer = StringBuffer(tokens.first);
  for (final token in tokens.skip(1)) {
    buffer.write(_capitalize(token));
  }
  var name = buffer.toString();

  if (RegExp(r'^[0-9]').hasMatch(name)) name = 'a$name';
  if (_dartReservedWords.contains(name)) name = '${name}_';
  return name;
}

/// PascalCase identifier for a generated class name, e.g. `images` ->
/// `Images` (used as `$AssetsImagesGen`).
String _toPascalCase(String basenameWithoutExt) {
  final tokens = _tokenize(basenameWithoutExt).map((t) => t.toLowerCase()).toList();
  if (tokens.isEmpty) return 'Asset';
  return tokens.map(_capitalize).join();
}

/// snake_case for a generated per-folder file name, e.g. `images` ->
/// `images`, `App Icons` -> `app_icons` (used as `assets_app_icons.gen.dart`).
String _toSnakeCase(String basenameWithoutExt) {
  final tokens = _tokenize(basenameWithoutExt).map((t) => t.toLowerCase()).toList();
  if (tokens.isEmpty) return 'asset';
  return tokens.join('_');
}

class _AssetFile {
  final String relativePath; // relative to the top-level folder, posix slashes
  final String fieldName;

  _AssetFile(this.relativePath, this.fieldName);
}

/// Resolves field-name collisions within one top-level folder's file list,
/// never dropping/overwriting an entry. Escalates in tiers: naive name ->
/// prefixed with immediate parent folder -> full path-segment chain ->
/// numeric suffix (stable sort order) as a last resort.
List<_AssetFile> _assignFieldNames(List<String> relativePaths) {
  List<String> namesFor(List<String> paths, int tier) {
    return paths.map((path) {
      final segments = p.posix.split(path);
      final fileName = segments.removeLast();
      final naive = _toCamelCase(p.basenameWithoutExtension(fileName));

      if (tier == 0) return naive;
      if (tier == 1) {
        final parent = segments.isNotEmpty ? segments.last : '';
        return parent.isEmpty ? naive : '${_toCamelCase(parent)}${_capitalize(naive)}';
      }
      if (tier == 2) {
        final chain = [...segments, p.basenameWithoutExtension(fileName)];
        final joined = chain.map((s) => _capitalize(_toCamelCase(s))).join();
        return joined.isEmpty
            ? naive
            : '${joined[0].toLowerCase()}${joined.substring(1)}';
      }
      return naive; // tier 3+ handled by numeric suffix below
    }).toList();
  }

  var tier = 0;
  var names = namesFor(relativePaths, tier);
  while (tier < 2 && _hasDuplicates(names)) {
    tier++;
    names = namesFor(relativePaths, tier);
  }

  if (_hasDuplicates(names)) {
    final seen = <String, int>{};
    for (var i = 0; i < names.length; i++) {
      final base = names[i];
      final count = (seen[base] ?? 0) + 1;
      seen[base] = count;
      names[i] = count == 1 ? base : '$base$count';
    }
  }

  return [
    for (var i = 0; i < relativePaths.length; i++)
      _AssetFile(relativePaths[i], names[i]),
  ];
}

bool _hasDuplicates(List<String> names) => names.toSet().length != names.length;

const _genHeader = '// GENERATED CODE - DO NOT MODIFY BY HAND\n'
    '// Regenerate with: moshaf_boilerplate assets\n';

/// Scans [assetsDir] and returns every generated file's content, keyed by
/// its path relative to `lib/core/constants/` — one small file per
/// top-level asset folder (`assets_gen/assets_<folder>.gen.dart`), plus a
/// single barrel file (`assets.gen.dart`) that exports all of them and
/// defines the `Assets` root class. Pure: no I/O beyond reading the
/// directory tree it's given, no side effects — fully testable in isolation.
Map<String, String> generateAssetsFiles(Directory assetsDir) {
  final topLevelDirs = assetsDir
      .listSync()
      .whereType<Directory>()
      .where((d) => !p.basename(d.path).startsWith('.'))
      .toList()
    ..sort((a, b) => p.basename(a.path).compareTo(p.basename(b.path)));

  final classes = <String, List<_AssetFile>>{};

  for (final dir in topLevelDirs) {
    final folderName = p.basename(dir.path);
    final relativePaths = dir
        .listSync(recursive: true)
        .whereType<File>()
        .map((f) => p.relative(f.path, from: dir.path))
        .where((rel) {
          final segments = p.split(rel);
          return !segments.any((s) => s.startsWith('.'));
        })
        .map((rel) => p.posix.joinAll(p.split(rel)))
        .toList()
      ..sort();

    if (relativePaths.isEmpty) continue;
    classes[folderName] = _assignFieldNames(relativePaths);
  }

  final files = <String, String>{};

  for (final entry in classes.entries) {
    final folderName = entry.key;
    final className = '\$Assets${_toPascalCase(folderName)}Gen';
    final fileName = 'assets_${_toSnakeCase(folderName)}.gen.dart';

    final buffer = StringBuffer(_genHeader)
      ..writeln()
      ..writeln('class $className {')
      ..writeln('  const $className();')
      ..writeln();
    for (final file in entry.value) {
      buffer.writeln(
          "  String get ${file.fieldName} => 'assets/$folderName/${file.relativePath}';");
    }
    buffer.writeln('}');

    files['assets_gen/$fileName'] = buffer.toString().trimRight() + '\n';
  }

  final barrel = StringBuffer(_genHeader)..writeln();
  for (final folderName in classes.keys) {
    barrel.writeln(
        "export 'assets_gen/assets_${_toSnakeCase(folderName)}.gen.dart';");
  }
  barrel.writeln();
  for (final folderName in classes.keys) {
    barrel.writeln(
        "import 'assets_gen/assets_${_toSnakeCase(folderName)}.gen.dart';");
  }
  barrel
    ..writeln()
    ..writeln('class Assets {')
    ..writeln('  Assets._();')
    ..writeln();
  for (final folderName in classes.keys) {
    barrel.writeln(
        '  static const $folderName = \$Assets${_toPascalCase(folderName)}Gen();');
  }
  barrel.writeln('}');

  files['assets.gen.dart'] = barrel.toString().trimRight() + '\n';

  return files;
}

/// Regenerates `lib/core/constants/assets.gen.dart` + its per-folder
/// `assets_gen/*.gen.dart` files for the project rooted at [projectDir].
/// `assets_gen/` is wiped and rewritten from scratch each run, so a folder
/// removed from `assets/` doesn't leave a stale generated file behind.
/// Throws a plain exception (does not call `exit()`) on failure, so it's
/// safe to call from `runGenerator()`'s own soft-fail try/catch —
/// [mainAssets] below is the only caller that exits the process.
Future<void> generateAssetsFile(String projectDir) async {
  final assetsDir = Directory(p.join(projectDir, 'assets'));
  if (!await assetsDir.exists()) {
    throw StateError('No "assets" folder found in $projectDir.');
  }

  final constantsDir = p.join(projectDir, 'lib', 'core', 'constants');
  final genDir = Directory(p.join(constantsDir, 'assets_gen'));
  if (await genDir.exists()) {
    await genDir.delete(recursive: true);
  }

  final files = generateAssetsFiles(assetsDir);
  for (final entry in files.entries) {
    final outFile = File(p.join(constantsDir, entry.key));
    await outFile.parent.create(recursive: true);
    await outFile.writeAsString(entry.value);
  }
}

/// CLI entry for `moshaf_boilerplate assets` — scans `<cwd>/assets` and
/// (re)writes `<cwd>/lib/core/constants/assets.gen.dart`. Also runnable
/// directly via `bin/assets.dart`, independent of the `moshaf_boilerplate`
/// entry point.
Future<void> mainAssets(List<String> arguments) async {
  final cwd = Directory.current.path;

  try {
    await runStep(
      'Generating assets.gen.dart',
      () => generateAssetsFile(cwd),
    );
  } catch (e) {
    logError('Failed to generate assets: $e');
    exit(1);
  }

  logInfo(
      'lib/core/constants/assets.gen.dart and assets_gen/ are up to date.');
}
