import 'package:ProjectName/core/env/env.dart';

enum Flavor {
  dev(0),
  prod(1);

  const Flavor(this.level);
  final int level;
}

class AppConfig {
  final Flavor flavor;
  final String apiUrl;
  // final MessagingAuth messagingAuth;

  static AppConfig? _instance;

  factory AppConfig() {
    if (_instance == null) {
      throw UnimplementedError('AppConfig must be initialized first.');
    }

    return _instance!;
  }

  static Future<void> initialize({required Flavor flavor}) async {
    // setup Firebase
    // FirebaseApp firebaseApp = await Firebase.initializeApp();
    // debugPrint(">> Firebase Project ID:  ${firebaseApp.options.projectId}");

    // setup Crashlytics
    // await CrashlyticsLogger.init();

    // setup flipper
    // Flipper.init();

    // setup FCM
    // final fcmToken = await FirebaseMessaging.instance.getToken();
    // log(fcmToken ?? '', name: 'FCM Token');

    // setup remoteConfig
    // try {
    //   await RemoteConfig.initialize();
    // } catch (e) {
    //   if (kDebugMode) {
    //     print('remote config fetch failed');
    //   }
    // }
    // final remoteConfig = RemoteConfig.instance;

    // get base url
    final apiUrl = Env.apiUrl;

    _instance = AppConfig._internal(flavor: flavor, apiUrl: apiUrl);
  }

  AppConfig._internal({required this.flavor, required this.apiUrl});

  static AppConfig get instance => AppConfig();

  static bool get isDev => instance.flavor == Flavor.dev;
  static bool get isProd => instance.flavor == Flavor.prod;
}
