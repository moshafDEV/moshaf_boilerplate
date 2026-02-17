import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
// import 'package:gtm/gtm.dart';
import 'package:injectable/injectable.dart';
import 'package:example/core/env/secure_storage_key.dart';
import 'package:example/core/services/navigation_service.dart';
import 'package:example/core/utils/storage_data.dart';

import 'init_config.config.dart';

final getIt = GetIt.instance;
// final gtm = Gtm.instance;

@InjectableInit(
  initializerName: r'$initGetIt',
  preferRelativeImports: true,
  asExtension: false,
)
Future<void> initConfig() async {
  // Initialize any configurations or services here
  await configureDependencies();

  // Initialize secure storage
  await initSecureStorage();

  await SecureStorageUtils.setStorage(localeLangId, 'id');

  getIt.registerLazySingleton<NavigationService>(() => NavigationService());
}

Future<void> configureDependencies() async => await $initGetIt(getIt);
Future<void> initSecureStorage() async {
  const FlutterSecureStorage secureStorage = FlutterSecureStorage();
  getIt.registerSingleton<FlutterSecureStorage>(secureStorage);
}
