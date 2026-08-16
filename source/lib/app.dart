import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ProjectName/core/routes/app_router.dart';
import 'package:ProjectName/core/utils/theme_data.dart';
import 'package:flutter_flavor/flutter_flavor.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return FlavorBanner(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'ProjectName',
        routerConfig: appRouter,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        theme: themeData,
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
