import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:example/core/constants/api_path_constant.dart';
import 'package:example/core/constants/colors.dart';
import 'package:example/core/constants/textstyle.dart';
import 'package:example/domain/entities/feature_flags/feature_flag_state.dart';

const _jsonEncoder = JsonEncoder.withIndent('  ');

/// Both the on-screen accordion and the "copy expected response" button
/// derive from FeatureFlagState.toJson() — the single source of truth for
/// the API contract. Add a module there once (see feature_flag_state.dart)
/// and it shows up here automatically; nothing in this file needs touching.
Future<void> showFeatureFlagsDialog(
  BuildContext context,
  FeatureFlagState state,
) {
  final expectedResponse = state.toJson();
  return showDialog(
    context: context,
    builder: (_) => _FeatureFlagsDialog(
      sections: _sectionsFrom(expectedResponse),
      expectedResponse: expectedResponse,
    ),
  );
}

/// Reshapes the raw `{"features": {"auth": {...}, ...}}` JSON into
/// readable labels for display — see [_prettify].
Map<String, Map<String, bool>> _sectionsFrom(Map<String, dynamic> expectedResponse) {
  final features = expectedResponse['features'] as Map<String, dynamic>;
  return features.map((module, flags) {
    final prettyFlags = (flags as Map<String, dynamic>).map(
      (key, value) => MapEntry(_prettify(key), value as bool),
    );
    return MapEntry(_prettify(module), prettyFlags);
  });
}

/// Sentence case, not Title Case — "forgot_password_enabled" becomes
/// "Forgot password enabled" (only the first word capitalized), matching
/// how these labels read as plain English rather than a heading.
String _prettify(String snakeCase) {
  final words = snakeCase.split('_').where((w) => w.isNotEmpty).toList();
  if (words.isEmpty) return snakeCase;
  final first = words.first;
  final rest = words.skip(1).join(' ');
  final capitalizedFirst = first[0].toUpperCase() + first.substring(1);
  return rest.isEmpty ? capitalizedFirst : '$capitalizedFirst $rest';
}

class _FeatureFlagsDialog extends StatelessWidget {
  final Map<String, Map<String, bool>> sections;
  final Map<String, dynamic> expectedResponse;

  const _FeatureFlagsDialog({required this.sections, required this.expectedResponse});

  @override
  Widget build(BuildContext context) {
    final totalFlags = sections.values.fold<int>(0, (n, m) => n + m.length);

    return Dialog(
      backgroundColor: kMainWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Header(totalFlags: totalFlags, expectedResponse: expectedResponse),
            const Divider(height: 1, color: kMainGreySoft),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: sections.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: kMainGreySoft),
                itemBuilder: (context, index) {
                  final entry = sections.entries.elementAt(index);
                  return _ModuleSection(module: entry.key, flags: entry.value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int totalFlags;
  final Map<String, dynamic> expectedResponse;

  const _Header({required this.totalFlags, required this.expectedResponse});

  void _copyExpectedResponse(BuildContext context) {
    final text = 'GET ${ApiPath.UFeatureFlags}\n\n'
        '${_jsonEncoder.convert(expectedResponse)}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Expected response copied'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 12, 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: kMainInfo.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.flag_rounded, color: kMainInfo, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Feature Flags', style: genStyle16Bold),
                const SizedBox(height: 2),
                Text('$totalFlags flags', style: genStyle12Regular.copyWith(color: kMainGrey)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 18),
            tooltip: 'Copy expected API response',
            onPressed: () => _copyExpectedResponse(context),
            splashRadius: 20,
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 20),
            onPressed: () => Navigator.of(context).pop(),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
}

class _ModuleSection extends StatelessWidget {
  final String module;
  final Map<String, bool> flags;

  const _ModuleSection({required this.module, required this.flags});

  @override
  Widget build(BuildContext context) {
    final onCount = flags.values.where((v) => v).length;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 20),
        childrenPadding: EdgeInsets.zero,
        title: Text(module, style: genStyle14Bold),
        subtitle: Text(
          '$onCount/${flags.length} on',
          style: genStyle12Regular.copyWith(color: kMainGrey),
        ),
        children: flags.entries.map((e) => _FlagRow(label: e.key, value: e.value)).toList(),
      ),
    );
  }
}

class _FlagRow extends StatelessWidget {
  final String label;
  final bool value;

  const _FlagRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final color = value ? kMainSuccess : kMainGrey;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: genStyle12Regular)),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              value ? 'ON' : 'OFF',
              style: genStyle12Bold.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
