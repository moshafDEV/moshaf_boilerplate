import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/colors.dart';
import '../constants/textstyle.dart';

final themeData = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: Colors.white,
  colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue),
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  ),
  datePickerTheme: DatePickerThemeData(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    headerForegroundColor: Colors.black,
    headerBackgroundColor: Colors.white,
    cancelButtonStyle: ButtonStyle(
      foregroundColor: WidgetStateProperty.all(Colors.black),
    ),
    confirmButtonStyle: ButtonStyle(
      foregroundColor: WidgetStateProperty.all(Colors.black),
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    hintStyle: TextStyle(fontSize: 12),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: colorRed),
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: colorRed),
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: colorNeutralGrey),
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: colorBlue),
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 0,
    scrolledUnderElevation: 0,
    surfaceTintColor: Colors.white,
    centerTitle: true,
    titleTextStyle: black14Medium.copyWith(
      fontWeight: FontWeight.w500,
      color: colorNeutralBlack,
      fontSize: 14,
    ),
    systemOverlayStyle: const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ),
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    // backgroundColor: Colors.white, --> optional if you want to change the background color
    surfaceTintColor: Colors.white,
  ),
  expansionTileTheme: const ExpansionTileThemeData(
    iconColor: colorGrey,
    textColor: colorGrey,
    collapsedIconColor: colorGrey,
    tilePadding: EdgeInsets.zero,
  ),
  chipTheme: ChipThemeData(
    backgroundColor: colorRedBadgeDiscount,
    labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
    secondaryLabelStyle: TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.bold,
    ),
    padding: EdgeInsets.symmetric(vertical: 4.h),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: colorBlue,
      foregroundColor: colorWhite,
      textStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
    ),
  ),
  dialogTheme: const DialogThemeData(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
  ),
  checkboxTheme: CheckboxThemeData(
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return colorBlue;
      }
      return colorWhite;
    }),
  ),
  iconButtonTheme: IconButtonThemeData(
    style: ButtonStyle(padding: WidgetStateProperty.all(EdgeInsets.zero)),
  ),
  fontFamily: 'Poppins',
);
