import 'package:example/core/config/app_config.dart';
import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';

void main() {
  FlavorConfig(
    name: "DEV",
    color: Colors.red,
    location: BannerLocation.bottomEnd,
    variables: {"mode": Flavor.dev},
  );
  mainCommon(flavor: Flavor.dev);
}
