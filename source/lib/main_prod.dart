import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:ProjectName/core/config/app_config.dart';
import 'package:ProjectName/main.dart';

void main() {
  FlavorConfig(variables: {"mode": Flavor.prod});
  mainCommon(flavor: Flavor.prod);
}
