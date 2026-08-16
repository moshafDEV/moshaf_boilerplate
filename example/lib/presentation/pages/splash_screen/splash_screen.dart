import 'dart:async';

import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:example/core/constants/colors.dart';
import 'package:example/core/routes/app_path.dart' show Paths;

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _loadingAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _navigateToHome();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeInOut),
      ),
    );

    _loadingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  Timer? _navigationTimer;

  void _navigateToHome() {
    _navigationTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;

      // Always proceeds to the normal cold-start entry point — go_router's
      // `redirect` (app_router.dart) is the single source of truth for the
      // auth check, and fast-forwards an already-authenticated user
      // straight to Paths.home instead.
      context.go(Paths.welcome);
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 1,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      body: Container(
        width: screenSize.width,
        height: screenSize.height,
        color: kMainSecondary.withAlpha(20),
        child: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 42),
                      child: Image.network(
                        'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5d/MIT_logo_2003-2023.svg/330px-MIT_logo_2003-2023.svg.png',
                        width: 150,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 60,
                    left: 0,
                    right: 0,
                    child: _buildLoadingIndicator(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 200,
            height: 1,
            child: AnimatedBuilder(
              animation: _loadingAnimation,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: _loadingAnimation.value,
                  backgroundColor: kMainSecondary,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF4A90E2),
                  ),
                  minHeight: 4,
                );
              },
            ),
          ),
        ],
      ),
    ).paddingOnly(bottom: 24);
  }
}
