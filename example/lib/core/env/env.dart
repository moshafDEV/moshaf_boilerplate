import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'APP_NAME', obfuscate: true)
  static String appName = _Env.appName;

  @EnviedField(varName: 'API_URL', obfuscate: true)
  static String apiUrl = _Env.apiUrl;

  // Not obfuscated: a feature flag, not a secret. Gates Firebase
  // initialization — see AppConfig.initialize() and AppModule.analytic.
  @EnviedField(varName: 'ENABLE_FIREBASE', defaultValue: false)
  static bool enableFirebase = _Env.enableFirebase;

  // Gates production developer-mode unlock (see developer_pin_gate.dart).
  // Empty (the default — unset in .env) means no PIN is configured, so the
  // tap-7-times unlock alone is treated as sufficient.
  @EnviedField(varName: 'DEVELOPER_PIN', obfuscate: true, defaultValue: '')
  static String developerPin = _Env.developerPin;
}
