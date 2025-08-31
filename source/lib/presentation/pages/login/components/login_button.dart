import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ProjectName/core/constants/textstyle.dart';
import 'package:ProjectName/core/routes/app_path.dart';
import 'package:ProjectName/presentation/bloc/login/login_bloc.dart';
import 'package:ProjectName/presentation/components/button.dart';
import 'package:ProjectName/presentation/components/snackbar_widget.dart';

class LoginButton extends StatefulWidget {
  const LoginButton({super.key});

  @override
  State<LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton> {
  final TextEditingController textFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listenWhen: (previous, current) =>
          previous.isLoading != current.isLoading,
      listener: (context, state) {
        if (state.errorResponseMessage.isNotEmpty) {
          showCustomSnackBar(
            context,
            state.errorResponseMessage,
            SnackBarType.error,
          );
          return;
        }

        if (state.successLogin) {
          Navigator.of(context).pushReplacementNamed(Paths.home);
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        buildWhen: (previous, current) =>
            previous.isLoading != current.isLoading,
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PrimaryButton(
                text: 'Masuk',
                onPressed: () {
                  context.read<LoginBloc>().add(LoginEvent.onSubmit());
                },
                width: double.infinity,
                height: 45,
                textStyle: white16Bold,
              ),

              24.verticalSpace,

              _buildRegisterLink(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Center(
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(text: 'Belum punya akun? ', style: black14Regular),
            TextSpan(
              text: 'Daftar di sini.',
              style: blue14Medium,
              recognizer: TapGestureRecognizer()..onTap = _handleRegister,
            ),
          ],
        ),
      ),
    );
  }

  void _handleRegister() {
    HapticFeedback.lightImpact();
    Navigator.of(context).pushNamed(Paths.register);
  }
}
