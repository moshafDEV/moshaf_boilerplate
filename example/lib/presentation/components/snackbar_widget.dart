import 'package:flutter/material.dart';
import 'package:example/core/constants/colors.dart';

enum SnackBarType { success, error, info }

/// Prevents rapid repeated calls (e.g. several failing requests firing
/// near-simultaneously) from stacking multiple snackbars on screen.
class SnackBarDebouncer {
  static DateTime? _lastShown;

  static bool canShow(Duration debounceDuration) {
    final now = DateTime.now();
    if (_lastShown == null || now.difference(_lastShown!) > debounceDuration) {
      _lastShown = now;
      return true;
    }
    return false;
  }
}

void showCustomSnackBar(
  BuildContext context,
  String message,
  SnackBarType type, {
  Duration debounceDuration = const Duration(seconds: 1),
}) {
  if (!SnackBarDebouncer.canShow(debounceDuration)) return;

  Color backgroundColor;
  Icon icon;

  switch (type) {
    case SnackBarType.success:
      backgroundColor = kMainSuccess;
      icon = const Icon(Icons.check_circle, color: kMainWhite);
      break;
    case SnackBarType.error:
      backgroundColor = kMainDanger;
      icon = const Icon(Icons.error, color: kMainWhite);
      break;
    case SnackBarType.info:
      backgroundColor = kMainInfo;
      icon = const Icon(Icons.info, color: kMainWhite);
      break;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          icon,
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
