import 'package:awesome_extensions/awesome_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ProjectName/core/env/secure_storage_key.dart';
import 'package:ProjectName/core/routes/app_path.dart' show Paths;
import 'package:ProjectName/core/utils/storage_data.dart';

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

  void _navigateToHome() {
    Future.delayed(const Duration(seconds: 2), () async {
      if (mounted) {
        final accessToken = await SecureStorageUtils.getStorage(bearerToken);
        if (accessToken.isNotEmpty) {
          Navigator.of(context).pushReplacementNamed(Paths.home);
          return;
        }

        Navigator.of(context).pushNamedAndRemoveUntil(
          Paths.welcome,
          (route) => false, // Clear navigation stack
        );
      }
    });
  }

  @override
  void dispose() {
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
        color: const Color.fromARGB(255, 169, 216, 255),
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
                        'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2e/MIT_Logo_New.svg/330px-MIT_Logo_New.svg.png',
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
                  backgroundColor: const Color(0xFFECF0F1),
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
