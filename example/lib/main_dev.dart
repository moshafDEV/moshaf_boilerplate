import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:example_app/core/config/app_config.dart';
import 'package:example_app/main.dart';

void main() {
  FlavorConfig(
    name: "DEV",
    color: Colors.red,
    location: BannerLocation.topStart,
    variables: {"mode": Flavor.dev},
  );
  mainCommon(flavor: Flavor.dev);
}
