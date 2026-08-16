import 'package:injectable/injectable.dart';
import 'package:ProjectName/core/analytics/analytic.dart';
import 'package:ProjectName/core/analytics/firebase_analytic.dart';
import 'package:ProjectName/core/analytics/no_op_analytic.dart';
import 'package:ProjectName/core/config/firebase_support.dart';
import 'package:ProjectName/core/env/env.dart';
import 'package:ProjectName/core/http_client/main_client.dart';
// import 'package:shared_preferences/shared_preferences.dart';

@module
abstract class AppModule {
  //shared pref instance
  // @preResolve
  // Future<SharedPreferences> get sharedPref => SharedPreferences.getInstance();

  @lazySingleton
  MainClient get userClient => MainClient();

  // A factory getter (not @LazySingleton on FirebaseAnalytic itself) so the
  // choice is made at runtime from Env.enableFirebase and platform support,
  // instead of always constructing FirebaseAnalytic — which would touch
  // FirebaseAnalytics.instance even where Firebase was never initialized
  // (Windows/Linux ship no analytics implementation at all).
  @lazySingleton
  Analytic get analytic => (Env.enableFirebase && isFirebaseSupported)
      ? FirebaseAnalytic()
      : NoOpAnalytic();
}
