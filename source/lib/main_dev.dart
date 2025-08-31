import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:ProjectName/core/config/app_config.dart';
import 'package:ProjectName/main.dart';

void main() {
  FlavorConfig(
    name: "DEV",
    color: Colors.red,
    location: BannerLocation.topStart,
    variables: {"mode": Flavor.dev},
  );
  mainCommon(flavor: Flavor.dev);
}
