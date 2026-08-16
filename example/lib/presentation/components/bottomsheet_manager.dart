import 'dart:async';

import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/material.dart';
import 'package:example/core/constants/colors.dart';
import 'package:example/core/utils/safe_pop.dart';

class BottomSheetManager {
  BottomSheetManager._privateConstructor();

  static final BottomSheetManager _instance =
      BottomSheetManager._privateConstructor();

  static BottomSheetManager get instance => _instance;

  Future<T?> showReusableBottomSheet<T>({
    required BuildContext context,
    required WidgetBuilder bottomSheetBuilder,
    bool enableDrag = false,
    bool isDismissible = true,
    bool isScrollControlled = true,
    double? height,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withAlpha(128),
      builder: (BuildContext context) {
        Widget sheet = GestureDetector(
          onTap: () => safePop(context),
          child: Container(
            height: height,
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () {},
              child: bottomSheetBuilder(context),
            ),
          ).paddingOnly(bottom: MediaQuery.of(context).viewInsets.bottom),
        );

        if (!isDismissible) {
          // Prevent back button dismiss
          sheet = PopScope(canPop: false, child: sheet);
        }

        return sheet;
      },
    );
  }

  Future<T?> showReusableDraggableBottomSheet<T>({
    required BuildContext context,
    required Widget Function(BuildContext, ScrollController)
    draggableSheetBuilder,
    double initialChildSize = 0.25,
    List<double> draggableSnapSizes = const [0.25, 0.5, 0.9],
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: initialChildSize,
          minChildSize: draggableSnapSizes[0],
          maxChildSize: draggableSnapSizes.last,
          snap: true,
          snapSizes: draggableSnapSizes,
          expand: false,
          builder: (context, scrollController) {
            return ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: kMainGrey.withAlpha(50),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Expanded(
                    child: draggableSheetBuilder(context, scrollController),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
