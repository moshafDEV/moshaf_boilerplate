import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/material.dart';
import 'package:example/core/constants/colors.dart';
import 'package:example/core/constants/textstyle.dart';

class SmallChipGenWidget extends StatelessWidget {
  const SmallChipGenWidget({
    super.key,
    required this.text,
    this.textStyle,
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    this.colors = const [kMainPrimary, kMainInfo],
    this.borderRadius = const BorderRadius.all(Radius.circular(4)),
  });

  final String text;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry padding;
  final List<Color> colors;
  final BorderRadiusGeometry borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.bottomCenter,
          end: Alignment.topRight,
        ),
        borderRadius: borderRadius,
      ),
      child: Text(
        text,
        style: textStyle ?? genStyle10Bold.copyWith(color: kMainWhite),
      ),
    );
  }
}

class ChipGenWidget extends StatelessWidget {
  const ChipGenWidget({
    super.key,
    required this.label,
    this.styleLabel,
    this.customBgColor,
    this.isSelected = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    this.radius = const BorderRadius.all(Radius.circular(22)),
    this.onTap,
  });

  final String label;
  final TextStyle? styleLabel;
  final Color? customBgColor;
  final bool isSelected;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        label,
        style:
            styleLabel ??
            genStyle14Medium.copyWith(
              color: isSelected ? kMainWhite : kMainPrimary,
            ),
        overflow: TextOverflow.ellipsis,
      ),
      backgroundColor: customBgColor ?? (isSelected ? kMainInfo : kMainWhite),
      shape: RoundedRectangleBorder(borderRadius: radius),
      padding: padding,
      labelPadding: EdgeInsets.zero,
      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      side: BorderSide.none,
    ).onTap(() {
      onTap?.call();
    });
  }
}
