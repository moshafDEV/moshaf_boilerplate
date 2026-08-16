import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Constrains bottom-sheet content to the available height (minus keyboard inset) and respects the bottom safe area.
class ModalWrap extends StatelessWidget {
  const ModalWrap({super.key, this.scrollController, required this.child});

  final ScrollController? scrollController;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: 1.sh -
                MediaQuery.of(context).viewInsets.bottom -
                kToolbarHeight,
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: SafeArea(
              top: false,
              left: false,
              right: false,
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}
