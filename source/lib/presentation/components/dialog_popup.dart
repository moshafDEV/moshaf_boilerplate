import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ProjectName/core/constants/assets.gen.dart';
import 'package:ProjectName/core/constants/colors.dart';
import 'package:ProjectName/core/constants/textstyle.dart';
import 'package:ProjectName/core/utils/safe_pop.dart';
import 'package:ProjectName/presentation/components/button.dart';

class DialogShow {
  Future<void> imagePreview(
    BuildContext context, {
    required String imagePath,
    bool dismissible = true,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: dismissible,
      builder: (BuildContext context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(14.0),
        constraints: BoxConstraints(minWidth: 1.sw, minHeight: 150),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Stack(
          children: [
            // Add blur effect behind the image
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: SizedBox(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 55),
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: SizedBox(
                  width: 1.sw,
                  height: 1.sh > 1.sw ? (1.sh / 2) : 1.sh,
                  child: Image.network(
                    imagePath,
                    width: 1.sw,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 1.sw,
                        height: 200,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    },
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0,
              left: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: () => safePop(context),
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: kMainWhite,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close_rounded, color: kMainBlue, size: 26),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> general(
    BuildContext context, {
    String? imagePath,
    String? title,
    String? description,
    Widget? customBody,
    bool dismissible = true,
    bool hideCancelButton = false,
    bool hideDefaultButton = false,
    String buttonTextYes = 'Yes',
    Color? buttonYesColor,
    Color? textButtonYesColor,
    Function? onTapButtonYes,
    String buttonTextClose = 'Close',
    Function? onTapButtonClose,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: dismissible,
      builder: (BuildContext context) => Dialog(
        insetPadding: const EdgeInsets.all(14.0),
        constraints: BoxConstraints(minWidth: 1.sw, minHeight: 150),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (imagePath != null) ...[
                Image.asset(imagePath, width: 1.sw, fit: BoxFit.contain),
              ],
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title != null) ...[
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: genStyle20Bold.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    if (description != null) ...[
                      8.verticalSpace,
                      Text(
                        description,
                        textAlign: TextAlign.center,
                        style: genStyle16Regular.copyWith(color: kMainPrimary2),
                      ),
                    ],

                    if (customBody != null) ...[12.verticalSpace, customBody],

                    if (!hideDefaultButton) ...[
                      24.verticalSpace,
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!hideCancelButton) ...[
                            Expanded(
                              child: PrimaryButton(
                                text: buttonTextClose,
                                backgroundColor: kMainSecondarySoft,
                                onPressed: () {
                                  safePop(context, false);
                                  onTapButtonClose?.call();
                                },
                                textStyle: genStyle16Bold.copyWith(
                                  color: kMainBlack,
                                ),
                              ),
                            ),
                            12.horizontalSpace,
                          ],
                          Expanded(
                            child: PrimaryButton(
                              text: buttonTextYes,
                              backgroundColor: buttonYesColor ?? kMainBlue,
                              onPressed: () {
                                safePop(context, true);
                                onTapButtonYes?.call();
                              },
                              textStyle: genStyle16Bold.copyWith(
                                color: textButtonYesColor ?? kMainWhite,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> defaultInfo(
    BuildContext context, {
    String? title = 'Information',
    required String message,
    String? imagePath,
  }) {
    return DialogShow().general(
      context,
      imagePath: imagePath ?? Assets.images.imgDefaultInformation,
      title: title,
      description: message,
      buttonTextYes: 'Close',
      hideCancelButton: true,
    );
  }
}
