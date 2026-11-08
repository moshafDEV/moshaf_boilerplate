import 'package:flutter/material.dart';
import 'package:example/core/constants/colors.dart';
import 'package:example/core/constants/textstyle.dart';
import 'package:example/core/env/env.dart';

/// PIN gate for unlocking Developer Tools. Without `DEVELOPER_PIN` in
/// `.env.<flavor>`, the 7-tap unlock alone is enough.
Future<bool> verifyDeveloperPin(BuildContext context) async {
  final pin = Env.developerPin;
  if (pin.isEmpty) return true;

  final verified = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _DeveloperPinDialog(pin: pin),
  );
  return verified ?? false;
}

/// The dialog state owns the controller: it is disposed after the close
/// animation finishes, not when `showDialog` returns (the TextField is
/// still being built).
class _DeveloperPinDialog extends StatefulWidget {
  const _DeveloperPinDialog({required this.pin});

  final String pin;

  @override
  State<_DeveloperPinDialog> createState() => _DeveloperPinDialogState();
}

class _DeveloperPinDialogState extends State<_DeveloperPinDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _verify() {
    if (_controller.text == widget.pin) {
      Navigator.of(context).pop(true);
      return;
    }
    // wrong pin: stay in the dialog and clear the field for a quick retry
    _controller.clear();
    setState(() => _error = 'Incorrect PIN');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Developer PIN'),
      content: TextField(
        controller: _controller,
        obscureText: true,
        autofocus: true,
        keyboardType: TextInputType.number,
        onSubmitted: (_) => _verify(),
        decoration: InputDecoration(
          hintText: 'Enter PIN',
          errorText: _error,
          errorStyle: genStyle12Regular.copyWith(color: kMainDanger),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(onPressed: _verify, child: const Text('Verify')),
      ],
    );
  }
}
