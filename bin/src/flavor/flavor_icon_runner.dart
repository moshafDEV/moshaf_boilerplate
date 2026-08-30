import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

import '../common/console.dart';

/// Flavors that get a ribboned icon, and the label drawn on it. Matches the
/// in-app FlavorConfig banner exactly: prod is deliberately excluded (no
/// ribbon there either) so it stays visually "clean" as the real release
/// icon — see app.dart's _AppBanner.
const _ribbonedFlavors = {'dev': 'DEV', 'staging': 'STAGING'};

/// Same red as kMainDanger / the in-app FlavorConfig banner color, so the
/// icon ribbon and the in-app banner read as the same visual language.
final _ribbonColor = img.ColorRgba8(0xDE, 0x1C, 0x1F, 230);
final _ribbonTextColor = img.ColorRgba8(0xFF, 0xFF, 0xFF, 255);

/// Reads flutter_launcher_icons.yaml's `image_path`, draws a flavor-label
/// ribbon across the bottom of that icon for dev/staging, and writes a
/// matching `flutter_launcher_icons-<flavor>.yaml` next to it — picked up
/// automatically the next time `dart run flutter_launcher_icons` runs (it
/// scans for that filename pattern on its own, no extra flags needed).
Future<void> mainFlavorIcons(List<String> arguments) async {
  final projectDir = Directory.current.path;

  final baseConfigFile = File(p.join(projectDir, 'flutter_launcher_icons.yaml'));
  if (!await baseConfigFile.exists()) {
    logError(
      'flutter_launcher_icons.yaml not found — run this from a generated '
      'project root.',
    );
    exit(1);
  }
  final baseConfigContent = await baseConfigFile.readAsString();

  final imagePathMatch =
      RegExp(r'^\s*image_path:\s*"([^"]+)"', multiLine: true).firstMatch(baseConfigContent);
  final basePath = imagePathMatch?.group(1);
  if (basePath == null) {
    logError('Could not find "image_path:" in flutter_launcher_icons.yaml.');
    exit(1);
  }

  final baseImageFile = File(p.join(projectDir, basePath));
  if (!await baseImageFile.exists()) {
    logError(
      'Base icon not found at $basePath — drop your real app icon there '
      'first (see flutter_launcher_icons.yaml), then re-run this command.',
    );
    exit(1);
  }

  final baseImage = img.decodeImage(await baseImageFile.readAsBytes());
  if (baseImage == null) {
    logError('Could not decode $basePath as an image.');
    exit(1);
  }

  for (final entry in _ribbonedFlavors.entries) {
    final flavor = entry.key;
    final label = entry.value;

    await runStep('Generating "$flavor" flavor icon', () async {
      final ribboned = _addRibbon(baseImage, label);
      final outRelativePath = _ribbonedIconPath(basePath, flavor);
      final outFile = File(p.join(projectDir, outRelativePath));
      await outFile.parent.create(recursive: true);
      await outFile.writeAsBytes(img.encodePng(ribboned));

      // Every image_path in the base config pointed at the same source
      // icon (android/ios/web/macos all share one file in this
      // boilerplate) — replacing that literal path swaps the ribboned
      // icon in everywhere the base config used it.
      final flavorConfig = baseConfigContent.replaceAll(basePath, outRelativePath);
      await File(p.join(projectDir, 'flutter_launcher_icons-$flavor.yaml'))
          .writeAsString(flavorConfig);
    });
  }

  // flutter_launcher_icons has a sharp edge: the moment ANY
  // flutter_launcher_icons-<flavor>.yaml file exists, it stops processing
  // the base config entirely and ONLY runs the flavor configs it finds
  // (see its main.dart — `if (!hasFlavors) ... else { only flavors }`).
  // Without a prod config too, prod's icon would silently stop being
  // (re)generated the moment dev/staging configs exist. Verbatim copy of
  // the base config — prod stays plain, no ribbon.
  await runStep('Generating "prod" flavor config (plain, no ribbon)', () async {
    await File(p.join(projectDir, 'flutter_launcher_icons-prod.yaml'))
        .writeAsString(baseConfigContent);
  });

  stdout.writeln('');
  logInfo('Done. Next step:');
  logHint('  Run: dart run flutter_launcher_icons');
  logHint(
    '  (scans for flutter_launcher_icons-*.yaml on its own — one command '
    'regenerates icons for dev, staging, and prod together.)',
  );
}

String _ribbonedIconPath(String basePath, String flavor) {
  final dir = p.dirname(basePath);
  final ext = p.extension(basePath);
  final name = p.basenameWithoutExtension(basePath);
  return p.join(dir, '${name}_$flavor$ext');
}

/// A plain horizontal band across the bottom, not Flutter's diagonal
/// corner-ribbon geometry — deliberately simpler to keep this reliable
/// across arbitrary icon sizes/aspect ratios rather than replicating exact
/// diagonal-banner trigonometry for a purely cosmetic aid.
img.Image _addRibbon(img.Image base, String label) {
  final out = base.clone();
  final bandHeight = (out.height * 0.18).round();
  final bandTop = out.height - bandHeight;

  img.fillRect(
    out,
    x1: 0,
    y1: bandTop,
    x2: out.width,
    y2: out.height,
    color: _ribbonColor,
  );
  img.drawString(
    out,
    label,
    font: img.arial24,
    color: _ribbonTextColor,
    y: bandTop + ((bandHeight - 24) ~/ 2),
  );

  return out;
}
