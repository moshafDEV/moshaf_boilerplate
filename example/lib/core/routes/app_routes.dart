import 'package:example/presentation/pages/login/login_page.dart';
import 'package:example/presentation/pages/splash_screen/splash_screen.dart';
import 'package:example/presentation/pages/welcome/welcome_page.dart';

import '../../presentation/pages/home/home_page.dart';
import 'app_path.dart';

final appRoutes = {
  Paths.splash: (context) => const SplashScreen(),
  Paths.home: (context) => const MyHomePage(title: 'Home'),
  Paths.login: (context) => LoginPage(),
  Paths.welcome: (context) => const WelcomePage(),
};
