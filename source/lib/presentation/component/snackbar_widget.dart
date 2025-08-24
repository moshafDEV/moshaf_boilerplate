import 'package:flutter/material.dart';

enum SnackBarType { success, error }

void showCustomSnackBar(
  BuildContext context,
  String message,
  SnackBarType type,
) {
  Color backgroundColor;
  Icon icon;

  // Tentukan warna dan ikon berdasarkan tipe
  switch (type) {
    case SnackBarType.success:
      backgroundColor = Colors.green;
      icon = Icon(Icons.check_circle, color: Colors.white);
      break;
    case SnackBarType.error:
      backgroundColor = Colors.red;
      icon = Icon(Icons.error, color: Colors.white);
      break;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          icon,
          SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
