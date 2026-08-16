import 'package:flutter/material.dart';
import 'package:ProjectName/core/constants/colors.dart';
import 'package:ProjectName/core/constants/textstyle.dart';

class SeparatorWithTextWidget extends StatelessWidget {
  const SeparatorWithTextWidget({super.key, this.text, this.color});

  final String? text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 230,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Divider(color: kMainGreySoft2, height: 1, thickness: 1),
            ),
            if (text != null)
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  color: color ?? kMainWhite,
                  child: Text(
                    text ?? '',
                    style: genStyle14Regular.copyWith(color: kMainPrimary2),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
