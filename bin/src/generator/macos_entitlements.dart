import 'dart:io';

import 'package:xml/xml.dart';

import '../common/console.dart';

/// flutter_secure_storage on macOS uses Keychain Services, which under App
/// Sandbox (on by default in flutter create's entitlements) throws
/// errSecMissingEntitlement (-34018) on first read/write unless a
/// keychain-access-groups entitlement is present. Adds one matching the
/// app's own bundle id, to both debug and release entitlements.
///
/// Parses the entitlements plist as real XML instead of splicing text at
/// the last `</dict>` — that blind approach assumes there's only ever one
/// `<dict>` in the whole file, which breaks the moment the top-level dict
/// isn't the last one (e.g. a nested dict added by some other entitlement).
/// This finds the actual top-level `<dict>` (the `<plist>` root's own
/// child) and appends structured elements to it, which can't corrupt the
/// document as long as it parses as XML in the first place.
Future<void> addMacosKeychainEntitlement(
  String projectPath,
  String projectName,
) async {
  for (final relativePath in [
    'macos/Runner/DebugProfile.entitlements',
    'macos/Runner/Release.entitlements',
  ]) {
    final file = File('$projectPath/$relativePath');
    if (!file.existsSync()) continue;

    final document = XmlDocument.parse(await file.readAsString());
    final dict = document.rootElement.getElement('dict');
    if (dict == null) {
      logWarn(
          'Warning: could not find <dict> in $relativePath, skipping keychain entitlement.');
      continue;
    }

    final alreadyPresent = dict
        .findElements('key')
        .any((key) => key.innerText == 'keychain-access-groups');
    if (alreadyPresent) continue;

    dict.children.addAll([
      XmlElement.tag('key', children: [XmlText('keychain-access-groups')]),
      XmlElement.tag('array', children: [
        XmlElement.tag('string', children: [
          XmlText('\$(AppIdentifierPrefix)com.example.$projectName'),
        ]),
      ]),
    ]);

    await file
        .writeAsString('${document.toXmlString(pretty: true, indent: '\t')}\n');
  }
}
