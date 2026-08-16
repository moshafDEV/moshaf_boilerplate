import 'package:flutter/material.dart';
import 'package:ProjectName/core/constants/colors.dart';
import 'package:ProjectName/core/constants/textstyle.dart';

class TitleSectionWidget extends StatelessWidget {
  const TitleSectionWidget({
    super.key,
    required this.title,
    this.showIconTitle = true,
    this.iconTitlePressed,
    this.textColor = kMainPrimary,
    this.button,
  });

  final String title;
  final bool showIconTitle;
  final VoidCallback? iconTitlePressed;
  final Color textColor;
  final Widget? button;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 28, right: 28),
      child: Row(
        children: [
          Text(title, style: genStyle14Regular.copyWith(color: textColor)),
          if (showIconTitle)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                onPressed: iconTitlePressed,
                icon: const Icon(Icons.navigate_next_rounded, size: 18),
                color: kMainPrimary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                visualDensity: VisualDensity.compact,
                splashRadius: 16,
              ),
            ),
          const Spacer(),
          button ?? const SizedBox.shrink(),
        ],
      ),
    );
  }
}
