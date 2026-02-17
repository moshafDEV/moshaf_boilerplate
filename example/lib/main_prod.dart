import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:example/core/config/app_config.dart';
import 'package:example/main.dart';

void main() {
  FlavorConfig(variables: {"mode": Flavor.prod});
  mainCommon(flavor: Flavor.prod);
}
