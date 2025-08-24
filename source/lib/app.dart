import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:ProjectName/core/config/di_module/init_config.dart';
import 'package:ProjectName/core/routes/app_path.dart';
import 'package:ProjectName/core/routes/app_routes.dart';
import 'package:ProjectName/core/services/navigation_service.dart';
import 'package:ProjectName/core/utils/theme_data.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final RouteObserver<ModalRoute<void>> routeObserver =
        RouteObserver<ModalRoute<void>>();

    return FlavorBanner(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'PPID Injourney',
        navigatorKey: getIt<NavigationService>().navigatorKey,
        routes: appRoutes,
        navigatorObservers: [ChuckerFlutter.navigatorObserver, routeObserver],
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        theme: themeData,
        initialRoute: Paths.splash,
        builder: (context, child) {
          var mediaQuery = MediaQuery.of(context);
          double textScaleFactor;

          if (mediaQuery.size.height > 400) {
            textScaleFactor = 1.0;
          } else {
            textScaleFactor = 0.96;
          }

          return MediaQuery(
            data: mediaQuery.copyWith(
              textScaler: TextScaler.linear(textScaleFactor),
            ),
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
