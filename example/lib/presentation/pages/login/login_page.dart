import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:example/core/config/di_module/init_config.dart';
import 'package:example/core/constants/assets.gen.dart';
import 'package:example/core/constants/textstyle.dart';
import 'package:example/core/routes/app_path.dart';
import 'package:example/core/utils/keyboard_util.dart';
import 'package:example/domain/usecase/login/login.dart';
import 'package:example/domain/usecase/login/profile.dart';
import 'package:example/presentation/bloc/login/login_bloc.dart';
import 'package:example/presentation/components/fade_in_up_animate.dart';
import 'package:example/presentation/pages/login/components/email_input_field.dart';
import 'package:example/presentation/pages/login/components/login_button.dart';
import 'package:example/presentation/pages/login/components/password_input_field.dart';

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
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(Assets.images.imgLanding),
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
                      // Tapping the logo opens About — the entry point into
                      // the developer-mode unlock flow (see about_page.dart),
                      // deliberately not a visible button.
                      child: GestureDetector(
                        onTap: () => context.push(Paths.about),
                        child: ColorFiltered(
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                          child: Image.network(
                            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5d/MIT_logo_2003-2023.svg/330px-MIT_logo_2003-2023.svg.png',
                            width: 120,
                          ),
                        ),
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
                                  'Welcome back',
                                  style: genStyle12Bold.copyWith(fontSize: 20),
                                ),
                                8.verticalSpace,

                                Text(
                                  'Enjoy access to our services, all in one place!',
                                  style: genStyle12Regular.copyWith(fontSize: 16),
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
