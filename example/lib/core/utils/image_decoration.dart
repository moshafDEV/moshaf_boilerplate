import 'package:flutter/material.dart';

class ImageUtils {
  static DecorationImage imageDecorationCondition({
    required String image,
    BoxFit fit = BoxFit.cover,
    String placeHolder = 'assets/images/img_banner_event_default.jpg',
  }) => 
  DecorationImage(
    image: image.isEmpty ? AssetImage(placeHolder) : NetworkImage(image) as ImageProvider<Object>,
    fit: fit,
  );
}