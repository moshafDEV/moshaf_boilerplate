import 'package:flutter/material.dart';
import 'package:ProjectName/core/constants/colors.dart';
import 'package:ProjectName/core/constants/textstyle.dart';

/// Shared professional key-value dialog for developer-tools screens (see
/// App Information) — scrollable and height-capped so it degrades cleanly
/// if a caller ever passes a longer row list.
Future<void> showDeveloperInfoDialog(
  BuildContext context, {
  required String title,
  required IconData icon,
  required Color iconColor,
  required Map<String, String> rows,
}) {
  return showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: kMainWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 14),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: iconColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(title, style: genStyle16Bold)),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                    splashRadius: 20,
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: kMainGreySoft),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
                itemCount: rows.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: kMainGreySoft),
                itemBuilder: (context, index) {
                  final entry = rows.entries.elementAt(index);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            entry.key,
                            style: genStyle12Regular.copyWith(color: kMainGrey),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          flex: 2,
                          // Selectable — copying an API URL or version string
                          // for a bug report is the whole point of this dialog.
                          child: SelectableText(
                            entry.value,
                            style: genStyle12Medium,
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
