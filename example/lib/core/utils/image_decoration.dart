import 'package:flutter/material.dart';

class ImageUtils {
  static DecorationImage imageDecorationCondition({
    required String image,
    BoxFit fit = BoxFit.cover,
    String placeHolder = 'assets/images/img_banner_event_default.jpg',
  }) {
    if (image.isEmpty) {
      return DecorationImage(image: AssetImage(placeHolder), fit: fit);
    }

    // Separate returns, not a ternary: NetworkImage/AssetImage's differing generic type breaks ternary inference.
    if (image.startsWith('http://') || image.startsWith('https://')) {
      return DecorationImage(image: NetworkImage(image), fit: fit);
    }
    return DecorationImage(image: AssetImage(image), fit: fit);
  }
}
