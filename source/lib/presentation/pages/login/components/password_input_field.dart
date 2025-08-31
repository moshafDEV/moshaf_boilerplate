import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ProjectName/core/constants/textstyle.dart';
import 'package:ProjectName/presentation/bloc/login/login_bloc.dart';
import 'package:ProjectName/presentation/components/text_field_custom_widget.dart';

class PasswordInputField extends StatefulWidget {
  const PasswordInputField({super.key});

  @override
  State<PasswordInputField> createState() => _PasswordInputFieldState();
}

class _PasswordInputFieldState extends State<PasswordInputField> {
  final TextEditingController textFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listenWhen: (previous, current) => previous.password != current.password,
      listener: (context, state) {
        textFieldController.text = state.password.value;
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        buildWhen: (previous, current) => previous.password != current.password,
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFieldCustomWidget(
                fieldController: textFieldController,
                isRequired: true,
                isPassword: true,
                labelText: 'Password',
                hintText: 'Masukan password anda',
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.done,
                invalidMessage: state.password.invalidMessage,
                onChanged: (value) {
                  context.read<LoginBloc>().add(
                    LoginEvent.onPasswordChanged(value),
                  );
                },
              ),

              8.verticalSpace,

              _buildForgotPasswordLink(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildForgotPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: _handleForgotPassword,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text('Lupa Password', style: blue14Medium),
      ),
    );
  }

  void _handleForgotPassword() {
    HapticFeedback.lightImpact();
    Navigator.of(context).pushNamed('/forgot-password');
  }
}
