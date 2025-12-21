import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:example_app/core/config/app_config.dart';
import 'package:example_app/main.dart';

void main() {
  FlavorConfig(variables: {"mode": Flavor.prod});
  mainCommon(flavor: Flavor.prod);
}
