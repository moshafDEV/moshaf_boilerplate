import 'package:example_app/presentation/pages/login/login_page.dart';
import 'package:example_app/presentation/pages/splash_screen/splash_screen.dart';
import 'package:example_app/presentation/pages/welcome/welcome_page.dart';

import '../../presentation/pages/home/home_page.dart';
import 'app_path.dart';

final appRoutes = {
  Paths.splash: (context) => const SplashScreen(),
  Paths.home: (context) => const MyHomePage(title: 'Home'),
  Paths.login: (context) => LoginPage(),
  Paths.welcome: (context) => const WelcomePage(),
};
