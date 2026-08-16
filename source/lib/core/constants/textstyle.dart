import 'package:flutter/material.dart';

import 'colors.dart';

const defaultFont = TextStyle(fontFamily: 'Manrope', color: kMainPrimary);

/// Builds off [defaultFont] for any size/weight combo, so the type scale
/// isn't limited to the named genStyle* constants below.
TextStyle genStyle(double fontSize, FontWeight fontWeight, {Color? color}) {
  return defaultFont.copyWith(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
  );
}

final genStyle10Regular = genStyle(10, FontWeight.w400);
final genStyle10Medium = genStyle(10, FontWeight.w500);
final genStyle10Bold = genStyle(10, FontWeight.w600);

final genStyle11Regular = genStyle(11, FontWeight.w400);
final genStyle11Medium = genStyle(11, FontWeight.w500);
final genStyle11Bold = genStyle(11, FontWeight.w600);

final genStyle12Regular = genStyle(12, FontWeight.w400);
final genStyle12Medium = genStyle(12, FontWeight.w500);
final genStyle12Bold = genStyle(12, FontWeight.w600);

final genStyle14Regular = genStyle(14, FontWeight.w400);
final genStyle14Medium = genStyle(14, FontWeight.w500);
final genStyle14Bold = genStyle(14, FontWeight.w600);

final genStyle16Regular = genStyle(16, FontWeight.w400);
final genStyle16Medium = genStyle(16, FontWeight.w500);
final genStyle16Bold = genStyle(16, FontWeight.w600);

final genStyle18Regular = genStyle(18, FontWeight.w400);
final genStyle18Medium = genStyle(18, FontWeight.w500);
final genStyle18Bold = genStyle(18, FontWeight.w600);

final genStyle20Regular = genStyle(20, FontWeight.w400);
final genStyle20Medium = genStyle(20, FontWeight.w500);
final genStyle20Bold = genStyle(20, FontWeight.w600);

final genStyle24Regular = genStyle(24, FontWeight.w400);
final genStyle24Medium = genStyle(24, FontWeight.w500);
final genStyle24Bold = genStyle(24, FontWeight.w600);

final genStyle28Regular = genStyle(28, FontWeight.w400);
final genStyle28Medium = genStyle(28, FontWeight.w500);
final genStyle28Bold = genStyle(28, FontWeight.w600);

final genStyle32Regular = genStyle(32, FontWeight.w400);
final genStyle32Medium = genStyle(32, FontWeight.w500);
final genStyle32Bold = genStyle(32, FontWeight.w600);

final genStyle40Regular = genStyle(40, FontWeight.w400);
final genStyle40Medium = genStyle(40, FontWeight.w500);
final genStyle40Bold = genStyle(40, FontWeight.w600);
