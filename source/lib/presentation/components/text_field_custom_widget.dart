import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ProjectName/core/constants/colors.dart';
import 'package:ProjectName/core/constants/textstyle.dart';

class TextFieldCustomWidget extends StatelessWidget {
  final TextEditingController fieldController;
  final bool isPassword;
  final bool isRequired;
  final String labelText;
  final String hintText;
  final TextInputType keyboardType;
  final bool isReadOnly;
  final TextInputAction textInputAction;
  final String? invalidMessage;
  final Function(String)? onChanged;
  final FormFieldValidator<String>? validator;
  final Function(String)? onFieldSubmitted;

  const TextFieldCustomWidget({
    super.key,
    required this.fieldController,
    required this.labelText,
    required this.hintText,
    required this.keyboardType,
    this.isRequired = false,
    this.isPassword = false,
    this.isReadOnly = false,
    this.textInputAction = TextInputAction.done,
    this.invalidMessage,
    this.onChanged,
    this.onFieldSubmitted,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: labelText,
                style: darkBlue10Medium.copyWith(fontSize: 16),
              ),
              if (isRequired)
                TextSpan(
                  text: ' *',
                  style: darkBlue10Medium.copyWith(
                    fontSize: 16,
                    color: kMainRed,
                  ),
                ),
            ],
          ),
        ),
        8.verticalSpace,
        _TextFormFieldStateless(
          fieldController: fieldController,
          isPassword: isPassword,
          hintText: hintText,
          keyboardType: keyboardType,
          isReadOnly: isReadOnly,
          onChanged: onChanged,
          validator: validator,
          textInputAction: textInputAction,
          useErrorBorder: invalidMessage != null,
          onFieldSubmitted: onFieldSubmitted,
          errorText: invalidMessage,
        ),
      ],
    );
  }
}

class _TextFormFieldStateless extends StatefulWidget {
  final TextEditingController fieldController;
  final bool isPassword;
  final String hintText;
  final TextInputType keyboardType;
  final bool isReadOnly;
  final TextInputAction textInputAction;
  final bool useErrorBorder;
  final String? errorText;
  final Function(String)? onChanged;
  final FormFieldValidator<String>? validator;
  final Function(String)? onFieldSubmitted;

  const _TextFormFieldStateless({
    required this.fieldController,
    required this.isPassword,
    required this.hintText,
    required this.keyboardType,
    required this.isReadOnly,
    this.textInputAction = TextInputAction.done,
    this.useErrorBorder = false,
    this.errorText,
    this.onChanged,
    this.validator,
    this.onFieldSubmitted,
  });

  @override
  State<_TextFormFieldStateless> createState() =>
      _TextFormFieldStatelessState();
}

class _TextFormFieldStatelessState extends State<_TextFormFieldStateless> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.fieldController,
      obscureText: widget.isPassword ? !_isPasswordVisible : false,
      keyboardType: widget.keyboardType,
      readOnly: widget.isReadOnly,
      textInputAction: widget.textInputAction,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: darkBlue16Regular.copyWith(
          fontSize: 16,
          color: kMainGrayDark,
        ),
        filled: true,
        fillColor: colorFilledForm,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: widget.useErrorBorder
                ? const Color.fromARGB(255, 207, 37, 25)
                : colorBorderForm,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: colorBorderForm, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kMainGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        errorText: widget.errorText,
        suffixIcon: widget.isPassword
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: colorIconForm,
                  size: 20,
                ),
              )
            : null,
      ),
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: (_) =>
          widget.onFieldSubmitted?.call(widget.fieldController.text),
    );
  }
}
