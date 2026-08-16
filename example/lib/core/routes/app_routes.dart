import 'package:go_router/go_router.dart';
import 'package:example/presentation/pages/forgot_password/forgot_password_page.dart';
import 'package:example/presentation/pages/login/login_page.dart';
import 'package:example/presentation/pages/register/register_page.dart';
import 'package:example/presentation/pages/splash_screen/splash_screen.dart';
import 'package:example/presentation/pages/welcome/welcome_page.dart';

import '../../presentation/pages/home/home_page.dart';
import 'app_path.dart';

final List<RouteBase> appRoutes = [
  GoRoute(
    path: Paths.splash,
    builder: (context, state) => const SplashScreen(),
  ),
  GoRoute(
    path: Paths.home,
    builder: (context, state) => const MyHomePage(title: 'Home'),
  ),
  GoRoute(
    path: Paths.login,
    builder: (context, state) => LoginPage(),
  ),
  GoRoute(
    path: Paths.welcome,
    builder: (context, state) => const WelcomePage(),
  ),
  GoRoute(
    path: Paths.register,
    builder: (context, state) => const RegisterPage(),
  ),
  GoRoute(
    path: Paths.forgotPassword,
    builder: (context, state) => const ForgotPasswordPage(),
  ),
];
