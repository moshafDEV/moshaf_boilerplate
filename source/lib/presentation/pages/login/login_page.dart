import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ProjectName/core/config/di_module/init_config.dart';
import 'package:ProjectName/core/constants/textstyle.dart';
import 'package:ProjectName/core/utils/keyboard_util.dart';
import 'package:ProjectName/domain/usecase/login/login.dart';
import 'package:ProjectName/domain/usecase/login/profile.dart';
import 'package:ProjectName/presentation/bloc/login/login_bloc.dart';
import 'package:ProjectName/presentation/component/fade_in_up_animate.dart';
import 'package:ProjectName/presentation/pages/login/components/email_input_field.dart';
import 'package:ProjectName/presentation/pages/login/components/login_button.dart';
import 'package:ProjectName/presentation/pages/login/components/password_input_field.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          LoginBloc(getIt<LoginUsecase>(), getIt<ProfileUsecase>()),
      child: const LoginPageContent(),
    );
  }
}

class LoginPageContent extends StatelessWidget {
  const LoginPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => KeyboardUtils.dismissKeyboard(context),
      child: Scaffold(
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
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/img_landing.jpg'),
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter, // Set image position to top
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Container(
                constraints: BoxConstraints(maxHeight: 1.sh),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    60.verticalSpace,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 26),
                      child: SvgPicture.asset(
                        'assets/svg/logo.svg',
                        height: 80, // Adjust as needed
                        fit: BoxFit.contain,
                      ),
                    ),
                    40.verticalSpace,
                    Flexible(
                      child: FadeInUpAnimate(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                8.verticalSpace,

                                Text(
                                  'Selamat datang',
                                  style: black12Bold.copyWith(fontSize: 20),
                                ),
                                8.verticalSpace,

                                Text(
                                  'Nikmati akses layanan dalam satu genggaman!',
                                  style: black12Regular.copyWith(fontSize: 16),
                                ),

                                24.verticalSpace,

                                EmailInputField(),

                                14.verticalSpace,

                                PasswordInputField(),
                                32.verticalSpace,

                                LoginButton(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
