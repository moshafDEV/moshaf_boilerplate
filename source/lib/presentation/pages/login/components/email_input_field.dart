import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ProjectName/presentation/bloc/login/login_bloc.dart';
import 'package:ProjectName/presentation/components/text_field_custom_widget.dart';

class EmailInputField extends StatefulWidget {
  const EmailInputField({super.key});

  @override
  State<EmailInputField> createState() => _EmailInputFieldState();
}

class _EmailInputFieldState extends State<EmailInputField> {
  final TextEditingController textFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listenWhen: (previous, current) => previous.email != current.email,
      listener: (context, state) {
        // textFieldController.text = state.email.value;
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        buildWhen: (previous, current) => previous.email != current.email,
        builder: (context, state) {
          return TextFieldCustomWidget(
            fieldController: textFieldController,
            isRequired: true,
            labelText: 'Email',
            hintText: 'Masukan alamat email anda',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            invalidMessage: state.email.invalidMessage,
            onChanged: (value) {
              context.read<LoginBloc>().add(LoginEvent.onEmailChanged(value));
            },
          );
        },
      ),
    );
  }
}
