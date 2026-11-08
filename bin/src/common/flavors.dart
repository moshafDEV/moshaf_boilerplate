import 'dart:io';

import 'package:path/path.dart' as p;

const _ignoredEnvSuffixes = {'example', 'sample', 'template', 'local'};
const _flavorOrder = ['dev', 'staging', 'prod'];

/// Flavors a project defines, discovered from its `.env.<flavor>` files —
/// the same convention `env` copies from, so a flavor is selectable exactly
/// when it can actually be used. Built-in flavors come first.
List<String> discoverFlavors([String? projectDir]) {
  final dir = Directory(projectDir ?? Directory.current.path);
  if (!dir.existsSync()) return [];

  final pattern = RegExp(r'^\.env\.([a-z][a-z0-9_]*)$');
  final found = <String>{};
  for (final entity in dir.listSync(followLinks: false)) {
    if (entity is! File) continue;
    final match = pattern.firstMatch(p.basename(entity.path));
    final name = match?.group(1);
    if (name != null && !_ignoredEnvSuffixes.contains(name)) found.add(name);
  }

  int rank(String f) {
    final i = _flavorOrder.indexOf(f);
    return i == -1 ? _flavorOrder.length : i;
  }

  return found.toList()..sort((a, b) {
    final byRank = rank(a).compareTo(rank(b));
    return byRank != 0 ? byRank : a.compareTo(b);
  });
}
