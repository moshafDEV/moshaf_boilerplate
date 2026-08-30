import 'package:flutter/material.dart';
import 'package:ProjectName/core/constants/colors.dart';
import 'package:ProjectName/core/env/env.dart';

/// Gate for production unlock, per the spec's "optional developer PIN
/// verification". No PIN configured (the boilerplate default — see
/// DEVELOPER_PIN in env.dart) means there's nothing to check against, so the
/// tap-7-times unlock alone is treated as sufficient rather than locking
/// every generated project out until someone sets a secret.
Future<bool> verifyDeveloperPin(BuildContext context) async {
  if (Env.developerPin.isEmpty) return true;

  final controller = TextEditingController();
  final verified = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Developer PIN'),
      content: TextField(
        controller: controller,
        obscureText: true,
        autofocus: true,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(hintText: 'Enter PIN'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () =>
              Navigator.of(dialogContext).pop(controller.text == Env.developerPin),
          child: const Text('Verify'),
        ),
      ],
    ),
  );

  if (verified != true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Incorrect PIN'),
        backgroundColor: kMainDanger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  return verified ?? false;
}
