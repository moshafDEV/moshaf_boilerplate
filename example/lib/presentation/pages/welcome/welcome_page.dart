import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:example/core/constants/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:example/core/constants/textstyle.dart';
import 'package:example/core/env/secure_storage_key.dart';
import 'package:example/core/routes/app_path.dart';
import 'package:example/core/utils/storage_data.dart';
import 'package:example/presentation/components/button.dart';
import 'package:example/presentation/components/fade_in_up_animate.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 1,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: Container(
        width: 1.sw,
        height: 1.sh,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/img_landing.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withAlpha(30),
                Colors.black.withAlpha(50),
                Colors.black.withAlpha(70),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: FadeInUpAnimate(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    40.verticalSpace,
                    _buildLogo(),
                    18.verticalSpace,
                    _buildMainContent(),
                    const Spacer(flex: 1),
                    _buildStartButton(context),
                    40.verticalSpace,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ColorFiltered(
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          child: Image.network(
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5d/MIT_logo_2003-2023.svg/330px-MIT_logo_2003-2023.svg.png',
            width: 90,
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main title
        Text(
          'Welcome',
          style: genStyle16Bold.copyWith(
            fontSize: 36,
            height: 1.2,
            color: kMainWhite,
            letterSpacing: -0.5,
          ),
        ),

        24.verticalSpace,

        // Description text
        Text(
          'MOSHAF Boilerplate',
          style: genStyle16Regular.copyWith(color: kMainWhite),
        ),
      ],
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return PrimaryButton(
      text: 'Mulai',
      onPressed: () => _navigateToNextPage(context),
      width: double.infinity,
      height: 40,
      textStyle: genStyle14Bold.copyWith(color: kMainWhite),
    );
  }

  void _navigateToNextPage(BuildContext context) async {
    final accessToken = await SecureStorageUtils.getStorage(bearerToken);
    if (accessToken.isNotEmpty) {
      Navigator.of(context).pushReplacementNamed(Paths.home);
      return;
    }
    Navigator.of(context).pushReplacementNamed(Paths.login);
  }
}
