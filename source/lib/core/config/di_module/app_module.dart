import 'package:injectable/injectable.dart';
import 'package:ProjectName/core/http_client/main_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

@module
abstract class AppModule {
  //shared pref instance
  @preResolve
  Future<SharedPreferences> get sharedPref => SharedPreferences.getInstance();

  @lazySingleton
  MainClient get userClient => MainClient();
}
