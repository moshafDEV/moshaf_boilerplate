import 'package:ProjectName/presentation/pages/login/login_page.dart';
import 'package:ProjectName/presentation/pages/splash_screen/splash_screen.dart';
import 'package:ProjectName/presentation/pages/welcome/welcome_page.dart';

import '../../presentation/pages/home/home_page.dart';
import 'app_path.dart';

final appRoutes = {
  Paths.splash: (context) => const SplashScreen(),
  Paths.home: (context) => const MyHomePage(title: 'Home'),
  Paths.login: (context) => LoginPage(),
  Paths.welcome: (context) => const WelcomePage(),
};
