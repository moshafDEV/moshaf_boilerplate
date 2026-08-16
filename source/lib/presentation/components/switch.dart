import 'package:flutter/material.dart';
import 'package:ProjectName/core/constants/colors.dart';

class SwitchWidget extends StatefulWidget {
  const SwitchWidget({super.key, this.value = false, this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  State<SwitchWidget> createState() => _SwitchWidgetState();
}

class _SwitchWidgetState extends State<SwitchWidget> {
  @override
  Widget build(BuildContext context) {
    return Switch.adaptive(
      value: widget.value,
      onChanged: (val) {
        widget.onChanged?.call(val);
      },
      thumbColor: WidgetStateProperty.all(kMainWhite),
      trackOutlineWidth: WidgetStateProperty.all(0),
      inactiveTrackColor: kMainGreySoft,
      activeTrackColor: kMainBlue,
    );
  }
}
